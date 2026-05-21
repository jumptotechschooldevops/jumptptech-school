---
title: "Part 7: Prometheus & Grafana Monitoring Stack"
description: Prometheus scraping ECS services, Grafana dashboards, PromQL alerting rules, and CloudWatch integration
---

# Part 7: Prometheus & Grafana Monitoring Stack

**← [Part 6: Databases](enterprise-sre-lab-part6-database.md) | [Part 8: CI/CD Pipeline →](enterprise-sre-lab-part8-cicd.md)**

---

## Objective

Deploy Prometheus on ECS Fargate to scrape all ShopFlow services. Build Grafana dashboards for RED metrics (Rate, Errors, Duration). Configure alerting rules with PagerDuty integration. Add CloudWatch → Prometheus bridge for native AWS metrics.

---

## Observability Architecture

```
ECS Tasks (api, checkout)
    │  /metrics endpoint (port 9100)
    ▼
Prometheus (ECS Fargate)
    │  15s scrape interval
    ├─► TSDB (EFS persistent storage)
    ├─► Alert Manager → PagerDuty / Slack
    └─► Grafana (ECS Fargate)
            │
            ├─► CloudWatch data source (AWS metrics)
            ├─► Prometheus data source (app metrics)
            └─► Dashboards (RED, infrastructure, SLO)

CloudWatch Metrics Exporter
    │  RDS, ElastiCache, ALB metrics
    ▼
Prometheus
```

---

## Step 1 — EFS for Prometheus Storage

```hcl
resource "aws_efs_file_system" "prometheus" {
  creation_token   = "shopflow-${var.environment}-prometheus"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  kms_key_id       = var.kms_key_arn

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "shopflow-${var.environment}-prometheus-efs"
  }
}

resource "aws_efs_mount_target" "prometheus" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.prometheus.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "shopflow-${var.environment}-efs-sg"
  description = "EFS - allow NFS from monitoring tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.monitoring_security_group_id]
  }
}
```

---

## Step 2 — Prometheus Configuration

