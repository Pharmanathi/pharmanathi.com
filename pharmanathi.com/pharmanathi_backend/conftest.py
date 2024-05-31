import datetime

import pytest
from allauth.socialaccount.models import EmailAddress, SocialAccount, SocialApp
from rest_framework.test import APIClient

from pharmanathi_backend.appointments.tests.factories import (
    AppointmentFactory,
    AppointmentTypeFactory,
    TimeSlotFactory,
    get_random_time_str,
)
from pharmanathi_backend.users.models import User
from pharmanathi_backend.users.tests.factories import DoctorFactory, FutureDateByDOWFactory, UserFactory


@pytest.fixture(autouse=True)
def media_storage(settings, tmpdir):
    settings.MEDIA_ROOT = tmpdir.strpath


@pytest.fixture
def user(db) -> User:
    return UserFactory()


@pytest.fixture
def patient(user):
    return user


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def authenticated_user_api_client(api_client):
    class APIClientWithUser(APIClient):
        user = UserFactory()
        EmailAddress.objects.create(user=user, email=user.email, verified=True)

    api_client = APIClientWithUser()
    api_client.force_authenticate(user=api_client.user)
    return api_client


@pytest.fixture
def simple_doctor(db):
    return DoctorFactory()


@pytest.fixture
def simple_timeslot():
    return TimeSlotFactory()


@pytest.fixture
def timeslot_9_to_10_am(db):
    return TimeSlotFactory(start_time=datetime.time(9, 00), end_time=datetime.time(10, 00))


@pytest.fixture
def doctor_with_appointment_random(simple_doctor, patient):
    # Ensure appointment type's duration is smaller than TimeSlot's duration
    # otherwise getting available slots from this doctor won't be possible
    # if the duration requested is bigger than available duration in a TimeSlot.
    # For that reason, we live a 2 hours gap between start and end of TimeSlot
    timeslot_start_time = get_random_time_str(high_hour=15)
    timeslot_end_time = get_random_time_str(low_hour=17)
    timeslot_config = TimeSlotFactory(start_time=timeslot_start_time, end_time=timeslot_end_time, doctor=simple_doctor)
    appointment_type = AppointmentTypeFactory(doctor=simple_doctor)
    hour, minute = (int(v) for v in get_random_time_str(low_hour=9, high_hour=18).split(":"))
    appointment_start_dt = FutureDateByDOWFactory(timeslot_config.day, with_time=datetime.time(hour, minute))
    appointment = AppointmentFactory(
        doctor=simple_doctor, start_time=appointment_start_dt, appointment_type=appointment_type, patient=patient
    )
    return appointment.doctor


@pytest.fixture
def build_future_date():
    return FutureDateByDOWFactory


@pytest.fixture
def oauth_social_apps(db):
    from pharmanathi_backend.users.scripts.sync_social_apps import run

    run()
    return SocialApp.objects.all()


@pytest.fixture
def appointment_date_and_doctor(doctor_with_appointment_random) -> list:
    doctor = doctor_with_appointment_random
    return [FutureDateByDOWFactory(doctor.timeslot_set.first().day), doctor]


@pytest.fixture
def social_patient(db, patient):
    user = patient
    social_account, _ = SocialAccount.objects.get_or_create(user=user, provider="google")
    return social_account


@pytest.fixture
def social_simple_doctor(db, simple_doctor):
    social_account, _ = SocialAccount.objects.get_or_create(user=simple_doctor.user)
    return social_account
