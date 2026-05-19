---
title: "Cloud Service Models — Full SRE Lecture: IaaS, PaaS, SaaS"
description: "🌐 The Big Picture First   Think of cloud service models as a spectrum of responsibility...."
published: 2026-05-07
source: "https://dev.to/jumptotech/cloud-service-models-full-sre-lecture-iaas-paas-saas-44do"
tags: []
---

# Cloud Service Models — Full SRE Lecture: IaaS, PaaS, SaaS

# 

---

## 🌐 The Big Picture First

Think of cloud service models as a **spectrum of responsibility**. The more you move right, the less you manage — but also the less control you have.

```plaintext
YOUR RESPONSIBILITY
◄────────────────────────────────────────────►
Maximum                                Minimum

On-Premises → IaaS → PaaS → SaaS → Serverless
```

A useful analogy is **pizza**:

```plaintext
On-Premises  = Make pizza at home (you own everything)
IaaS         = Order dough & ingredients (you cook it)
PaaS         = Order pizza kit (just assemble & bake)
SaaS         = Order delivery (just eat it)
```

---

## 🏗️ Layer 1 — IaaS (Infrastructure as a Service)

### What it is
You rent raw infrastructure — servers, storage, networking — from a cloud provider. The provider manages the physical hardware. You manage **everything above the hypervisor.**

### Responsibility Split

```plaintext
Provider manages:        You manage:
─────────────────        ───────────────────────
Physical servers    →    Operating System
Data centers        →    Runtime & middleware
Networking HW       →    Applications
Hypervisor          →    Data
Storage HW          →    Security patches
                    →    Scaling
                    →    Backups
                    →    Monitoring
```

### Real Examples
| Provider | IaaS Products |
|---|---|
| AWS | EC2, EBS, VPC, S3 |
| GCP | Compute Engine, Cloud Storage |
| Azure | Virtual Machines, Azure Blob |

### IaaS Use Cases
- Lift & shift migrations from on-prem
- Custom OS configurations needed
- High performance computing (HPC)
- Full control over networking required
- Legacy applications that can't be containerized

### IaaS Code Example — Terraform EC2
```hcl
# You provision and OWN this — classic IaaS
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"

  # YOU are responsible for everything inside this machine
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "company-web-server"
  }
}
```

---

## 🚀 Layer 2 — PaaS (Platform as a Service)

### What it is
The provider manages OS, runtime, middleware, and scaling. You focus purely on **writing and deploying your application code.**

### Responsibility Split

```plaintext
Provider manages:        You manage:
─────────────────        ───────────────────────
Physical servers    →    Application code
Data centers        →    Data
Hypervisor          →    User access
Operating System    →    Configurations
Runtime             →    (sometimes) scaling rules
Middleware          →
Patching            →
Scaling infra       →
```

### Real Examples
| Provider | PaaS Products |
|---|---|
| AWS | Elastic Beanstalk, RDS, Lambda |
| GCP | App Engine, Cloud Run, Cloud SQL |
| Azure | Azure App Service, Azure SQL |
| Others | Heroku, Render, Railway |

### PaaS Use Cases
- Startups moving fast without dedicated DevOps
- Managed databases (RDS handles patching, backups)
- Web apps where you don't care about OS
- Rapid prototyping

### PaaS Code Example — AWS Elastic Beanstalk
```yaml
# You just push code — platform handles the rest
# .ebextensions/app.config

option_settings:
  aws:autoscaling:asg:
    MinSize: 2
    MaxSize: 10
  aws:elasticbeanstalk:environment:
    EnvironmentType: LoadBalanced
  aws:ec2:instances:
    InstanceTypes: t3.medium

# No OS management, no nginx config, no patching
# Platform handles it ALL
```

---

## 💻 Layer 3 — SaaS (Software as a Service)

### What it is
A fully managed application delivered over the internet. You don't manage infrastructure, OS, runtime, or the app itself. You just **use it.**

### Responsibility Split

```plaintext
Provider manages:        You manage:
─────────────────        ───────────────────────
Everything               Your data
Infrastructure      →    User access/permissions
OS & runtime        →    Configurations within app
Application         →    Integrations
Updates & patches   →
Scaling             →
Security            →
```

