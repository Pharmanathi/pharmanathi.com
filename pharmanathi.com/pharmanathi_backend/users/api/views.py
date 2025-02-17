from datetime import datetime
from threading import Thread

from allauth.account import app_settings as allauth_account_settings
from allauth.socialaccount.helpers import complete_social_login
from allauth.socialaccount.providers.google.provider import GoogleProvider
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from dj_rest_auth.registration.serializers import SocialLoginSerializer
from dj_rest_auth.registration.views import SocialLoginView
from django.contrib.auth import get_user_model
from django.db import IntegrityError, transaction
from django.db.models import Exists, OuterRef, Prefetch
from django.http import HttpResponseBadRequest
from google.auth.transport import requests
from google.oauth2 import id_token
from rest_framework import permissions, serializers, status
from rest_framework.decorators import action
from rest_framework.decorators import permission_classes as permission_classes_decorator
from rest_framework.exceptions import APIException
from rest_framework.mixins import ListModelMixin, RetrieveModelMixin, UpdateModelMixin
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet, ModelViewSet

from pharmanathi_backend.appointments.models import AppointmentType
from pharmanathi_backend.appointments.serializers import DoctorPublicListMinimalSerializer
from pharmanathi_backend.utils import user_is_doctor

from ..models import Address, Doctor, InvalidationReason, PracticeLocation, Speciality, VerificationReport
from .serializers import (
    AddressModelSerializer,
    DoctorModelSerializer,
    DoctorPublicListSerializer,
    PracticeLocationModelSerializerWithExtAddress,
    SpecialityModelSerializer,
    UserSerializer,
)

User = get_user_model()


class UserViewSet(RetrieveModelMixin, ListModelMixin, UpdateModelMixin, GenericViewSet):
    serializer_class = UserSerializer
    queryset = User.objects.all().prefetch_related(
        "doctor_profile",
        "doctor_profile__invalidationreason_set",
        "doctor_profile__verification_reports",
        "doctor_profile__specialities",
    )
    lookup_field = "pk"

    def get_queryset(self, *args, **kwargs):
        assert isinstance(self.request.user.id, int)
        return self.queryset.filter(id=self.request.user.id)

    @action(detail=False)
    def me(self, request):
        # Due to the nature of the /api/users/me, the user requesting
        # data about themselves has low chances of needing to see:
        #   - Invalidation reasons that have been resolved(the client will
        #     generally only need to inform them of pending issues)
        #   - Verificaition reports. Those are for use only.
        serializer = UserSerializer(
            User.objects.filter(pk=request.user.pk)
            .prefetch_related(
                Prefetch(
                    "doctor_profile__invalidationreason_set",
                    queryset=InvalidationReason.objects.select_related()
                    .filter(is_resolved=False)
                    .order_by("date_created"),
                ),
                Prefetch(
                    "doctor_profile__verification_reports",
                    queryset=VerificationReport.objects.filter(mp=0),
                ),
            )
            .first(),
            context={"request": request},
        )
        return Response(status=status.HTTP_200_OK, data=serializer.data)


