# Lab 1 · Full Monitoring Stack

**Duration:** ~90 minutes  
**Goal:** Deploy a complete observability stack with Prometheus, Grafana, node-exporter, and a sample application. Write PromQL queries and build a dashboard.

---

## Part 1 — Stack setup

```bash
mkdir -p ~/monitoring-lab/{prometheus,grafana/provisioning/{datasources,dashboards},alertmanager}
cd ~/monitoring-lab
```

### 1.1 The sample application

Create a simple Flask API with Prometheus instrumentation:

```bash
mkdir -p app

cat > app/app.py << 'EOF'
import time
import random
import threading
from flask import Flask, request, jsonify
from prometheus_client import (
    Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
)

app = Flask(__name__)

# --- Metrics ---

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration",
    ["method", "endpoint"],
    buckets=[.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5]
)

ACTIVE_USERS = Gauge(
    "app_active_users",
    "Number of active users"
)

QUEUE_DEPTH = Gauge(
    "app_queue_depth",
    "Number of items in processing queue"
)

# Simulate some background activity
def simulate_activity():
    while True:
        ACTIVE_USERS.set(random.randint(50, 200))
        QUEUE_DEPTH.set(random.randint(0, 50))
        time.sleep(5)

threading.Thread(target=simulate_activity, daemon=True).start()

# --- Request instrumentation ---

@app.before_request
def start_timer():
    request._start_time = time.time()

@app.after_request
def record_metrics(response):
    duration = time.time() - request._start_time
    endpoint = request.endpoint or "unknown"
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=endpoint,
        status=str(response.status_code)
    ).inc()
    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=endpoint
    ).observe(duration)
    return response

# --- Endpoints ---

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/api/fast")
def fast():
    # Fast endpoint — 1-30ms
    time.sleep(random.uniform(0.001, 0.03))
    return jsonify({"result": "fast response"})

@app.route("/api/slow")
def slow():
    # Slow endpoint — 200-800ms
    time.sleep(random.uniform(0.2, 0.8))
    return jsonify({"result": "slow response"})

@app.route("/api/errors")
def errors():
    # Randomly returns errors (30% of the time)
    if random.random() < 0.3:
        return jsonify({"error": "internal server error"}), 500
    return jsonify({"result": "ok"})

@app.route("/api/users")
def users():
    time.sleep(random.uniform(0.05, 0.15))
    return jsonify({"users": [{"id": i, "name": f"User {i}"} for i in range(10)]})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
EOF

cat > app/requirements.txt << 'EOF'
flask==3.0.3
prometheus-client==0.20.0
gunicorn==22.0.0
EOF

cat > app/Dockerfile << 'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]
EOF
```

### 1.2 Prometheus configuration

```bash
cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: "lab"
    environment: "local"

rule_files:
  - "/etc/prometheus/rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "flask-app"
    scrape_interval: 10s
    static_configs:
      - targets: ["app:8000"]
    metrics_path: /metrics
EOF

mkdir -p prometheus/rules

cat > prometheus/rules/alerts.yml << 'EOF'
groups:
  - name: app-alerts
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(http_requests_total{status=~"5.."}[5m]))
            /
            sum(rate(http_requests_total[5m]))
          ) > 0.20
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} (threshold: 20%)"

      - alert: SlowEndpoint
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint)
          ) > 0.5
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Slow endpoint: {{ $labels.endpoint }}"
          description: "p95 latency for {{ $labels.endpoint }} is {{ $value }}s"

      - alert: AppDown
        expr: up{job="flask-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Flask application is down"

      - alert: HighMemoryUsage
        expr: |
          (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"
EOF
```

### 1.3 Alertmanager configuration

```bash
cat > alertmanager/alertmanager.yml << 'EOF'
global:
  resolve_timeout: 5m

route:
  group_by: [alertname, severity]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: "default"

receivers:
  - name: "default"
    webhook_configs:
      - url: "http://alertmanager:9093/api/v2/alerts"
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: critical
    target_match:
      severity: warning
    equal: [alertname]
EOF
```

### 1.4 Grafana provisioning

```bash
cat > grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "15s"
EOF

cat > grafana/provisioning/dashboards/dashboards.yml << 'EOF'
apiVersion: 1
providers:
  - name: Default
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
EOF
```

---

## Part 2 — Docker Compose stack

```bash
cat > compose.yml << 'EOF'
services:

  app:
    build: ./app
    ports:
      - "8000:8000"
    healthcheck:
      test: ["CMD", "python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
      interval: 10s
      timeout: 5s
      retries: 3

  prometheus:
    image: prom/prometheus:v2.52.0
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/rules:/etc/prometheus/rules:ro
      - prometheus_data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=7d"
      - "--web.enable-lifecycle"
      - "--web.enable-admin-api"
    ports:
      - "9090:9090"
    depends_on:
      - app

  node-exporter:
    image: prom/node-exporter:v1.8.0
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - "--path.procfs=/host/proc"
      - "--path.sysfs=/host/sys"
      - "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
    ports:
      - "9100:9100"

  alertmanager:
    image: prom/alertmanager:v0.27.0
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    command:
      - "--config.file=/etc/alertmanager/alertmanager.yml"
    ports:
      - "9093:9093"

  grafana:
    image: grafana/grafana:11.0.0
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: devops123
      GF_USERS_ALLOW_SIGN_UP: "false"
      GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH: /var/lib/grafana/dashboards/app.json
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:
EOF
```

