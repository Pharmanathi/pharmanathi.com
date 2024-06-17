import pytest

pytestmark = pytest.mark.django_db


def test_admisite_redirect_to_login_if_not_authed(web_client):
    res = web_client.get("/custom-admin/MHPs/unverified/")
    assert res.status_code == 302


def test_home_stats(staff_web_client, unverified_mhp_client):
    res = staff_web_client.get("/custom-admin/")
    print(dir(res), res.context.get("stats"))
    assert res.status_code == 200
    assert res.context.get("stats").get("unverifed_mhps") == 1
