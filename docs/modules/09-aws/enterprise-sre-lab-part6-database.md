---
title: "Part 6: RDS Aurora MySQL Multi-AZ + ElastiCache Redis Cluster"
description: Aurora MySQL cluster with read replicas, ElastiCache Redis cluster mode, connection pooling, and backup strategy
---

# Part 6: RDS Aurora MySQL Multi-AZ + ElastiCache Redis Cluster

**← [Part 5: ECS Fargate](enterprise-sre-lab-part5-ecs.md) | [Part 7: Prometheus & Grafana →](enterprise-sre-lab-part7-monitoring.md)**

---

## Objective

Provision a production-grade Aurora MySQL cluster with 3-AZ replication, read replicas, enhanced monitoring, and slow query logging. Set up an ElastiCache Redis cluster in cluster mode for session management and caching. Configure connection pooling with RDS Proxy.

---

## Database Architecture

```
Application Layer (ECS Tasks)
         │
         ▼
    RDS Proxy (connection pooling)
         │
    ┌────┴────────────────┐
    │                     │
 Writer Endpoint       Reader Endpoint
    │                     │
Aurora MySQL          Aurora MySQL
 Primary (1a)         Read Replica 1 (1b)
                      Read Replica 2 (1c)

ElastiCache Redis Cluster Mode
    │
 Shard 1 (Primary + Replica)  →  AZ-a
 Shard 2 (Primary + Replica)  →  AZ-b
 Shard 3 (Primary + Replica)  →  AZ-c
```

---

## Step 1 — Aurora MySQL Cluster

### DB Subnet Group

```hcl
resource "aws_db_subnet_group" "main" {
  name       = "shopflow-${var.environment}-db-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name = "shopflow-${var.environment}-db-subnet-group"
  }
}
```

### Aurora Parameter Group

```hcl
resource "aws_rds_cluster_parameter_group" "main" {
  name        = "shopflow-${var.environment}-aurora-mysql8"
  family      = "aurora-mysql8.0"
  description = "ShopFlow Aurora MySQL 8.0 parameter group"

  # Performance tuning
  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "1"  # Log queries > 1 second
  }

  parameter {
    name  = "log_queries_not_using_indexes"
    value = "1"
  }

  parameter {
    name  = "performance_schema"
    value = "1"
    apply_method = "pending-reboot"
  }

  # Security
  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  tags = {
    Name = "shopflow-${var.environment}-aurora-params"
  }
}

resource "aws_db_parameter_group" "instance" {
  name   = "shopflow-${var.environment}-aurora-mysql8-instance"
  family = "aurora-mysql8.0"

  parameter {
    name  = "general_log"
    value = "0"  # Disable in prod (too verbose)
  }

  tags = {
    Name = "shopflow-${var.environment}-aurora-instance-params"
  }
}
```

### Aurora Cluster Resource

```hcl
resource "aws_rds_cluster" "main" {
  cluster_identifier = "shopflow-${var.environment}"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"
  engine_mode        = "provisioned"

  database_name   = "shopflow"
  master_username = "shopflow_admin"
  manage_master_user_password = true  # AWS manages rotation automatically

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  backup_retention_period   = var.rds_backup_retention  # 14 days for prod
  preferred_backup_window   = "03:00-04:00"             # 3-4 AM UTC
  preferred_maintenance_window = "mon:04:00-mon:05:00"  # Mon 4-5 AM

  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "shopflow-prod-final-${formatdate("YYYY-MM-DD", timestamp())}" : null

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery"
  ]

  # Auto-scaling storage (Aurora Serverless v2 style)
  serverlessv2_scaling_configuration {
    max_capacity = 64
    min_capacity = 0.5
  }

  tags = {
    Name = "shopflow-${var.environment}-aurora"
  }
}
```

### Aurora Cluster Instances

```hcl
# Writer instance
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "shopflow-${var.environment}-writer"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverlessv2"  # Auto-scales
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  db_parameter_group_name = aws_db_parameter_group.instance.name

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = var.kms_key_arn

  auto_minor_version_upgrade = true

  tags = {
    Name = "shopflow-${var.environment}-aurora-writer"
    Role = "writer"
  }
}

# Read replicas (2 additional instances for read scaling)
resource "aws_rds_cluster_instance" "reader" {
  count = 2

  identifier         = "shopflow-${var.environment}-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverlessv2"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  db_parameter_group_name = aws_db_parameter_group.instance.name

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Promote reader 0 first if writer fails
  promotion_tier = count.index

  auto_minor_version_upgrade = true

  tags = {
    Name = "shopflow-${var.environment}-aurora-reader-${count.index + 1}"
    Role = "reader"
  }
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "shopflow-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
```

