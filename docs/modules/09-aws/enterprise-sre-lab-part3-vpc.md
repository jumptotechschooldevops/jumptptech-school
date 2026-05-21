---
title: "Part 3: VPC & Network Architecture"
description: Multi-AZ VPC design, subnets, NAT, VPC endpoints, security groups, NACLs, and Flow Logs
---

# Part 3: VPC & Network Architecture

**← [Part 2: Terraform State](enterprise-sre-lab-part2-terraform.md) | [Part 4: Security Hardening →](enterprise-sre-lab-part4-security.md)**

---

## Objective

Design and provision a production VPC for ShopFlow with proper subnet tiering, redundant NAT Gateways, VPC endpoints for AWS services, security groups, NACLs, and VPC Flow Logs feeding into CloudWatch.

---

## Network Design

```
VPC: 10.0.0.0/16  (65,536 addresses)

Availability Zone A          Availability Zone B          Availability Zone C
─────────────────────        ─────────────────────        ─────────────────────
Public  10.0.1.0/24          Public  10.0.2.0/24          Public  10.0.3.0/24
  └─ ALB, NAT GW               └─ ALB, NAT GW               └─ ALB, NAT GW

Private 10.0.11.0/24         Private 10.0.12.0/24         Private 10.0.13.0/24
  └─ ECS Tasks                  └─ ECS Tasks                 └─ ECS Tasks

Data    10.0.21.0/24         Data    10.0.22.0/24         Data    10.0.23.0/24
  └─ RDS, ElastiCache          └─ RDS, ElastiCache           └─ RDS, ElastiCache
```

**Why 3 tiers?**
- Public: Only load balancers and NAT Gateways touch the internet
- Private: Application containers — no direct internet exposure
- Data: Databases — only reachable from private tier, never from internet

---

## Step 1 — VPC Module

### modules/vpc/main.tf

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "shopflow-${var.environment}-vpc"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "shopflow-${var.environment}-igw"
  }
}

# Public subnets (ALB, NAT GW)
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false  # Never auto-assign public IPs

  tags = {
    Name = "shopflow-${var.environment}-public-${var.availability_zones[count.index]}"
    Tier = "public"
  }
}

# Private subnets (ECS Tasks)
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "shopflow-${var.environment}-private-${var.availability_zones[count.index]}"
    Tier = "private"
  }
}

# Data subnets (RDS, ElastiCache)
resource "aws_subnet" "data" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 21)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "shopflow-${var.environment}-data-${var.availability_zones[count.index]}"
    Tier = "data"
  }
}
```

---

## Step 2 — NAT Gateways

One NAT Gateway per AZ ensures that if one AZ goes down, traffic from other AZs is not affected.

```hcl
# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "shopflow-${var.environment}-nat-eip-${count.index + 1}"
  }
}

# NAT Gateways (one per AZ)
resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "shopflow-${var.environment}-nat-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}
```

---

## Step 3 — Route Tables

```hcl
# Public route table (routes to IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "shopflow-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route tables (one per AZ, each routes to its own NAT GW)
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "shopflow-${var.environment}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Data subnets use the same private route tables
resource "aws_route_table_association" "data" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```

---

## Step 4 — VPC Endpoints

VPC Endpoints keep traffic to AWS services inside the AWS network — no internet traversal through NAT Gateway, which reduces cost and improves security.

```hcl
# S3 Gateway Endpoint (free, no data processing charge)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id
  )

  tags = {
    Name = "shopflow-${var.environment}-s3-endpoint"
  }
}

# ECR API Interface Endpoint (for ECS pulling images)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "shopflow-${var.environment}-ecr-api-endpoint"
  }
}

# ECR DKR Interface Endpoint (for Docker image layers)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "shopflow-${var.environment}-ecr-dkr-endpoint"
  }
}

# Secrets Manager Interface Endpoint
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "shopflow-${var.environment}-secretsmanager-endpoint"
  }
}

