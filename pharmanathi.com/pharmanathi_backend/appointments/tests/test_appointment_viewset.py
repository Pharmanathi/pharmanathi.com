import datetime
import random
from unittest.mock import patch

import pytest

from pharmanathi_backend.appointments.models import Appointment
from pharmanathi_backend.utils import UTC_time_to_SA_time

pytestmark = pytest.mark.django_db


def test_create_appointment(authenticated_user_api_client, appointment_date_and_doctor, dummy_provider):
    # TODO: Parametrize to use multiple providers once we have any other.
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
