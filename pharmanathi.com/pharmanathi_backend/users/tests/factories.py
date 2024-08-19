import datetime
from collections.abc import Sequence
from os import environ
from typing import Any

import factory.fuzzy
from django.contrib.auth import get_user_model
from factory import Faker, SubFactory, post_generation
from factory.django import DjangoModelFactory

from pharmanathi_backend.users.models import (
    Address,
    Doctor,
    InvalidationReason,
    PracticeLocation,
    Speciality,
    VerificationReport,
)


class UserFactory(DjangoModelFactory):
    email = Faker("email")
    name = Faker("name")
    is_staff = False

    @post_generation
    def password(self, create: bool, extracted: Sequence[Any], **kwargs):
        password = (
            extracted
            if extracted
            else Faker(
                "password",
                length=42,
                special_chars=True,
                digits=True,
                upper_case=True,
                lower_case=True,
            ).evaluate(None, None, extra={"locale": None})
        )
        self.set_password(password)

    @classmethod
    def _after_postgeneration(cls, instance, create, results=None):
        """Save again the instance if creating and at least one hook ran."""
        if create and results and not cls._meta.skip_postgeneration_save:
            # Some post-generation hooks ran, and may have modified us.
            instance.save()

    class Meta:
        model = get_user_model()
        django_get_or_create = ["email"]


class AddressFactory(DjangoModelFactory):
    line_1 = factory.fuzzy.FuzzyText(length=70)
    line_2 = factory.fuzzy.FuzzyText(length=70)
    suburb = factory.fuzzy.FuzzyText(length=25)
    city = factory.fuzzy.FuzzyText(length=25)
    province = factory.fuzzy.FuzzyChoice(Address.ProvinceChoice)

    class Meta:
        model = Address


class PracticeLocationFactory(DjangoModelFactory):
    name = factory.fuzzy.FuzzyText(length=40)
    address = SubFactory(AddressFactory)

    class Meta:
        model = PracticeLocation


class SpecialityFactory(DjangoModelFactory):
    name = factory.fuzzy.FuzzyText(length=100)
    symbol = factory.fuzzy.FuzzyText(length=15)

    class Meta:
        model = Speciality


class DoctorFactory(DjangoModelFactory):
    hpcsa_no = factory.fuzzy.FuzzyText(length=5)
    mp_no = factory.fuzzy.FuzzyText(length=5)
    _is_verified = False
    user = SubFactory(UserFactory)

    class Meta:
        model = Doctor


def FutureDateByDOWFactory(day_of_the_week, with_time: datetime.time = None) -> datetime.date | datetime.datetime:
    """Returns a future date by day of the week
    day_of_the_week: int between 1 and 7
    """
    if day_of_the_week not in range(1, 8):
        raise ValueError(
            f"Invalid day({day_of_the_week}) of the week integer. Value should be between 1...7(inclusive)"
        )

    start_dt = datetime.date.today() + datetime.timedelta(days=1)

    def get_future_date():
        return factory.fuzzy.FuzzyDate(start_dt, datetime.date(start_dt.year + 1, 12, 31)).fuzz()

    def get_future_datetime():
        """Will return a future datetime object with time equal to with_time"""
        fd = get_future_date()
        return datetime.datetime.combine(fd, with_time)

    future_date = get_future_datetime() if with_time else get_future_date()
    MAX_ITERATIONS = int(environ.get("PYTEST_LOOP_MAX_ITERATIONS", "100"))
    while future_date.isoweekday() != day_of_the_week and MAX_ITERATIONS:
        # @TODO: Can we imnprove this?
        print("Struggling to get future date from FutureDateByDOWFactory()")
        future_date = get_future_datetime() if with_time else get_future_date()
        MAX_ITERATIONS -= 1

    return future_date


class InvalidationReasonFactory(DjangoModelFactory):
    mhp = SubFactory(DoctorFactory)
    created_by = SubFactory(UserFactory)
    is_resolved = False
    resolved_by = SubFactory(UserFactory)

    class Meta:
        model = InvalidationReason


class VerificationReportFactory(DjangoModelFactory):
    mp = SubFactory(DoctorFactory)
    report = {}

    class Meta:
        model = VerificationReport
