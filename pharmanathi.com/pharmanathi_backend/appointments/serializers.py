from rest_framework import serializers

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

class SimplifiedAppointmentTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AppointmentType
        fields = ['id', 'is_online'] 


class AppointmentPublicSerializer(AppointmentSerializer):
    doctor = DoctorPublicListSerializer()
    patient = UserSerializerSimplified()
    appointment_type = SimplifiedAppointmentTypeSerializer()

    class Meta:
        model = models.Appointment
        fields = "__all__"
        # exclude = ["doctor__practicelocations"]
