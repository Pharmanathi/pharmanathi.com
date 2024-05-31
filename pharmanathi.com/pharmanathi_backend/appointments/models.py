from datetime import date, datetime, timedelta

from django.contrib.auth import get_user_model
from django.db import models

from pharmanathi_backend.users.models import Doctor
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

    # @TODO: verification that patient is not self.
    @property
    def end_time(self) -> datetime.time:
        return self.start_time + timedelta(minutes=self.appointment_type.duration)

    @property
    def timeslot_repr(self) -> tuple:
        return (
            UTC_time_to_SA_time(self.start_time).strftime("%H:%M"),
            UTC_time_to_SA_time(self.end_time).strftime("%H:%M"),
        )


class Rating(BaseCustomModel):
    RATING_CHOICES = ((1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5"))
    appointment = models.ForeignKey(Appointment, on_delete=models.PROTECT)
    datetime = models.DateTimeField(auto_now_add=True)
    value = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name="receiver")
    giver = models.ForeignKey(User, on_delete=models.CASCADE, related_name="giver")
