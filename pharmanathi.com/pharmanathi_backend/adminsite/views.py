import datetime
import logging

from django.contrib.admin.views.decorators import staff_member_required
from django.db.models import F, Q
from django.http import JsonResponse
from django.shortcuts import HttpResponse, get_object_or_404, render

from pharmanathi_backend.users.api.serializers import UserSerializer
from pharmanathi_backend.users.models import Doctor, InvalidationReason, User

admin_logger = logging.getLogger("")


def handle404errors(request):
    # TODO: Deprecate
    return render(request, "adminsite/404.html", {})


@staff_member_required()
def main(request):
    today = datetime.date.today()
    first_day_last_month = datetime.date.today().replace(day=1, month=today.month - 1)
    last_day_last_month = today.replace(day=1) - datetime.timedelta(days=1)
    current_month = today.month
    Q_last_month = Q(date_created__date__gte=first_day_last_month) & Q(date_created__date__lte=last_day_last_month)
    count_signups_last_month = User.objects.filter(Q_last_month).count()
    count_signups_this_month = User.objects.filter(date_created__gte=today.replace(day=1)).count()
    stats = {
        "unverifed_mhps": Doctor.objects.filter(_is_verified=False).count(),
        "signups_this_month": count_signups_this_month,
        "signups_last_month": count_signups_last_month,
        "signups_increased": count_signups_this_month > count_signups_last_month,
        "signups_": (
            (count_signups_this_month * 100) // count_signups_last_month if count_signups_last_month > 0 else 100
        ),
    }
    return render(request, "adminsite-2/dashboard.html", {"stats": stats})


@staff_member_required()
def list_unverified_mhps(request):
    return render(
        request,
        "adminsite-2/mhp-unverified.html",
        {
            "unverified_mhps": Doctor.objects.filter(_is_verified=False)
            .prefetch_related("user")
            .values("id", "user__email", "user__first_name", "user__last_name", "user__id")
        },
    )


@staff_member_required
def get_user_detail(request, user_id):
    return render(
        request,
        "adminsite-2/user-detail.html",
        {
            "user": UserSerializer(
                get_object_or_404(
                    User.objects.prefetch_related("doctor_profile", "doctor_profile__invalidationreason_set"),
                    pk=user_id,
                )
            ).data
        },
    )


@staff_member_required
def validate_mhp_profile(request, mhp_id):
    # fail if has unresolved validation errors
    if InvalidationReason.objects.filter(mhp__id=mhp_id, is_resolved=False).exists():
        return JsonResponse(
            {"detail": "This MP has one or more unresolved Invalidation Reasons. They must be resolved first."},
            status=403,
        )
    try:
        mhp = Doctor.objects.get(id=mhp_id)
        mhp.mark_as_vefified()
        admin_logger.info(f"{request.user} verified MHP {mhp}")
        return HttpResponse(status=200)
    except Exception as e:
        admin_logger.info(f"{request.user} tried to verify MHP with ID {mhp_id} but failed with error: <{e}>")
        return JsonResponse({"detail": str(e)}, status=500)


import json


@staff_member_required
def invalidate_mhp_profile(request, mhp_id):
    try:
        invalidation_reason = json.loads(request.body.decode("utf-8")).get("reason")
        mhp = Doctor.objects.get(id=mhp_id)
        mhp.invalidate_mhp_profile(request.user, invalidation_reason)
        admin_logger.info(f"{request.user} invalidated MHP {mhp}")
        return HttpResponse(status=200)
    except Exception as e:
        admin_logger.info(f"{request.user} tried to invalidate MHP with ID {mhp_id} but failed with error: <{e}>")
        return JsonResponse({"detail": str(e)}, status=500)


@staff_member_required
def resolve_invalidation_reason(request, ir_id):
    try:
        InvalidationReason.objects.filter(id=ir_id).update(is_resolved=True, resolved_by=request.user)
        return HttpResponse(status=200)
    except Exception as e:
        return JsonResponse({"detail": str(e)}, status=500)
