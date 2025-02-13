from enum import Enum

import firebase_admin
from django.conf import settings
from firebase_admin import messaging

cred = firebase_admin.credentials.Certificate(settings.BASE_DIR / "service-account.json")
default_app = firebase_admin.initialize_app(cred)


class NotificationCategory(Enum):
    GENERAL = "General"
    APPOINTMENT = "Appointment"
    # The category below includes anything that touches on the
    # MP's professional information settings in the app. i.e:
    # Invalidation, Validation
    PROFESSION = "Profession"


def send_individual_notification(category: str, title: str, body: str, token: str, image_url: str = None):
    """Sends individual notification to a single target device.

    Args:
        category (str): Category type.
        title (str): Notification title
        body (str): Notification body
        token (str): Recipient device token
        image_url (str, optional): URL to image to display in the notication. Note that this
                is different from the app's icon. Defaults to None.

    Returns:
        str: value from firebase_admin.messaging.send
    """
    assert category in list(
        map(lambda c: c.value, list(NotificationCategory))
    ), f"Invalid notification category. Got {category}, expected one of {list(NotificationCategory)}"

    message = messaging.Message(
        data={
            "category": category,
            "screen": "/appointments",  # deprecate since UI takes care of this
        },
        notification=messaging.Notification(
            title=title,
            body=body,  # "New appointment booking with reference ${reference} for Monday 27th October at 12:30.",
            image=image_url,
        ),
        token=token,
    )
    return messaging.send(message, app=default_app)
