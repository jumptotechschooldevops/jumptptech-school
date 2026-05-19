# Lecture 2 · Prometheus & Grafana

## How Prometheus works

Prometheus is a monitoring system and time series database. Unlike systems that receive pushed metrics, Prometheus **scrapes** — it periodically polls an HTTP endpoint on each target and reads the metrics exposed there.

```
Target (your app)        Prometheus server
  /metrics endpoint  ←── scrape every 15s
  return metrics     ──→ store in TSDB
                         evaluate alert rules
                         serve PromQL queries
```

This pull-based model has advantages: Prometheus knows whether a target is reachable, not just whether it is sending data. Dead targets are obviously dead.

---

## The data model

Every metric in Prometheus is identified by:

- A **metric name**: `http_requests_total`
- Zero or more **labels** (key=value pairs): `{method="GET", status="200", endpoint="/api/users"}`

Together, a metric name plus labels form a **time series**. Prometheus stores the value of each time series at each scrape interval.

```
http_requests_total{method="GET", status="200", endpoint="/api/users"} 1024
http_requests_total{method="POST", status="201", endpoint="/api/users"} 47
http_requests_total{method="GET", status="500", endpoint="/api/users"} 3
```

Each of these is a separate time series, even though they share the metric name.

### Metric naming conventions

```
# Format: <namespace>_<subsystem>_<name>_<unit>

# Counters — always end in _total
http_requests_total
process_cpu_seconds_total

# Gauges
node_memory_MemAvailable_bytes
process_open_fds

# Histograms — automatically create _bucket, _sum, _count
http_request_duration_seconds
```

---

## The /metrics endpoint

Every target exposes metrics over HTTP in Prometheus text format:

```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} 1024
http_requests_total{method="GET",status="404"} 15
http_requests_total{method="POST",status="201"} 47
http_requests_total{method="POST",status="400"} 3

# HELP http_request_duration_seconds HTTP request latency
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.05"} 847
http_request_duration_seconds_bucket{le="0.1"} 932
http_request_duration_seconds_bucket{le="0.25"} 1024
http_request_duration_seconds_bucket{le="0.5"} 1035
http_request_duration_seconds_bucket{le="1.0"} 1039
http_request_duration_seconds_bucket{le="+Inf"} 1039
http_request_duration_seconds_sum 52.3
http_request_duration_seconds_count 1039

# HELP process_resident_memory_bytes Resident memory size in bytes
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 1.245e+08
```

Client libraries (for Python, Go, Java, Node.js, etc.) make it trivial to instrument your application and expose this endpoint.

---

## prometheus.yml configuration

```yaml
global:
  scrape_interval: 15s     # how often to scrape targets
  evaluation_interval: 15s  # how often to evaluate alert rules

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]   # Prometheus scrapes itself

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "myapp"
    metrics_path: "/metrics"    # default, but can be customised
    scrape_interval: 10s        # override global interval
    static_configs:
      - targets: ["app:8000"]
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance

  # Kubernetes service discovery
  - job_name: "kubernetes-pods"
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: "true"
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
```

---

## PromQL — the query language

PromQL (Prometheus Query Language) is how you retrieve and transform metrics.

### Selectors

```promql
# All time series with this metric name
http_requests_total

# Filter by label (exact match)
http_requests_total{method="GET"}

# Filter by label (regex match)
http_requests_total{status=~"5.."}     # 5xx errors
http_requests_total{status!~"2.."}     # non-2xx

# Multiple filters
http_requests_total{method="GET", status="200"}
```

### Range vectors

A range vector selects data over a time range. Used with functions like `rate()`:

```promql
# Request rate over the last 5 minutes
rate(http_requests_total[5m])

# Error rate per second
rate(http_requests_total{status=~"5.."}[5m])
```

### Aggregation

