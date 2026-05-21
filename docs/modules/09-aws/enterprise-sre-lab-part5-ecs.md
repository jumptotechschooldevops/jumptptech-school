---
title: "Part 5: ECS Fargate Services with Auto Scaling"
description: ECS cluster, task definitions, ALB integration, service auto scaling, and deployment strategies
---

# Part 5: ECS Fargate Services with Auto Scaling

**← [Part 4: Security](enterprise-sre-lab-part4-security.md) | [Part 6: RDS Aurora & Redis →](enterprise-sre-lab-part6-database.md)**

---

## Objective

Deploy the ShopFlow API and Checkout services on ECS Fargate with Application Load Balancer, target tracking auto scaling, health checks, rolling deployments, and container insights.

---

## ECS Architecture

```
Internet → WAF → CloudFront → WAF → ALB
                                     │
                    ┌────────────────┼─────────────────┐
                    │                │                  │
               us-east-1a      us-east-1b         us-east-1c
                    │                │                  │
           ┌────────┴──────┐ ┌───────┴───────┐ ┌───────┴───────┐
           │ api-service   │ │ api-service   │ │ api-service   │
           │ task (2)      │ │ task (2)      │ │ task (2)      │
           │               │ │               │ │               │
           │ checkout      │ │ checkout      │ │ checkout      │
           │ task (2)      │ │ task (2)      │ │ task (2)      │
           └───────────────┘ └───────────────┘ └───────────────┘
```

---

## Step 1 — ECR Repositories

```hcl
resource "aws_ecr_repository" "api" {
  name                 = "shopflow/api-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Name = "shopflow-api-service"
  }
}

resource "aws_ecr_repository" "checkout" {
  name                 = "shopflow/checkout-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Name = "shopflow-checkout-service"
  }
}

# Lifecycle policy: keep only last 10 images
resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
```

---

## Step 2 — ECS Cluster

```hcl
resource "aws_ecs_cluster" "main" {
  name = "shopflow-${var.environment}"

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "shopflow-${var.environment}"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 2  # Always run at least 2 FARGATE tasks (not SPOT)
  }
}

resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/aws/ecs/shopflow-${var.environment}/exec"
  retention_in_days = 7
}
```

---

## Step 3 — Task Definitions

### API Service Task Definition

```hcl
resource "aws_ecs_task_definition" "api" {
  family                   = "shopflow-${var.environment}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.api_cpu     # 1024 (1 vCPU)
  memory                   = var.api_memory  # 2048 (2 GB)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"  # Graviton2 — 20% cheaper
  }

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${var.ecr_registry}/shopflow/api-service:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
          name          = "api-http"
        }
      ]

      environment = [
        { name = "APP_ENV", value = var.environment },
        { name = "PORT", value = "8080" },
        { name = "REDIS_HOST", value = var.redis_endpoint }
      ]

      # Secrets from Secrets Manager (injected at container start)
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:shopflow/${var.environment}/db-password"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:shopflow/${var.environment}/jwt-secret"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/aws/ecs/shopflow-${var.environment}/api"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      # Resource limits to prevent one task from starving others
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]

      # Stop timeout: allow 30s for graceful shutdown
      stopTimeout = 30

      readonlyRootFilesystem = true

      # Drop all capabilities, add only what's needed
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
        initProcessEnabled = true
      }
    },

    # Sidecar: Prometheus exporter
    {
      name      = "prometheus-exporter"
      image     = "prom/node-exporter:latest"
      essential = false

      portMappings = [
        {
          containerPort = 9100
          protocol      = "tcp"
          name          = "metrics"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/aws/ecs/shopflow-${var.environment}/api"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "exporter"
        }
      }
    }
  ])

  tags = {
    Name = "shopflow-${var.environment}-api-task"
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/ecs/shopflow-${var.environment}/api"
  retention_in_days = 30
}
```

---

## Step 4 — Application Load Balancer

```hcl
resource "aws_lb" "main" {
  name               = "shopflow-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod" ? true : false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "shopflow-${var.environment}-alb"
    enabled = true
  }

  tags = {
    Name = "shopflow-${var.environment}-alb"
  }
}

# HTTP → HTTPS redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# Target groups
resource "aws_lb_target_group" "api" {
  name        = "shopflow-${var.environment}-api-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # Required for Fargate

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  deregistration_delay = 30  # Give tasks 30s to finish requests

  tags = {
    Name = "shopflow-${var.environment}-api-tg"
  }
}

resource "aws_lb_target_group" "checkout" {
  name        = "shopflow-${var.environment}-checkout-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  deregistration_delay = 60  # Checkout needs more time for order completion

  tags = {
    Name = "shopflow-${var.environment}-checkout-tg"
  }
}

# Route /checkout/* to checkout service
resource "aws_lb_listener_rule" "checkout" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.checkout.arn
  }

  condition {
    path_pattern {
      values = ["/checkout/*", "/orders/*", "/payment/*"]
    }
  }
}
```

