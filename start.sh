# start.sh
export FLASK_APP=app
# export FLASK_ENV=development
export prometheus_multiproc_dir=/tmp
export ES_HOST_URL=http://lad-elasticsearch-service-aiops-prod-prometheus-scrape.cloud.paas.psi.redhat.com

# Gunicorn environment variables
GUNICORN_BIND=0.0.0.0:8088
GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0
GUNICORN_LIMIT_REQUEST_LINE=0
GUNICORN_TIMEOUT=60
GUNICORN_WORKERS=2
LANG=C.UTF-8
LC_ALL=C.UTF-8
PYTHONPATH=/etc/superset:/opt/superset/work-dir:$PYTHONPATH
AD_DEMO_REPO=${AD_DEMO_REPO_OWNER}/${AD_DEMO_NAME}
AD_DEMO_NAME=${AD_DEMO_NAME}
AD_DEMO_HOME=/var/lib/ad_demo
export GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE} --config=config.py"

function main(){
  PROD="false"
  DEVMODE="false"
  while getopts "hdp" opt; do
    case ${opt} in
      h)
        usage
        exit 0
        ;;
      d)
        DEVMODE="true"
        ;;
      p)
        PROD="true"
        ;;
      \?)
        echo "Invalid option" >&2
        usage
        exit 1
        ;;
    esac
  done

  shift "$((OPTIND-1))"

  if [[ "$DEVMODE" == "true" ]] && [[ "$PROD" == "true" ]]; then
    echo "Please specify only one of -p or -d "
  elif [[ "$DEVMODE" == "true" ]]; then
    flask run
  elif [[ "$PROD" == "true" ]]; then
    gunicorn "app:create_app()"
  else
    echo "No -d (devmode) or -p (production) mode specified"
    exit 1
  fi
}

function usage() {
  echo
  echo "Run demo app."
  echo
  echo "Usage: ./start.sh [-d|-p]"
  echo
  echo "optional arguments:"
  echo "  -d                  Run flask in devmode"
  echo "  -p                  Run flask using gunicorn in production mode."
}


main $@
exit $?
