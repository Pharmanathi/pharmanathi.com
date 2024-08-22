from datetime import datetime, time, timedelta
from unittest.mock import patch

import pytest
from freezegun import freeze_time

from pharmanathi_backend.appointments.tests.factories import AppointmentTypeFactory, TimeSlotFactory
from pharmanathi_backend.users.models import Doctor, User, VerificationReport
from pharmanathi_backend.users.tests.factories import (
    DoctorFactory,
    InvalidationReasonFactory,
    PracticeLocationFactory,
    SpecialityFactory,
    VerificationReportFactory,
)
from pharmanathi_backend.utils import to_aware_dt

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

    # However, should include any non-passed timeslot even on future dates
    forty_minuts_before_end_of_slot = to_aware_dt(build_future_date(day_of_the_week, time(9, 20)))
    with freeze_time(forty_minuts_before_end_of_slot):
        assert mp.get_available_slots_on(datetime.now(), appointment_type.duration) == {("09:30", "10:00")}


# profile has changed on new profile account should return false
def test_new_dr_profile_has_changed_since_last_vr_return_false():
    doctor = DoctorFactory()
    assert doctor.has_changed_since_last_verification() is False


def test_has_changed_since_last_vr_is_true_if_hpcsa_no_changed():
    from pharmanathi_backend.users.models import VerificationReport as VR

    vr = VerificationReportFactory()
    vr.mp.hpcsa_no = "something-else"
    with patch("pharmanathi_backend.users.models.auto_mp_verification_task.delay") as patched_vrf_task:
        vr.mp.save()
    patched_vrf_task.assert_called
    patched_vrf_task.assert_called_with(vr.mp.pk)

    # mp_no
    vr.mp.mp_no = "something-else"
    with patch("pharmanathi_backend.users.models.auto_mp_verification_task.delay") as patched_vrf_task:
        vr.mp.save()
    patched_vrf_task.assert_called
    patched_vrf_task.assert_called_with(vr.mp.pk)


def test_run_auto_mp_verification_task_on_update():
    doctor = DoctorFactory(_is_verified=False)
    with patch("pharmanathi_backend.users.models.Doctor.run_auto_mp_verification_task") as p:
        Doctor.objects.filter(pk=doctor.pk).first().mark_as_vefified()
        assert p.assert_called

    with patch("pharmanathi_backend.users.models.Doctor.run_auto_mp_verification_task") as p:
        doctor._is_verified = False
        doctor.update()
    assert p.assert_called


def test_mark_resolved_raises_exception_if_non_staff(authenticated_user_api_client):
    # ensure they are no staff
    user = authenticated_user_api_client.user
    if user.is_staff:
        user.is_staff = False
        user.save()
        user.refresh_from_db()

    iv = InvalidationReasonFactory()

    with pytest.raises(Exception):
        iv.mark_resolved(user)


@pytest.mark.parametrize("speciality_symbol, type", [("SOMESYMBOL", "HPCSA"), ("PHAR", "SAPC")])
def test_det_verification_type(speciality_symbol, type):
    doctor = DoctorFactory()
    doctor.specialities.add(SpecialityFactory(symbol=speciality_symbol))
    assert VerificationReport.det_verification_type(doctor) == type