```yaml
# prometheus.yml — stored in SSM Parameter Store
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    environment: prod
    cluster: shopflow-prod

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "/etc/prometheus/rules/*.yml"

scrape_configs:
  # Prometheus self-monitoring
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # API Service - using ECS Service Discovery
  - job_name: 'shopflow-api'
    ec2_sd_configs:
      - region: us-east-1
        filters:
          - name: tag:ecs_service
            values: ['shopflow-prod-api']
    relabel_configs:
      - source_labels: [__meta_ec2_private_ip]
        target_label: __address__
        replacement: '${1}:9100'
      - source_labels: [__meta_ec2_tag_Name]
        target_label: instance

  # ECS Service Discovery via HTTP SD (requires custom discovery)
  - job_name: 'ecs-services'
    http_sd_configs:
      - url: http://ecs-discovery:8080/targets
        refresh_interval: 30s
    metrics_path: /metrics
    relabel_configs:
      - source_labels: [__meta_ecs_task_definition_family]
        target_label: service
      - source_labels: [__meta_ecs_cluster]
        target_label: cluster

  # CloudWatch metrics exporter
  - job_name: 'cloudwatch-exporter'
    static_configs:
      - targets: ['cloudwatch-exporter:9106']

  # RDS via CloudWatch exporter
  - job_name: 'rds'
    static_configs:
      - targets: ['cloudwatch-exporter:9106']
    params:
      namespace: ['AWS/RDS']

  # Node Exporter on monitoring instances
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

---

## Step 3 — Alerting Rules

### rules/shopflow-alerts.yml

```yaml
groups:
  - name: shopflow-api-alerts
    interval: 30s
    rules:

      # High error rate
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{job="shopflow-api", status=~"5.."}[5m]))
          /
          sum(rate(http_requests_total{job="shopflow-api"}[5m])) > 0.01
        for: 2m
        labels:
          severity: critical
          team: sre
        annotations:
          summary: "High HTTP 5xx error rate on API service"
          description: "Error rate is {{ $value | humanizePercentage }} (threshold: 1%)"
          runbook: "https://docs.shopflow.internal/runbooks/high-error-rate"
          dashboard: "https://grafana.shopflow.internal/d/api-red"

      # High p99 latency
      - alert: HighLatencyP99
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket{job="shopflow-api"}[5m])) by (le)
          ) > 0.5
        for: 5m
        labels:
          severity: warning
          team: sre
        annotations:
          summary: "API p99 latency exceeds 500ms"
          description: "p99 latency is {{ $value | humanizeDuration }} (threshold: 500ms)"
          runbook: "https://docs.shopflow.internal/runbooks/high-latency"

      # Service down (no scrape data)
      - alert: ServiceDown
        expr: up{job=~"shopflow.*"} == 0
        for: 1m
        labels:
          severity: critical
          team: sre
        annotations:
          summary: "Service {{ $labels.job }} is DOWN"
          description: "Prometheus cannot scrape {{ $labels.instance }}"

      # Too few tasks running
      - alert: ECSServiceUnhealthy
        expr: |
          aws_ecs_service_running_task_count{cluster_name="shopflow-prod"}
          < aws_ecs_service_desired_task_count{cluster_name="shopflow-prod"} * 0.75
        for: 3m
        labels:
          severity: critical
          team: sre
        annotations:
          summary: "ECS service {{ $labels.service_name }} has fewer tasks than desired"
          description: "Running: {{ $value }} tasks (expected: {{ $labels.desired_count }})"

  - name: shopflow-checkout-alerts
    rules:

      # Checkout failure rate
      - alert: CheckoutFailureRate
        expr: |
          sum(rate(checkout_orders_total{status="failed"}[5m]))
          /
          sum(rate(checkout_orders_total[5m])) > 0.001
        for: 2m
        labels:
          severity: critical
          team: sre
          pagerduty_key: "shopflow-checkout-oncall"
        annotations:
          summary: "Checkout failure rate exceeds 0.1%"
          description: "Checkout failure rate: {{ $value | humanizePercentage }}"

  - name: shopflow-database-alerts
    rules:

      # RDS high connections
      - alert: RDSHighConnections
        expr: aws_rds_database_connections_average{db_cluster_identifier="shopflow-prod"} > 800
        for: 5m
        labels:
          severity: warning
          team: sre
        annotations:
          summary: "RDS connection count exceeding 800"
          description: "Current connections: {{ $value }}"
          runbook: "https://docs.shopflow.internal/runbooks/db-connection-exhaustion"

      # Redis memory pressure
      - alert: RedisMemoryHigh
        expr: aws_elasticache_database_memory_usage_percentage_average > 80
        for: 10m
        labels:
          severity: warning
          team: sre
        annotations:
          summary: "ElastiCache Redis memory usage above 80%"
          description: "Memory usage: {{ $value | humanizePercentage }}"

  - name: shopflow-slo-alerts
    rules:

      # SLO burn rate alert (fast burn: 14.4x over 1h means budget burns out in ~5 days)
      - alert: SLOFastBurnRate
        expr: |
          (
            sum(rate(http_requests_total{job="shopflow-api", status=~"5.."}[1h]))
            /
            sum(rate(http_requests_total{job="shopflow-api"}[1h]))
          ) > 14.4 * (1 - 0.9995)
        for: 2m
        labels:
          severity: critical
          team: sre
        annotations:
          summary: "SLO fast burn: error budget burning 14.4x faster than expected"
          description: "Current burn rate: {{ $value | humanizePercentage }}"

      # Slow burn (3x over 6h)
      - alert: SLOSlowBurnRate
        expr: |
          (
            sum(rate(http_requests_total{job="shopflow-api", status=~"5.."}[6h]))
            /
            sum(rate(http_requests_total{job="shopflow-api"}[6h]))
          ) > 3 * (1 - 0.9995)
        for: 15m
        labels:
          severity: warning
          team: sre
        annotations:
          summary: "SLO slow burn: error budget depleting at 3x normal rate"
```

---

## Step 4 — Alertmanager Configuration

```yaml
# alertmanager.yml
global:
  resolve_timeout: 5m
  slack_api_url: 'https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX'

route:
  group_by: ['alertname', 'team']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default'

  routes:
    # Critical alerts go to PagerDuty immediately
    - match:
        severity: critical
      receiver: pagerduty
      group_wait: 0s  # No delay for critical
      repeat_interval: 1h

    # Warning alerts go to Slack
    - match:
        severity: warning
      receiver: slack-warnings
      group_wait: 1m

receivers:
  - name: 'default'
    slack_configs:
      - channel: '#shopflow-alerts'
        send_resolved: true
        title: '{{ if eq .Status "firing" }}🔥{{ else }}✅{{ end }} [{{ .Status | toUpper }}] {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_KEY'
        description: '{{ .GroupLabels.alertname }}: {{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        details:
          environment: '{{ .GroupLabels.environment }}'
          runbook: '{{ (index .Alerts 0).Annotations.runbook }}'
    slack_configs:
      - channel: '#shopflow-incidents'
        title: '🚨 PD ALERT: {{ .GroupLabels.alertname }}'
        send_resolved: true

  - name: 'slack-warnings'
    slack_configs:
      - channel: '#shopflow-alerts'
        title: '⚠️ WARNING: {{ .GroupLabels.alertname }}'
        send_resolved: true

