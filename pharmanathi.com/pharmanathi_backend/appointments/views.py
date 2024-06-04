from datetime import timedelta

from rest_framework import mixins, permissions, status, viewsets
from rest_framework.exceptions import APIException
from rest_framework.response import Response

from pharmanathi_backend.utils import user_is_doctor

from . import serializers

models = serializers.models


class AppointmentTypeViewSet(viewsets.ModelViewSet):
    serializer_class = serializers.AppointmentTypeSerializer
    queryset = models.AppointmentType.objects.all()

    class NonOnlineException(APIException):
        default_detail = "Only online appointments are posible at the moment."
        default_code = "on_online_appointment_type"
        status_code = status.HTTP_400_BAD_REQUEST

    class DisabledOnlineAppointmentTypeException(APIException):
        default_detail = "Online appointments are currently disabled."
        default_code = "online_appointment_disabled"
        status_code = status.HTTP_400_BAD_REQUEST

    class EndDatedImmortalType(APIException):
        default_detail = (
            "A type of appointment that runs forever cannot have an end date. Please exclude it from your payload"
        )
        default_code = "end_dated_immortal_appointment_type"
        status_code = status.HTTP_400_BAD_REQUEST

    class InvalidDateRange(APIException):
        default_detail = "Invalid appoitment type date range"
        default_code = "end_dated_immortal_appointment_type"
        status_code = status.HTTP_400_BAD_REQUEST

    def get_serializer_class(self):
        if self.request.method == "POST":
            return serializers.AppointmentTypeWithEditableDoctorSerializer
        return self.serializer_class

    def get_queryset(self):
        # Since we're only allowing one type per MHP, this queryset should filter the result to
        # the connected MHP's type
        qs = super().get_queryset()
        if self.request.user.is_doctor:
            return qs.filter(doctor=self.request.user.doctor_profile)
        return qs  # @TODO: we must filter to the doctor being viewed

    def create(self, request):
        # As things stand, we will be updating the one and only type
        # that each doctor is allowed to have for now.
        existing_type = models.AppointmentType.objects.filter(doctor=self.request.user.doctor_profile)
        if existing_type.exists():
            serialized_app_type = self.get_serializer(existing_type.first(), data=request.data)
        else:
            serialized_app_type = self.get_serializer(data=request.data)

        # Serializer data validation
        serialized_app_type.is_valid(raise_exception=True)

        # Business validations
        # We only accept in-preson visits for now
        if serialized_app_type.validated_data["is_online"] is True:
            raise self.DisabledOnlineAppointmentTypeException()

        # if run forever, explicitely revoke end_date
        if serialized_app_type.validated_data["is_run_forever"] and serialized_app_type.validated_data.get(
            "end_date", None
        ):
            raise self.EndDatedImmortalType()
        else:
            # end_date is greater than start date
            if not serialized_app_type.validated_data["is_run_forever"] and (
                serialized_app_type.validated_data.get("end_date", None)
                < serialized_app_type.validated_data.get("start_date", None)
            ):
                raise self.InvalidDateRange()

        serialized_app_type.save()
        return Response(serialized_app_type.data)


class TimeSlotViewSet(mixins.ListModelMixin, mixins.UpdateModelMixin, viewsets.GenericViewSet):
    queryset = models.TimeSlot.objects.all().order_by("day")
    serializer_class = serializers.TimeSlotSerializer

    class InvalidStartTime(APIException):
        default_detail = "Invalid start time. Must come before end time."
        default_code = "invalid_start_time"
        status_code = status.HTTP_400_BAD_REQUEST

    class ExpectListOfTimeSlots(APIException):
        default_detail = "Must submit a list of timeslot. This list will replace the existing timeslots"
        default_code = "expected_list_of_timeslots"
        status_code = 400

    def get_queryset(self):
        # Since we're only allowing one type per MHP, this queryset should filter the result to
        # the connected MHP's type
        qs = super().get_queryset()
        if self.request.user.is_doctor:
            return qs.filter(doctor=self.request.user.doctor_profile)
        return qs  # @TODO: we must filter to the doctor being viewed

    def create(self, request):
        """We only allow submitting a list that will replace the current configuration."""
        post_data = request.data
        if not isinstance(post_data, list):
            raise self.ExpectListOfTimeSlots()

        self.queryset.delete()

        post_data = [{**timeslot, "doctor": self.request.user.doctor_profile.id} for timeslot in post_data]
        sz_timeslot = self.serializer_class(data=post_data, many=True)
        sz_timeslot.is_valid(raise_exception=True)

        sz_timeslot.save()
        return Response(sz_timeslot.data, status=status.HTTP_201_CREATED)


class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = models.Appointment.objects.all()
    serializer_class = serializers.AppointmentSerializer

    def get_serializer(self, *args, **kwargs):
        if self.request.method in permissions.SAFE_METHODS:
            return serializers.AppointmentPublicSerializer(*args, **kwargs)

        return super().get_serializer(*args, **kwargs)

    def get_queryset(self):
        if user_is_doctor(self.request):
            return self.queryset.filter(doctor__user=self.request.user)

        return self.queryset.filter(patient=self.request.user)

    def create(self, request):
        # Get the MHP's unique ppointment type
        # This value overrides anything selected on the user side since right now
        # we only allow one appointment type per MHP
        appointment_type = models.AppointmentType.objects.get(doctor__id=request.data.get("doctor"))
        prepared_appointment_data = {
            **request.data,
            "appointment_type": appointment_type.id,
            "patient": request.user.id,
        }
        sz_appointment = self.get_serializer(data=prepared_appointment_data)
        sz_appointment.is_valid(raise_exception=True)

        # Ensure selected timeslot is among the list of available slots
        # Make request to /api/doctor/:id/availability to verify that the selected
        # timeslot is valid
        selected_timeslot_datetime = sz_appointment.validated_data["start_time"]
        selected_timeslot = (
            selected_timeslot_datetime.strftime("%H:%M"),
            (
                selected_timeslot_datetime
                + timedelta(minutes=sz_appointment.validated_data["appointment_type"].duration)
            ).strftime("%H:%M"),
        )
        available_slots = appointment_type.doctor.get_available_slots_on(
            selected_timeslot_datetime.date(), appointment_type.duration
        )

        if selected_timeslot not in available_slots:
            return Response({"detail": "Selected timeslot is unavailable"}, status=400)

        sz_appointment.save()
        return Response(serializers.AppointmentPublicSerializer(sz_appointment.instance).data, status=201)
