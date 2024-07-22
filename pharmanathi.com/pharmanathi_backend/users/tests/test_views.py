import datetime
import random
from unittest.mock import patch

import pytest
from django.conf import settings
from django.contrib import messages
from django.contrib.auth.models import AnonymousUser
from django.contrib.messages.middleware import MessageMiddleware
from django.contrib.sessions.middleware import SessionMiddleware
from django.http import HttpRequest, HttpResponseRedirect
from django.test import RequestFactory
from django.urls import reverse
from django.utils.translation import gettext_lazy as _

from pharmanathi_backend.appointments.tests.factories import AppointmentTypeFactory, TimeSlotFactory
from pharmanathi_backend.users.forms import UserAdminChangeForm
from pharmanathi_backend.users.models import User
from pharmanathi_backend.users.permissions import IsVerifiedDoctor
from pharmanathi_backend.users.tests.factories import DoctorFactory, FutureDateByDOWFactory, UserFactory
from pharmanathi_backend.users.views import UserRedirectView, UserUpdateView, user_detail_view

pytestmark = pytest.mark.django_db

URI_TOKEN_RETRIEVAL = "/api/google-login-by-id-token/"


def add_query_param_to_uri(uri, param_name, param_value):
    if "?" not in uri:
        uri += "?"
    p_string = uri[uri.index("?") + 1 :]
    p_array = list(filter(lambda i: i != "", p_string.split("&")))
    p_array.append(f"{param_name}={param_value}")
    return uri.replace(p_string, "") + "&".join(p_array)


class TestUserUpdateView:
    """
    TODO:
        extracting view initialization code as class-scoped fixture
        would be great if only pytest-django supported non-function-scoped
        fixture db access -- this is a work-in-progress for now:
        https://github.com/pytest-dev/pytest-django/pull/258
    """

    def dummy_get_response(self, request: HttpRequest):
        return None

    def test_get_success_url(self, user: User, rf: RequestFactory):
        view = UserUpdateView()
        request = rf.get("/fake-url/")
        request.user = user

        view.request = request
        assert view.get_success_url() == f"/users/{user.pk}/"

    def test_get_object(self, user: User, rf: RequestFactory):
        view = UserUpdateView()
        request = rf.get("/fake-url/")
        request.user = user

        view.request = request

        assert view.get_object() == user

    def test_form_valid(self, user: User, rf: RequestFactory):
        view = UserUpdateView()
        request = rf.get("/fake-url/")

        # Add the session/message middleware to the request
        SessionMiddleware(self.dummy_get_response).process_request(request)
        MessageMiddleware(self.dummy_get_response).process_request(request)
        request.user = user

        view.request = request

        # Initialize the form
        form = UserAdminChangeForm()
        form.cleaned_data = {}
        form.instance = user
        view.form_valid(form)

        messages_sent = [m.message for m in messages.get_messages(request)]
        assert messages_sent == [_("Information successfully updated")]


class TestUserRedirectView:
    def test_get_redirect_url(self, user: User, rf: RequestFactory):
        view = UserRedirectView()
        request = rf.get("/fake-url")
        request.user = user

        view.request = request
        assert view.get_redirect_url() == f"/users/{user.pk}/"


class TestUserDetailView:
    def test_authenticated(self, user: User, rf: RequestFactory):
        request = rf.get("/fake-url/")
        request.user = UserFactory()
        response = user_detail_view(request, pk=user.pk)

        assert response.status_code == 200

    def test_not_authenticated(self, user: User, rf: RequestFactory):
        request = rf.get("/fake-url/")
        request.user = AnonymousUser()
        response = user_detail_view(request, pk=user.pk)
        login_url = reverse(settings.LOGIN_URL)

        assert isinstance(response, HttpResponseRedirect)
        assert response.status_code == 302
        assert response.url == f"{login_url}?next=/fake-url/"


@pytest.mark.parametrize(
    "duration, expected_slots",
    [
        ["30", [("09:00", "09:30"), ("09:30", "10:00"), ("10:00", "10:30"), ("10:30", "11:00")]],
        ["60", [("09:00", "10:00"), ("10:00", "11:00")]],
        ["90", [("09:00", "10:30")]],
    ],
)
def test_availability(duration, expected_slots, authenticated_user_api_client):
    timeslot = TimeSlotFactory(start_time="09:00", end_time="11:00")
    appointment_selected_dt = FutureDateByDOWFactory(timeslot.day)
    AppointmentTypeFactory(doctor=timeslot.doctor, duration=duration)

    response = authenticated_user_api_client.get(
        f"/api/doctors/{timeslot.doctor.id}/availability/?d={appointment_selected_dt.strftime('%d/%m/%Y')}"
    )

    assert response.status_code == 200
    assert len(response.data) > 0
    assert set(expected_slots) == response.data