inhibit_rules:
  # If service is DOWN, don't also fire HighLatency alerts for it
  - source_match:
      alertname: 'ServiceDown'
    target_match_re:
      alertname: 'HighLatency.*|HighErrorRate'
    equal: ['job']
```

---

## Step 5 — Grafana Dashboards

### Dashboard 1: RED Metrics (Rate, Errors, Duration)

Key panels to build in Grafana:

**Request Rate:**
```promql
sum(rate(http_requests_total{job="shopflow-api"}[5m])) by (handler)
```

**Error Rate (%):**
```promql
100 * sum(rate(http_requests_total{job="shopflow-api", status=~"5.."}[5m]))
    / sum(rate(http_requests_total{job="shopflow-api"}[5m]))
```

**p50 / p95 / p99 Latency:**
```promql
histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{job="shopflow-api"}[5m])) by (le))
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="shopflow-api"}[5m])) by (le))
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{job="shopflow-api"}[5m])) by (le))
```

**Active ECS Tasks:**
```promql
aws_ecs_service_running_task_count{cluster_name="shopflow-prod"}
```

### Dashboard 2: SLO Burn Rate

**Error Budget Remaining (%):**
```promql
100 * (1 - (
  sum(increase(http_requests_total{status=~"5.."}[30d]))
  /
  sum(increase(http_requests_total[30d]))
) / (1 - 0.9995))
```

**Burn Rate (1h window):**
```promql
sum(rate(http_requests_total{status=~"5.."}[1h]))
/ sum(rate(http_requests_total[1h]))
/ (1 - 0.9995)
```

### Dashboard 3: Infrastructure

**RDS Connections:**
```promql
aws_rds_database_connections_average{db_cluster_identifier="shopflow-prod"}
```

**Redis Memory Usage:**
```promql
aws_elasticache_database_memory_usage_percentage_average{replication_group_id="shopflow-prod-redis"}
```

**ALB 5xx Rate:**
```promql
sum(rate(aws_applicationelb_httpcode_elb_5_xx_count_sum[5m]))
/ sum(rate(aws_applicationelb_request_count_sum[5m]))
```

---

## Step 6 — Prometheus ECS Task Definition

```hcl
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "shopflow-${var.environment}-prometheus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048  # 2 vCPU
  memory                   = 4096  # 4 GB
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.prometheus.arn

  volume {
    name = "prometheus-data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.prometheus.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        iam = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:v2.48.0"
      essential = true

      portMappings = [{ containerPort = 9090, protocol = "tcp" }]

      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus/data",
        "--storage.tsdb.retention.time=15d",
        "--storage.tsdb.retention.size=10GB",
        "--web.enable-lifecycle",
        "--web.enable-admin-api"
      ]

      mountPoints = [
        {
          sourceVolume  = "prometheus-data"
          containerPath = "/prometheus/data"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/aws/ecs/shopflow-${var.environment}/prometheus"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
    },
    {
      name      = "grafana"
      image     = "grafana/grafana:10.2.0"
      essential = true

      portMappings = [{ containerPort = 3000, protocol = "tcp" }]

      environment = [
        { name = "GF_SECURITY_ADMIN_PASSWORD__FILE", value = "/run/secrets/grafana_password" },
        { name = "GF_USERS_ALLOW_SIGN_UP", value = "false" },
        { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "false" },
        { name = "GF_SERVER_ROOT_URL", value = "https://monitoring.shopflow.internal" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/aws/ecs/shopflow-${var.environment}/prometheus"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])
}
```

---

## Verification Checklist — Part 7

```
[ ] EFS file system created for Prometheus storage
[ ] Prometheus scrape config covers API, checkout, cloudwatch-exporter
[ ] 15-second scrape interval configured
[ ] Alert rules defined: high error rate, high latency, service down, ECS unhealthy, checkout failure
[ ] SLO burn rate alerts: fast burn (14.4x) and slow burn (3x)
[ ] Alertmanager routes critical to PagerDuty, warnings to Slack
[ ] Inhibition rules prevent alert storms (ServiceDown suppresses latency alerts)
[ ] RED dashboard panels: request rate, error rate, p50/p95/p99 latency
[ ] SLO dashboard: error budget remaining, burn rate
[ ] Infrastructure dashboard: RDS connections, Redis memory, ALB 5xx
[ ] Grafana connected to both Prometheus and CloudWatch data sources
[ ] Grafana admin password from Secrets Manager (not hardcoded)
[ ] Prometheus data retention: 15 days, 10 GB
[ ] Prometheus task has EFS mount for persistence across task restarts
```

---

**[Part 8: GitHub Actions CI/CD →](enterprise-sre-lab-part8-cicd.md)**
