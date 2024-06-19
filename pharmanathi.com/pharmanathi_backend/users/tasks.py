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
