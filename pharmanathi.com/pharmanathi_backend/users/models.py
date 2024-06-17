import datetime

from django.contrib.auth.models import AbstractUser
from django.core.validators import MaxLengthValidator, MinLengthValidator
from django.db import models
from django.urls import reverse
from django.utils.translation import gettext_lazy as _
from pharmanathi_backend.users.managers import UserManager
from pharmanathi_backend.users.tasks import mail_user_task
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
    id = models.SmallIntegerField(primary_key=True)
    name = models.CharField(max_length=100)
    symbol = models.CharField(max_length=7)

    def __str__(self) -> str:
        return f"{self.name}({self.symbol})"


class Address(BaseCustomModel):
    line_1 = models.CharField(max_length=100, null=False)
    line_2 = models.CharField(max_length=100, null=True)
    suburb = models.CharField(max_length=50)
    city = models.CharField(max_length=50)
    province = models.CharField(max_length=50)
    lat = models.DecimalField(decimal_places=10, max_digits=13)
    long = models.DecimalField(decimal_places=10, max_digits=13)


class PracticeLocation(BaseCustomModel):
    name = models.CharField(max_length=50)
    address = models.OneToOneField(Address, on_delete=models.CASCADE)

    def __str__(self) -> str:
        return self.name


class Doctor(BaseCustomModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="doctor_profile")
    specialities = models.ManyToManyField(Speciality)
    practicelocations = models.ManyToManyField(PracticeLocation)
    hpcsa_no = models.CharField("HPCSA No.", max_length=5, null=True)
    mp_no = models.CharField("Mp No.", max_length=5, null=True)
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
    def upcoming_appointments(self) -> models.query.QuerySet:
        now_today = datetime.datetime.now()
        return self.appointment_set.filter(start_time__gte=now_today)

    def get_busy_slots_on(self, dt: datetime.date) -> list[tuple]:
        return [appointment.timeslot_repr for appointment in self.upcoming_appointments.filter(start_time__date=dt)]

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

    def invalidate_mhp_profile(self):
        assert self.pk
        if self.is_verified is False:
            return

        self._is_verified = False
        self.save()
        message = """
            Your MHP Profile has been invalidate for the following reasons:
            <br><br>
            - Reason 1<br>
            - Reason 2<br>
            - Reason 3<br>
            <br>
            Please make the required adjustment to validate your MHP profile.
            <br><br>
            Should you require any further assitance, pleae feel free to reach us at <strong>support@pharmanathi.coza</strong>.
            <br><br>
            Kindest regards,
            """
        mail_user_task.delay(self.user.email, "Medical Health Professional Profile Invalidation", message, message)
