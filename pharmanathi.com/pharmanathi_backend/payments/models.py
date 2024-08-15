from typing import Any

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models

from .providers.provider import (
    BaseProvider,
    ProviderNotFoundException,
    check_provider_exists,
    get_provider,
    provider_registry,
)

# We can probably do better down here when it comes to getting
# making this model availalbe thoughout the payments app.
UserModel = get_user_model()


class RelatedObjectNotLinked(Exception):
    """To be raised if Payment instance was never
    linked to a related object.
    """

    message = "Reverse lookup failed to find the related object through reverse_lookup_field"

    def __init__(self, *args: object) -> None:
        super().__init__(self.message)


class MissingOnPaymentCallabackException(Exception):
    message = f"Payment related object missing on_payment_callback attribute."

    def __init__(self, *args: object) -> None:
        super().__init__(self.message)


class Payment(models.Model):
    class PaymentStatus(models.TextChoices):
        PENDING = ("PENDING", "Pending")
        PAID = ("PAID", "Paid")
        FAILED = ("FAILED", "Failed")

    def get_provider_choices():
        provider_choices = list(map(lambda p: (p, p), provider_registry.keys()))
        return provider_choices

    date_created = models.DateTimeField(auto_now_add=True)
    date_modified = models.DateTimeField(auto_now=True)
    amount = models.DecimalField(decimal_places=2, max_digits=6, null=False, blank=False)
    user = models.ForeignKey(UserModel, on_delete=models.PROTECT, blank=False)
    _provider = models.CharField(max_length=25, choices=get_provider_choices, null=False, blank=True)
    reference = models.CharField(max_length=32, null=False, blank=True)
    status = models.CharField(max_length=10, choices=PaymentStatus, default=PaymentStatus.PENDING)
    json = models.JSONField(null=True, blank=True)

    # we need a way to inform the related model of some events e.g: payment has changed
    # statuses. Hence, since we can use a reverse-lookup using realtionships, the field
    # below serves the pupose of specifying the attribute to use for the reverse lookup
    reverse_lookup_field = models.CharField(
        max_length=100, null=True, blank=True  # TODO(nehemie): make non-nullable next release
    )

    def __str__(self):
        return f"<Payment({self.status}) {self.id}: {self.reference}>"

    @classmethod
    def get_user_by_email(cls, email):
        """Returns the User with the associated email.
        The email field used is the value specied by
        settings.PAYMENT_USER_EMAIL_FIELD or ``email`` if unset

        Args:
            email (_type_): _description_

        Returns:
            _type_: _description_
        """
        if hasattr(settings, "PAYMENT_USER_EMAIL_FIELD") and settings.PAYMENT_USER_EMAIL_FIELD not in ["", " "]:
            email_field = settings.PAYMENT_USER_EMAIL_FIELD
        else:
            email_field = "email"
        return UserModel.objects.get(**{email_field: email})

    def set_provider(self, name):
        if check_provider_exists(name) is False:
            raise ProviderNotFoundException(name)

        # check user has access to this provider
        provider_klass: BaseProvider = provider_registry.get(name)
        provider_klass.is_available_to_user(self.user)

        self._provider = name

    @property
    def provider(self):
        if hasattr(self, "_provider_instance") is False:
            self._provider_instance = get_provider(self._provider)
        return self._provider_instance

    def _save_pending_changes(self):
        self.save()

    def set_status_paid(self, save=False):
        self.status = Payment.PaymentStatus.PAID
        if save:
            self._save_pending_changes()

    def set_status_failed(self, save=False):
        self.status = Payment.PaymentStatus.FAILED
        if save:
            self._save_pending_changes()

    def set_status_pending(self, save=False):
        self.status = Payment.PaymentStatus.PENDING
        if save:
            self._save_pending_changes()

    def get_related_object(self, raise_not_linked=False):
        """Return the instance from self.reverse_lookup_field

        Args:
            raise_not_linked (bool, optional): Whether we should raise an exception
            if unable to find the object. Defaults to False.
        """
        if self.reverse_lookup_field is None:
            raise ValueError("self.reverse_lookup_field is unset")

        if hasattr(self, self.reverse_lookup_field) is False:
            if raise_not_linked:
                raise RelatedObjectNotLinked()
            return None
        return getattr(self, self.reverse_lookup_field)

    def callback(self, old_status):
        """Notify the related object of status change.
        The on_payment_callback() method or function on the related
        object  should accept 2 parameters which represent the payment's
        status before change, and the payment after change.

        Sample Implementation of on_payment_callback:
        ```
        def on_payment_callback(self, old_status):
            if old_status == "PENDING" and self.payment.status == "PAID":
                print("Payment successful")
            else:
                print(f"payment {payment_updated.status}")
        ```
        """
        self.refresh_from_db()
        rel_obj = self.get_related_object(True)
        if hasattr(rel_obj, "on_payment_callback") is None:
            raise MissingOnPaymentCallabackException()

        rel_obj.on_payment_callback(self, old_status)

    def get_message(self):
        return self.provider.get_payment_feedback(self)
