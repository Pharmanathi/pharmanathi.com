from datetime import datetime

from verifi.api import log, logs


def test_log():
    log("test")
    assert len(log) == 1
    now = datetime.now()
    assert f"{now().strftime('[%D/%b/%Y %H:%M:')}" == log[0][:16]
    assert log[-4:] == "test"
