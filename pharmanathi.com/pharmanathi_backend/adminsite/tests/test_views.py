import pytest

from pharmanathi_backend.users.api.serializers import UserSerializer

pytestmark = pytest.mark.django_db


def test_admisite_redirect_to_login_if_not_authed(web_client):
    res = web_client.get("/custom-admin/MHPs/unverified/")
    assert res.status_code == 302


def test_home_stats(staff_web_client, unverified_mhp_client):
    # unverified_mhp_client is used to generate an exisiting MP
    res = staff_web_client.get("/custom-admin/")
    print(dir(res), res.context.get("stats"))
    # atests staff has access to site
    assert res.status_code == 200

    # stats tests
    assert res.context.get("stats").get("unverifed_mhps") == 1


def test_unverified_mhps_view(staff_web_client, unverified_mhp_client, verified_mhp_client):
    verified_mp_user = verified_mhp_client.user
    unverified_mp_user = unverified_mhp_client.user
    res = staff_web_client.get("/custom-admin/MHPs/unverified/")
    assert res.status_code == 200
    # unverified MP in response's context
    assert {
        "id": unverified_mp_user.doctor_profile.id,
        "user__email": unverified_mp_user.email,
        "user__id": unverified_mp_user.id,
        "user__first_name": unverified_mp_user.first_name,
        "user__last_name": unverified_mp_user.last_name,
    } in res.context.get("unverified_mhps")
    # verified MP not in response
    assert {
        "id": verified_mp_user.doctor_profile.id,
        "user__email": verified_mp_user.email,
        "user__id": verified_mp_user.id,
        "user__first_name": verified_mp_user.first_name,
        "user__last_name": verified_mp_user.last_name,
    } not in res.context.get("unverified_mhps")


def test_user_detail_view(staff_web_client, user):
    res = staff_web_client.get(f"/custom-admin/users/detail/{user.id}/")
    assert res.status_code == 200
    assert res.context.get("user") == UserSerializer(user).data


def test_validate_mhp_profile(staff_web_client, unverified_mhp_client):
    # @TODO: test that notification instruction was triggered
    mhp_profile = unverified_mhp_client.user.doctor_profile
    assert mhp_profile.is_verified is False
    res = staff_web_client.get(f"/custom-admin/MHPs/actions/{mhp_profile.id}/mark-verified/")
    assert res.status_code == 200
    mhp_profile.refresh_from_db(fields=["_is_verified"])
    assert mhp_profile.is_verified is True


def test_invalidate_mhp_profile(staff_web_client, verified_mhp_client):
    # @TODO: test that notification instruction was triggered
    mhp_profile = verified_mhp_client.user.doctor_profile
    assert mhp_profile.is_verified is True
    res = staff_web_client.get(f"/custom-admin/MHPs/actions/{mhp_profile.id}/invalidate/")
    assert res.status_code == 200
    mhp_profile.refresh_from_db(fields=["_is_verified"])
    assert mhp_profile.is_verified is False

