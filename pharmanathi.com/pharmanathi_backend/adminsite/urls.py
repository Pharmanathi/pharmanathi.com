from django.urls import path
from pharmanathi_backend.adminsite import views as adminviews

urlpatterns = [
    path("", view=adminviews.main, name="customadminsite-home"),
    path("MHPs/unverified/", view=adminviews.unverified_mhps, name="customadminsite-mhps-unverified"),
    path("MHPs/actions/<int:mhp_id>/mark-verified/", view=adminviews.validate_mhp_profile),
    path("MHPs/actions/<int:mhp_id>/invalidate/", view=adminviews.invalidate_mhp_profile),
    path("users/detail/<int:user_id>/", view=adminviews.user_detail, name="customadminsite-user-detail"),
]
