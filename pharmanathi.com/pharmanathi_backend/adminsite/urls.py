from django.urls import path
from pharmanathi_backend.adminsite import views as adminviews

urlpatterns = [path("", view=adminviews.main, name="admin-home")]