### Real Examples
| Category | SaaS Products |
|---|---|
| Monitoring | Datadog, New Relic, PagerDuty |
| Communication | Slack, Gmail, Zoom |
| CI/CD | GitHub Actions, CircleCI |
| Security | Okta, CrowdStrike |
| Storage | Dropbox, Google Drive |

### SaaS from SRE perspective
```plaintext
You don't manage the app BUT you must manage:
✅ API integrations with your systems
✅ SSO/SAML configuration
✅ Data retention policies
✅ Vendor SLA monitoring
✅ Cost & license management
✅ Data backup (vendor may not guarantee YOUR data)
```

---

## 🔄 Shared Responsibility Model — Deep Dive

This is **critical for SRE engineers** to understand deeply.

```plaintext
                    ON-PREM   IaaS    PaaS    SaaS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Applications          YOU      YOU     YOU    VENDOR
Data                  YOU      YOU     YOU     YOU ⚠️
Runtime               YOU      YOU    VENDOR  VENDOR
Middleware            YOU      YOU    VENDOR  VENDOR
OS                    YOU      YOU    VENDOR  VENDOR
Virtualization        YOU     VENDOR  VENDOR  VENDOR
Servers               YOU     VENDOR  VENDOR  VENDOR
Storage               YOU     VENDOR  VENDOR  VENDOR
Networking            YOU     VENDOR  VENDOR  VENDOR
Data Center           YOU     VENDOR  VENDOR  VENDOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> ⚠️ **Data is always YOUR responsibility** regardless of model. Even in SaaS, if vendor loses your data — that's your problem operationally.

---

## 🧠 What an SRE Must Know About Each Model

---

### IaaS — SRE Responsibilities

**1. OS Hardening & Patching**
```bash
# You own this with IaaS
# Automated patching with SSM
aws ssm send-command \
  --document-name "AWS-RunPatchBaseline" \
  --targets "Key=tag:Environment,Values=production" \
  --parameters '{"Operation":["Install"]}'
```

**2. Auto Scaling & Self Healing**
```hcl
resource "aws_autoscaling_group" "web" {
  min_size         = 2
  max_size         = 20
  desired_capacity = 4

  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Self-healing — replace unhealthy instances automatically
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
```

**3. Monitoring You Must Set Up Yourself**
```yaml
# Prometheus scrape config for IaaS EC2
scrape_configs:
  - job_name: 'ec2-instances'
    ec2_sd_configs:
      - region: us-east-1
        port: 9100  # node_exporter port
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Environment]
        target_label: environment
```

**4. Backup Strategy**
```bash
# EBS snapshots — YOUR responsibility in IaaS
aws ec2 create-snapshot \
  --volume-id vol-xxxxxxxx \
  --description "Daily backup $(date +%Y-%m-%d)"
```

---

### PaaS — SRE Responsibilities

**1. Monitor What the Platform Exposes**
```python
# RDS is PaaS — you monitor metrics, not the OS
import boto3

cloudwatch = boto3.client('cloudwatch')

# Key RDS metrics to alert on
rds_metrics = [
    'CPUUtilization',        # > 80% = alert
    'FreeStorageSpace',      # < 20% = alert
    'DatabaseConnections',   # near max = alert
    'ReadLatency',           # > 20ms = investigate
    'WriteLatency',          # > 20ms = investigate
    'ReplicaLag',            # > 30s = alert
]
```

**2. Understand Platform Limits**
```plaintext
AWS RDS Limits you MUST know as SRE:
- Max connections per instance type
- Storage autoscaling thresholds
- Failover time (~60-120 seconds)
- Backup retention (1-35 days)
- Maintenance windows impact

If you don't know these → you'll miss incidents
```

**3. Runbook for PaaS Failures**
```markdown
## RDS Failover Runbook

