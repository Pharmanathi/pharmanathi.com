"""
Simple script for syncing the list of MHP speciliaties
"""

import environ
from allauth.socialaccount.models import SocialApp
from django.conf import settings
from django.contrib.sites.models import Site

env = environ.Env()

APPS = [
    env.dict("SOCIAL_APP_GOOGLE_MHP_ANDROID"),
    env.dict("SOCIAL_APP_GOOGLE_MHP_IOS"),
    env.dict("SOCIAL_APP_GOOGLE_PATIENT_ANDROID"),
    env.dict("SOCIAL_APP_GOOGLE_PATIENT_IOS"),
]
GOOGLE_DEFAULT_SCOPE = {"SCOPE": ["profile", "email", "openid"]}


def run():
    pharmanthidotcom_site = Site.objects.get(id=settings.SITE_ID)
    for app in APPS:
        app_name = app["name"]
        social_app, created = SocialApp.objects.get_or_create(
            name=app_name,
            defaults={
                "settings": GOOGLE_DEFAULT_SCOPE,
                "provider": app["provider"],
                "client_id": app["client_id"],
                "secret": app["secret"],
            },
        )
        social_app.sites.set([pharmanthidotcom_site])
