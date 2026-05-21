---
title: "Part 9: Production Runbooks"
description: 4 detailed incident runbooks — ECS failures, DB connection exhaustion, high latency, and Prometheus monitoring issues
---

# Part 9: Production Runbooks

**← [Part 8: CI/CD](enterprise-sre-lab-part8-cicd.md) | [Part 10: Interview Q&A →](enterprise-sre-lab-part10-interview.md)**

---

## Overview

Runbooks are the most important SRE artifact. They enable any engineer — even someone who has never seen this system — to respond to an incident correctly under pressure. Every runbook follows the same structure:

1. **Symptoms** — what the alert / user report looks like
2. **Impact** — who is affected and how severely
3. **Diagnosis steps** — ordered investigation procedure
4. **Remediation** — actions to resolve the issue
5. **Escalation** — when to wake up your senior or the database team
6. **Post-incident** — what to do after the fire is out

---

## Runbook 1: ECS Service Failure

**Alert:** `ServiceDown` or `ECSServiceUnhealthy` fires in PagerDuty
**Severity:** P1 — Critical

---

### Symptoms

- PagerDuty alert: `ECS service shopflow-prod-api has fewer running tasks than desired`
- Grafana: `Running Tasks < Desired Tasks` panel shows degradation
- ALB: 5xx error rate spike or connection timeouts
- Users reporting: "API is down", "500 errors", "Cannot checkout"

### Impact

- `api-service` degraded: degraded read experience, catalog may not load
- `checkout-service` degraded: **orders cannot be placed** — high revenue impact
- Full service down: all users affected

---

### Step 1 — Assess Current Service State

```bash
# How many tasks are running vs desired?
aws ecs describe-services \
  --cluster shopflow-prod \
  --services shopflow-prod-api shopflow-prod-checkout \
  --query 'services[*].{Service:serviceName, Running:runningCount, Desired:desiredCount, Status:status}'

# What's the last deployment status?
aws ecs describe-services \
  --cluster shopflow-prod \
  --services shopflow-prod-api \
  --query 'services[0].deployments[*].{Status:status,Desired:desiredCount,Running:runningCount,Failed:failedTasks,Created:createdAt}'
```

### Step 2 — Check Stopped Tasks for Failure Reason

```bash
# List recently stopped tasks
STOPPED_TASKS=$(aws ecs list-tasks \
  --cluster shopflow-prod \
  --service-name shopflow-prod-api \
  --desired-status STOPPED \
  --query 'taskArns' \
  --output text | head -5)

# Get stop reason for each task
aws ecs describe-tasks \
  --cluster shopflow-prod \
  --tasks $STOPPED_TASKS \
  --query 'tasks[*].{TaskArn:taskArn,StopCode:stopCode,StoppedReason:stoppedReason,Container:containers[0].{ExitCode:exitCode,Reason:reason}}'
```

Common stop codes:
| StopCode | Meaning | Action |
|----------|---------|--------|
| `TaskFailedToStart` | Container didn't start | Check image, secrets, port conflicts |
| `EssentialContainerExited` | App crashed | Check CloudWatch logs |
| `OutOfMemoryError` | OOM killed | Increase task memory |
| `CannotPullContainerError` | ECR pull failure | Check VPC endpoints, IAM role |

### Step 3 — Read Container Logs

```bash
# Get logs from the last stopped task
TASK_ID="arn:aws:ecs:us-east-1:123456789012:task/shopflow-prod/XXXX"

aws logs get-log-events \
  --log-group-name /aws/ecs/shopflow-prod/api \
  --log-stream-name "api/${TASK_ID##*/}" \
  --limit 100 \
  --query 'events[*].message' \
  --output text
```

```bash
# Or use CloudWatch Insights for a broader search
aws logs start-query \
  --log-group-name /aws/ecs/shopflow-prod/api \
  --start-time $(date -d '30 minutes ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR|FATAL|panic/ | sort @timestamp desc | limit 50'
```

### Step 4 — Common Fix: Image Pull Failure

