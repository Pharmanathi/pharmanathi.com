import pytest

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
