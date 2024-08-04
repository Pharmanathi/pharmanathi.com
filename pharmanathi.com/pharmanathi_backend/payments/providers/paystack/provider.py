import copy

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
        return kwargs.get("email"), kwargs.get("amount")

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
        return {"email": email, "amount": amount, "callback_url": self.callback_url}

    def process_payment(self, cb_request_data: dict):
        print("Hellllooooooooooo ----------->>>>")
        payment = self.get_payment_by_reference(cb_request_data.get("data").get("reference"))
        status = cb_request_data.get("data").get("status")
        if status == "success":
            payment.set_status_paid()
            print("saved the mother fuctker ----------->>>>")
        else:
            payment.set_status_failed()

        payment.json = cb_request_data
        payment.save()
