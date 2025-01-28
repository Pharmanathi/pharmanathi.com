import datetime
import random
from unittest.mock import patch

import pytest

from pharmanathi_backend.appointments.tests.factories import (
    Appointment,
    AppointmentFactory,
    PaymentFactory,
    UserFactory,
)
from pharmanathi_backend.payments.models import Payment
from pharmanathi_backend.utils import UTC_time_to_SA_time

from rest_framework.test import APIClient

from pharmanathi_backend.appointments.tests.factories import AppointmentFactory, AppointmentTypeFactory
from pharmanathi_backend.users.tests.factories import UserFactory, DoctorFactory

pytestmark = pytest.mark.django_db


def test_create_appointment(authenticated_user_api_client, appointment_date_and_doctor, dummy_provider):
    # TODO(nehemie): Parametrize to use multiple providers once we have any other.
    patient = authenticated_user_api_client.user
    appointment_date, appointment_doctor = appointment_date_and_doctor
    response = authenticated_user_api_client.get(
        f"/api/doctors/{appointment_doctor.id}/availability/?d={appointment_date.strftime('%d/%m/%Y')}"
    )
    assert response.status_code == 200
    assert len(response.data) > 0
    timeslot = response.data.pop()
    appointment_date_str = f"{appointment_date.strftime('%Y-%m-%d')}T{timeslot[0]}"
    payload = {
        "doctor": appointment_doctor.id,
        "patient": patient.id,
        "start_time": appointment_date_str,
        "reason": "test create appointment",
        "payment_process": random.choices(Appointment.PAYMENT_PROCESSES_CHOICES)[0][0],
        "payment_provider": dummy_provider.name,
    }
    response = authenticated_user_api_client.post(
        "/api/appointments/",
        payload,
        format="json",
    )
    print(payload, response.json())
    assert response.status_code == 201
    assert Appointment.objects.filter(
        patient=payload["patient"], reason=payload["reason"], doctor=payload["doctor"]
    ).exists()
    assert (
        UTC_time_to_SA_time(datetime.datetime.fromisoformat(response.data["appointment"]["start_time"])).strftime(
            "%Y-%m-%dT%H:%M"
        )
        == payload["start_time"]
    )
    assert "action_data" in response.data


def test_patient_list_appointments(authenticated_user_api_client):
    patient = authenticated_user_api_client.user
    payment_1 = PaymentFactory(user=patient, status=Payment.PaymentStatus.PENDING)
    AppointmentFactory(patient=patient, payment=payment_1)
    payment_2 = PaymentFactory(user=patient, status=Payment.PaymentStatus.PAID)
    AppointmentFactory(patient=patient, payment=payment_2)
    res = authenticated_user_api_client.get("/api/appointments/")
    assert res.status_code == 200
    assert len(res.data) == 2
    assert "end_time" in res.data[0]
    assert "start_time" in res.data[0]
    assert "reason" in res.data[0]
    assert "appointment_type" in res.data[0]
    assert "patient" in res.data[0]
    assert "doctor" in res.data[0]

    appointment_doctor_json = res.data[1].get("doctor")
    assert sorted(appointment_doctor_json.get("user").keys()) == sorted(
        ["first_name", "last_name", "contact_no", "initials", "title", "id", "image_url"]
    )
    appointment_payment_json = res.data[1].get("payment")
    assert sorted(appointment_payment_json.keys()) == sorted(["provider", "user", "status"])


def test_patient_cannot_list_unrelated_appointments(authenticated_user_api_client):
    patient = authenticated_user_api_client.user
    # ensure they have no appointments
    patient.appointment_set.all().delete()

    # Unrelated appointment
    AppointmentFactory(patient=UserFactory())
    res = authenticated_user_api_client.get(f"/api/appointments/")
    assert res.status_code == 200
    assert res.data == []


def test_patient_get_unpaid_appointment(authenticated_user_api_client, pending_payment):
    patient = authenticated_user_api_client.user
    payment = PaymentFactory(user=patient, status=Payment.PaymentStatus.PENDING)
    appointment = AppointmentFactory(patient=patient, payment=payment)
    res = authenticated_user_api_client.get(f"/api/appointments/{appointment.id}/")
    assert res.status_code == 200


def test_patient_get_paid_appointment(authenticated_user_api_client):
    patient = authenticated_user_api_client.user
    payment = PaymentFactory(user=patient, status=Payment.PaymentStatus.PAID)
    appointment = AppointmentFactory(patient=patient, payment=payment)
    res = authenticated_user_api_client.get(f"/api/appointments/{appointment.id}/")
    assert res.status_code == 200


def test_patient_cannot_get_unrelated_appointment(authenticated_user_api_client):
    patient = authenticated_user_api_client.user
    unrelated_appointment = AppointmentFactory(patient=UserFactory())
    res = authenticated_user_api_client.get(f"/api/appointments/{unrelated_appointment.id}/")
    assert res.status_code == 404


def test_mp_cannot_list_unpaidfor_appointments(verified_mhp_client, pending_payment):
    unpaid_appointment = AppointmentFactory(
        patient=pending_payment.user, payment=pending_payment, doctor=verified_mhp_client.user.doctor_profile
    )
    res = verified_mhp_client.get("/api/appointments/")
    res.status_code == 200
    assert unpaid_appointment.id not in map(lambda a: a.id, res.data)

@pytest.mark.django_db
def test_appointments_endpoint_includes_nested_practice_locations():
    """
    Test that the /api/appointments/ endpoint includes the doctor, their practice locations, and addresses.
    """
    # Set up test data
    client = APIClient()

    # Create a user and authenticate
    user = UserFactory()
    client.force_authenticate(user=user)

    # Create a doctor with practice locations and specialities
    doctor = DoctorFactory()
    practice_location = doctor.practicelocations.first()
    appointment_type = AppointmentTypeFactory(doctor=doctor, duration=60)

    # Create an appointment
    AppointmentFactory(
        doctor=doctor,
        patient=user,
        appointment_type=appointment_type,
        start_time="2025-01-28T10:00:00+02:00",
        end_time="2025-01-28T11:00:00+02:00",
        reason="Routine check-up",
    )

    # Call the API endpoint
    response = client.get("/api/appointments/")

    # Verify the response
    assert response.status_code == 200
    assert len(response.data) > 0

    # Verify the first appointment in the response
    appointment_data = response.data[0]

    # Check doctor details
    doctor_data = appointment_data["doctor"]
    assert doctor_data["id"] == doctor.id
    assert doctor_data["user"]["first_name"] == doctor.user.first_name
    assert doctor_data["user"]["last_name"] == doctor.user.last_name

    # Verify specialities
    assert doctor_data["specialities"] == [s.name for s in doctor.specialities.all()]

    # Check practice locations
    practice_locations = doctor_data["practicelocations"]
    assert len(practice_locations) > 0

    # Validate the first practice location
    practice_location_data = practice_locations[0]
    assert practice_location_data["name"] == practice_location.name

    # Validate the address of the practice location
    address = practice_location_data["address"]
    db_address = practice_location.address
    assert address["line_1"] == db_address.line_1
    assert address["city"] == db_address.city
    assert address["province"] == db_address.province

    # Verify appointment type details
    appointment_type_data = doctor_data["appointment_types"][0]
    assert appointment_type_data["id"] == appointment_type.id
    assert appointment_type_data["cost"] == str(appointment_type.cost)

    # Check patient details
    patient_data = appointment_data["patient"]
    assert patient_data["first_name"] == user.first_name
    assert patient_data["last_name"] == user.last_name