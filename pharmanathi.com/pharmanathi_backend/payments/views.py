import json
import logging

from django.shortcuts import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from .models import Payment
from .providers.provider import get_provider

logger = logging.getLogger(__file__)


@csrf_exempt
@require_POST
def cb(request, provider):
    cb_request_data = json.loads(request.body)
    provider_klass = get_provider(provider)  # We're hopping that Sentry catches any miss
    try:
        provider_klass.process_payment(cb_request_data)
    except Payment.DoesNotExist as e:
        print(dir(e), e)
        logger.warning(f"No {provider} payment satisifies callback with info {cb_request_data}")
    except Exception as e:
        raise e
    return HttpResponse("OK", content_type="text/plain")
