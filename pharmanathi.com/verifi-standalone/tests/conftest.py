import pytest
from verifi.api import app


@pytest.fixture
def test_app():
    app.config.update(
        {
            "TESTING": True,
        }
    )
    return app


@pytest.fixture()
def client(test_app):
    return app.test_client()
