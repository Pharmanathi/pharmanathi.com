#@TODO: Slim this image
FROM python:3.12.5-slim-bookworm as python

# Python build stage
FROM python as python-build-stage

ARG BUILD_ENVIRONMENT=production

# Install apt packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential

COPY ./requirements/verifi/ .
RUN pip wheel --wheel-dir /usr/src/app/wheels  \
  -r ${BUILD_ENVIRONMENT}.txt

FROM python AS python-run-stage

ARG BUILD_ENVIRONMENT=production
ARG APP_HOME=/app

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR ${APP_HOME}

RUN groupadd --system verifi \
    && adduser --system --ingroup verifi verifi

RUN apt-get update && apt-get install --no-install-recommends -y \
  curl \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

COPY --from=python-build-stage /usr/src/app/wheels  /wheels/

RUN pip install --no-cache-dir --no-index --find-links=/wheels/ /wheels/* \
  && rm -rf /wheels/

COPY --chown=verifi:verifi ./compose/${BUILD_ENVIRONMENT}/verifi/entrypoint /entrypoint
RUN chmod +x /entrypoint

COPY --chown=verifi:verifi ./compose/${BUILD_ENVIRONMENT}/verifi/start /start
RUN chmod +x /start

COPY --chown=verifi:verifi ./verifi-standalone/__init__.py ${APP_HOME}/__init__.py
COPY --chown=verifi:verifi ./verifi-standalone/verifi ${APP_HOME}/verifi

ENTRYPOINT [ "/entrypoint"]
