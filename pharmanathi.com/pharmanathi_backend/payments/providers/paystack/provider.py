from ..provider import CashProvider, register_provider

__all__ = ["PaystackProvider"]


@register_provider
class PaystackProvider(CashProvider):
    class Meta:
        name = "Paystack"

    def parse_initalization_request_data(self, *args, **kwargs):
        assert kwargs is not None, "Paystack.parse_initalization_request_data expects a dict argument"
        assert (
            "email" in kwargs and "amount" in kwargs
        ), "Paystack.parse_initalization_request_data expects a dict of the form {email, amount}"
        return kwargs.get("email"), kwargs.get("amount")

    def build_initialization_req_body(self, *args, **kwargs):
        assert hasattr(self, "callback_url")
        email, amount = self.parse_initalization_request_data(*args, **kwargs)
        return {"email": email, "amount": amount, "callback_url": self.callback_url}

    def parse_intialization_response(self, response_data):
        if response_data.get("status") is False:
            raise ValueError(response_data.get("message"))

        data = response_data.get("data")
        return (data.get("reference"), data.get("authorization_url"), data.get("reference"))

    def process_payment(self, cb_request_data: dict):
        payment = self.get_payment_by_reference(cb_request_data.get("data").get("reference"))
        status = cb_request_data.get("data").get("status")
        if status == "success":
            payment.set_status_paid()
        else:
            payment.set_status_failed()

        payment.json = cb_request_data
        payment.save()
