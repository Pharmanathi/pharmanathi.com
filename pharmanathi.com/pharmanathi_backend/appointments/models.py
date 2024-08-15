from datetime import date, datetime, timedelta

from django.contrib.auth import get_user_model
from django.db import models, transaction
from rest_framework.exceptions import ValidationError

from pharmanathi_backend.payments.models import Payment
from pharmanathi_backend.payments.providers.provider import get_provider
from pharmanathi_backend.users.models import Doctor
from pharmanathi_backend.users.tasks import mail_admins_task, mail_user_task
from pharmanathi_backend.utils import UTC_time_to_SA_time
from pharmanathi_backend.utils.helper_models import BaseCustomModel

User = get_user_model()


class TimeSlot(BaseCustomModel):
    WEEK_DAY_CHOICES = [(1, "MON"), (2, "TUE"), (3, "WED"), (4, "THU"), (5, "FRI"), (6, "SAT"), (7, "SUN")]
    doctor = models.ForeignKey(Doctor, on_delete=models.PROTECT)
    day = models.SmallIntegerField(choices=WEEK_DAY_CHOICES)
    start_time = models.TimeField(null=False)
    end_time = models.TimeField(null=False)

    @classmethod
    def filter_weekday_choices_by_int(cls, day_int) -> str:
        return list(filter(lambda x: x[0] == day_int, cls.WEEK_DAY_CHOICES))[0][1]

    def __str__(self):
        return (
            f"TimeSlot: {self.filter_weekday_choices_by_int(self.day)}(Day {self.day})"
            f"{self.start_time}-{self.end_time}"
        )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["doctor", "day", "start_time", "end_time"], name="unique_timeslot_configuration"
            ),
            models.UniqueConstraint(fields=["doctor", "day", "start_time"], name="same_start_time_timeslot"),
            models.UniqueConstraint(fields=["doctor", "day", "end_time"], name="same_ebd_time_timeslot"),
        ]

    def break_into_slots_of(self, minutes: int) -> list[tuple]:
        """Breaks timeslot into a lists of string-based time interval sets

        Args:
            minutes (int): minutes interval to use

        Returns:
            list: chunks of intervals
        """
        some_date = date.today()  # this is just needed to build a valid datetime object.
        start_time = datetime.combine(some_date, self.start_time)
        end_time = datetime.combine(some_date, self.end_time)
        current_time = start_time
        slots = []

        while current_time < end_time:
            end_slot = current_time + timedelta(minutes=minutes)
            # test that we still in the specified time period of the TimeSlot
            if end_slot.time() > self.end_time:
                break
            slots.append((current_time.strftime("%H:%M"), end_slot.strftime("%H:%M")))
            current_time += timedelta(minutes=minutes)

        return slots


class AppointmentType(BaseCustomModel):
    doctor = models.ForeignKey(Doctor, on_delete=models.PROTECT)
    duration = models.SmallIntegerField(null=False)  # duration in minutes
    is_online = models.BooleanField(null=False)
    cost = models.DecimalField(decimal_places=2, max_digits=7)
    no_show_cost = models.DecimalField(
        decimal_places=2,
        max_digits=7,
        null=True,
        default=0,
    )
    is_run_forever = models.BooleanField(default=True)
    start_date = models.DateField(null=True)
    end_date = models.DateField(null=True)

    def __str__(self):
        return f"Appointment Type ({self.pk}): {self.duration}min "


