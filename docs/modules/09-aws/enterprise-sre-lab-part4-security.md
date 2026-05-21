---
title: "Part 4: Security Hardening — WAF, GuardDuty, Security Hub, Macie"
description: Production security layer with WAF rules, threat detection, compliance posture, and S3 data classification
---

# Part 4: Security Hardening

**← [Part 3: VPC](enterprise-sre-lab-part3-vpc.md) | [Part 5: ECS Fargate →](enterprise-sre-lab-part5-ecs.md)**

---

## Objective

Harden the ShopFlow platform with a defense-in-depth security model: WAF for application-layer protection, GuardDuty for threat detection, Security Hub for compliance posture, and Macie for S3 data classification.

---

## Security Architecture

```
Internet
   │
   ▼
CloudFront ──► WAF Web ACL
   │              └─ AWS Managed Rules (Core, Known Bad Inputs, SQLi, XSS)
   │              └─ Rate-based rules
   │              └─ Geo-blocking
   ▼
ALB ──► WAF Web ACL (second layer)
   │
   ▼
ECS Tasks

Side channels:
  GuardDuty ──────────────► SNS ──► PagerDuty
  Security Hub ───────────► EventBridge ──► Lambda (auto-remediation)
  Macie ──────────────────► SNS ──► Security team Slack
  CloudTrail + Config ────► Security Hub (findings aggregation)
```

---

## Step 1 — AWS WAF

### 1.1 Create WAF Web ACL

```hcl
resource "aws_wafv2_web_acl" "shopflow" {
  name        = "shopflow-${var.environment}-waf"
  description = "WAF protection for ShopFlow ${var.environment}"
  scope       = "REGIONAL"  # Use CLOUDFRONT for CloudFront distributions

  default_action {
    allow {}
  }

  # Rule 1: AWS Managed Rules - Common Rule Set (OWASP Top 10)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # Override to count (not block) SQLi false positives during testing
        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: SQL Injection Protection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: Rate-based rule (anti-DDoS)
  rule {
    name     = "RateLimitRule"
    priority = 40

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000  # requests per 5 minutes per IP
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # Rule 5: Geo-block high-risk countries (example)
  rule {
    name     = "GeoBlockRule"
    priority = 50

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["KP", "IR", "CU", "SY"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockRule"
      sampled_requests_enabled   = true
    }
  }

  # Rule 6: IP reputation list
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationList"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "shopflow-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "shopflow-${var.environment}-waf"
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.shopflow.arn
}
```

### 1.2 WAF Logging to S3

```hcl
resource "aws_s3_bucket" "waf_logs" {
  bucket = "shopflow-waf-logs-${var.aws_account_id}"

  tags = {
    Name = "shopflow-${var.environment}-waf-logs"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "shopflow" {
  log_destination_configs = [aws_s3_bucket.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.shopflow.arn

  # Redact sensitive fields from logs
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}
```

---

## Step 2 — Amazon GuardDuty

GuardDuty uses machine learning to detect:
- EC2 instances communicating with known bad IPs
- Unusual API call patterns (credential exfiltration)
- Cryptocurrency mining
- Port scanning
- RDS login anomalies

### 2.1 Enable GuardDuty (Organization-wide)

```hcl
# Enable GuardDuty in the security account (delegated admin)
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Name = "shopflow-${var.environment}-guardduty"
  }
}

# Organization-wide GuardDuty admin delegation
resource "aws_guardduty_organization_admin_account" "main" {
  admin_account_id = var.security_account_id
}

# Auto-enroll new accounts
resource "aws_guardduty_organization_configuration" "main" {
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.main.id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}
```

### 2.2 GuardDuty Findings → SNS → PagerDuty

```hcl
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "shopflow-guardduty-high-severity"
  description = "Route HIGH severity GuardDuty findings to PagerDuty"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]  # HIGH and CRITICAL only
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "GuardDutySNS"
  arn       = aws_sns_topic.security_alerts.arn

  input_transformer {
    input_paths = {
      severity    = "$.detail.severity"
      type        = "$.detail.type"
      description = "$.detail.description"
      account     = "$.detail.accountId"
      region      = "$.region"
    }

    input_template = <<EOF
{
  "alarm": "GuardDuty Finding",
  "severity": "<severity>",
  "type": "<type>",
  "description": "<description>",
  "account": "<account>",
  "region": "<region>"
}
EOF
  }
}

resource "aws_sns_topic" "security_alerts" {
  name              = "shopflow-${var.environment}-security-alerts"
  kms_master_key_id = var.kms_key_id
}
```

---

## Step 3 — AWS Security Hub

Security Hub aggregates findings from GuardDuty, Macie, Inspector, Config, and third-party tools into a single security posture view.

### 3.1 Enable Security Hub with Standards

