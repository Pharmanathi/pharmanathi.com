import json
import logging

from django.shortcuts import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from .providers.provider import get_provider

logger = logging.getLogger(__file__)


@csrf_exempt
@require_POST
def cb(request, provider):
    cb_request_data = json.loads(request.body)
    logger.info(f"Got call from {provider} with body {cb_request_data}")
    provider_klass = get_provider(provider)  # We're hopping that Sentry catches any miss
    provider_klass.process_payment(cb_request_data)
    return HttpResponse("OK", content_type="text/plain")
