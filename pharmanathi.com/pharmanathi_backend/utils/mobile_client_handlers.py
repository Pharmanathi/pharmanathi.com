from django.http import HttpResponseRedirect
from django.shortcuts import redirect, resolve_url


def handle_ios_app_association(request):
    return redirect("/static/apple-app-site-association")


def handle_deeplink_redirect(request):
    HttpResponseRedirect.allowed_schemes.append("news")
    full_path = request.get_full_path()
    args = full_path[full_path.index("?") + 1 :].split("=")
    screen = args[args.index("screen") + 1]

    class UnilinkRedirect(HttpResponseRedirect):
        allowed_schemes = ["unilinks"]

    return UnilinkRedirect(resolve_url(f"unilinks://pharmanathi.com{screen}"))
