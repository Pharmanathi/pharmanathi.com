import datetime
from logging import FileHandler
from pathlib import Path

from django.conf import settings


class AdminFileHandler(FileHandler):
    def __init__(self, **kwargs):
        filepath = Path(settings.ADMIN_LOGFOLDER / datetime.datetime.now().strftime("admin_log_%d%m%Y"))
        super().__init__(**{**kwargs, "filename": filepath, "mode": "a"})
