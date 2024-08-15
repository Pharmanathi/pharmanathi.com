"""Code for base provider interface, a.k.a strategy
"""

import requests
from django.conf import settings


class BaseProvider:
    """
    This is the base class for any provider. It has a few subclass
    and concrete implementation inside the ``providers`` folder.
    For instance, one Provider; Pastack, can be found in the
    ``/providers/paystack/provider.py`` module. How does one work?

    ## Adding a new provider

    - You would start by creating a concrete implementation in the
    ``/providers` as a package or a module.
    - Next, make sure to decorate the class subclassing ``BaseProvider``
    or any of its subclass with the ``register_provider`` decorator.
    - Finally, inside ``payments/apps.py`` import the class to trigger
    the registration.

    ## Customizing a provider

    You customize a provider by either overriding its inherited im-
    plementation or by providing a configuration dictionary to the
    PAYMENT_PROVIDERS settings in your application's settings module.
    The entry inside settings.PAYMENT_PROVIDERS should look something like
    the following:

    ```
    "name": {
        key1: value1
        key2: value2,
    }
    ```

    During the registration process of a provider, should there exist an entry
    corresponding to a concrete provider's ``name`` attribute, the specified
    keys will be added as attribute to the class, with the specified values. This
    is implemented by the ``register_provider`` helper function in this module.

    @TODO:
    - Add tests to a good coverage level
    - Centraly handle app's configuration
    """

    name: str  # Provided by sublacss

    class ProviderValidationError(Exception):
        pass

    class UsageDeniedException(Exception):
        def __init__(self, provider_name, user_email) -> None:
            message = f"User '{user_email}' is not allowed to use the '{provider_name}' provider"
            super().__init__(message)

    def __init__(*args, **kwargs) -> None:
        pass

    def __str__(self):
        return f"<Provider: {self.name}>"

    def generate_reference(length=20):
        """Leaving this task to the providers for the time being

        Generate a reference number. Subclasses are free to override
        this method as long as they adhere to the Payment class constraints
        for a reference number

        Args:
            length (int, optional): _description_. Defaults to 20.
        """
        pass

    def initialize_payment(self, *args, **kwargs):
        """Initializes and return a payment instance as well
        as any extra info that may be necessary in a dictionary

        Raises:
            NotImplementedError: _description_

        Returns:
            tuple: (payment: Payment, extras: dict)
        """
        raise NotImplementedError()

    def process_payment(
        cb_request_data: dict,
    ):
        """Handle callback request from providers

        Args:
            cb_request_data (dict): body of the provider's callback
            request to the callback endpoint.

        Raises:
            NotImplementedError: _description_
        """
        raise NotImplementedError()

    @classmethod
    def validate_provider(cls, payment):
        """It is important to use this method whenever you
        are working with a payment instance to ensure it works
        with the right provider.

        Args:
            payment (_type_): _description_

        Raises:
            cls.ProviderValidationError: _description_
        """
        provider = payment.get_provider()
        if isinstance(provider, cls) is False:
            raise cls.ProviderValidationError

    @classmethod
    def _is_available_to_user(cls, user):
        raise NotImplementedError()

    @classmethod
    def is_available_to_user(cls, user, raise_exception=True):
        """Checks whether this provider can be used by the user
        making the payment. You must not override this method,
        rather overried ``_is_available_to_user`` with checks
        matching your use case.
        """
        user_can_use = cls._is_available_to_user(user)
        if user_can_use is False and raise_exception:
            raise cls.UsageDeniedException(cls.name, user.email)

        return user_can_use

    def get_payment_by_reference(self, reference: str):
        from ..models import Payment

        return Payment.objects.get(reference=reference)

    def execute_callback(self, payment, old_status):
        payment.callback(old_status)

    def get_payment_feedback(self, payment) -> str:
        """Return the feedback from Payment provider
        after processing the payment.

        Args:
            payment (Payment): the payment object to work
            with.

        Raises:
            NotImplementedError

        Returns:
            str: message from the provider
        """
        raise NotImplementedError()


class MedicalAidProvider(BaseProvider):
    """The idea here is, since this is a medical aid payment,
    as things stand, the MP will have to claim this payment directly
    from the provider, ``physically``.

    The best way to handle this type of might be provider
    all the required info for what the payment should bbe as well as
    setting it as "PAID".

    Args:
        payment_object (_type_): _description_

    Returns:
        _type_: _description_
    """

    pass