class DoctorModelViewSet(ModelViewSet):
    serializer_class = DoctorModelSerializer
    queryset = Doctor.objects.prefetch_related("user", "practicelocations", "specialities").all()
    permission_classes = [permissions.IsAdminUser]

    def get_serializer_class(self):
        if user_is_doctor(self.request):
            return super().get_serializer_class()
        elif self.request.user.is_staff:
            return DoctorPublicListSerializer
        return DoctorPublicListMinimalSerializer

    @action(detail=True, methods=["GET"])
    @permission_classes_decorator([permissions.IsAuthenticated])
    def availability(self, request, pk=None):
        """Returns available timeslots for a particular date"""
        date_str = request.GET.get("d", None)
        if date_str is None or date_str == "":
            return Response({"detail": "Missing 'd' parameter from request of the form d=DD/MM/YYYY"}, status=400)

        try:
            appointment_datetime = datetime.strptime(date_str, "%d/%m/%Y")
        except ValueError:
            return Response({"detail": "Invalid date format. Use DD/MM/YYYY"}, status=400)

        doctor: Doctor = super().get_object()
        duration = doctor.appointmenttype_set.first().duration  # Since we're restricting them to one App. Type
        return Response(doctor.get_available_slots_on(appointment_datetime, duration))

    def partial_update(self, request, *args, **kwargs):
        # TODO: move some of this logic close to model, e.g: update from_http_request()
        doctor = self.get_object()
        data = request.data.copy()
        should_update_specialities = False
        should_update_practice_locations = False
        # Dealing with nested relationships requires custom handling.
        # Hence, if any of `specialities` or `practice_locations` is
        # present in the payload, we will extract them to be processed
        # separately. If the Model ever changes to include or remove
        # a nested realtionship, this code might require reviewing.
        if "specialities" in data:
            # expects a list of PKs, not a dictionary
            data_specialities = data.pop("specialities")
            if len(list(filter(lambda s: type(s) != int, data_specialities))) > 0:
                # TODO: log client_name and issue
                return Response({"detail": "List of specialities must only contain integers"}, 400)

            specialities = Speciality.objects.filter(pk__in=data_specialities)
            if specialities.exists() is False or specialities.count() != len(data_specialities):
                # TODO: log client_name and issue
                return Response({"detail": "Speciality not found"}, 404)

            should_update_specialities = True

        if "practice_locations" in data:
            # On this one, we handle newly created practice locations or
            # those that already exists. Hence, the list practice_locations
            # can contain:
            #     - int: an integer pointing to an existing practice location
            #     - dict: a payload representing a new practice practice location
            practice_locations = []
            practice_locations_data = data.pop("practice_locations")
            requested_locations_list = list(filter(lambda l: type(l) == int, practice_locations_data))
            found_locations = PracticeLocation.objects.filter(pk__in=requested_locations_list)
            if requested_locations_list:
                if len(requested_locations_list) != found_locations.count():
                    # TODO: log client_name and issue
                    return Response({"detail": "Practice Location not found"}, 404)

            new_locations = list(filter(lambda l: type(l) == dict, practice_locations_data))
            pl_serializer = PracticeLocationModelSerializerWithExtAddress(data=new_locations, many=True)
            pl_serializer.is_valid(raise_exception=True)
            should_update_practice_locations = True

        with transaction.atomic():
            if should_update_specialities:
                doctor.update_specialities(list(specialities))

            if should_update_practice_locations:
                pl_serializer.save()
                practice_locations = practice_locations + list(pl_serializer.instance)
                doctor.update_practice_locations(practice_locations)

            # update the Doctor model instance if anything left
            if data:
                doctor_serializer = self.get_serializer_class()(doctor, data=data, partial=True)
                doctor_serializer.is_valid(raise_exception=True)
                doctor_serializer.save()

        doctor = Doctor.objects.prefetch_related("practicelocations", "specialities", "user").get(pk=doctor.pk)
        return Response(self.get_serializer_class()(doctor).data)


class PublicDoctorModelViewSet(DoctorModelViewSet):
    queryset = Doctor.objects.filter(
        Exists(AppointmentType.objects.filter(doctor=OuterRef("pk"))), _is_verified=True
    ).prefetch_related("user", "practicelocations", "specialities", "appointmenttype_set")
    permission_classes = [permissions.IsAuthenticated]

    # def get_serializer_class(self):
    #     return DoctorPublicListMinimalSerializer

    def get_queryset(self):
        if user_is_doctor(self.request):
            # Because we would like to allow non-verified doctors to update their details
            # At the same time, we are only returning a queryset that will always return
            # only them as existing Doctor. They would know about other doctors his way.
            return Doctor.objects.filter(pk=self.request.user.doctor_profile.id)

        return super().get_queryset()


class SpecialityModelViewset(RetrieveModelMixin, ListModelMixin, GenericViewSet):
    serializer_class = SpecialityModelSerializer
    queryset = Speciality.objects.all()


class AddressModelViewset(ModelViewSet):
    queryset = Address.objects.all()
    serializer_class = AddressModelSerializer


class PracticeLocationModelViewset(ModelViewSet):
    serializer_class = PracticeLocationModelSerializerWithExtAddress

    def get_queryset(self):
        is_doctor = self.request.user.doctor

        if is_doctor:
            return self.request.user.doctor.practicelocations

        return PracticeLocation.objects.filter(doctor__is_verfied=True)


