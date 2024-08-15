from unittest.mock import patch

import pytest
from pharmanathi_backend.appointments.tests.factories import (
    AppointmentFactory,
    PaymentFactory,
)

pytestmark = pytest.mark.django_db


def test_on_payment_callback():
    # Move this to BaseProvider
    payment = PaymentFactory(reverse_lookup_field="appointment")
    appointment = AppointmentFactory(payment=payment)
    payment = appointment.payment
    old_status = payment.status

    with patch("pharmanathi_backend.appointments.models.Appointment.on_payment_callback") as pcb:
        appointment.payment.provider.execute_callback(appointment.payment, old_status)
    pcb.assert_called
    pcb.assert_called_with(payment, old_status)