```bash
# Check if ECR VPC endpoint is healthy
aws ec2 describe-vpc-endpoints \
  --filters "Name=service-name,Values=com.amazonaws.us-east-1.ecr.dkr" \
  --query 'VpcEndpoints[0].State'

# Verify task execution role can access ECR
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:role/shopflow-ecs-execution-role \
  --action-names "ecr:GetDownloadUrlForLayer" \
  --resource-arns "arn:aws:ecr:us-east-1:123456789012:repository/shopflow/api-service"
```

### Step 5 — Common Fix: Secrets Manager Failure

```bash
# Test that the task can read its secret
aws secretsmanager get-secret-value \
  --secret-id shopflow/prod/db-password \
  --query 'SecretString'
```

### Step 6 — Force New Deployment

```bash
# Force ECS to re-deploy (pulls fresh tasks)
aws ecs update-service \
  --cluster shopflow-prod \
  --service shopflow-prod-api \
  --force-new-deployment

# Monitor progress
watch -n 10 'aws ecs describe-services \
  --cluster shopflow-prod \
  --services shopflow-prod-api \
  --query "services[0].{Running:runningCount,Desired:desiredCount,Pending:pendingCount}"'
```

### Step 7 — Rollback to Previous Task Definition

If the issue is a bad deployment:

```bash
# Get last stable revision
aws ecs list-task-definitions \
  --family-prefix shopflow-prod-api \
  --sort DESC \
  --query 'taskDefinitionArns[:3]'

# Roll back
aws ecs update-service \
  --cluster shopflow-prod \
  --service shopflow-prod-api \
  --task-definition shopflow-prod-api:PREVIOUS_REVISION \
  --force-new-deployment
```

### Escalation Triggers

- More than 5 stopped tasks with `EssentialContainerExited` → escalate to App team (application crash, not infra)
- All 3 AZs showing task failures → escalate to Network team (possible VPC/endpoint issue)
- Issue persists > 15 minutes with no clear cause → wake up SRE lead

### Post-Incident

- [ ] Add stop reason to incident ticket
- [ ] Review CloudWatch logs for root cause
- [ ] Update this runbook if a new failure mode was discovered
- [ ] Create alert for the specific failure mode if missing

---

## Runbook 2: Database Connection Exhaustion

**Alert:** `RDSHighConnections` fires — connections > 800
**Severity:** P1 if > 950 (near max_connections limit), P2 if > 800

---

### Symptoms

- Alert: `RDS connection count approaching max_connections limit`
- Application logs: `Too many connections` or `HikariPool-1 - Connection is not available`
- Grafana: RDS Connections panel showing flat line near 1000
- Users: intermittent errors, slow page loads

### Impact

- New connections rejected → cascading failures across all services
- Once `max_connections` is hit, database becomes completely unreachable

---

### Step 1 — Check Current Connection Count

```bash
# CloudWatch metric — current connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBClusterIdentifier,Value=shopflow-prod \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Maximum

# Or query directly from MySQL
mysql -h $RDS_PROXY_ENDPOINT -u shopflow_admin -p shopflow \
  -e "SHOW STATUS LIKE 'Threads_connected';"
```

### Step 2 — Identify Connection Sources

```sql
-- Connect to the writer endpoint (not proxy, to see real connections)
mysql -h $WRITER_ENDPOINT -u shopflow_admin -p

-- Where are connections coming from?
SELECT
  user,
  host,
  COUNT(*) AS connection_count,
  db,
  command
FROM information_schema.processlist
GROUP BY user, LEFT(host, LOCATE(':', host) - 1), db, command
ORDER BY connection_count DESC;

-- Any long-running queries holding connections?
SELECT
  id, user, host, db, command, time, state,
  LEFT(info, 100) AS query
FROM information_schema.processlist
WHERE command != 'Sleep'
  AND time > 30
ORDER BY time DESC;
```

### Step 3 — Check RDS Proxy

