from rest_framework.serializers import ModelSerializer, SerializerMethodField

from .models import Payment


class PaymentModelSerializer(ModelSerializer):
    provider = SerializerMethodField()

    def get_provider(self, obj):
        return obj.provider.name

    class Meta:
        model = Payment
        fields = ["provider", "user", "status"]
