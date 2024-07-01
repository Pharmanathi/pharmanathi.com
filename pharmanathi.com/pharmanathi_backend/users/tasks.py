from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import mail_admins, send_mail

from config import celery_app


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
        html_message=html_message,
    )


@celery_app.task
def mail_user_task(user_email, subject, message, html_message=None):
    return send_mail(
        f"[Pharmanthi] {subject}", message, recipient_list=[user_email], from_email=None, html_message=html_message
    )


@celery_app.task
def set_rejection_reason_task(mhp_id, text, creator_user_id):
    from pharmanathi_backend.users.models import Doctor, InvalidationReason, User

    mhp = Doctor.objects.get(id=mhp_id)
    creator = User.objects.get(id=creator_user_id)
    return str(InvalidationReason.objects.create(mhp=mhp, created_by=creator, text=text))


@celery_app.task
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

    from pharmanathi_backend.users.models import Doctor, VerificationReport

    mp = Doctor.objects.filter(pk=mp_pk).prefetch_related("specialities").get()
    verification_type = VerificationReport.det_verification_type(mp)
    identifier = mp.mp_no if mp.is_pharmacist else mp.hpcsa_no
    verification_url = f"{settings.VERIFI_URL}/?type={verification_type}&id={identifier}"
    verifi_response = requests.get(verification_url)
    vr = VerificationReport.objects.create(mp=mp, type=verification_type, report=verifi_response.json())
    return f"Created {vr}"


""""
from pharmanathi_backend.users.models import Doctor as D

d = D.objects.first()
d.run_auto_mp_verification_task()
"""
