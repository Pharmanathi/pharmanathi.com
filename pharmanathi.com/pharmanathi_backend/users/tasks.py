import logging
from datetime import datetime

from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import mail_admins, send_mail

from config import celery_app

admin_logger = logging.getLogger(__name__)  # TODO: target a more specific logger here, admin and/or sentry


@celery_app.task()
def get_users_count():
    """A pointless Celery task to demonstrate usage."""
    User = get_user_model()
    return User.objects.count()


@celery_app.task()
def mail_admins_task(subject, simple_message, html_message):
    return mail_admins(
        subject,
        simple_message,
        fail_silently=False,
        html_message=html_message.replace("\n", "<br>"),
    )


@celery_app.task
def mail_user_task(user_email, subject, message, html_message=None):
    return send_mail(
        f"[Pharmanthi] {subject}",
        message,
        recipient_list=[user_email],
        from_email=None,
        html_message=html_message.replace("\n", "<br>"),
    )


@celery_app.task
def set_rejection_reason_task(mhp_id, text, creator_user_id):
    from pharmanathi_backend.users.models import Doctor, InvalidationReason, User

    mhp = Doctor.objects.get(id=mhp_id)
    creator = User.objects.get(id=creator_user_id)
    return str(InvalidationReason.objects.create(mhp=mhp, created_by=creator, text=text))


@celery_app.task(soft_time_limit=settings.VERIFI_GLOBAL_SOFT_LIMIT)
def auto_mp_verification_task(mp_pk):
    """Triggers scrapping task to collect and update MP profile

    Args:
        mp_pk (Any): primary key of the Medical Professional

    @TODO:
        - PR with initial work
        - PR or issue on displaying the reports in the custom admin interface.
          Let Thabang work on this one if he wants to, to improve his Django
        - Pharmacouncil check
        - PR or issue for tests
        - Logging for failures
        - Production setup
        - Squash Migrations
    """
    import requests

    from pharmanathi_backend.users.api.serializers import VerificationReportUserStateSerializer
    from pharmanathi_backend.users.models import Doctor, VerificationReport

    mp = Doctor.objects.filter(pk=mp_pk).prefetch_related("specialities").get()
    state_now = VerificationReportUserStateSerializer(mp.user).data
    verification_type = VerificationReport.det_verification_type(mp)
    identifier = mp.mp_no if mp.is_pharmacist else mp.hpcsa_no
    verification_url = f"{settings.VERIFI_URL}/?mp_type={verification_type}&id={identifier}&first_name={mp.user.first_name}&last_name={mp.user.last_name}"
    admin_logger.info(f"Starting {verification_type} verification on MP {mp} with URL {verification_url}")

    try:
        verifi_response = requests.get(verification_url)
        verifi_response_json = verifi_response.json()
        if verifi_response.status_code != 200:
            err_message = f"Verification failed with error '{verifi_response_json.get('error')}' "
            admin_logger.error(err_message)
            verifi_response_json = {"_logs": [f"{datetime.now().strftime('[%D/%b/%Y %H:%M:%S]')} {err_message}"]}
    except Exception as e:
        if "_logs" not in verifi_response_json:
            verifi_response_json["_logs"] = []
        verifi_response_json.append(f"{datetime.now().strftime('[%D/%b/%Y %H:%M:%S]')} {e}")

    vr = VerificationReport.objects.create(
        mp=mp, type=verification_type, report={**verifi_response_json, "state_before": state_now}
    )
    return f"Created {vr}"


@celery_app.task
def update_user_social_profile_picture_url_task(user_pk: int, url: str) -> None:
    from pharmanathi_backend.users.models import User

    User.objects.filter(pk=user_pk).update(_profile_pic=url.replace("s96-c", "s192-c"))
