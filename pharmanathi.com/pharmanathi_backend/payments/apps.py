from django.apps import AppConfig


class PaymentsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "pharmanathi_backend.payments"

    def ready(self):
        from pharmanathi_backend.payments.providers.paystack import provider