1. Alert fires: RDS_ReplicaLag > 30s
2. Check: AWS Console → RDS → Events
3. If primary unhealthy → failover triggers automatically
4. Expected downtime: 60-120 seconds
5. Verify: application reconnects (check connection pooling)
6. Notify: stakeholders if > 2 min downtime
7. Postmortem: if failover was unexpected
```

---

### SaaS — SRE Responsibilities

**1. Vendor SLA Tracking**
```python
# Track your SaaS vendors' uptime against their SLA
vendors = {
    "datadog": {
        "sla_target": 99.9,
        "status_page": "https://status.datadoghq.com",
        "impact": "CRITICAL"  # no monitoring if down
    },
    "pagerduty": {
        "sla_target": 99.9,
        "status_page": "https://status.pagerduty.com",
        "impact": "CRITICAL"  # no alerting if down
    },
    "github": {
        "sla_target": 99.9,
        "status_page": "https://githubstatus.com",
        "impact": "HIGH"  # no deploys if down
    }
}
```

**2. SaaS Dependency Risk**
```plaintext
As SRE you must ask:
❓ What happens if Datadog goes down?
   → Do we have fallback monitoring?

❓ What happens if PagerDuty goes down?
   → Do we have SMS/phone tree backup?

❓ What happens if GitHub goes down?
   → Can we still deploy hotfixes?

❓ What happens if Okta goes down?
   → Can engineers still access production?
```

**3. Data Backup for SaaS**
```bash
# Even SaaS data needs backup — vendor not responsible
# Example: backup GitHub repos

#!/bin/bash
ORGS=("company-org")
for org in "${ORGS[@]}"; do
  repos=$(gh repo list $org --json name -q '.[].name')
  for repo in $repos; do
    git clone --mirror \
      https://github.com/$org/$repo.git \
      /backups/github/$org/$repo.git
  done
done
```

---

## 📊 SLO/SLI Design Per Model

This is where SRE expertise really shows:

```plaintext
IaaS — You define AND measure everything:
  SLI: Custom metrics from your app + infra
  SLO: 99.9% availability (you control this)
  Error Budget: You own it fully

PaaS — Platform gives you some metrics:
  SLI: Mix of platform metrics + app metrics
  SLO: Limited by platform's own SLA
  Error Budget: Platform failures count against YOU

SaaS — You mostly observe:
  SLI: API response times, login success rate
  SLO: Constrained by vendor SLA
  Error Budget: Vendor downtime burns YOUR budget
```

---

## 🔥 Real Incident Scenarios by Model

### IaaS Incident
```plaintext
Alert: High CPU on EC2 fleet (95%)
SRE Actions:
1. SSH into instance → top → find runaway process
2. Check ASG → is it scaling?
3. Check ALB → redistribute traffic
4. Patch if OS-level issue
5. You have FULL access to diagnose

Resolution time: Fast if skilled, slow if not
```

### PaaS Incident
```plaintext
Alert: RDS connections maxed out
SRE Actions:
1. Check CloudWatch → DatabaseConnections metric
2. Check application → connection pool config
3. Scale instance type (few minutes)
4. Add read replica to distribute load
5. You CANNOT ssh into RDS — limited visibility

Resolution time: Dependent on platform tooling
```

### SaaS Incident
```plaintext
Alert: Datadog not receiving metrics
SRE Actions:
1. Check status.datadoghq.com
2. Check your agent → is it running?
3. If vendor issue → wait + use backup monitoring
4. You have ZERO control over their infrastructure

Resolution time: Entirely up to vendor
```

---

## 💡 Key SRE Takeaways

| Topic | IaaS | PaaS | SaaS |
|---|---|---|---|
| **Toil level** | High | Medium | Low |
| **Control** | Full | Partial | None |
| **Blast radius** | You caused it | Shared | Vendor caused it |
| **MTTR** | You control | Partly you | Vendor controls |
| **Cost model** | Pay per resource | Pay per usage | Pay per seat |
| **Scaling** | Manual/ASG | Auto | Automatic |
| **Patching** | You | Vendor | Vendor |
| **Debugging** | Full access | Limited | API/logs only |

---

## 🎓 Senior SRE Mental Model

At 6 years experience, you should think about this like:

```plaintext
IaaS = Maximum flexibility, maximum toil
       → Use when you NEED control
       → Automate everything or drown

PaaS = Sweet spot for most workloads
       → Understand platform limits deeply
       → Know exactly what you can't control

SaaS = Treat vendors like internal services
       → Track their SLAs
       → Build fallbacks for critical ones
       → Own YOUR data always

Modern SRE reality:
Most companies use ALL THREE simultaneously
Your job = understand the boundary of responsibility
           at each layer and build reliability
           within those constraints
```


