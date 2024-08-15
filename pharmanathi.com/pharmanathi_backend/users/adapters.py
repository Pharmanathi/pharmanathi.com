from __future__ import annotations

import typing

from allauth.account.adapter import DefaultAccountAdapter
from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from allauth.socialaccount.models import SocialLogin
from django.conf import settings
from django.core.exceptions import MultipleObjectsReturned
from django.http import HttpRequest
from rest_framework.exceptions import PermissionDenied

from pharmanathi_backend.users.models import User


class AccountAdapter(DefaultAccountAdapter):
    def is_open_for_signup(self, request: HttpRequest) -> bool:
        return getattr(settings, "ACCOUNT_ALLOW_REGISTRATION", True)


class SocialAccountAdapter(DefaultSocialAccountAdapter):
    @property
    def default_app(self):
        return self._default_app

    @default_app.setter
    def default_app(self, app_name):
        """Allows setting a default apop to return in case of ambiguity.
        Ambiguity here is when the original implementation would return
        a MultipleObjectsReturned error
        """
        from allauth.socialaccount.models import SocialApp

        self._default_app = SocialApp.objects.get(name=app_name)

    def is_open_for_signup(self, request: HttpRequest, sociallogin: SocialLogin) -> bool:
        return getattr(settings, "ACCOUNT_ALLOW_REGISTRATION", True)

    def populate_user(self, request: HttpRequest, sociallogin: SocialLogin, data: dict[str, typing.Any]) -> User:
        """
        Populates user information from social provider info.

        See: https://django-allauth.readthedocs.io/en/latest/advanced.html?#creating-and-populating-user-instances
        """
        user = sociallogin.user
        if name := data.get("name"):
            user.name = name
        elif first_name := data.get("first_name"):
            user.name = first_name
            if last_name := data.get("last_name"):
                user.name += f" {last_name}"
        return super().populate_user(request, sociallogin, data)

    def list_apps(self, request, provider=None, client_id=None):
        apps = super().list_apps(request, provider, client_id)
        return apps

    def get_app(self, request, provider, client_id=None, app_name=None):
        from allauth.socialaccount.models import SocialApp

        if client_id is None:
            pass
        if app_name is None:
            pass
        apps = self.list_apps(request, provider=provider, client_id=client_id)
        if len(apps) > 1:
            raise MultipleObjectsReturned
        elif len(apps) == 0:
            raise SocialApp.DoesNotExist()
        return apps[0]

    def pre_social_login(self, request, sociallogin):
        signing_as_doctor = "_mhp_" in request.headers.get("auth-app")
        # As per the django-auth docs, during the running of this method
        # SocialLogin contains a prepopulated instance of User(self.user)
        # that's not saved! Hence, we cannot;
        # pass it to a related model just yet. The only way for us to validate
        # that a user exists before trying to sign them in/up is by doing it explicitely
        has_doctor_profile = False  # sociallogin.user.is_doctor
        user_query = User.objects.filter(email=sociallogin.user.email)
        user_exists = user_query.exists()
        if user_exists:
            has_doctor_profile = user_query.first().is_doctor
        if ((user_exists and signing_as_doctor) and not has_doctor_profile) is True:
            raise PermissionDenied(detail="Invalid app for current profile")