RDS Proxy should multiplex connections. If connections are bypassing the proxy, it won't help.

```bash
# Check proxy connection count
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name ClientConnections \
  --dimensions Name=ProxyName,Value=shopflow-prod-rds-proxy \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Maximum

# Is proxy healthy?
aws rds describe-db-proxies \
  --db-proxy-name shopflow-prod-rds-proxy \
  --query 'DBProxies[0].Status'
```

### Step 4 — Emergency: Kill Idle Connections

```sql
-- Kill sleeping connections older than 5 minutes
SELECT CONCAT('KILL ', id, ';')
FROM information_schema.processlist
WHERE command = 'Sleep'
  AND time > 300
  AND user = 'shopflow_api';

-- Execute (be careful — confirm with DBA before running in prod)
-- Run the CONCAT output as individual KILL statements
```

### Step 5 — Scale Up ECS Tasks (Reduces per-task connections)

Counterintuitively, **fewer ECS tasks** can reduce total connections if each task holds fewer connections. Check if a recent scale-out caused the spike:

```bash
# Check if connection spike correlates with ECS scale-out
aws cloudwatch get-metric-statistics \
  --namespace ECS/ContainerInsights \
  --metric-name RunningTaskCount \
  --dimensions Name=ClusterName,Value=shopflow-prod Name=ServiceName,Value=shopflow-prod-api \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Maximum
```

### Step 6 — Temporary max_connections Increase

Only as a last resort (requires instance reboot to apply via parameter group):

```bash
# Increase max_connections in parameter group
aws rds modify-db-cluster-parameter-group \
  --db-cluster-parameter-group-name shopflow-prod-aurora-mysql8 \
  --parameters "ParameterName=max_connections,ParameterValue=2000,ApplyMethod=immediate"
```

### Escalation Triggers

- Connections > 950 with no improvement in 5 minutes → escalate to DBA
- Application not using RDS Proxy → escalate to App team to fix connection string

### Post-Incident

- [ ] Verify RDS Proxy is being used by all services
- [ ] Review connection pool settings (`min=2, max=10` per task is usually right)
- [ ] Add pre-emptive alert at 700 connections (earlier warning)
- [ ] Consider adding a `wait_timeout` parameter to auto-close idle connections

---

## Runbook 3: High API Latency Investigation

**Alert:** `HighLatencyP99` fires — p99 latency > 500ms for 5 minutes
**Severity:** P2

---

### Symptoms

- Alert: `API p99 latency exceeds 500ms`
- Grafana latency panels showing degradation
- Users complaining: "site feels slow", "checkout is hanging"
- p99 > 500ms but error rate still < 1%

---

### Step 1 — Determine Scope

```bash
# Is it all endpoints or specific ones?
# Prometheus query — latency by endpoint
# Run in Grafana Explore:
# histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{job="shopflow-api"}[5m])) by (le, handler))
```

```bash
# Is it both services or just one?
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=$ALB_ARN Name=TargetGroup,Value=$CHECKOUT_TG_ARN \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics p99 \
  --extended-statistics p99
```

### Step 2 — Check Resource Saturation

```bash
# ECS CPU & Memory
aws cloudwatch get-metric-statistics \
  --namespace ECS/ContainerInsights \
  --metric-name CpuUtilized \
  --dimensions Name=ClusterName,Value=shopflow-prod Name=ServiceName,Value=shopflow-prod-api \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average

# If CPU > 80% on tasks → latency is from CPU saturation
# Fix: trigger manual scale-out
aws application-autoscaling put-scheduled-action \
  --service-namespace ecs \
  --resource-id service/shopflow-prod/shopflow-prod-api \
  --scalable-dimension ecs:service:DesiredCount \
  --scheduled-action-name emergency-scale-out \
  --schedule "at($(date -u +%Y-%m-%dT%H:%M:%S))" \
  --scalable-target-action MinCapacity=10,MaxCapacity=20
```

### Step 3 — Check Database Latency

