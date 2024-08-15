import random
from decimal import Decimal
from unittest.mock import patch

import pytest

from pharmanathi_backend.appointments.models import Appointment
from pharmanathi_backend.payments.models import Payment
from pharmanathi_backend.payments.tests.factories import PaymentFactory, UserFactory


def test_parse_initalization_request_data_raises_if_no_email_and_amount(paystack_provider):
    with pytest.raises(AssertionError) as e:
        paystack_provider.parse_initalization_request_data(some_value="some_data")


@pytest.mark.parametrize(
    "amount",
    (
        960,
        960.80,
        "900",
        "45.50",
        "55.00",
        22.8,
    ),
)
def test_parse_initalization_request_data_passes(amount, paystack_provider):
    test_data = {"email": "some-email", "amount": amount, "some-other-key": "its value"}

    assert paystack_provider.parse_initalization_request_data(**test_data) == ("some-email", Decimal(amount))


@pytest.mark.parametrize("amount", (960, 960.80, "900", "45.50", "55.00"))
def test_build_initialization_req_body(amount, paystack_provider):
    test_data = {"email": "some-email", "amount": amount, "some-other-key": "its value"}
    assert paystack_provider.build_initialization_req_body(**test_data) == {
        "amount": str(Decimal(amount) * 100),
        "email": test_data.get("email"),
        "callback_url": paystack_provider.callback_url,
    }


def test_build_initialization_req_body_fails_if_callback_url_is_None(paystack_provider):
    paystack_provider.callback_url = None
    with pytest.raises(AssertionError):
        test_data = {"email": "some-email", "amount": 980.00, "some-other-key": "its value"}
        paystack_provider.build_initialization_req_body(**test_data)


def test_parse_intialization_response(paystack_provider):
    response_data = {
        "status": True,
        "message": "Authorization URL created",
        "data": {
            "authorization_url": "https://some.url/some/path",
            "access_code": "test-code",
            "reference": "test-ref",
        },
    }

    assert (
        response_data.get("data").get("reference"),
        response_data.get("data").get("authorization_url"),
        {"access_code": response_data.get("data").get("access_code")},
    ) == paystack_provider.parse_intialization_response(response_data)


def test_parse_intialization_response_fails_if_missing_reference_or_authorization_url(paystack_provider):
    response_data = {
        "status": True,
        "message": "Authorization URL created",
        "data": {
            "access_code": "test-code",
        },
    }

    with pytest.raises(KeyError):
        paystack_provider.parse_intialization_response(response_data)


@pytest.mark.django_db
def test_process_payment_mark_as_paid(paystack_provider):
    from pharmanathi_backend.payments.tests.paystack_sample import cb

    payment = PaymentFactory(reference=cb.get("data").get("reference"))
    payment.set_provider = paystack_provider.name
    payment._save_pending_changes()

    with patch(
        "pharmanathi_backend.payments.providers.provider.BaseProvider.execute_callback"
    ) as patched_execute_callback:
        paystack_provider.process_payment(cb)

    payment.refresh_from_db()
    patched_execute_callback.assert_called
    assert payment.status == "PAID"


@pytest.mark.django_db
def test_process_payment_mark_as_unpaid(paystack_provider):
    from pharmanathi_backend.payments.tests.paystack_sample import cb

    cb["data"]["status"] = "failed"
    payment = PaymentFactory(reference=cb.get("data").get("reference"))
    payment.set_provider = paystack_provider.name
    payment._save_pending_changes()

    with patch(
        "pharmanathi_backend.payments.providers.provider.BaseProvider.execute_callback"
    ) as patched_execute_callback:
        paystack_provider.process_payment(cb)

    payment.refresh_from_db()
    patched_execute_callback.assert_called
    assert payment.status == "FAILED"


@pytest.mark.django_db
@pytest.mark.parametrize(
    "status, status_bd",
    [
        ("success", "PAID"),
        ("failed", "FAILED"),
    ],
)
def test_callback_view_sets_success_failed(status, status_bd, api_client, paystack_provider):
    from pharmanathi_backend.payments.tests.paystack_sample import cb

    cb["data"]["status"] = status

    pending_payment = PaymentFactory(reference=cb["data"]["reference"])
    pending_payment.set_provider(paystack_provider.name)
    with patch(
        "pharmanathi_backend.payments.providers.provider.BaseProvider.execute_callback"
    ) as patched_execute_callback:
        response = api_client.post(f"/api/payments/cb/{pending_payment.provider.name}", cb, format="json")

    assert response.status_code == 200
    patched_execute_callback.assert_called
    patched_execute_callback.assert_called_with(pending_payment, pending_payment.status)

    pending_payment.refresh_from_db()
    if status == status:
        assert pending_payment.status == status_bd


@pytest.mark.django_db
def test_book_appointment_with_paysfast(authenticated_user_api_client, appointment_date_and_doctor, paystack_provider):
    patient = authenticated_user_api_client.user
    appointment_date, appointment_doctor = appointment_date_and_doctor
    appointment_type = appointment_doctor.appointmenttype_set.first()
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
        "payment_provider": paystack_provider.name,
    }

    payment = PaymentFactory(
        amount=appointment_type.cost,
        _provider=paystack_provider.name,
        user=patient,
        status=Payment.PaymentStatus.PENDING,
    )
    with patch(
        "pharmanathi_backend.payments.providers.provider.CashProvider.initialize_payment"
    ) as pacthed_initialize_payment:
        pacthed_initialize_payment.return_value = (payment, {"payment_url": "some-uri"})
        response = authenticated_user_api_client.post(
            "/api/appointments/",
            payload,
            format="json",
        )
    assert response.status_code == 201
    assert "payment_url" in response.data.get("action_data")
    assert response.data.get("appointment").get("payment").get("provider") == paystack_provider.name
    assert response.data.get("appointment").get("payment").get("status") == Payment.PaymentStatus.PENDING


@pytest.mark.django_db
def test_make_payment(paystack_provider):
    user = UserFactory()
    paystack_provider.make_payment_instance("some_field", 100, user, "sample_reference")

    assert Payment.objects.filter(
        reverse_lookup_field="some_field", amount=100, user=user, reference="sample_reference"
    )
