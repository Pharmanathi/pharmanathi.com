from ..provider import BaseProvider, register_provider

__all__ = ["PaystackProvider"]


@register_provider
class NHIProvider(BaseProvider):
    """The National Health Insurance"""

    class Meta:
        name = "NHI"
