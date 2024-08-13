import datetime

import factory.fuzzy
from factory import SubFactory, lazy_attribute
from factory.django import DjangoModelFactory

from pharmanathi_backend.appointments.models import Appointment, AppointmentType, TimeSlot
from pharmanathi_backend.payments.tests.factories import PaymentFactory
from pharmanathi_backend.users.tests.factories import DoctorFactory, FutureDateByDOWFactory, UserFactory


def get_random_time_str(low_hour=1, high_hour=17, minutes_choices=None):
    if not minutes_choices:
        minutes_choices = [0, 30]
    return (
        f"{factory.fuzzy.FuzzyInteger(low_hour, high_hour).fuzz():>02}:"
        f"{factory.fuzzy.FuzzyChoice(minutes_choices).fuzz():>02}"
    )


def get_random_appointment_start_datetime(verified_doctor):
    timeslot_start_time = get_random_time_str(high_hour=15)
    timeslot_end_time = get_random_time_str(low_hour=17)
    timeslot_config = TimeSlotFactory(
        start_time=timeslot_start_time, end_time=timeslot_end_time, doctor=verified_doctor
    )
    appointment_type = AppointmentTypeFactory(doctor=verified_doctor)
    hour, minute = (int(v) for v in get_random_time_str(low_hour=9, high_hour=18).split(":"))
    appointment_start_dt = FutureDateByDOWFactory(timeslot_config.day, with_time=datetime.time(hour, minute))
    return appointment_start_dt


class TimeSlotFactory(DjangoModelFactory):
    doctor = SubFactory(DoctorFactory, _is_verified=True)
    day = factory.fuzzy.FuzzyChoice(range(1, 8))

    @factory.lazy_attribute
    def start_time(self):
        return get_random_time_str(low_hour=8)

    @factory.lazy_attribute
    def end_time(self):
        hour_minimum = int(self.start_time.split(":")[0]) + 1
        return get_random_time_str(low_hour=hour_minimum, high_hour=20)

    class Meta:
        model = TimeSlot


class AppointmentTypeFactory(DjangoModelFactory):
    doctor = SubFactory(DoctorFactory)
    duration = factory.fuzzy.FuzzyChoice([30, 60, 45, 90, 120])
    is_online = factory.fuzzy.FuzzyChoice([True, False])
    cost = factory.fuzzy.FuzzyInteger(100)
    no_show_cost = factory.fuzzy.FuzzyInteger(0)

    class Meta:
        model = AppointmentType


class AppointmentFactory(DjangoModelFactory):
    doctor = SubFactory(DoctorFactory, _is_verified=True)
    appointment_type = SubFactory(AppointmentTypeFactory)
    payment = SubFactory(PaymentFactory)
    patient = SubFactory(UserFactory)

    @lazy_attribute
    def appointment_type(self):
        return AppointmentTypeFactory(doctor=self.doctor)

    @lazy_attribute
    def start_time(self):
        timeslot_start_time = get_random_time_str(high_hour=15)
        timeslot_end_time = get_random_time_str(low_hour=17)
        timeslot_config = TimeSlotFactory(
            start_time=timeslot_start_time, end_time=timeslot_end_time, doctor=self.doctor
        )
        hour, minute = (int(v) for v in get_random_time_str(low_hour=9, high_hour=18).split(":"))
        appointment_start_dt = FutureDateByDOWFactory(timeslot_config.day, with_time=datetime.time(hour, minute))
        return appointment_start_dt

    class Meta:
        model = Appointment
