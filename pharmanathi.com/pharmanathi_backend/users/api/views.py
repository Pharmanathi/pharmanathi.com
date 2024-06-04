from datetime import datetime

from allauth.account import app_settings as allauth_account_settings
from allauth.socialaccount.helpers import complete_social_login
from allauth.socialaccount.providers.google.provider import GoogleProvider
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from dj_rest_auth.registration.serializers import SocialLoginSerializer
from dj_rest_auth.registration.views import SocialLoginView
from django.contrib.auth import get_user_model
from django.db import IntegrityError
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

from pharmanathi_backend.utils import user_is_doctor

from ..models import Address, Doctor, PracticeLocation, Speciality
from .serializers import (
    AddressModelSerializer,
    DoctorModelSerializer,
    DoctorPublicListSerializer,
    PracticeLocationModelSerializer,
    SpecialityModelSerializer,
    UserSerializer,
)

User = get_user_model()


class UserViewSet(RetrieveModelMixin, ListModelMixin, UpdateModelMixin, GenericViewSet):
    serializer_class = UserSerializer
    queryset = User.objects.all().prefetch_related("doctor_profile")
    lookup_field = "pk"

    def get_queryset(self, *args, **kwargs):
        assert isinstance(self.request.user.id, int)
        return self.queryset.filter(id=self.request.user.id)

    @action(detail=False)
    def me(self, request):
        serializer = UserSerializer(request.user, context={"request": request})
        return Response(status=status.HTTP_200_OK, data=serializer.data)


class DoctorModelViewSet(ModelViewSet):
    serializer_class = DoctorModelSerializer
    queryset = Doctor.objects.all()
    permission_classes = [permissions.IsAdminUser]

    def get_serializer_class(self):
        if user_is_doctor(self.request):
            return super().get_serializer_class()

        print(Doctor.objects.all())
        return DoctorPublicListSerializer

    @action(detail=True, methods=["GET"])
    @permission_classes_decorator([permissions.IsAuthenticated])
    def availability(self, request, pk=None):
        """Returns available timeslots for a particular date"""
        date_str = request.GET.get("d", None)
        if date_str is None or date_str == "":
            return Response({"detail": "Missing 'd' parameter from request of the form d=DD/MM/YYYY"}, status=400)

        try:
            appointment_date = datetime.strptime(date_str, "%d/%m/%Y")
        except ValueError:
            return Response({"detail": "Invalid date format. Use DD/MM/YYYY"}, status=400)

        doctor: Doctor = super().get_object()
        duration = doctor.appointmenttype_set.first().duration  # Since we're restricting them to one App. Type
        return Response(doctor.get_available_slots_on(appointment_date, duration))


class PublicDoctorModelViewSet(DoctorModelViewSet):
    queryset = Doctor.objects.all()  # TODO: filter(is_verified=True)
    permission_classes = [permissions.IsAuthenticated]


class SpecialityModelViewset(RetrieveModelMixin, ListModelMixin, GenericViewSet):
    serializer_class = SpecialityModelSerializer
    queryset = Speciality.objects.all()


class AddressModelViewset(ModelViewSet):
    queryset = Address.objects.all()
    serializer_class = AddressModelSerializer


class PracticeLocationModelViewset(ModelViewSet):
    serializer_class = PracticeLocationModelSerializer

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
            Doctor.objects.get_or_create(user=user)

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
