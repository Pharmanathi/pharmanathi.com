import copy
from decimal import Decimal

from ...models import Payment
from ..provider import CashProvider, register_provider

__all__ = ["PaystackProvider"]


@register_provider
class PaystackProvider(CashProvider):
    name = "Paystack"

    def parse_initalization_request_data(self, **kwargs):
        assert kwargs is not None, "Paystack.parse_initalization_request_data expects a dict argument"
        assert (
            "email" in kwargs and "amount" in kwargs
        ), "Paystack.parse_initalization_request_data expects a dict that includes the keys (email, amount)"
        return kwargs.get("email"), Decimal(kwargs.get("amount"))

    def parse_intialization_response(self, response_data):
        if response_data.get("status") is False:
            raise ValueError(response_data.get("message"))

        response_data_copy = copy.deepcopy(response_data)
        data = response_data_copy.get("data")
        reference = data.pop("reference")
        authorization_url = data.pop("authorization_url")
        ret = (reference, authorization_url, data)
        if None in ret:
            raise KeyError("reponse_data['data'] must have a ``reference`` and ``authorization_url``")
        return ret

    def build_initialization_req_body(self, **kwargs):
        assert self.callback_url is not None
        email, amount = self.parse_initalization_request_data(**kwargs)
        decimal_amount = Decimal(amount)
        return {
            "email": email,
            "amount": str(decimal_amount * 100),  # https://paystack.com/docs/api/#supported-currency
            "callback_url": self.callback_url,
        }

    def make_payment_instance(self, reverse_lookup_field, amount, user, reference) -> Payment:
        return Payment.objects.create(
            reverse_lookup_field=reverse_lookup_field,
            amount=amount,
            user=user,
            reference=reference,
            _provider=self.name,
        )

    def process_payment(self, cb_request_data: dict):
        payment = self.get_payment_by_reference(cb_request_data.get("data").get("reference"))
        old_status = payment.status

        status = cb_request_data.get("data").get("status")
        if status == "success":
            payment.set_status_paid()
        else:
            payment.set_status_failed()

        payment.json = cb_request_data
        payment.save()
        self.execute_callback(payment, old_status)

    def get_payment_feedback(self, payment) -> str:
        if type(payment.json.get("data").get("log")) is dict and "history" in payment.json.get("data").get("log"):
            logs = payment.json.get("data").get("log").get("history")
            logs.sort(key=lambda l: l.get("time"))
            return logs[-1].get("message")
        else:
            return payment.json.get("data").get("status")

    def parse_callback_data(data: dict) -> dict:
        return {
            "reference": data.get("data").get("reference"),
            "status": data.get("data").get("status"),
            "amount": int(data.get("data").get("amount")) / 100,
            "user": data.get("data").get("customer"),
        }
