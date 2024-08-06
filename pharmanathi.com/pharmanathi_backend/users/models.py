import datetime
from urllib.parse import unquote_plus

from django.contrib.auth.models import AbstractUser
from django.core.validators import MaxLengthValidator, MinLengthValidator
from django.db import models
from django.urls import reverse
from django.utils.translation import gettext_lazy as _

from pharmanathi_backend.users.managers import UserManager
from pharmanathi_backend.users.tasks import mail_user_task, set_rejection_reason_task
from pharmanathi_backend.utils.helper_models import BaseCustomModel


class User(BaseCustomModel, AbstractUser):
    """
    Default custom user model for Pharmanathi All-In-One Backend.
    If adding fields that need to be filled at user signup,
    check forms.SignupForm and forms.SocialSignupForms accordingly.
    """

    # First and last name do not cover name patterns around the globe
    name = models.CharField(_("Name of User"), blank=True, max_length=255)
    first_name = models.CharField(_("First name"), blank=True, max_length=255)
    last_name = models.CharField(_("Last name"), blank=True, max_length=255)
    email = models.EmailField(_("email address"), unique=True)
    _profile_pic = models.URLField(null=True, blank=True)
    username = None  # type: ignore

    sa_id_no_13_digits_validator = [
        MaxLengthValidator(limit_value=13, message="Must be exactly 13 digits."),
        MinLengthValidator(limit_value=13, message="Must be exactly 13 digits."),
    ]
    sa_id_no = models.IntegerField("South African ID Number", null=True, validators=sa_id_no_13_digits_validator)
    initials = models.CharField("Initials", max_length=5, null=True)

    TITLE_CHOICES = (
        ("Mr", "Mr"),
        ("Miss", "Miss"),
        ("Mrs", "Mrs"),
        ("Ms", "Ms"),
    )
    title = models.CharField("Title", max_length=5, null=True, choices=TITLE_CHOICES)

    contact_no = models.CharField("Contact Number", max_length=15, null=True)
    university = models.CharField("University", max_length=100, null=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    objects = UserManager()

    def get_absolute_url(self) -> str:
        """Get URL for user's detail view.

        Returns:
            str: URL for user detail.

        """
        return reverse("users:detail", kwargs={"pk": self.id})

    @property
    def is_doctor(self) -> bool:
        return hasattr(self, "doctor_profile")


class Speciality(BaseCustomModel):
    name = models.CharField(max_length=100)
    symbol = models.CharField(max_length=15)

    def __str__(self) -> str:
        return f"{self.name}({self.symbol})"


class Address(BaseCustomModel):
    class ProvinceChoice(models.TextChoices):
        EASTERN_CAPE = "EC", "Eastern Cape"
        FREE_STATE = "FS", "Free State"
        GAUTENG = "GP", "Gauteng"
        KWAZULU_NATAL = "KZN", "KwaZulu-Natal"
        LIMPOPO = "LP", "Limpopo"
        NORTHERN_CAPE = "NC", "Northern Cape"
        NORTH_WEST = "NW", "North-West"
        WESTERN_CAPE = "WC", "Western Cape"

    line_1 = models.CharField(max_length=100, null=False)
    line_2 = models.CharField(max_length=100, null=True, blank=True)
    suburb = models.CharField(max_length=50)
    city = models.CharField(max_length=50)
    province = models.CharField(max_length=3, choices=ProvinceChoice)
    lat = models.DecimalField(decimal_places=13, max_digits=16, null=True)
    long = models.DecimalField(decimal_places=13, max_digits=16, null=True)

    def __str__(self):
        return f"{self.line_1}{ ', ' + self.line_2 if self.line_2 else ''}, {self.city}, {self.province}"


class PracticeLocation(BaseCustomModel):
    name = models.CharField(max_length=50)
    address = models.OneToOneField(Address, on_delete=models.CASCADE)

    def __str__(self) -> str:
        return self.name


class Doctor(BaseCustomModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="doctor_profile")
    specialities = models.ManyToManyField(Speciality)
    practicelocations = models.ManyToManyField(PracticeLocation)
    hpcsa_no = models.CharField("HPCSA No.", max_length=12)  # HPCSA registration number]
    mp_no = models.CharField("Mp No.", max_length=20)
    _is_verified = models.BooleanField(default=False)

    def __str__(self) -> str:
        pseudo = self.user.email
        if self.user.last_name:
            pseudo = f"{self.user.last_name} {self.user.first_name}"
        return f"Dr. {pseudo}"

    @property
    def is_verified(self) -> bool:
        return self._is_verified

    @property
    def is_pharmacist(self):
        # Using the hard-code value PHAR may not be the best thing to
        return self.specialities.filter(symbol="PHAR").exists()

    def get_upcoming_appointments(self, include_pending_payments=False) -> models.query.QuerySet:
        """Say patient `A` et `B` are both booking on timeslot `T`. 
        Assume A is slightly ahead of `B` in the booking process.
        When `A` reaches the payment screen, they take a little long
        to put in their details and at that instant `B` reaches the 
        calendar screen. Should we show `T` as an available slot to 
        `B` or keep it safe for `A`?

        A payment's status can either be `PENDING`,`FAILED` or `PAID`.
        It is:
        - `PENDING` if created and payment attempt was has not been made
        - `PAID` if payment attempt was succesfull
        - `FAILED` if payment attempt failed.

        This PR ensures we reserve the spot for a user whilst they are
        still trying to pay.
        """
        from pharmanathi_backend.payments.models import Payment

        now_today = datetime.datetime.now()
        payment_status_filters = [Payment.PaymentStatus.PAID]
        if include_pending_payments:
            payment_status_filters.append(Payment.PaymentStatus.PENDING)
        return self.appointment_set.filter(start_time__gte=now_today, payment__status__in=payment_status_filters)

    def run_auto_mp_verification_task(self):
        from .tasks import auto_mp_verification_task

        auto_mp_verification_task.delay(self.pk)

    def has_consulted_before(self, patient_id):
        return self.appointment_set.filter(patient__id=patient_id).exists()

    def get_busy_slots_on(self, dt: datetime.date) -> list[tuple]:
        return [
            appointment.timeslot_repr
            for appointment in self.get_upcoming_appointments(include_pending_payments=True).filter(
                start_time__date=dt
            )
        ]

    def get_possible_appointment_slots_on(self, dt: datetime.date, duration: int) -> set[str]:
        """Returns a set of all possible slots on a given date

        Args:
            dt (datetime.date): date choosen for an appointment.
            duration (int): duration choosen for appointment in minutes.

        Returns:
            set[str]: A set of slots. May include slots used
        """
        timeslots = self.timeslot_set.filter(day=dt.isoweekday())
        possible_slots = set()
        for ts in timeslots:
            possible_slots = possible_slots.union(set(ts.break_into_slots_of(duration)))
        return possible_slots

    def get_available_slots_on(self, dt: datetime.date, duration: int) -> set[str]:
        """Returns (slots for a day) - (busy or taken slots)

        Args:
            dt (datetime.date): datetime of the day of the appoinment
            duration (int): duration of the appointment in minutes

        Returns:
            set[str]: A set of slots that are presumed not clashing with any other appointments
        """
        return self.get_possible_appointment_slots_on(dt, duration) - set(self.get_busy_slots_on(dt))

    # TODO; Provide text and HTML versions for the messages below
    def mark_as_vefified(self):
        assert self.pk
        if self.is_verified is True:
            return

        self._is_verified = True
        self.save()
        message = """
            Your MHP Profile has been validated.
            <br><br>
            Should you require any further assitance, please feel free to reach us at <strong>support@pharmanathi.coza</strong>.
            <br><br>
            Kindest regards,
            """
        mail_user_task.delay(self.user.email, "Medical Health Professional Profile Validated", message, message)

    def invalidate_mhp_profile(self, creator, reason):
        assert self.pk
        assert creator, "Provide the InvalidationReason.creator value"
        assert reason, "Cannot invalidate MP profile without providing a reason."

        self._is_verified = False
        self.save()
        temp_invaliadtion = InvalidationReason(text=reason)
        message = f"""
            Your MHP Profile has been invalidate for the following reasons:
            <br><br>
            {temp_invaliadtion.text_email}
            <br>
            Please make the required adjustment to validate your MHP profile.
            <br><br>
            Should you require any further assitance, pleae feel free to reach us at <strong>support@pharmanathi.coza</strong>.
            <br><br>
            Kindest regards,
            """
        mail_user_task.delay(self.user.email, "Medical Health Professional Profile Invalidation", message, message)
        set_rejection_reason_task.delay(self.id, reason, creator.id)

    def update_specialities(self, speciality_list: list[Speciality]):
        """Updates the specialities the MP is assciated with

        Args:
            speciality_list (list): a list of specialities
            :warning: if empty list, the effect is to clear the associations

        Returns:
            None
        """
        self.specialities.clear()
        self.specialities.add(*speciality_list)

    def update_practice_locations(self, location_list: list[Speciality]):
        """Same as self.update_specialities but for locations"""
        self.practicelocations.clear()
        self.practicelocations.add(*location_list)


class InvalidationReason(BaseCustomModel):
    mhp = models.ForeignKey(Doctor, on_delete=models.PROTECT, null=False)
    text = models.TextField(null=False)
    is_resolved = models.BooleanField(default=False)
    created_by = models.ForeignKey(User, on_delete=models.PROTECT, related_name="creator")
    resolved_by = models.ForeignKey(User, on_delete=models.PROTECT, related_name="resolver", null=True)

    def __str__(self):
        return f"({'resolved' if self.is_resolved else 'unresolved'})Invalidation Reason for {self.mhp}: {self.text[:15]}..."

    @property
    def text_unquoted(self):
        return unquote_plus(self.text)

    @property
    def text_email(self):
        return self.text_unquoted.replace("\n", "<br>")

    def mark_resolved(self, resolver: User):
        if resolver.is_staff is False:
            raise Exception("Cannot set a non-staff user as resolver of an invalidation reason.")
        return InvalidationReason.objects.filter(pk=self.pk).update(is_resolved=True, resolved_by=resolver)


class VerificationReport(BaseCustomModel):
    STR_SUM_END_SUCCESS_REPORT_TXT = "was SUCCESSFULL!"
    mp = models.ForeignKey(Doctor, related_name="verification_reports", on_delete=models.PROTECT)
    report: models.JSONField = models.JSONField()

    type_choices = [("SAPC", "SAPC"), ("HPCSA", "HPCSA")]
    type = models.CharField(choices=type_choices, max_length=7, null=False, blank=False, editable=False)

    @staticmethod
    def det_verification_type(mp: Doctor):
        """Determine the verification type to be used for a Medical Professional

        Args:
            mp (Doctor): Doctor(Medical Professional) instance
        """
        return "SAPC" if mp.is_pharmacist else "HPCSA"

    def __str__(self) -> str:
        return f"VR({self.type})|{self.mp.user.email}|{self.date_created.strftime('%d %b %Y')}"

    def _summary_hpcsa(self) -> str:
        """Returns a string summary of a HPCSA report"""
        # Case: Not registration found
        if self.report.get("profile").get("names") == "":
            return "did not find any registration profile. MP does not seem to exist"

        # Case: possible mismatch
        db_names_set = set(self.mp.user.get_full_name().split(" "))
        report_names = set(self.report.get("profile").get("names").split(" "))
        match_percentage = (len(db_names_set.intersection(report_names)) * 100) // len(db_names_set)
        if match_percentage < 50:
            return (
                f"returns a partial match of {match_percentage}%. A match of more than 50% is recommended"
                "when comparing the names found on the HPCSA profile page."
            )

        # Case: exists but no active registration
        has_active_registraion = False
        for reg in self.report.get("registrations"):
            if "REGISTRATION STATUS" in reg:
                if reg.get("REGISTRATION STATUS") == "ACTIVE":
                    has_active_registraion = True
        if has_active_registraion is False:
            return "found one or more registrations but none is active."

        return self.STR_SUM_END_SUCCESS_REPORT_TXT

    def _summary_sapc(self) -> str:
        """Returns a string summary of a SAPC report"""
        # Case: No records found
        returned_no_record = "returned no records" in self.report.get("_logs")
        registrion_is_empty = self.report.get("report") == {}
        if returned_no_record or registrion_is_empty:
            return "failed. No records were found"

        # Case: Inactive
        if self.report.get("registration").get("Status") != "Registered - Active":
            return "seems to report an inactive registration"

        # Case: profile belongs to a different MP
        has_non_matching_surname = (
            self.report.get("registration").get("Surname").lower() not in self.mp.user.last_name.lower()
        )
        has_non_matching_firstname = (
            self.report.get("registration").get("First Name").lower() not in self.mp.user.first_name.lower()
        )
        if has_non_matching_firstname or has_non_matching_surname:
            return "returned a what seems to be a different profile!"

        return self.STR_SUM_END_SUCCESS_REPORT_TXT

    def summary(self) -> str:
        """Returns a string summary of a report"""
        summary_start = f"{self.type.upper()} verification on MP {self.mp} with URL {self.report.get('url')} "

        # Case: Error occured, regardless of type
        if "error" in self.report:
            return self.report.get("error")
        elif self.type == "SAPC":
            summary_end = self._summary_sapc()
        else:
            summary_end = self._summary_hpcsa()
        return f"{summary_start} {summary_end}"
