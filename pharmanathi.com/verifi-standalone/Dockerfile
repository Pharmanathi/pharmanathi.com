#@TODO: Slim this image
FROM python:3.9-slim

ARG BUILD_ENVIRONMENT=production
ARG APP_HOME=/app

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

COPY --chown=verifi:verifi ./requirements.txt /tmp/requirements.txt
RUN apt update && pip install -r /tmp/requirements.txt

RUN addgroup --system verifi \
    && adduser --system --ingroup verifi verifi

COPY --chown=verifi:verifi ./start /start
RUN chmod +x /start

WORKDIR ${APP_HOME}

COPY --chown=verifi:verifi ./src ./
RUN  chown verifi:verifi .

CMD ["/start"]