---

## Step 2 — RDS Proxy (Connection Pooling)

RDS Proxy pools database connections, reducing connection overhead for high-concurrency ECS workloads. Critical when each Fargate task opens its own DB connections.

```hcl
resource "aws_db_proxy" "main" {
  name                   = "shopflow-${var.environment}-rds-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [var.rds_security_group_id]
  vpc_subnet_ids         = var.data_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "REQUIRED"  # Require IAM authentication
    secret_arn  = aws_rds_cluster.main.master_user_secret[0].secret_arn
  }

  tags = {
    Name = "shopflow-${var.environment}-rds-proxy"
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 90
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "main" {
  db_cluster_identifier = aws_rds_cluster.main.id
  db_proxy_name         = aws_db_proxy.main.name
  target_group_name     = aws_db_proxy_default_target_group.main.name
}

# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy" {
  name = "shopflow-${var.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "rds_proxy" {
  name = "rds-proxy-policy"
  role = aws_iam_role.rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = aws_rds_cluster.main.master_user_secret[0].secret_arn
    }]
  })
}
```

---

## Step 3 — ElastiCache Redis Cluster

### Subnet Group and Parameter Group

```hcl
resource "aws_elasticache_subnet_group" "main" {
  name       = "shopflow-${var.environment}-redis-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name = "shopflow-${var.environment}-redis-subnet-group"
  }
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "shopflow-${var.environment}-redis7"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"  # Evict least recently used keys
  }

  parameter {
    name  = "activerehashing"
    value = "yes"
  }

  parameter {
    name  = "lazyfree-lazy-eviction"
    value = "yes"  # Async eviction to avoid latency spikes
  }

  parameter {
    name  = "tcp-keepalive"
    value = "300"
  }

  tags = {
    Name = "shopflow-${var.environment}-redis-params"
  }
}
```

### Redis Replication Group (Cluster Mode Enabled)

```hcl
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "shopflow-${var.environment}-redis"
  description          = "ShopFlow Redis cluster for ${var.environment}"

  node_type            = var.redis_node_type  # cache.r6g.large for prod
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.redis_security_group_id]

  # Cluster mode: 3 shards, each with 1 replica
  num_node_groups         = 3  # Number of shards
  replicas_per_node_group = 1  # 1 replica per shard = 6 total nodes

  automatic_failover_enabled = true
  multi_az_enabled           = true

  engine_version = "7.0"

  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn
  transit_encryption_enabled = true
  auth_token                 = var.redis_auth_token  # From Secrets Manager

  snapshot_retention_limit = 7
  snapshot_window          = "04:00-05:00"
  maintenance_window       = "mon:05:00-mon:06:00"

  auto_minor_version_upgrade = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name = "shopflow-${var.environment}-redis"
  }
}

resource "aws_cloudwatch_log_group" "redis_slow" {
  name              = "/aws/elasticache/shopflow-${var.environment}/slow-log"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "redis_engine" {
  name              = "/aws/elasticache/shopflow-${var.environment}/engine-log"
  retention_in_days = 7
}
```

---

## Step 4 — Database Secrets Management

```hcl
# Redis auth token stored in Secrets Manager
resource "aws_secretsmanager_secret" "redis_auth" {
  name                    = "shopflow/${var.environment}/redis-auth-token"
  recovery_window_in_days = 7
  kms_key_id              = var.kms_key_arn

  tags = {
    Name = "shopflow-${var.environment}-redis-auth"
  }
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id = aws_secretsmanager_secret.redis_auth.id
  secret_string = jsonencode({
    auth_token = var.redis_auth_token
    endpoint   = aws_elasticache_replication_group.main.configuration_endpoint_address
    port       = 6379
  })
}

# RDS connection info secret
resource "aws_secretsmanager_secret" "rds_connection" {
  name                    = "shopflow/${var.environment}/rds-connection"
  recovery_window_in_days = 7
  kms_key_id              = var.kms_key_arn

  tags = {
    Name = "shopflow-${var.environment}-rds-connection"
  }
}

resource "aws_secretsmanager_secret_version" "rds_connection" {
  secret_id = aws_secretsmanager_secret.rds_connection.id
  secret_string = jsonencode({
    writer_endpoint = aws_rds_cluster.main.endpoint
    reader_endpoint = aws_rds_cluster.main.reader_endpoint
    proxy_endpoint  = aws_db_proxy.main.endpoint
    database        = aws_rds_cluster.main.database_name
    port            = aws_rds_cluster.main.port
  })
}
```

---

## Step 5 — CloudWatch Alarms for RDS & Redis