```bash
# RDS read/write latency
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name ReadLatency \
  --dimensions Name=DBClusterIdentifier,Value=shopflow-prod \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average

aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name WriteLatency \
  --dimensions Name=DBClusterIdentifier,Value=shopflow-prod \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average
```

```sql
-- If DB latency is high, check for lock contention
SHOW ENGINE INNODB STATUS\G

-- Long-running transactions
SELECT
  trx_id, trx_state, trx_started, trx_wait_started,
  TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS trx_duration_sec,
  trx_rows_locked, trx_rows_modified
FROM information_schema.innodb_trx
ORDER BY trx_duration_sec DESC;

-- Index usage (queries with full table scan)
SELECT
  digest_text,
  count_star,
  avg_timer_wait/1000000000 AS avg_ms
FROM performance_schema.events_statements_summary_by_digest
WHERE digest_text LIKE '%orders%'
ORDER BY avg_timer_wait DESC
LIMIT 10;
```

### Step 4 — Check Redis / Cache Efficiency

```bash
# Redis CPU
aws cloudwatch get-metric-statistics \
  --namespace AWS/ElastiCache \
  --metric-name EngineCPUUtilization \
  --dimensions Name=ReplicationGroupId,Value=shopflow-prod-redis \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average

# Redis hit rate (low hit rate = more DB queries = higher latency)
# Prometheus query: aws_elasticache_cache_hits_sum / (aws_elasticache_cache_hits_sum + aws_elasticache_cache_misses_sum)
```

```bash
# Use redis-cli to check
redis-cli -h $REDIS_ENDPOINT -p 6379 -a $AUTH_TOKEN INFO stats | grep -E 'keyspace_hits|keyspace_misses'
```

### Step 5 — Check for Downstream Service Issues

```bash
# AWS X-Ray service map (shows latency across services)
aws xray get-service-graph \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)

# Find slow trace IDs
aws xray get-traces \
  --filter-expression "responsetime > 0.5 AND service(id(name: \"shopflow-api\"))" \
  --sampling false
```

### Step 6 — Check for External Dependencies

```bash
# Is the latency introduced by a 3rd party API (payment, shipping)?
# Check X-Ray for external HTTP calls
# In application logs:
aws logs insights-query \
  --log-group /aws/ecs/shopflow-prod/api \
  --query-string 'fields @message | filter @message like "external" | stats avg(duration) by endpoint'
```

### Escalation Triggers

- DB latency > 100ms p95 with no obvious cause → escalate to DBA
- Redis hit rate < 50% → escalate to App team (likely a cache invalidation bug)
- ECS CPU > 90% and scale-out not helping → escalate to App team (efficiency issue)

---

## Runbook 4: Prometheus Monitoring Issues

**Alert:** On-call engineer notices Grafana panels showing "No Data" or CloudWatch alert fires for "Prometheus health check failed"
**Severity:** P2 — monitoring blind spot (not a user-facing outage, but prevents detecting one)

---

### Symptoms

- Grafana dashboards show "No data" or "N/A" for metrics that normally have data
- Alert: `ServiceDown{job="shopflow-api"}` fires but no application issues are visible
- Prometheus UI shows targets as DOWN
- Alert: `PrometheusNotConnectedToAlertmanager`

---

### Step 1 — Check Prometheus Container Health

```bash
# Is the Prometheus ECS task running?
aws ecs describe-services \
  --cluster shopflow-prod \
  --services shopflow-prod-prometheus \
  --query 'services[0].{Running:runningCount,Desired:desiredCount,Status:status}'

# Check container logs
aws logs tail /aws/ecs/shopflow-prod/prometheus --since 30m
```

### Step 2 — Check Prometheus Targets

```bash
# Port-forward to Prometheus (via ECS Exec or bastion)
# Then check:
curl http://prometheus:9090/api/v1/targets | python3 -m json.tool | grep -A5 "health"

# Or check via the Prometheus UI: http://prometheus:9090/targets
# Look for: state = "down" and lastError field
```

