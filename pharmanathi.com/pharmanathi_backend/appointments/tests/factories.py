import factory.fuzzy
from factory import SubFactory
from factory.django import DjangoModelFactory

from pharmanathi_backend.appointments.models import Appointment, AppointmentType, TimeSlot
from pharmanathi_backend.users.tests.factories import DoctorFactory


def get_random_time_str(low_hour=1, high_hour=17, minutes_choices=None):
    if not minutes_choices:
        minutes_choices = [0, 30]
    return (
        f"{factory.fuzzy.FuzzyInteger(low_hour, high_hour).fuzz():>02}:"
        f"{factory.fuzzy.FuzzyChoice(minutes_choices).fuzz():>02}"
    )


class TimeSlotFactory(DjangoModelFactory):
    doctor = SubFactory(DoctorFactory)
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
    doctor = SubFactory(DoctorFactory)
    appointment_type = SubFactory(AppointmentTypeFactory)

    class Meta:
        model = Appointment
