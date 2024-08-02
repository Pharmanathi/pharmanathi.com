from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models

from .providers.provider import BaseProvider, ProviderNotFoundException, get_provider, provider_registry

UserModel = get_user_model()


class Payment(models.Model):
    class PaymentStatus(models.TextChoices):
        PENDING = ("PENDING", "Pending")
        PAID = ("PAID", "Paid")
        FAILED = ("FAILED", "Failed")

    provider_choices = map(lambda p: (p, p), provider_registry.keys())
    amount = models.DecimalField(decimal_places=2, max_digits=6, null=False, blank=False)
    user = models.ForeignKey(UserModel, on_delete=models.PROTECT, blank=False)
    _provider = models.CharField(max_length=25, choices=provider_choices, null=False, blank=True)
    reference = models.CharField(max_length=32, null=False, blank=True)
    status = models.CharField(max_length=10, choices=PaymentStatus, default=PaymentStatus.PENDING)
    json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return f"<Payment({self.provider.name}): {self.reference}>"

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
        if hasattr(settings, "PAYMENT_USER_EMAIL_FIELD"):
            email_field = settings.PAYMENT_USER_EMAIL_FIELD
        else:
            email_field = "email"
        return UserModel.objects.get(**{email_field: email})

    def set_provider(self, name):
        # check provider exists
        if BaseProvider.check_provider_exists(name) is False:
            raise ProviderNotFoundException(name)

        # check user has access to this provider
        provider_klass: BaseProvider = provider_registry.get(name)
        provider_klass.is_available_to_user(self.user)

        # finally, lazy set
        self._provider = name

    @property
    def provider(self):
        if hasattr(self, "provider_instance") is False:
            self.provider_instance = get_provider(self._provider)
        return self.provider_instance

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