class CustomSocialLoginSerializer(SocialLoginSerializer):
    def validate(self, attrs):
        view = self.context.get("view")
        request = self._get_request()

        if not view:
            raise serializers.ValidationError("View is not defined, pass it as a context variable")

        adapter_class = getattr(view, "adapter_class", None)
        if not adapter_class:
            raise serializers.ValidationError("Define adapter_class in view")

        adapter = adapter_class(request)
        social_app_name = request.headers.get("auth-app")
        adapter.default_app = social_app_name
        app = adapter.default_app
        google_provider = GoogleProvider(request, app)
        access_token = request.GET["id_token"]
        sign_as_doctor = request.GET.get("is_doctor", None)  # Cause we don't always expect this
        sign_as_doctor = True if sign_as_doctor and sign_as_doctor.lower() == "true" else False

        # You cannot be a doctor and auth with an Auth App that's not *_mhp_*
        if sign_as_doctor and "_mhp_" not in social_app_name:
            return Response({"detail": "Invalid app for current profile"}, 403)

        if not access_token:
            raise APIException("access_token or code is required.", code=400)

        tokens_to_parse = {"access_token": access_token}
        social_token = adapter.parse_token(tokens_to_parse)
        social_token.app = app
        idinfo = id_token.verify_oauth2_token(access_token, requests.Request(), app.client_id)

        login = google_provider.sociallogin_from_response(request, idinfo)
        # we force the assignment of the provider with the selected app so that
        # no arbitrary/app-empty provider will be selected later causing a MultipleObjectReturned later
        setattr(login.account, "_provider", google_provider)
        ret = complete_social_login(request, login)
        if isinstance(ret, HttpResponseBadRequest):
            raise serializers.ValidationError(ret.content)

        if not login.is_existing:
            # We have an account already signed up in a different flow
            # with the same email address: raise an exception.
            # This needs to be handled in the frontend. We can not just
            # link up the accounts due to security constraints
            if allauth_account_settings.UNIQUE_EMAIL:
                # Do we have an account already with this email address?
                account_exists = (
                    get_user_model()
                    .objects.filter(
                        email=login.user.email,
                    )
                    .exists()
                )
                if account_exists:
                    raise serializers.ValidationError("User is already registered with this e-mail address.")

            login.lookup()
            try:
                login.save(request, connect=True)
            except IntegrityError as ex:
                raise serializers.ValidationError(
                    "User is already registered with this e-mail address.",
                ) from ex
            self.post_signup(login, attrs)

        attrs["user"] = user = login.account.user

        # should they be signinng in or up as doctor, create their doctor profile
        if sign_as_doctor:
            new_mp, created = Doctor.objects.get_or_create(user=user)

            if created:
                from pharmanathi_backend.users.tasks import mail_admins_task

                message = "A new Medical Health Professional was registered."
                mail_admins_task.delay(
                    "New MHP registration",
                    message,
                    message,
                )
                # new_mp.run_auto_mp_verification_task()

        # Because Google profile picture's URL change.
        # TODO(nehemie): add tests
        user.update_picture_url(idinfo.get("picture"))
        Thread(target=user.update_device_token, args=[request.GET.get("device_token", "")]).start()

        return attrs


class CustomGoogleOAuth2Adapter(GoogleOAuth2Adapter):
    @property
    def default_app(self):
        return self._default_app

    @default_app.setter
    def default_app(self, app_name):
        """Allows setting a default apop to return in case of ambiguity.
        Ambiguity here is when the original implementation would return
        a MultipleObjectsReturned error
        """
        from allauth.socialaccount.models import SocialApp

        self._default_app = SocialApp.objects.get(name=app_name)

    def get_app(self, request, provider, client_id=None, app_name=None):
        from allauth.socialaccount.models import SocialApp

        if client_id is None:
            pass
        if app_name is None:
            pass
        apps = self.list_apps(request, provider=provider, client_id=client_id)
        if len(apps) > 1:
            return self.default_app
        elif len(apps) == 0:
            raise SocialApp.DoesNotExist()
        return apps[0]


class GoogleLoginView(SocialLoginView):
    adapter_class = CustomGoogleOAuth2Adapter
    serializer_class = CustomSocialLoginSerializer

    def get(self, request, *args, **kwargs):
        if request.query_params.get("id_token") is None:
            return Response({"detail": "Missing id_token query string parameter"}, status=400)

        if request.headers.get("auth-app") is None:
            return Response({"detail": "Missing social app header in token retrieval request."}, status=400)

        request.data["access_token"] = request.query_params.get("id_token")
        request.data["is_doctor"] = request.query_params.get("is_doctor", None)

        if "mhp" not in request.headers.get("auth-app") and request.data.get("is_doctor"):
            return Response({"detail": "Mismatch in query parameter and headers"}, status=400)

        return self.post(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        self.request = request
        self.serializer = self.get_serializer(data=self.request.data)
        self.serializer.is_valid(raise_exception=True)

        self.login()
        return self.get_response()