---

## Step 5 — ECS Services

```hcl
resource "aws_ecs_service" "api" {
  name            = "shopflow-${var.environment}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.api_service_desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 2
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4  # 80% SPOT tasks (cheaper), 20% always-on FARGATE
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true  # Auto-rollback on failed deployment
  }

  deployment_controller {
    type = "ECS"  # Rolling update
  }

  # Rolling update: maintain availability during deployments
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # Wait for service to be stable after deployment
  wait_for_steady_state = true

  enable_execute_command = true  # Allow ECS Exec for debugging

  # Spread tasks across AZs for HA
  placement_constraints {
    type = "distinctInstance"
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name      = "api-http"
      discovery_name = "api"

      client_alias {
        port     = 8080
        dns_name = "api.shopflow.internal"
      }
    }
  }

  tags = {
    Name = "shopflow-${var.environment}-api-service"
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
```

---

## Step 6 — Auto Scaling

```hcl
# Auto Scaling Target
resource "aws_appautoscaling_target" "api" {
  max_capacity       = 20
  min_capacity       = var.api_service_desired_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU Target Tracking (scale out when CPU > 70%)
resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "shopflow-${var.environment}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300  # 5 min cooldown before scaling in
    scale_out_cooldown = 60   # 1 min to scale out quickly
  }
}

# Memory Target Tracking (scale out when Memory > 80%)
resource "aws_appautoscaling_policy" "api_memory" {
  name               = "shopflow-${var.environment}-api-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ALB Request Count Scaling (scale based on requests per task)
resource "aws_appautoscaling_policy" "api_requests" {
  name               = "shopflow-${var.environment}-api-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.api.arn_suffix}"
    }
    target_value       = 1000  # Target 1000 requests per task
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Scheduled scaling: scale up before peak hours
resource "aws_appautoscaling_scheduled_action" "api_peak_scale_up" {
  name               = "shopflow-${var.environment}-api-peak-scale-up"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  schedule           = "cron(0 8 * * ? *)"  # 8 AM UTC daily

  scalable_target_action {
    min_capacity = 6
    max_capacity = 20
  }
}

resource "aws_appautoscaling_scheduled_action" "api_off_peak_scale_down" {
  name               = "shopflow-${var.environment}-api-off-peak-scale-down"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  schedule           = "cron(0 2 * * ? *)"  # 2 AM UTC daily

  scalable_target_action {
    min_capacity = var.api_service_desired_count
    max_capacity = 20
  }
}
```

---

## Step 7 — ECS Exec (Emergency Debugging)

```bash
# Enable ECS Exec to connect to a running container
aws ecs execute-command \
  --cluster shopflow-prod \
  --task TASK_ARN \
  --container api \
  --interactive \
  --command "/bin/sh"

# Inside the container: check connectivity
curl -v http://localhost:8080/health
nslookup shopflow-prod.cluster.local
nc -zv $RDS_ENDPOINT 3306
```

!!! warning "ECS Exec in Production"
    ECS Exec is powerful but should be used only during incidents. All sessions are logged to CloudWatch via the execute_command_configuration KMS key.

---

## Step 8 — CloudWatch Container Insights Dashboards

```bash
# View ECS metrics in CloudWatch
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {
      "Id": "cpu",
      "MetricStat": {
        "Metric": {
          "Namespace": "ECS/ContainerInsights",
          "MetricName": "CpuUtilized",
          "Dimensions": [
            {"Name": "ClusterName", "Value": "shopflow-prod"},
            {"Name": "ServiceName", "Value": "shopflow-prod-api"}
          ]
        },
        "Period": 60,
        "Stat": "Average"
      }
    }
  ]' \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)
```

---

## Verification Checklist — Part 5

```
[ ] ECR repositories created with image scanning and immutable tags
[ ] ECR lifecycle policy keeps only last 10 images
[ ] ECS cluster created with Container Insights enabled
[ ] FARGATE + FARGATE_SPOT capacity providers configured (80/20 split)
[ ] API task definition with Graviton2 (ARM64), health check, and read-only root FS
[ ] Secrets injected from Secrets Manager (no env var hardcoding)
[ ] Prometheus exporter sidecar in task definition
[ ] ALB with HTTP→HTTPS redirect, TLS 1.3 policy
[ ] Path-based routing: /checkout/* → checkout target group
[ ] Deployment circuit breaker with auto-rollback enabled
[ ] Rolling deployment: min 100%, max 200%
[ ] CPU (70%) and Memory (80%) target tracking auto scaling
[ ] Request count auto scaling (1000 req/task)
[ ] Scheduled scaling for peak/off-peak hours
[ ] ECS Exec enabled and tested
```

---

**[Part 6: RDS Aurora & ElastiCache Redis →](enterprise-sre-lab-part6-database.md)**
