import pytest

from pharmanathi_backend.users.models import User

pytestmark = pytest.mark.django_db


def test_user_get_absolute_url(user: User):
    assert user.get_absolute_url() == f"/users/{user.pk}/"


def test_is_doctor_False_if_no_doctor_profile(user):
    assert user.is_doctor is False


def test_is_doctor_on_simple_doctor(simple_doctor):
    assert simple_doctor.user.is_doctor is True


def test_is_doctor_on_social_doctor(social_simple_doctor):
    assert social_simple_doctor.user.is_doctor is True