```hcl
resource "aws_securityhub_account" "main" {}

# AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.main]
}

# CIS AWS Foundations Benchmark v1.4.0
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.4.0"

  depends_on = [aws_securityhub_account.main]
}

# PCI DSS (if processing payments)
resource "aws_securityhub_standards_subscription" "pci" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/pci-dss/v/3.2.1"

  depends_on = [aws_securityhub_account.main]
}

# Enable GuardDuty integration
resource "aws_securityhub_product_subscription" "guardduty" {
  product_arn = "arn:aws:securityhub:${var.aws_region}::product/aws/guardduty"

  depends_on = [aws_securityhub_account.main]
}
```

### 3.2 Auto-Remediation with EventBridge + Lambda

```hcl
# Automatically disable public RDS snapshots
resource "aws_cloudwatch_event_rule" "securityhub_rds_public" {
  name        = "shopflow-remediate-public-rds-snapshot"
  description = "Auto-remediate public RDS snapshots detected by Security Hub"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        GeneratorId = ["aws-foundational-security-best-practices/v/1.0.0/RDS.1"]
        Compliance = {
          Status = ["FAILED"]
        }
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "remediate_rds" {
  rule      = aws_cloudwatch_event_rule.securityhub_rds_public.name
  target_id = "RemediateRDSPublicSnapshot"
  arn       = aws_lambda_function.remediate_rds_snapshot.arn
}
```

---

## Step 4 — Amazon Macie

Macie uses machine learning to discover, classify, and protect sensitive data in S3 (PII, credit cards, credentials).

### 4.1 Enable Macie

```hcl
resource "aws_macie2_account" "main" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# Create Macie classification job for assets bucket
resource "aws_macie2_classification_job" "assets_bucket" {
  job_type = "SCHEDULED"
  name     = "shopflow-assets-pii-scan"

  schedule_frequency {
    weekly_schedule = "MONDAY"
  }

  s3_job_definition {
    bucket_definitions {
      account_id = var.aws_account_id
      buckets    = [var.assets_bucket_name]
    }
  }

  sampling_percentage = 100

  tags = {
    Name = "shopflow-assets-macie-job"
  }

  depends_on = [aws_macie2_account.main]
}
```

### 4.2 Macie Findings → SNS

```hcl
resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = "shopflow-macie-sensitive-data"
  description = "Alert on Macie sensitive data findings"

  event_pattern = jsonencode({
    source      = ["aws.macie"]
    detail-type = ["Macie Finding"]
    detail = {
      type = [
        "SensitiveData:S3Object/Credentials",
        "SensitiveData:S3Object/Financial",
        "SensitiveData:S3Object/Personal"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "macie_sns" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "MacieSNS"
  arn       = aws_sns_topic.security_alerts.arn
}
```

---

## Step 5 — AWS Config Rules

Config continuously records resource configuration changes and evaluates them against compliance rules.

```hcl
resource "aws_config_configuration_recorder" "main" {
  name     = "shopflow-${var.environment}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "shopflow-${var.environment}-config-channel"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

# Managed rules
resource "aws_config_config_rule" "encrypted_volumes" {
  name = "encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds_encryption" {
  name = "rds-storage-encrypted"

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "s3_bucket_public_read" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "mfa_enabled" {
  name = "mfa-enabled-for-iam-console-access"

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  depends_on = [aws_config_configuration_recorder.main]
}
```

---

## Step 6 — KMS Key Policy for Data Encryption

All ShopFlow data at rest is encrypted with KMS CMKs:

```hcl
resource "aws_kms_key" "shopflow_data" {
  description             = "ShopFlow data encryption key - ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow ECS to use this key"
        Effect = "Allow"
        Principal = {
          AWS = var.ecs_task_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow RDS to use this key"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Deny key deletion without MFA"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:DeleteImportedKeyMaterial"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  tags = {
    Name = "shopflow-${var.environment}-data-key"
  }
}
```

---

## Verification Checklist — Part 4

```
[ ] WAF Web ACL created with 6 rules (IP reputation, common, bad inputs, SQLi, rate limit, geo-block)
[ ] WAF associated with ALB
[ ] WAF logging enabled to S3 with sensitive fields redacted
[ ] GuardDuty enabled with S3, Kubernetes, and malware protection data sources
[ ] GuardDuty high-severity findings route to SNS
[ ] Security Hub enabled with FSBP, CIS, and PCI DSS standards
[ ] Security Hub integrated with GuardDuty
[ ] Auto-remediation EventBridge rule for critical Security Hub findings
[ ] Macie enabled and classification job scheduled for assets bucket
[ ] Macie PII findings route to security SNS topic
[ ] AWS Config recorder enabled for all resource types
[ ] Config rules: encrypted-volumes, rds-encryption, s3-public-read-prohibited, mfa-enabled
[ ] KMS CMK created for data encryption with key rotation enabled
[ ] KMS key policy denies deletion without MFA
```

---

**[Part 5: ECS Fargate & Auto Scaling →](enterprise-sre-lab-part5-ecs.md)**
