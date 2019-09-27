FROM registry.access.redhat.com/ubi8/python-36

# Demo App version
ARG AD_DEMO_REPO_OWNER=HumairAK

# Must match repo name on vcs
ARG AD_DEMO_NAME=anomaly-detection-demo-app

# Configure environment
ENV GUNICORN_BIND=0.0.0.0:8088 \
    GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0 \
    GUNICORN_LIMIT_REQUEST_LINE=0 \
    GUNICORN_TIMEOUT=60 \
    GUNICORN_WORKERS=2 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/opt/superset/work-dir:$PYTHONPATH \
    AD_DEMO_REPO=${AD_DEMO_REPO_OWNER}/${AD_DEMO_NAME}\
    AD_DEMO_VERSION=${DEMO_APP_VERSION} \
    AD_DEMO_HOME=/var/lib/ad_demo
ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"

USER 0
WORKDIR .

RUN mkdir ${AD_DEMO_HOME} && \
    chgrp -R 0 ${AD_DEMO_HOME} && chmod -R g=u ${AD_DEMO_HOME} && \
    dnf update -y && \
    dnf install npm -y

RUN cd ${AD_DEMO_HOME} && git clone https://github.com/${AD_DEMO_REPO} && \
    pip3 install pipenv==2018.11.26 && \
    cd ${AD_DEMO_HOME}/${AD_DEMO_NAME} && \
    pipenv install --deploy --system

RUN cd ${AD_DEMO_HOME}/${AD_DEMO_NAME}/app && \
    npm install && npm run-script build

## Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "app:create_app()"]

USER 1001
