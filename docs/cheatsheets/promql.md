# PromQL Cheatsheet

## Selectors

```promql
# All time series for a metric
http_requests_total

# Exact label match
http_requests_total{job="api"}

# Multiple labels
http_requests_total{job="api", method="GET"}

# Regex match (=~)
http_requests_total{status=~"5.."}           # 5xx errors
http_requests_total{endpoint=~"/api/.*"}     # paths starting with /api/

# Regex not-match (!~)
http_requests_total{status!~"2.."}           # non-2xx responses

# Not equal (!=)
http_requests_total{method!="GET"}

# Range vector (for rate/increase functions)
http_requests_total[5m]                      # last 5 minutes
http_requests_total[1h]                      # last 1 hour
```

## Essential functions

### Rate and increase

```promql
# Per-second rate over 5 minutes (for counters)
rate(http_requests_total[5m])

# Per-second rate with label
rate(http_requests_total{status="200"}[5m])

# Total increase over a time range
increase(http_requests_total[1h])           # requests in last hour

# Rate of rate (second derivative — is it speeding up?)
deriv(node_memory_MemAvailable_bytes[10m])
```

**When to use:** `rate()` for per-second values. `increase()` for total count over a window.

### Aggregation operators

```promql
# Sum all series
sum(rate(http_requests_total[5m]))

# Sum, grouped by label
sum(rate(http_requests_total[5m])) by (status)
sum(rate(http_requests_total[5m])) by (job, endpoint)

# Sum, without certain labels
sum(rate(http_requests_total[5m])) without (instance, pod)

# Other aggregators
avg(node_cpu_seconds_total[5m])             # average
min(node_memory_MemFree_bytes)              # minimum value
max(process_resident_memory_bytes)          # maximum value
count(up == 1)                              # count of healthy instances
count by (job)(up)                          # count per job
topk(5, rate(http_requests_total[5m]))      # top 5 highest
bottomk(3, node_memory_MemAvailable_bytes)  # bottom 3 lowest
```

### Histogram functions

```promql
# Percentile from histogram (most important)
histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))   # p50 (median)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))   # p95
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))   # p99

# With label grouping (separate percentile per endpoint)
histogram_quantile(0.99,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint)
)

# Average latency from histogram
rate(http_request_duration_seconds_sum[5m])
  / rate(http_request_duration_seconds_count[5m])
```

### Other functions

```promql
# Avoid counting restarts when rate() dips below 0
irate(http_requests_total[5m])              # instant rate (last two samples)

# Offset — compare to historical values
rate(http_requests_total[5m]) offset 1h    # 1 hour ago
rate(http_requests_total[5m]) offset 1d    # 24 hours ago (same time yesterday)

# Predict future value (linear regression)
predict_linear(node_filesystem_free_bytes[6h], 4*3600)  # predicted in 4h

# Return last known value (for sparse metrics)
last_over_time(my_metric[1h])

# Absent — true if metric is missing (for "down" alerts)
absent(up{job="myapp"})

# Min/max over time window
min_over_time(node_memory_MemAvailable_bytes[1h])
max_over_time(http_requests_total[1d])
avg_over_time(cpu_usage[30m])
```

## Arithmetic

```promql
# Simple math
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024   # bytes to GB

# Between two metrics (match on all shared labels)
http_errors_total / http_requests_total    # error fraction

# Percentage
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)

# Ratio — multiply by 100 for percentage
100 * sum(rate(http_requests_total{status=~"5.."}[5m]))
    / sum(rate(http_requests_total[5m]))
```

## Comparison operators

```promql
# Return only matching series
node_cpu_usage > 0.8                        # CPU > 80%
node_memory_MemAvailable_bytes < 1e9        # < 1GB available
up == 0                                     # down services

# Boolean mode (1 if true, 0 if false, no filtering)
node_cpu_usage > bool 0.8                   # returns 1/0 for all series
```

## Common recipes

### Request rate (RED method)

```promql
# Rate
sum(rate(http_requests_total[5m]))

# Error rate
sum(rate(http_requests_total{status=~"5.."}[5m]))

# Error percentage
100 * sum(rate(http_requests_total{status=~"5.."}[5m]))
    / sum(rate(http_requests_total[5m]))

# Duration (p99)
histogram_quantile(0.99,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

### System resources (USE method)

```promql
# CPU utilisation (1 = 100%)
1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)

# CPU saturation (load average vs cores)
node_load1 / count without(cpu, mode)(node_cpu_seconds_total{mode="idle"})

# Memory utilisation
1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)

# Memory available in bytes
node_memory_MemAvailable_bytes

# Disk utilisation
1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)

# Disk I/O saturation (time spent doing I/O)
rate(node_disk_io_time_seconds_total[5m])

# Network errors
rate(node_network_receive_errs_total[5m])
rate(node_network_transmit_errs_total[5m])

# Network bandwidth
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Kubernetes

```promql
# Pod count by namespace
count(kube_pod_info) by (namespace)

# Pods not running
count(kube_pod_status_phase{phase!="Running", phase!="Succeeded"}) by (namespace, phase)

# Container CPU usage
rate(container_cpu_usage_seconds_total{container!=""}[5m])

# Container memory usage
container_memory_working_set_bytes{container!=""}

# Container memory limit usage
container_memory_working_set_bytes / container_spec_memory_limit_bytes

# Node count
count(kube_node_info)

# Nodes not ready
count(kube_node_status_condition{condition="Ready", status!="true"})

# Deployment replicas available vs desired
kube_deployment_status_replicas_available / kube_deployment_spec_replicas
```

## Alert rule templates

```yaml
# Error rate alert
- alert: HighErrorRate
  expr: |
    (
      sum(rate(http_requests_total{status=~"5.."}[5m]))
      / sum(rate(http_requests_total[5m]))
    ) > 0.05
  for: 5m
  labels:
    severity: critical

# Latency alert
- alert: HighLatency
  expr: |
    histogram_quantile(0.99,
      sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service)
    ) > 1.0
  for: 5m

# Service down
- alert: ServiceDown
  expr: up == 0
  for: 1m
  labels:
    severity: critical

# Disk space
- alert: DiskSpaceLow
  expr: |
    (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.10
  for: 10m
  labels:
    severity: warning

# Predicting disk full
- alert: DiskWillFillIn4Hours
  expr: |
    predict_linear(node_filesystem_free_bytes[6h], 4*3600) < 0
  for: 30m

# Missing metrics (service stopped sending)
- alert: MetricsMissing
  expr: absent(up{job="myapp"})
  for: 5m
```

## Operators precedence (high to low)

1. `^` (exponentiation)
2. `* / % atan2`
3. `+ -`
4. `== != < > <= >=`
5. `and unless`
6. `or`

## Time durations

```
ms  — milliseconds
s   — seconds
m   — minutes
h   — hours
d   — days (24h)
w   — weeks (7d)
y   — years (365d)

Examples: 5m, 1h, 2d, 1w
```

## Grafana variables in PromQL

```promql
# Use $variable for template variables in Grafana
sum(rate(http_requests_total{job="$service"}[5m])) by (status)

# Use ${variable} for disambiguation
rate(http_requests_total{endpoint="${endpoint}_total"}[5m])
```
