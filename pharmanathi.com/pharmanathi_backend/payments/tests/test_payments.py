# tests for the Payment model
import pytest

from pharmanathi_backend.payments.models import Payment
from pharmanathi_backend.payments.providers.provider import CashProvider, ProviderNotFoundException, register_provider
from pharmanathi_backend.payments.tests.factories import PaymentFactory

pytestmark = pytest.mark.django_db


def test_str(pending_payment):
    assert f"{pending_payment}" == f"<Payment({pending_payment.status}): {pending_payment.reference}>"


def test_get_user_by_email(patient):
    assert Payment.get_user_by_email(patient.email) == patient


def test_set_provider_raises_not_found_if_setting_inexisting_provider(pending_payment):
    pending_payment._provider = None
    with pytest.raises(ProviderNotFoundException):
        pending_payment.set_provider("inexistant_provider")


def test_set_provider_raises_usage_denied_if_provider_cant_be_used(pending_payment, patient):
    provider_name = "test-provider"

    @register_provider
    class TProvider(CashProvider):
        name = provider_name

        def _is_available_to_user(
            self,
        ):
            return False

    pending_payment._provider = None
    with pytest.raises(CashProvider.UsageDeniedException):
        pending_payment.set_provider(provider_name)


def test_set_provider(pending_payment):
    # includes testing the provider getter on the Payment model.
    provider_name = "test-provider"

    @register_provider
    class TProvider(CashProvider):
        name = provider_name

    pending_payment._provider = None
    pending_payment.set_provider(provider_name)
    assert isinstance(pending_payment.provider, TProvider)


def test_set_status_paid(pending_payment):
    pending_payment.set_status_paid(save=True)
    assert pending_payment.status == Payment.PaymentStatus.PAID


def test_set_status_failed(pending_payment):
    pending_payment.set_status_failed(save=True)
    assert pending_payment.status == Payment.PaymentStatus.FAILED
