from django.conf import settings
from django.urls import path
from rest_framework.routers import DefaultRouter, SimpleRouter

from pharmanathi_backend.appointments.views import AppointmentTypeViewSet, AppointmentViewSet, TimeSlotViewSet
from pharmanathi_backend.users.api.views import (
    AddressModelViewset,
    GoogleLoginView,
    PracticeLocationModelViewset,
    PublicDoctorModelViewSet,
    SpecialityModelViewset,
    UserViewSet,
)

if settings.DEBUG:
    router = DefaultRouter()
else:
    router = SimpleRouter()

router.register("users", UserViewSet)
router.register("doctors", PublicDoctorModelViewSet)
router.register("specialities", SpecialityModelViewset)
router.register("addresses", AddressModelViewset)
router.register("practice-locations", PracticeLocationModelViewset, "practicelocations")
router.register("appointment-types", AppointmentTypeViewSet, "appointment-types")
router.register("timeslots", TimeSlotViewSet, "timeslots")
router.register("appointments", AppointmentViewSet, "appointments")


app_name = "api"
urlpatterns = router.urls + [path("google-login-by-id-token/", GoogleLoginView.as_view())]
