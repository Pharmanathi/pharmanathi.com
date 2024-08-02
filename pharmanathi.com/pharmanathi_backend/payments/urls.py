from django.urls import path

from .views import cb

urlpatterns = [path("cb/<str:provider>", cb)]
