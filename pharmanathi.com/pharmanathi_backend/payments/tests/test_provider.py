from unittest.mock import patch

import pytest
from django.test import override_settings

from pharmanathi_backend.payments.models import Payment
from pharmanathi_backend.payments.providers.provider import (
    BaseProvider,
    CashProvider,
    ProviderNotFoundException,
    check_provider_exists,
    get_provider,
    provider_registry,
    register_provider,
)
from pharmanathi_backend.users.tests.factories import UserFactory


def test_register_provider():
    @register_provider
    class SomeProvider(BaseProvider):
        name = "someprovider"

    assert "someprovider" in provider_registry


def test_register_provider_fails_if_no_name():
    with pytest.raises(AttributeError):

        @register_provider
        class SomeProvider(BaseProvider):
            pass


@override_settings(
    PAYMENT_PROVIDERS={
        "Yourprovider": {
            "initialization_url": "some-uri",
            "authorization": "some-token",
            "callback_url": "some-uri",
        }
    }
)
def test_register_provider_with_provided_settings():
    @register_provider
    class YourProvider(BaseProvider):
        name = "Yourprovider"

    your_provider_instance = YourProvider()
    assert your_provider_instance.initialization_url == "some-uri"
    assert your_provider_instance.authorization == "some-token"
    assert your_provider_instance.callback_url == "some-uri"


def test_check_provider_exists():
    @register_provider
    class SomeProvider(BaseProvider):
        name = "someprovider"

    assert check_provider_exists("someprovider") is True


def test_get_provider():
    @register_provider
    class SomeProvider(BaseProvider):
        name = "someprovider"

    assert isinstance(get_provider("someprovider"), SomeProvider) is True


def test_get_provider_raises_provider_not_found_if_does_not_exist():
    with pytest.raises(ProviderNotFoundException):
        get_provider("inexistant")


@pytest.mark.django_db
def test_get_payment_by_reference(pending_payment):
    payment_provider = get_provider(pending_payment._provider)
    assert pending_payment == payment_provider.get_payment_by_reference(pending_payment.reference)


@pytest.mark.django_db
def test_initialize_payment():
    @register_provider
    class SampleProvider(CashProvider):
        name = "sp"

        def build_initialization_req_body(self, *args, **kwargs):
            return {}

        def parse_intialization_response(self, *args, **kwargs):
            return "sample-ref", "sample-uri", ""

        def parse_initalization_request_data(self, **kwargs):
            return kwargs.get("email"), kwargs.get("amount")

        def get_intialization_data(self, *args, **kwargs):
            return self.parse_intialization_response(*args, **kwargs)

    user = UserFactory()
    sp = SampleProvider()

    payment, extra_dict = sp.initialize_payment("rlf", 100, user.email)
    assert payment.user == user
    assert payment.reference == "sample-ref"

    assert isinstance(payment, Payment)