class Appointment(BaseCustomModel):
    PAYMENT_PROCESSES_CHOICES = (("BV", "Before Visit"), ("AV", "After Visit"))
    doctor = models.ForeignKey(Doctor, on_delete=models.PROTECT)
    patient = models.ForeignKey(User, on_delete=models.PROTECT)
    datetime_booked = models.DateTimeField(auto_now_add=True)
    start_time = models.DateTimeField(null=False)
    appointment_type = models.ForeignKey(AppointmentType, on_delete=models.PROTECT)
    reason = models.CharField(max_length=500)
    payment_process = models.CharField(max_length=2, choices=PAYMENT_PROCESSES_CHOICES)
    payment = models.OneToOneField(Payment, on_delete=models.PROTECT)  # TODO(nehemie): check this

    # @TODO: verification that patient is not self. Meaning, patient should not be
    # able to book an appointment with themselves.

    def __str__(self):
        return f"<Appointment({self.pk}): {self.patient.email}>"

    @property
    def end_time(self) -> datetime.time:
        return self.start_time + timedelta(minutes=self.appointment_type.duration)

    @property
    def timeslot_repr(self) -> tuple:
        return (
            UTC_time_to_SA_time(self.start_time).strftime("%H:%M"),
            UTC_time_to_SA_time(self.end_time).strftime("%H:%M"),
        )

    @classmethod
    def create_from_http_client(cls, view, request) -> tuple:
        """This method does quite a few things:

        1- Creates and start the process for payment
        2- If successfull, creates an appointment and attaches
        the payment to it.
        3- Returns a tuple of the form (appointment, paymemt, action_data)

        Args:
            view (_type_): The view that called this method
            request (_type_): the view's request object

        Raises:
            ValueError: if selected user data is invalid

        Returns:
            tuple: (appointment, paymemt, action_data)
        """
        with transaction.atomic():
            # get appointment type
            appointment_type = AppointmentType.objects.get(doctor__id=request.data.get("doctor"))

            # create payment
            payment_provider = get_provider(request.data.get("payment_provider"))
            payment, payment_extras = payment_provider.initialize_payment(
                "appointment",
                appointment_type.cost.to_eng_string(),
                request.user.email,
            )

            # create appoinment
            prepared_appointment_data = {
                **request.data,
                "appointment_type": appointment_type.id,
                "patient": request.user.id,
                "payment": payment.pk,
            }
            sz_appointment = view.get_serializer(data=prepared_appointment_data)
            sz_appointment.is_valid(raise_exception=True)

            # Ensure selected timeslot is valid
            selected_timeslot_datetime = sz_appointment.validated_data["start_time"]
            selected_timeslot = (
                selected_timeslot_datetime.strftime("%H:%M"),
                (
                    selected_timeslot_datetime
                    + timedelta(minutes=sz_appointment.validated_data["appointment_type"].duration)
                ).strftime("%H:%M"),
            )
            available_slots = appointment_type.doctor.get_available_slots_on(
                selected_timeslot_datetime.date(), appointment_type.duration
            )

            if selected_timeslot not in available_slots:
                raise ValidationError("Selected timeslot is unavailable")

            sz_appointment.save()

        return (payment.appointment, payment, payment_extras)

    def on_payment_callback(self, payment, old_status):
        from pharmanathi_backend.payments.models import Payment

        if old_status in (Payment.PaymentStatus.PENDING, Payment.PaymentStatus.FAILED) and payment.status == "PAID":
            admin_message = f"New payment with reference {self.payment.reference.upper()} by user {self.payment.user}"
            mail_admins_task.delay("New Successful Payment", admin_message, admin_message)

            message = f"""
                Here are the details of your Appointment
                Date & Time: {self.start_time.strftime("%B %d, %Y")}

                Payment Details
                Reference: {self.payment.reference.upper()}
                Amount: {self.payment.amount}
                Date & Time: {self.payment.date_modified.strftime("%B %d, %Y")}

                Pharmanathi.com
                support@pharmanthi.com
            """
            mail_user_task.delay(self.doctor.user.email, "New Appointment Confirmed", message, message)
            mail_user_task.delay(self.patient.email, "Appointment Confirmed", message, message)
        else:
            subject = f"Payment {payment.status}"
            message = f"Payment with reference {payment.status} with reason: {payment.get_message()}"
            mail_user_task.delay(self.patient.email, subject, message, message)


class Rating(BaseCustomModel):
    RATING_CHOICES = ((1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5"))
    appointment = models.ForeignKey(Appointment, on_delete=models.PROTECT)
    datetime = models.DateTimeField(auto_now_add=True)
    value = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name="receiver")
    giver = models.ForeignKey(User, on_delete=models.CASCADE, related_name="giver")
