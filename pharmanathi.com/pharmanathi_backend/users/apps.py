from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class UsersConfig(AppConfig):
    name = "pharmanathi_backend.users"
    verbose_name = _("Users")

    def ready(self):
        try:
            import pharmanathi_backend.users.signals  # noqa: F401
        except ImportError:
            pass
