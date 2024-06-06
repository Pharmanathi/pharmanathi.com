import datetime

import pytz
from django.conf import settings
from django.http import request


def user_is_doctor(req: request) -> bool:
    """Returns True if the authenticated user is a doctor(MHP)

    Args:
        req (request): view request

    Returns:
        bool: _description_
    """
    if not req.user.is_authenticated:
        return False

    return req.user.is_doctor


def UTC_time_to_SA_time(utc_time: datetime.datetime):
    return utc_time.astimezone(pytz.timezone(settings.TIME_ZONE))