def test_availability_is_empty_on_different_day_than_timeslot_day(authenticated_user_api_client):
    timeslot = TimeSlotFactory()
    AppointmentTypeFactory(doctor=timeslot.doctor)
    selected_app_day = FutureDateByDOWFactory(timeslot.day) + datetime.timedelta(days=random.randint(1, 6))
    response = authenticated_user_api_client.get(
        f"/api/doctors/{timeslot.doctor.id}/availability/?d={selected_app_day.strftime('%d/%m/%Y')}"
    )
    assert response.status_code == 200
    assert response.data == set()  # empty set, empty results


def test_token_retrieval_fail_if_no_idtoken_query_param(api_client):
    response = api_client.get(URI_TOKEN_RETRIEVAL)
    assert response.status_code == 400
    assert response.data == {"detail": "Missing id_token query string parameter"}


def test_token_retrieval_fail_if_no_auth_app_header(api_client):
    URI = add_query_param_to_uri(URI_TOKEN_RETRIEVAL, "id_token", "some-oicd-token")
    response = api_client.get(URI)
    assert response.status_code == 400
    assert response.data == {"detail": "Missing social app header in token retrieval request."}


@pytest.mark.parametrize("auth_app_name", ["google_patient_android", "google_patient_ios"])
def test_token_retrieval_fail_if_patient_auth_app_but_is_doctor_is_set(auth_app_name, api_client, oauth_social_apps):
    URI = add_query_param_to_uri(URI_TOKEN_RETRIEVAL, "id_token", "some-oicd-token")
    URI = add_query_param_to_uri(URI, "is_doctor", "true")
    headers = {"auth-app": auth_app_name}
    response = api_client.get(URI, headers=headers)
    assert response.status_code == 400
    assert response.data == {"detail": "Mismatch in query parameter and headers"}


@pytest.mark.parametrize(
    "auth_app_name,is_doctor",
    [
        ["google_mhp_android", "true"],
        ["google_mhp_ios", None],
    ],
)
def test_patient_token_retrieval_from_doctor_app_should_fail(
    auth_app_name, is_doctor, api_client, oauth_social_apps, social_patient
):
    user = social_patient.user
    URI = add_query_param_to_uri(URI_TOKEN_RETRIEVAL, "id_token", "some-oicd-token")
    if is_doctor:
        URI = add_query_param_to_uri(URI, "is_doctor", is_doctor)

    headers = {"auth-app": auth_app_name}

    with patch("google.oauth2.id_token.verify_oauth2_token") as patched_verify:
        patched_verify.return_value = {
            "iss": "https://accounts.google.com",
            "azp": "710242232170-jetc349ucliase4l5t8v2lgebd6sphbu.apps.googleusercontent.com",
            "aud": "710242232170-jetc349ucliase4l5t8v2lgebd6sphbu.apps.googleusercontent.com",
            "sub": "102321401536920088163",
            "hd": user.email[user.email.index("@") + 1],
            "email": user.email,
            "email_verified": True,
            "at_hash": "OVa4AqaLyKtT7KTyVuu7yg",
            "nonce": "TF1w-FjKLznD2DLmH5QOsInOMSvqXO9khZtwlTQrrGo",
            "name": "Test Example",
            "picture": "some-uri",
            "given_name": "Test",
            "family_name": "Example",
            "iat": 1716877569,
            "exp": 1716881169,
        }
        response = api_client.get(URI, headers=headers)

    assert response.status_code == 403
    assert response.data["detail"] == "Invalid app for current profile"


@pytest.mark.parametrize("auth_app_name", ["google_mhp_android", "google_mhp_ios"])
def test_social_doctor_can_retrive_token(auth_app_name, oauth_social_apps, api_client):
    URI = add_query_param_to_uri(URI_TOKEN_RETRIEVAL, "id_token", "some-oicd-token")
    URI = add_query_param_to_uri(URI, "is_doctor", "true")
    headers = {"auth-app": auth_app_name}

    with patch("google.oauth2.id_token.verify_oauth2_token") as patched_verify:
        patched_verify.return_value = {
            "iss": "https://accounts.google.com",
            "azp": "710242232170-jetc349ucliase4l5t8v2lgebd6sphbu.apps.googleusercontent.com",
            "aud": "710242232170-jetc349ucliase4l5t8v2lgebd6sphbu.apps.googleusercontent.com",
            "sub": "102321401536920088163",
            "hd": "example.com",
            "email": "test@example.com",
            "email_verified": True,
            "at_hash": "OVa4AqaLyKtT7KTyVuu7yg",
            "nonce": "TF1w-FjKLznD2DLmH5QOsInOMSvqXO9khZtwlTQrrGo",
            "name": "Test Example",
            "picture": "some-uri",
            "given_name": "Test",
            "family_name": "Example",
            "iat": 1716877569,
            "exp": 1716881169,
        }
        response = api_client.get(URI, headers=headers)
        assert response.status_code == 200
        assert "key" in response.data


