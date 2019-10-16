DEBUG = False  # Turns on debugging features in Flask
BCRYPT_LOG_ROUNDS = 12  # Configuration for the Flask-Bcrypt extension

import os
from prometheus_flask_exporter.multiprocess import GunicornPrometheusMetrics


def when_ready(server):
    metric_server_port = int(os.getenv("METRICS_SERVER_PORT", "9153"))
    GunicornPrometheusMetrics.start_http_server_when_ready(metric_server_port)
    print("Metrics Server started on port: {0}".format(metric_server_port))


def child_exit(server, worker):
    GunicornPrometheusMetrics.mark_process_dead_on_child_exit(worker.pid)
    print("Metrics Server Exited")
