import logging

from django.http import HttpResponseRedirect
from django.shortcuts import redirect, resolve_url

logger = logging.getLogger(__file__)


def handle_ios_app_association(request):
    return redirect("/static/apple-app-site-association")


def handle_deeplink_redirect(request):
    HttpResponseRedirect.allowed_schemes.append("news")
    full_path = request.get_full_path()
    args = full_path[full_path.index("?") :]

    deeplink = f"unilinks://pharmanathi.com/{args}"
    logger.info(f"Deeplink redirect to {deeplink} from {full_path}")

    class UnilinkRedirect(HttpResponseRedirect):
        allowed_schemes = ["unilinks"]

    logger.info(f"Deeplink redirect to {deeplink} from {full_path}")
    return UnilinkRedirect(resolve_url(deeplink))
