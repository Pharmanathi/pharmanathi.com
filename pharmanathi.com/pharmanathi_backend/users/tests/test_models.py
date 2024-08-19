from datetime import datetime, time, timedelta

import pytest
from freezegun import freeze_time

from pharmanathi_backend.appointments.tests.factories import AppointmentTypeFactory, TimeSlotFactory
from pharmanathi_backend.users.models import User
from pharmanathi_backend.users.tests.factories import PracticeLocationFactory, SpecialityFactory

pytestmark = pytest.mark.django_db


def test_user_get_absolute_url(user: User):
    assert user.get_absolute_url() == f"/users/{user.pk}/"


def test_is_doctor_False_if_no_doctor_profile(user):
    assert user.is_doctor is False


def test_is_doctor_on_simple_doctor(simple_doctor):
    assert simple_doctor.user.is_doctor is True


def test_is_doctor_on_social_doctor(social_simple_doctor):
    assert social_simple_doctor.user.is_doctor is True


def test_has_consulted_before_is_True_if_consulted(doctor_with_appointment_random):
    appointment_patient = doctor_with_appointment_random.appointment_set.first().patient
    assert doctor_with_appointment_random.has_consulted_before(appointment_patient.id) is True


def test_has_consulted_before_is_False_if_never_consulted(simple_doctor, patient):
    simple_doctor.appointment_set.all().delete()
    assert simple_doctor.has_consulted_before(patient.id) is False


def test_update_specialities(doctor_with_speciality):
    specialities = [
        SpecialityFactory(),
        SpecialityFactory(),
        SpecialityFactory(),
    ]
    assert doctor_with_speciality.specialities.count() == 1
    doctor_with_speciality.update_specialities(specialities)
    assert list(doctor_with_speciality.specialities.all()) == specialities


def test_practice_locations(doctor_with_practice_location):
    practice_locations = [
        PracticeLocationFactory(),
        PracticeLocationFactory(),
    ]
    assert doctor_with_practice_location.practicelocations.count() == 1
    doctor_with_practice_location.update_practice_locations(practice_locations)
    assert list(doctor_with_practice_location.practicelocations.all()) == practice_locations


def test_get_available_slots_on_with_past_date(build_future_date):
    timeslot = TimeSlotFactory(start_time=time(9, 00), end_time=time(10, 00))
    mp = timeslot.doctor
    appointment_type = AppointmentTypeFactory(doctor=mp, duration=30)
    day_of_the_week = timeslot.day
    tobe_past_date: datetime = build_future_date(day_of_the_week, time(9, 0))
    with freeze_time(tobe_past_date + timedelta(days=3)):
        # in the future, pointing to tobe_past_date as appointment day should not
        # return any available slots since this day has passed.
        assert mp.get_available_slots_on(tobe_past_date, appointment_type.duration) == set()

    # past date is today but pass any available timelots. Should still return empty set
    one_second_later = tobe_past_date.replace(hour=10, minute=0, second=0) + timedelta(minutes=1)
    with freeze_time(one_second_later + timedelta(minutes=1)):
        assert mp.get_available_slots_on(one_second_later, appointment_type.duration) == set()