Common target DOWN errors:
| Error | Cause | Fix |
|-------|-------|-----|
| `dial tcp: i/o timeout` | Security group blocks port 9100 | Check ECS SG allows 9100 from monitoring SG |
| `connection refused` | Exporter container crashed | Check task logs, restart exporter |
| `context deadline exceeded` | Scrape timeout | Increase scrape_timeout in config |
| `certificate verify failed` | TLS mismatch | Disable TLS verify or fix cert |

### Step 3 — Check EFS Mount (Data Persistence)

```bash
# Is EFS mounted in the Prometheus container?
aws ecs execute-command \
  --cluster shopflow-prod \
  --task $PROMETHEUS_TASK_ARN \
  --container prometheus \
  --interactive \
  --command "df -h /prometheus/data"

# If EFS mount failed, Prometheus uses ephemeral storage and loses data on restart
# Check mount target health
aws efs describe-mount-targets \
  --file-system-id $EFS_ID \
  --query 'MountTargets[*].{AZ:AvailabilityZoneName,State:LifeCycleState}'
```

### Step 4 — Check TSDB (Time Series Database)

```bash
# Inside Prometheus container
# Check disk usage
df -h /prometheus/data

# Check TSDB status
curl http://localhost:9090/api/v1/status/tsdb | python3 -m json.tool

# If disk full: check retention settings
# --storage.tsdb.retention.size=10GB should auto-clean
# Manual cleanup if needed:
curl -X POST http://localhost:9090/api/v1/admin/tsdb/clean_tombstones
```

### Step 5 — Check Alertmanager Connectivity

```bash
# Is Alertmanager running?
aws ecs describe-services \
  --cluster shopflow-prod \
  --services shopflow-prod-alertmanager \
  --query 'services[0].{Running:runningCount,Desired:desiredCount}'

# Check Prometheus → Alertmanager connection
curl http://prometheus:9090/api/v1/alertmanagers

# Reload Prometheus config (no restart needed)
curl -X POST http://prometheus:9090/-/reload
```

### Step 6 — Restart Prometheus (Last Resort)

```bash
# Force new Prometheus task (EFS data is persistent)
aws ecs update-service \
  --cluster shopflow-prod \
  --service shopflow-prod-prometheus \
  --force-new-deployment

# Wait for it to be stable
aws ecs wait services-stable \
  --cluster shopflow-prod \
  --services shopflow-prod-prometheus

# Verify targets after restart
sleep 60
curl http://prometheus:9090/api/v1/targets?state=unhealthy
```

### Step 7 — Restore Alerting During Outage

If Prometheus is down but you need alerting, use CloudWatch alarms as a backup:

```bash
# Enable CloudWatch alarm for ECS service health (as backup during Prometheus outage)
aws cloudwatch put-metric-alarm \
  --alarm-name "shopflow-prod-api-tasks-backup" \
  --metric-name RunningTaskCount \
  --namespace ECS/ContainerInsights \
  --dimensions Name=ClusterName,Value=shopflow-prod Name=ServiceName,Value=shopflow-prod-api \
  --comparison-operator LessThanThreshold \
  --threshold 3 \
  --period 60 \
  --evaluation-periods 2 \
  --statistic Average \
  --alarm-actions $SNS_ARN
```

### Escalation Triggers

- EFS mount failures in multiple AZs → escalate to infra team
- Prometheus data corrupted (TSDB errors) → escalate, may need full TSDB rebuild from remote_write backup
- Alertmanager not routing pages for > 10 minutes → manually notify on-call via phone/Slack

### Post-Incident

- [ ] Add CloudWatch backup alarms for critical services (not solely reliant on Prometheus)
- [ ] Review Prometheus resource limits (if OOMKilled)
- [ ] Consider adding Prometheus remote_write to Thanos/Cortex for long-term storage
- [ ] Document monitoring SLO: "monitoring system itself should have 99.9% uptime"

---

**[Part 10: SRE Interview Q&A →](enterprise-sre-lab-part10-interview.md)**
