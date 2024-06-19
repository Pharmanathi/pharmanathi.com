from django.urls import path

from pharmanathi_backend.adminsite import views as adminviews

urlpatterns = [
    path("", view=adminviews.main, name="customadminsite-home"),
    # --------------------- MHPs ---------------------#
    path("MHPs/unverified/", view=adminviews.list_unverified_mhps, name="customadminsite-mhps-unverified"),
    path("MHPs/<int:mhp_id>/mark-verified/", view=adminviews.validate_mhp_profile),
    path("MHPs/<int:mhp_id>/invalidate/", view=adminviews.invalidate_mhp_profile),
    # --------------------- Invalidation Reasons ---------------------#
    path("IRs/<int:ir_id>/resolve/", view=adminviews.resolve_invalidation_reason),
    # --------------------- Users ---------------------#
    path("users/detail/<int:user_id>/", view=adminviews.get_user_detail, name="customadminsite-user-detail"),
]