```promql
# Total request rate across all instances
sum(rate(http_requests_total[5m]))

# Request rate grouped by status code
sum(rate(http_requests_total[5m])) by (status)

# Average request rate per endpoint
avg(rate(http_requests_total[5m])) by (endpoint)

# 99th percentile latency
histogram_quantile(0.99, 
    sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# 50th percentile (median)
histogram_quantile(0.50,
    sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

### Arithmetic and comparison

```promql
# Error rate percentage
100 * sum(rate(http_requests_total{status=~"5.."}[5m])) 
    / sum(rate(http_requests_total[5m]))

# Memory usage in GB
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024

# Available memory as percentage
100 * node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes

# Alert condition: true when error rate > 5%
100 * sum(rate(http_requests_total{status=~"5.."}[5m])) 
    / sum(rate(http_requests_total[5m])) > 5
```

### Offset modifier

Compare current values to historical values:

```promql
# Current request rate vs 24 hours ago
rate(http_requests_total[5m]) 
    / rate(http_requests_total[5m] offset 24h)
```

---

## Alert rules

Alert rules evaluate PromQL expressions and fire when the expression returns results.

```yaml
# prometheus-rules.yml
groups:
  - name: api-alerts
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(http_requests_total{status=~"5.."}[5m]))
            / sum(rate(http_requests_total[5m]))
          ) > 0.05
        for: 5m         # must be true for 5 minutes before alerting
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "High error rate on {{ $labels.service }}"
          description: "Error rate is {{ $value | humanizePercentage }} (threshold: 5%)"
          runbook_url: "https://wiki.internal/runbooks/high-error-rate"

      - alert: SlowResponses
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
          ) > 1.0
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "p99 latency above 1 second"
          description: "99th percentile latency is {{ $value }}s"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"
```

---

## Alertmanager

Alertmanager receives alerts from Prometheus, deduplicates, groups, and routes them to notification channels.

```yaml
# alertmanager.yml
global:
  slack_api_url: "https://hooks.slack.com/services/..."

route:
  group_by: [alertname, severity]
  group_wait: 30s       # wait before sending first notification
  group_interval: 5m    # minimum between sending grouped alerts
  repeat_interval: 4h   # repeat if still firing after 4h
  receiver: default

  routes:
    - match:
        severity: critical
      receiver: pagerduty
      continue: true   # also send to default

    - match:
        severity: warning
      receiver: slack

receivers:
  - name: default
    slack_configs:
      - channel: "#alerts"
        title: "{{ .CommonAnnotations.summary }}"
        text: "{{ .CommonAnnotations.description }}"

  - name: pagerduty
    pagerduty_configs:
      - routing_key: "{{ secrets.PAGERDUTY_KEY }}"
        description: "{{ .CommonAnnotations.description }}"
```

---

## Grafana

Grafana connects to Prometheus (and other data sources) and renders dashboards.

### Useful built-in dashboards

Import these from grafana.com/dashboards:

- **1860** — Node Exporter Full (comprehensive server metrics)
- **315** — Kubernetes cluster monitoring
- **12740** — Docker and system monitoring
- **9614** — nginx ingress controller

### Creating a dashboard

Basic workflow:
1. New Dashboard → Add Panel
2. Choose Prometheus data source
3. Write PromQL in the query field
4. Choose visualisation type (graph, gauge, stat, table)
5. Configure axes, thresholds, and legend
6. Save dashboard with variables for environment/service filtering

### Variables

Template variables make dashboards reusable across services:

```
Variable: service
Type: Query
Query: label_values(http_requests_total, service)
```

Then use `$service` in queries:

```promql
sum(rate(http_requests_total{service="$service"}[5m])) by (status)
```

---

## Summary

- Prometheus scrapes metrics from targets. Pull-based — dead targets are obviously dead.
- Every metric is a name + labels. Labels create separate time series.
- `rate()` converts counters to per-second rates. `histogram_quantile()` computes percentiles.
- Alert rules fire when a PromQL expression is true for a duration. Always set `for:` to avoid flapping.
- Alertmanager routes, deduplicates, and groups alerts before sending to Slack, PagerDuty, etc.
- Grafana dashboards visualise Prometheus data. Import community dashboards to get started.
