from rest_framework import serializers

from pharmanathi_backend.payments.serializers import PaymentModelSerializer
from pharmanathi_backend.users.api.serializers import DoctorPublicListSerializer, UserSerializerSimplified

from . import models


class AppointmentTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AppointmentType
        fields = "__all__"
        extra_kwargs = {"doctor": {"read_only": True}}


class AppointmentTypeWithEditableDoctorSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AppointmentType
        fields = "__all__"


class TimeSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.TimeSlot
        fields = ["id", "day", "start_time", "end_time", "doctor"]


class AppointmentSerializer(serializers.ModelSerializer):
    end_time = serializers.DateTimeField(read_only=True)

    class Meta:
        model = models.Appointment
        fields = "__all__"


class AppointmentListTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AppointmentType
        fields = ["id", "is_online"]


class DoctorPublicListMinialSerializer(DoctorPublicListSerializer):
    specialities = serializers.SlugRelatedField(many=True, read_only=True, slug_field="name")

    class Meta:
        model = models.Doctor
        depth = 1
        fields = ["user", "specialities", "is_verified", "has_consulted_before", "id"]

    def to_representation(self, instance):
        return super(DoctorPublicListSerializer, self).to_representation(instance)


class AppointmentPublicSerializer(AppointmentSerializer):
    doctor = DoctorPublicListMinialSerializer()
    patient = UserSerializerSimplified()
    payment = PaymentModelSerializer()
    appointment_type = AppointmentListTypeSerializer(read_only=True)

    class Meta:
        model = models.Appointment
        fields = [
            "id",
            "end_time",
            "start_time",
            "doctor",
            "payment",
            "appointment_type",
            "reason",
            "payment_process",
            "patient",
        ]
