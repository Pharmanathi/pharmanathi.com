import factory.fuzzy
from factory import SubFactory
from factory.django import DjangoModelFactory

from pharmanathi_backend.payments.models import Payment
from pharmanathi_backend.payments.providers.provider import get_all_providers
from pharmanathi_backend.users.tests.factories import UserFactory


class PaymentFactory(DjangoModelFactory):
    amount = factory.fuzzy.FuzzyDecimal(100.00, 9999.99, precision=2)
    status = factory.fuzzy.FuzzyChoice(Payment.PaymentStatus)
    _provider = factory.fuzzy.FuzzyChoice(get_all_providers())
    user = SubFactory(UserFactory)
    reference = factory.fuzzy.FuzzyText()
    json = {}
    reverse_lookup_field = factory.fuzzy.FuzzyText(length=100)

    class Meta:
        model = Payment
