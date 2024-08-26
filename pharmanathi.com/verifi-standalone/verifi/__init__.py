from datetime import datetime

logs = []


def log(text):
    """Allows for tracing this verification by aggregating logs into the report[]"_logs"] object"""
    logs.append(f"{datetime.now().strftime('[%D/%b/%Y %H:%M:%S]')} {text}")


def get_logs():
    return logs
