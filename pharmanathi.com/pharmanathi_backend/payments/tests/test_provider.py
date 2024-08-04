import pytest
from django.test import override_settings

from pharmanathi_backend.payments.providers.provider import (
    BaseProvider,
    ProviderNotFoundException,
    check_provider_exists,
    get_provider,
    provider_registry,
    register_provider,
)


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