class CashProvider(BaseProvider):
    authorization: str  # provided by subclass
    callback_url: str  # provided by subclass
    initialization_url: str  # provided by subclass

    @classmethod
    def _is_available_to_user(self, user):
        return True  # available to all

    def get_intialization_data(self, request_body):
        assert hasattr(self, "initialization_url"), "%s has no ``initialization_url`` set." % self.name
        assert hasattr(self, "authorization"), "%s has no HTTP ``authorization`` key set." % self.name
        response: requests.Response = requests.post(
            self.initialization_url,
            headers={"Authorization": self.authorization},
            json=request_body,
        )
        response.raise_for_status()
        return response.json()

    def parse_intialization_response(self, response_data):
        """Implement this to extract:
        - the payment's reference
        - the payment URL to use by the client
        - any other data necessary to your provider. This thrid element
        should be a object with all remamining values or those that are
        worthy of keeping

        Your implementation should return a tuple with those 3 elements
        in the specified order otherwise you must also override
        self.initialize_payment() to process the data your way.

        This method also serves the role of protector against failed
        initializations. Your implementation should cater for failed
        transaction. See the Paystack implementation for more example.

        Args:
            response_data (_type_): JSON data typically from
            ``self.get_intialization_data()``

        Raises:
            NotImplementedError: _description_
        """
        raise NotImplementedError

    def parse_initalization_request_data(self, *args, **kwargs):
        """Responsible for parsing data passed to ``self.initialize_payment()``
        in order to get from it the additional info required to build a payment
        instance. This is left unimplemented so you can customize it according
        to your provider.

        The expected return value is a tuple that contains what's needed for
        building a Payment. The said tuple should take the following form:
            (user_email, amount)

        The value for Payment.provider as well as Payment.reference are supplied
        in the ``initialize_payment()`` method.
        """
        raise NotImplementedError()

    def build_initialization_req_body(self, *args, **kwargs):
        """Build the data body to be used as part of the HTPP request
        to initialize a payment. As with all the other stuff, this too
        is your responsibility.
        """
        raise NotImplementedError()

    def make_payment_instance(self, reverse_lookup_field, amount, user, reference):
        """Return a payment instance configured as per your provider. Override this method
        if your provider requires making changes that may have impacted the actual data.
        For instance, the Paystack provider requires sending amount in subunit, meaning:
            amount = amount * 100
        For such a provider, the payment amount has to be modified when sending it for
        initialization, and then used as was when saving the payment. To provide a common
        interface, each provider has the ability to override the ``build_initialization_req_body``
        method and pass it whatever values they want, and overried this ``make_payment_instance``
        to provide values that should go into the DB.

        You may wonder whether the apporach descibed above won't make it possible for
        provider to introduce discrepencies, well, that is alright, since the provider will
        inform us of the correct details once the payment has been made, details that will
        match what the user sees when making the payment.

        Args:
            amount (str|int|float|Decimal): Payment amount
            user (User): User making the payment
            reference (str): Payment reference

        Returns:
            Payment: newly created Payment instance


        """
        from pharmanathi_backend.payments.models import Payment

        return Payment.objects.create(
            reverse_lookup_field=reverse_lookup_field,
            amount=amount,
            user=user,
            reference=reference,
            _provider=self.name,
        )

    def initialize_payment(self, reverse_lookup_field, amount, email) -> tuple:
        """Intialize payment and return it along with the payment
        URL the client should redirect to to complete the payment process.

        Returns:
            tuple: (payment: Payment, payment_url: str)
            reverse_lookup_field (str): field use for reverse lookup
            on payment object.
        """
        from ..models import Payment

        email, amount = self.parse_initalization_request_data(**{"amount": amount, "email": email})
        user = Payment.get_user_by_email(email)
        intialization_req_body = self.build_initialization_req_body(**{"amount": amount, "email": email})
        reference, payment_url, _ = self.parse_intialization_response(
            self.get_intialization_data(intialization_req_body)
        )
        payment = self.make_payment_instance(reverse_lookup_field, amount, user, reference)
        return (payment, {"payment_url": payment_url})

    def parse_callback_data(data: dict) -> dict:
        """Can be utilized to parse data from callback requests
        from providers.

        Args:
            data (dict): i.e a POST request's body

        Returns:
            dict: _description_
        """
        raise NotImplementedError()


provider_registry = {}


class ProviderNotFoundException(Exception):
    def __init__(self, lookup_name):
        message = "Provider '{}' does not exist. Valid choices are '{}' ".format(
            lookup_name,
            ", ".join(provider_registry.keys()),
        )
        super().__init__(message)


def register_provider(f):
    """A decorator for registering available providers.
    The registry is nothing else than the `provider_registry` object
    mapping provider name to their related class.
    """
    assert f.name is not None and hasattr(
        f, "name"
    ), f"Invalid provider `{f.__name__}`. Did you forget to set its ``name``?"

    def _register_provider(f):
        provider_name = f.name
        provider_registry[provider_name] = f

        if settings.PAYMENT_PROVIDERS and provider_name in settings.PAYMENT_PROVIDERS:
            for k, v in settings.PAYMENT_PROVIDERS.get(provider_name).items():
                setattr(f, k, v)

        return f

    return _register_provider(f)


def check_provider_exists(name: str) -> bool:
    return name in provider_registry.keys()


def get_provider(name: str) -> BaseProvider:
    """Returns an instance of the specified provider if exists,
    otherwise returns a ``ProviderNotFoundException`` error."""
    provider_klass = provider_registry.get(name, None)
    if provider_klass is None:
        raise ProviderNotFoundException(name)
    return provider_klass()


def get_all_providers() -> list:
    return provider_registry.keys()


class EFTProvider(CashProvider):
    pass


class CardProvider(CashProvider):
    pass
