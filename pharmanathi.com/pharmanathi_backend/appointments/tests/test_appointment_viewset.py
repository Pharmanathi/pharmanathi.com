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


def test_get_patient_unpaid_appointment(authenticated_user_api_client, pending_payment):
    patient = authenticated_user_api_client.user
    payment = PaymentFactory(user=patient, status=Payment.PaymentStatus.PENDING)
    appointment = AppointmentFactory(patient=patient, payment=payment)
    res = authenticated_user_api_client.get(f"/api/appointments/{appointment.id}/")
    assert res.status_code == 200


def test_get_patient_paid_appointment(authenticated_user_api_client):
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
