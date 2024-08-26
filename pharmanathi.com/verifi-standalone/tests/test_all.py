import sys
from datetime import datetime

from verifi.api import log, logs


def test_log():
    now = datetime.now()
    log("test")
    assert len(logs) == 1
    assert f"{now.strftime('[%D/%b/%Y %H:%M:')}" == logs[0][:25]
    assert logs[0][-4:] == "test"
