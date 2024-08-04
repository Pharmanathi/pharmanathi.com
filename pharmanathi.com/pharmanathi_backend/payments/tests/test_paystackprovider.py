from unittest.mock import patch

import pytest

from pharmanathi_backend.payments.tests.factories import PaymentFactory


def test_parse_initalization_request_data_raises_if_no_email_and_amount(paystack_provider):
    with pytest.raises(AssertionError) as e:
        paystack_provider.parse_initalization_request_data(some_value="some_data")


def test_parse_initalization_request_data_passes(paystack_provider):
    test_data = {"email": "some-email", "amount": 980.00, "some-other-key": "its value"}

    assert paystack_provider.parse_initalization_request_data(**test_data) == ("some-email", 980.00)


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
    from pharmanathi_backend.payments.tests.factories import PaymentFactory
    from pharmanathi_backend.payments.tests.paystack_sample import cb

    payment = PaymentFactory(reference=cb.get("data").get("reference"))
    payment.set_provider = paystack_provider.name
    payment._save_pending_changes()

    paystack_provider.process_payment(cb)
    payment.refresh_from_db()
    assert payment.status == "PAID"


@pytest.mark.django_db
def test_process_payment_mark_as_unpaid(paystack_provider):
    from pharmanathi_backend.payments.tests.factories import PaymentFactory
    from pharmanathi_backend.payments.tests.paystack_sample import cb

    cb["data"]["status"] = "failed"
    payment = PaymentFactory(reference=cb.get("data").get("reference"))
    payment.set_provider = paystack_provider.name
    payment._save_pending_changes()

    paystack_provider.process_payment(cb)
    payment.refresh_from_db()
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

    response = api_client.post(f"/api/payments/cb/{pending_payment.provider.name}", cb, format="json")
    assert response.status_code == 200

    pending_payment.refresh_from_db()
    if status == status:
        assert pending_payment.status == status_bd