# @TODO test_social_doctor_can_retrive_token with existing user


def test_get_appointments_fails_if_mhp_unverified(unverified_mhp_client):
    response = unverified_mhp_client.get("/api/appointments/")
    assert response.status_code == 403
    assert response.data["detail"] == IsVerifiedDoctor.message


def test_get_appointments_passes_for_verified_mhp(verified_mhp_client, doctor_with_appointment_random):
    mhp = doctor_with_appointment_random
    appointment = mhp.appointment_set.first()
    client = verified_mhp_client
    client.force_authenticate(user=mhp.user)
    response = client.get("/api/appointments/")
    assert response.status_code == 200
    assert appointment.id in map(lambda a: a["id"], response.data)


def test_patients_cant_list_unverified_mhp(authenticated_user_api_client):
    unverified_mhp = DoctorFactory(_is_verified=False)
    response = authenticated_user_api_client.get("/api/doctors/")
    assert response.status_code == 200
    assert unverified_mhp.id not in map(lambda d: d["id"], response.data)


def test_patients_can_list_verified_mhp(authenticated_user_api_client):
    verified_mhp = DoctorFactory(_is_verified=True)
    response = authenticated_user_api_client.get("/api/doctors/")
    assert response.status_code == 200
    assert verified_mhp.id in map(lambda d: d["id"], response.data)


def test_patients_cant_see_unverified_mhp_appoinments(authenticated_user_api_client, doctor_with_appointment_random):
    mhp = doctor_with_appointment_random
    mhp._is_verified = False
    mhp.save()
    appointment = mhp.appointment_set.first()
    patient = appointment.patient
    client = authenticated_user_api_client
    client.force_authenticate(user=patient)
    response = client.get("/api/appointments/")
    assert response.status_code == 200
    assert appointment.id not in map(lambda a: a["id"], response.data)


def test_patients_can_see_verified_mhp_appoinments(authenticated_user_api_client, doctor_with_appointment_random):
    appointment = doctor_with_appointment_random.appointment_set.first()
    patient = appointment.patient
    client = authenticated_user_api_client
    client.force_authenticate(user=patient)
    response = client.get("/api/appointments/")
    assert response.status_code == 200
    assert appointment.id in map(lambda a: a["id"], response.data)


def test_has_consulted_before_is_False_if_never_consulted(authenticated_user_api_client, verified_doctor):
    verified_doctor.appointment_set.all().delete()
    res = authenticated_user_api_client.get("/api/doctors/")
    doctor_payload = list(filter(lambda d: d.get("id") == verified_doctor.id, res.data))[0]
    print(doctor_payload)
    assert doctor_payload.get("has_consulted_before") is False


def test_has_consulted_before_is_True_if_consulted_before(api_client, doctor_with_appointment_random):
    patient = doctor_with_appointment_random.appointment_set.first().patient
    api_client.force_authenticate(user=patient)
    res = api_client.get("/api/doctors/")
    doctor_payload = list(filter(lambda d: d.get("id") == doctor_with_appointment_random.id, res.data))[0]
    print(doctor_payload)
    assert doctor_payload.get("has_consulted_before") is True


def test_mp_can_builk_update_doctor_profile(mhp_client, speciality):
    # The bulk update includes updating the following models at once:
    # - Doctor
    # - PracticeLocation
    # - Specialities
    # This is usually triggered by the Mobile client
    doctor = mhp_client.user.doctor_profile
    payload = {
        "hpcsa_no": "some value",
        "specialities": [speciality.id],
        "practice_locations": [
            {
                "name": "Netcare Unitas Hospital",
                "address": {
                    "line_1": " 866 Clifton Ave",
                    "suburb": "Die Hoewes",
                    "city": "Centurion",
                    "postal_code": "0163",
                    "province": "GP",
                },
            }
        ],
    }
    response = mhp_client.patch(f"/api/doctors/{doctor.id}/", payload, format="json")
    assert response.status_code == 200
    doctor.refresh_from_db()
    assert doctor.hpcsa_no == payload.get("hpcsa_no")
    assert doctor.practicelocations.filter(name=payload.get("practice_locations")[0].get("name"))
    assert speciality in doctor.specialities.all()
