from datetime import datetime
from unittest.mock import MagicMock, patch

import pytest
from verifi import get_logs, log


def test_log():
    now = datetime.now()
    log("test")

    logs = get_logs()
    assert len(logs) == 1
    assert f"{now.strftime('[%D/%b/%Y %H:%M:')}" == logs[0][:25]
    assert logs[0][-4:] == "test"


def test_verify_fails_if_no_identifier(client):
    response = client.get("/?first_name=first_name&last_name=last_name&mp_type=mp_type")
    assert response.status_code == 400
    assert response.get_json()["detail"] == "Missing or invalid `id` request argument"


def test_verify_fails_if_no_first_name(client):
    response = client.get("/?id=id&last_name=last_name&mp_type=mp_type")
    assert response.status_code == 400
    assert response.get_json()["detail"] == "Missing or invalid `first_name` request argument"


def test_verify_fails_if_no_last_name(client):
    response = client.get("/?id=id&first_name=first_name&mp_type=mp_type")
    assert response.status_code == 400
    assert response.get_json()["detail"] == "Missing or invalid `last_name` request argument"


def test_verify_fails_if_no_mp_type(client):
    response = client.get("/?id=id&first_name=first_name&last_name=last_name")
    assert response.status_code == 400
    assert (
        response.get_json()["detail"]
        == "Missing or invalid `mp_type` request argument. It must be one of `SAPC` or `HPCSA`"
    )


def test_verify_calls_invalid_provider(client):
    response = client.get("/?id=id&first_name=first_name&last_name=last_name&mp_type=inexistant")
    assert response.status_code == 400
    assert (
        response.get_json()["detail"]
        == "Missing or invalid `mp_type` request argument. It must be one of `SAPC` or `HPCSA`"
    )


@pytest.mark.parametrize("mp_type", ["hpcsa", "HPcsa", "HPCSA"])
def test_verify_calls_hpcsa(mp_type, client):
    webdriver_instance_mock = MagicMock()
    with patch("verifi.api.webdriver.Remote", return_value=webdriver_instance_mock) as patched_driver:
        process_mock = MagicMock(return_value={})
        with patch("verifi.api.hpcsa.process", process_mock) as patched_process:
            response = client.get(
                f"/?id=sampleRegNo&first_name=some first name&last_name=some-last-name&mp_type={mp_type}"
            )

            assert response.status_code == 200
            patched_process.assert_called_once_with(
                webdriver_instance_mock, "sampleRegNo", "some first name", "some-last-name"
            )


@pytest.mark.parametrize("mp_type", ["sapc", "SApC"])
def test_verify_calls_sapc(mp_type, client):
    webdriver_instance_mock = MagicMock()
    with patch("verifi.api.webdriver.Remote", return_value=webdriver_instance_mock) as patched_driver:
        process_mock = MagicMock(return_value={})
        with patch("verifi.api.sapc.process", process_mock) as patched_process:
            response = client.get(
                f"/?id=sampleRegNo&first_name=some first name&last_name=some-last-name&mp_type={mp_type}"
            )

            assert response.status_code == 200
            patched_process.assert_called_once_with(
                webdriver_instance_mock, "sampleRegNo", "some first name", "some-last-name"
            )