# CloudWatch Logs Interface Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "shopflow-${var.environment}-logs-endpoint"
  }
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "shopflow-${var.environment}-vpc-endpoints-sg"
  description = "Allow HTTPS from private subnets to VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopflow-${var.environment}-vpc-endpoints-sg"
  }
}
```

---

## Step 5 — Security Groups

### ALB Security Group (public-facing)

```hcl
resource "aws_security_group" "alb" {
  name        = "shopflow-${var.environment}-alb-sg"
  description = "ALB - allows HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "shopflow-${var.environment}-alb-sg" }
}
```

### ECS Tasks Security Group

```hcl
resource "aws_security_group" "ecs_tasks" {
  name        = "shopflow-${var.environment}-ecs-tasks-sg"
  description = "ECS Tasks - allows traffic only from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "shopflow-${var.environment}-ecs-tasks-sg" }
}
```

### RDS Security Group

```hcl
resource "aws_security_group" "rds" {
  name        = "shopflow-${var.environment}-rds-sg"
  description = "RDS - allows MySQL only from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from ECS tasks only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = { Name = "shopflow-${var.environment}-rds-sg" }
}
```

### ElastiCache Security Group

```hcl
resource "aws_security_group" "redis" {
  name        = "shopflow-${var.environment}-redis-sg"
  description = "ElastiCache - allows Redis only from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from ECS tasks only"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = { Name = "shopflow-${var.environment}-redis-sg" }
}
```

---

## Step 6 — Network ACLs

NACLs are a second layer of defense at the subnet boundary. They are stateless (you need both inbound and outbound rules).

```hcl
# NACL for private subnets — block database ports from public subnets
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Allow inbound from within VPC
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = var.vpc_cidr
  }

  # Allow inbound HTTPS from VPC endpoints
  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = var.vpc_cidr
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "shopflow-${var.environment}-private-nacl"
  }
}

# NACL for data subnets — only allow DB ports from private subnets
resource "aws_network_acl" "data" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.data[*].id

  # Allow MySQL from private subnets only
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3306
    to_port    = 3306
    cidr_block = "10.0.11.0/22"  # Private subnet range
  }

  # Allow Redis from private subnets only
  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 6379
    to_port    = 6379
    cidr_block = "10.0.11.0/22"
  }

  # Allow ephemeral ports for responses
  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = var.vpc_cidr
  }

  # Deny everything else inbound
  ingress {
    rule_no    = 32766
    action     = "deny"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "shopflow-${var.environment}-data-nacl"
  }
}
```

---

## Step 7 — VPC Flow Logs

Flow Logs capture all IP traffic going to and from network interfaces in your VPC. Critical for security investigations and debugging connectivity issues.

```hcl
# CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/shopflow-${var.environment}/flow-logs"
  retention_in_days = 30

  tags = {
    Name = "shopflow-${var.environment}-vpc-flow-logs"
  }
}

# IAM Role for Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "shopflow-${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# Enable Flow Logs on the VPC
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  tags = {
    Name = "shopflow-${var.environment}-flow-logs"
  }
}
```

---

## Step 8 — Module Outputs

### modules/vpc/outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "data_subnet_ids" {
  value = aws_subnet.data[*].id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}
```

---

## Verification Checklist — Part 3

```
[ ] VPC created with correct CIDR and DNS enabled
[ ] 3 public subnets across 3 AZs
[ ] 3 private subnets across 3 AZs
[ ] 3 data subnets across 3 AZs
[ ] Internet Gateway attached to VPC
[ ] 3 NAT Gateways (one per AZ)
[ ] Public route table routes to IGW
[ ] Private route tables route to respective NAT GW
[ ] S3 Gateway Endpoint created
[ ] ECR API + DKR Interface Endpoints created
[ ] Secrets Manager Interface Endpoint created
[ ] CloudWatch Logs Interface Endpoint created
[ ] ALB SG allows 80+443 from internet
[ ] ECS SG allows only from ALB SG
[ ] RDS SG allows only MySQL from ECS SG
[ ] Redis SG allows only 6379 from ECS SG
[ ] Data NACL blocks all traffic except DB ports from private subnets
[ ] VPC Flow Logs enabled and sending to CloudWatch
```

---

**[Part 4: Security Hardening →](enterprise-sre-lab-part4-security.md)**