```hcl
# RDS: CPU > 80%
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "shopflow-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Aurora MySQL CPU exceeded 80%"
  alarm_actions       = [var.sns_alarm_arn]
  ok_actions          = [var.sns_alarm_arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }
}

# RDS: Freeable Memory < 512 MB
resource "aws_cloudwatch_metric_alarm" "rds_memory_low" {
  alarm_name          = "shopflow-${var.environment}-rds-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 536870912  # 512 MB in bytes
  alarm_description   = "Aurora MySQL freeable memory below 512MB"
  alarm_actions       = [var.sns_alarm_arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }
}

# RDS: Database Connections > 800
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "shopflow-${var.environment}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 800
  alarm_description   = "RDS connection count approaching max_connections limit"
  alarm_actions       = [var.sns_alarm_arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }
}

# Redis: CPU > 70%
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "shopflow-${var.environment}-redis-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "ElastiCache Redis CPU exceeded 70%"
  alarm_actions       = [var.sns_alarm_arn]

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.main.id
  }
}

# Redis: Memory > 80%
resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "shopflow-${var.environment}-redis-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ElastiCache Redis memory usage exceeded 80%"
  alarm_actions       = [var.sns_alarm_arn]

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.main.id
  }
}
```

---

## Step 6 — Database Backup and Recovery Testing

### Manual snapshot for testing

```bash
# Create a manual cluster snapshot
aws rds create-db-cluster-snapshot \
  --db-cluster-identifier shopflow-prod \
  --db-cluster-snapshot-identifier shopflow-prod-manual-$(date +%Y%m%d)

# Restore to a new cluster (testing recovery)
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier shopflow-recovery-test \
  --snapshot-identifier shopflow-prod-manual-20240115 \
  --engine aurora-mysql \
  --engine-version 8.0.mysql_aurora.3.04.0 \
  --db-subnet-group-name shopflow-prod-db-subnet-group \
  --vpc-security-group-ids sg-xxxxxxxx
```

### Slow Query Analysis

```sql
-- Find top 10 slow queries via Performance Insights
SELECT
  digest_text,
  count_star AS executions,
  avg_timer_wait / 1000000000 AS avg_latency_ms,
  sum_timer_wait / 1000000000 AS total_latency_ms
FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 10;

-- Check index usage
SELECT
  table_schema,
  table_name,
  index_name,
  stat_value AS pages
FROM mysql.innodb_index_stats
WHERE stat_name = 'size'
ORDER BY stat_value DESC
LIMIT 20;

-- Active connections breakdown
SELECT
  user,
  host,
  db,
  command,
  time,
  state,
  info
FROM information_schema.processlist
WHERE command != 'Sleep'
ORDER BY time DESC;
```

---

## Step 7 — Module Outputs

```hcl
output "rds_writer_endpoint" {
  value     = aws_rds_cluster.main.endpoint
  sensitive = true
}

output "rds_reader_endpoint" {
  value     = aws_rds_cluster.main.reader_endpoint
  sensitive = true
}

output "rds_proxy_endpoint" {
  value     = aws_db_proxy.main.endpoint
  sensitive = true
}

output "redis_configuration_endpoint" {
  value     = aws_elasticache_replication_group.main.configuration_endpoint_address
  sensitive = true
}

output "rds_cluster_id" {
  value = aws_rds_cluster.main.cluster_identifier
}
```

---

## Verification Checklist — Part 6

```
[ ] Aurora MySQL cluster created with engine version 8.0
[ ] Slow query log enabled (queries > 1 second)
[ ] Performance Schema enabled
[ ] require_secure_transport ON in parameter group
[ ] Writer instance + 2 read replicas across different AZs
[ ] Storage encryption with KMS CMK
[ ] Automated backups: 14 days retention, 3-4 AM window
[ ] Deletion protection enabled in prod
[ ] Final snapshot identifier set for prod
[ ] CloudWatch slow query and error logs enabled
[ ] RDS Proxy created with IAM auth required
[ ] Connection pool: max 90%, idle 50%
[ ] ElastiCache Redis 7.0 in cluster mode (3 shards, 1 replica each)
[ ] Redis at-rest and in-transit encryption enabled
[ ] Redis auth token in Secrets Manager
[ ] Redis slow log and engine log to CloudWatch
[ ] CloudWatch alarms: RDS CPU, memory, connections; Redis CPU, memory
[ ] DB secrets stored in Secrets Manager (not hardcoded in ECS task)
```

---

**[Part 7: Prometheus & Grafana Monitoring →](enterprise-sre-lab-part7-monitoring.md)**
