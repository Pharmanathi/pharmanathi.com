from django.contrib.auth import get_user_model
from rest_framework import serializers

from pharmanathi_backend.users.models import Address, Doctor, InvalidationReason, PracticeLocation, Speciality
from pharmanathi_backend.users.models import User as UserType
from pharmanathi_backend.users.models import VerificationReport

User = get_user_model()


class InvalidationReasonSerializer(serializers.ModelSerializer):
    text_unquoted = serializers.CharField(read_only=True)

    class Meta:
        model = InvalidationReason
        fields = "__all__"
        ordering = ["-date_created", "is_resolved", "date_modified", "text_unquoted"]


class VerificationReportSerializer(serializers.ModelSerializer):
    summary = serializers.CharField(read_only=True)

    class Meta:
        model = VerificationReport
        fields = "__all__"
        ordering = ["-date_created"]


class SimpleSpecialityModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Speciality
        fields = ["id", "name"]


class DoctorProfileSerializer(serializers.ModelSerializer):
    specialities = SimpleSpecialityModelSerializer(many=True)
    invalidationreason_set = InvalidationReasonSerializer(many=True, read_only=True)
    is_verified = serializers.BooleanField(read_only=True)
    verification_reports = VerificationReportSerializer(many=True)

    class Meta:
        model = Doctor
        exclude = ["user", "date_created"]


class UserSerializer(serializers.ModelSerializer[UserType]):
    is_doctor = serializers.BooleanField(read_only=True)
    doctor_profile = DoctorProfileSerializer(read_only=True)

    class Meta:
        model = User
        exclude = ["password", "groups", "name", "_profile_pic"]
        extra_kwargs = {
            "url": {"view_name": "api:user-detail", "lookup_field": "pk"},
        }


class UserSerializerSimplified(UserSerializer):
    is_doctor = serializers.BooleanField(read_only=True)

    class Meta:
        model = User
        fields = ["first_name", "last_name", "contact_no", "initials", "title", "id"]


class DoctorModelSerializer(serializers.ModelSerializer):
    is_verified = serializers.BooleanField(read_only=True)
    specialities = SimpleSpecialityModelSerializer(many=True)

    class Meta:
        model = Doctor
        exclude = ["date_created"]


class DoctorPublicListSerializer(DoctorModelSerializer):
    user = UserSerializerSimplified()
    has_consulted_before = serializers.SerializerMethodField()

    def get_has_consulted_before(self, obj):
        request = self.context.get("request", None)
        if request and request.user:
            return obj.has_consulted_before(request.user.id)
        return False

    def to_representation(self, instance):
        from pharmanathi_backend.appointments.models import AppointmentType
        from pharmanathi_backend.appointments.serializers import AppointmentTypeSerializer

        repr = super().to_representation(instance)
        return {
            **repr,
            "appointment_types": AppointmentTypeSerializer(
                AppointmentType.objects.filter(doctor=repr.get("id")), many=True
            ).data,
        }

    class Meta:
        model = Doctor
        fields = ["user", "is_verified", "specialities", "practicelocations", "id", "has_consulted_before"]


class DoctorAppointmentSerializer(DoctorPublicListSerializer):
    user = UserSerializerSimplified()

    class Meta:
        model = Doctor
        fields = [
            "user",
            "specialities",
        ]


class SpecialityModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Speciality
        fields = "__all__"


class AddressModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = "__all__"


class PracticeLocationModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = PracticeLocation
        fields = "__all__"


class PracticeLocationModelSerializerWithExtAddress(serializers.ModelSerializer):
    address = AddressModelSerializer()

    class Meta:
        model = PracticeLocation
        fields = "__all__"
