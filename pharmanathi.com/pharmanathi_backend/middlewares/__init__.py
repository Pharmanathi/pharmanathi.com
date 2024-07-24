import logging

from django.conf import settings

logger = logging.getLogger("middlewares")


class CodeVersionMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)

        # Inject the version in the response header
        if settings.GIT_CODE_VERSION is None:
            logger.warn("settings.GIT_CODE_VERSION is was never set")

        response.headers.setdefault("X-SCV", settings.GIT_CODE_VERSION)
        return response