---

## Part 3 — Start the stack

```bash
docker compose up -d --build

# Watch all services start
docker compose logs -f

# Wait until Prometheus is up
until curl -sf http://localhost:9090/-/ready; do echo "Waiting for Prometheus..."; sleep 3; done
echo "Prometheus ready"

# Wait for Grafana
until curl -sf http://localhost:3000/api/health; do echo "Waiting for Grafana..."; sleep 3; done
echo "Grafana ready"
```

---

## Part 4 — Generate traffic

```bash
# Generate traffic to all endpoints in the background
cat > generate_traffic.sh << 'EOF'
#!/bin/bash
endpoints=("/api/fast" "/api/slow" "/api/errors" "/api/users" "/health")
while true; do
    endpoint=${endpoints[$RANDOM % ${#endpoints[@]}]}
    curl -sf "http://localhost:8000$endpoint" > /dev/null 2>&1
    sleep 0.1
done
EOF

chmod +x generate_traffic.sh
./generate_traffic.sh &
TRAFFIC_PID=$!
echo "Traffic generator PID: $TRAFFIC_PID"
```

Let this run throughout the lab. Stop it at the end with `kill $TRAFFIC_PID`.

---

## Part 5 — Prometheus queries

Open Prometheus at http://localhost:9090/graph

### 5.1 Basic queries

Run each of these in the expression field:

```promql
# 1. How many requests per second is the app handling?
sum(rate(http_requests_total[5m]))

# 2. Request rate broken down by endpoint
sum(rate(http_requests_total[5m])) by (endpoint)

# 3. Error rate (5xx) per second
sum(rate(http_requests_total{status=~"5.."}[5m]))

# 4. Error percentage
100 * sum(rate(http_requests_total{status=~"5.."}[5m]))
    / sum(rate(http_requests_total[5m]))

# 5. p50 latency
histogram_quantile(0.50,
    sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# 6. p95 latency by endpoint
histogram_quantile(0.95,
    sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint)
) by (endpoint)
```

### 5.2 Infrastructure queries

```promql
# Node memory available in GB
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024

# Memory used percentage
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# CPU usage (1 - idle)
100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (cpu))

# Disk space available
node_filesystem_avail_bytes{fstype!="tmpfs"} / 1024 / 1024 / 1024

# Active user count from the app
app_active_users

# Queue depth
app_queue_depth
```

---

## Part 6 — Grafana dashboard

Open Grafana at http://localhost:3000 — login admin / devops123.

### 6.1 Create a dashboard

1. Click the `+` icon → Dashboard
2. Add a new panel

### 6.2 Request rate panel (time series)

- Query: `sum(rate(http_requests_total[5m])) by (endpoint)`
- Legend: `{{endpoint}}`
- Title: "Request Rate by Endpoint"
- Unit: "reqps"

### 6.3 Error rate panel (gauge)

- Query: `100 * sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))`
- Visualization: Gauge
- Unit: Percent (0-100)
- Thresholds: 0=green, 5=yellow, 20=red
- Title: "Error Rate %"

### 6.4 Latency panel (time series)

Add two queries on the same panel:

- Query A: `histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))`
  Legend: `p50`
- Query B: `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))`
  Legend: `p99`

Title: "Request Latency"  
Unit: seconds

### 6.5 System panel (stat)

Add stats in a row:
- CPU: `100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[1m])))`
- Memory: `100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)`

Save the dashboard as "Application Overview".

---

## Part 7 — Alerts

### 7.1 View active alerts

Open http://localhost:9090/alerts

Some alerts should be firing (especially `HighErrorRate` since `/api/errors` returns errors ~30% of the time).

### 7.2 View Alertmanager

Open http://localhost:9093

You should see the grouped alerts.

### 7.3 Trigger an alert manually

```bash
# Stop the app to trigger AppDown alert
docker compose stop app
sleep 75   # wait for 'for: 1m' threshold
```

Check Prometheus → Alerts — `AppDown` should move from Pending to Firing.

```bash
docker compose start app
```

After the app recovers, the alert should resolve.

---

## Part 8 — Import community dashboard

1. Grafana → Dashboards → Import
2. Enter dashboard ID: **1860** (Node Exporter Full)
3. Select Prometheus as the data source
4. Import

Explore the pre-built panels — this is the kind of comprehensive dashboard you can have for free.

---

## Cleanup

```bash
kill $TRAFFIC_PID 2>/dev/null || true
docker compose down -v
```

---

## Summary

You have deployed:
- [x] Flask application with Prometheus instrumentation
- [x] Prometheus scraping the app and node-exporter every 10-15s
- [x] Alert rules with `for:` clauses to prevent flapping
- [x] Alertmanager receiving and grouping alerts
- [x] Grafana with automatically provisioned Prometheus data source
- [x] A custom dashboard with request rate, error rate, and latency panels

This is the foundation. In a real environment, you would add:
- Loki for log aggregation
- Tempo for distributed traces
- More alert rules mapped to runbooks
- Annotation integration (mark deployments on graphs)
- Long-term storage (Thanos, Mimir) for multi-week retention
