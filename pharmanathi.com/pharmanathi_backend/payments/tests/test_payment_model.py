# tests for the Payment model
from unittest.mock import Mock, patch

import pytest
from django.test.utils import isolate_apps
from pharmanathi_backend.payments.models import Payment, RelatedObjectNotLinked
from pharmanathi_backend.payments.providers.provider import (
    BaseProvider,
    CashProvider,
    ProviderNotFoundException,
    register_provider,
)
from pharmanathi_backend.payments.tests.factories import PaymentFactory, UserFactory

pytestmark = pytest.mark.django_db


def test_str(pending_payment):
    assert (
        f"{pending_payment}"
        == f"<Payment({pending_payment.status}) {pending_payment.pk}: {pending_payment.reference}>"
    )


def test_provider_choices():
    @register_provider
    class TestProvider(BaseProvider):
        name = "Test Provider"

    assert (TestProvider.name, TestProvider.name) in Payment.get_provider_choices()


def test_get_user_by_email(patient):
    assert Payment.get_user_by_email(patient.email) == patient


def test_get_user_by_email_default_value(patient):
    from django.conf import settings

    if hasattr(settings, "PAYMENT_USER_EMAIL_FIELD"):
        del settings.PAYMENT_USER_EMAIL_FIELD

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


def test_get_related_object_raises_if_field_unset():
    payment = PaymentFactory(reverse_lookup_field=None)
    with pytest.raises(ValueError):
        payment.get_related_object()


def test_get_related_object_raises_not_linked():
    payment = PaymentFactory(reverse_lookup_field="somefield")
    with pytest.raises(RelatedObjectNotLinked):
        payment.get_related_object(raise_not_linked=True)


def test_get_related_object_return_none_if_raises_silenced():
    payment = PaymentFactory(reverse_lookup_field="somefield")
    assert payment.get_related_object(raise_not_linked=False) == None


def test_get_related_object():
    # this test is not complete as it only caters for
    # appointments. It needs to be made more generic
    from pharmanathi_backend.appointments.tests.factories import AppointmentFactory

    payment = PaymentFactory(reverse_lookup_field="appointment")
    appointment = AppointmentFactory(payment=payment)
    assert payment.get_related_object() == appointment


def test_get_message():
    @register_provider
    class SampleProvider(BaseProvider):
        name = "sample-provider"

        def get_payment_feedback(self, payment=None):
            return "fake message"

    payment = PaymentFactory(_provider="sample-provider")
    assert payment.get_message() == "fake message"


def test_callback():
    from django.apps import apps
    from django.core.management.color import no_style
    from django.db import connection, models
    from factory.django import DjangoModelFactory
    from pharmanathi_backend.payments.models import Payment as RealPaymentModel

    with isolate_apps("pharmanathi_backend.users", "pharmanathi_backend.payments"):

        class Payment(RealPaymentModel):
            class Meta:
                app_label = "pharmanathi_backend.payments"

            def get_related_object(self, raise_not_linked=False):
                return super().get_related_object(raise_not_linked).get()

        class ThingToPayFor(models.Model):
            class Meta:
                app_label = "pharmanathi_backend.users"

            payment = models.ForeignKey(Payment, related_name="paid_for", on_delete=models.PROTECT)

            def on_payment_callback(self, old_status):
                pass

        with connection.schema_editor() as schema_editor:
            schema_editor.create_model(Payment)
            schema_editor.create_model(ThingToPayFor)

        apps.clear_cache()

        user = UserFactory()
        payment = Payment.objects.create(reverse_lookup_field="paid_for", amount=900, user=user)
        thing_to_pay_for = ThingToPayFor.objects.create(payment=payment)

        with patch.object(ThingToPayFor, "on_payment_callback") as p:
            payment.callback("some-status")

        payment.refresh_from_db()
        p.assert_called
        p.assert_called_with(thing_to_pay_for.payment, "some-status")
