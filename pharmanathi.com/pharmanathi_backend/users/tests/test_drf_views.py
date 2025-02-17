import pytest
from rest_framework.test import APIRequestFactory

from pharmanathi_backend.users.api.views import UserViewSet
from pharmanathi_backend.users.models import User


class TestUserViewSet:
    @pytest.fixture
    def api_rf(self) -> APIRequestFactory:
        return APIRequestFactory()

    def test_get_queryset(self, user: User, api_rf: APIRequestFactory):
        view = UserViewSet()
        request = api_rf.get("/fake-url/")
        request.user = user

        view.request = request

        assert user in view.get_queryset()

    def test_me(self, user: User, api_rf: APIRequestFactory):
        view = UserViewSet()
        request = api_rf.get("/fake-url/")
        request.user = user

        view.request = request

        response = view.me(request)  # type: ignore

        assert response.data.get("id", None) == user.id
        # {
        #     "url": f"http://testserver/api/users/{user.pk}/",
        #     "name": user.name,
        # }
