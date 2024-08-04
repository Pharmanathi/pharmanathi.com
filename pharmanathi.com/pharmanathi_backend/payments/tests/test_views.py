from unittest.mock import patch

import pytest

from pharmanathi_backend.payments.providers.provider import BaseProvider, register_provider
from pharmanathi_backend.payments.tests.factories import PaymentFactory


@pytest.mark.django_db
def test_callback_view(api_client):
    from pharmanathi_backend.payments.tests.paystack_sample import cb

    cb["data"]["status"] = "success"
    provider_name = "some-provider"

    @register_provider
    class TProvider(BaseProvider):
        name = provider_name

        @classmethod
        def _is_available_to_user(cls, user):
            return True

    pending_payment = PaymentFactory(reference=cb["data"]["reference"])
    pending_payment.set_provider(provider_name)

    with patch(
        "pharmanathi_backend.payments.providers.provider.BaseProvider.process_payment"
    ) as patched_process_payment:
        response = api_client.post(f"/api/payments/cb/{pending_payment.provider.name}", cb, format="json")
    assert response.status_code == 200
    assert patched_process_payment.called
