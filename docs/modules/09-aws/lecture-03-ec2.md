# Lecture 3 · EC2 & Storage

EC2 (Elastic Compute Cloud) is the foundational compute service. You rent virtual machines, choose the OS, configure networking, attach storage, and get root access. Understanding EC2 well makes every other AWS service easier because many services (RDS, EKS, Beanstalk) are built on top of it.

---

## Instance types

Instance type names encode family, generation, and size:

```
t3.medium
│ │  └── size: nano, micro, small, medium, large, xlarge, 2xlarge...
│ └──── generation: 3rd gen
└────── family: T (burstable)
```

### Families

| Family | Optimised for | Examples |
|--------|--------------|---------|
| T | Burstable general purpose | Web servers, dev environments |
| M | General purpose (balanced) | Application servers |
| C | Compute (high vCPU:memory) | CPU-bound workloads, batch |
| R | Memory (high memory:vCPU) | In-memory databases, caches |
| I | Storage (NVMe SSDs) | NoSQL, data warehousing |
| G / P | GPU | ML training, video transcoding |
| Hpc | HPC | Tightly coupled simulations |

For the exam: **T** = Burstable, **C** = Compute, **R** = Ram/Memory, **I** = I/O storage.

### Burstable instances (T family)

T instances accumulate CPU credits when idle and spend them when busy. A t3.micro gets 12 credits/hour; each credit = 1 vCPU at 100% for 1 minute. This is ideal for workloads with low average CPU but occasional spikes.

`t3a` uses AMD processors (cheaper), `t4g` uses ARM (Graviton, cheaper + more efficient).

---

## Purchasing options

| Option | When to use | Discount vs on-demand |
|--------|-------------|----------------------|
| On-demand | Unpredictable workloads, short-term | baseline |
| Savings Plans | Flexible commitment (any family/region) | up to 66% |
| Reserved Instances | Specific instance type commitment | up to 72% |
| Spot | Fault-tolerant, interruption-tolerant | up to 90% |
| Dedicated Host | Licensing compliance, physical isolation | no discount |
| Dedicated Instance | Tenancy isolation (not full host) | ~10% premium |

**Spot interruption**: AWS gives you a 2-minute warning via instance metadata. Design apps to checkpoint state and handle graceful shutdown.

---

## AMIs

An AMI (Amazon Machine Image) is a snapshot of a root volume plus metadata (OS, architecture, block device mappings). It is the template for launching instances.

Sources of AMIs:
- **AWS provided** — Amazon Linux 2023, Ubuntu, Windows Server
- **AWS Marketplace** — pre-installed software (e.g., NGINX Plus, CIS-hardened images)
- **Community AMIs** — shared by other AWS users (review carefully before using)
- **Your own** — create from a running instance or snapshot

### Creating a custom AMI

```bash
# From a running instance
aws ec2 create-image \
  --instance-id i-0abc123def456789 \
  --name "my-app-v1.2.3" \
  --description "App server with nginx 1.24"

# AMI is regional — copy to other regions if needed
aws ec2 copy-image \
  --source-region us-east-1 \
  --source-image-id ami-0abc123 \
  --region eu-west-1 \
  --name "my-app-v1.2.3"
```

---

## User Data

User data is a script that runs once when an instance first launches (as root). Use it for bootstrapping: installing packages, pulling config from S3, starting services.

```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>$(hostname)</h1>" > /usr/share/nginx/html/index.html
```

Pass it at launch:
```bash
aws ec2 run-instances \
  --image-id ami-0abcdef \
  --instance-type t3.micro \
  --user-data file://bootstrap.sh \
  ...
```

Logs: `/var/log/cloud-init-output.log`

---

## Security Groups

Security groups are stateful firewalls that control inbound and outbound traffic to EC2 instances.

- **Stateful**: if you allow inbound on port 80, the response is automatically allowed outbound — you do not need an explicit outbound rule for the return traffic
- Rules can reference **IP CIDR ranges** or **other security groups** (by ID)
- Default: all outbound allowed, all inbound denied
- You can attach multiple security groups to an instance

```bash
# Create a security group
aws ec2 create-security-group \
  --group-name web-sg \
  --description "Web server" \
  --vpc-id vpc-0abc123

# Allow HTTP from anywhere
aws ec2 authorize-security-group-ingress \
  --group-id sg-0abc123 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow SSH only from your IP
aws ec2 authorize-security-group-ingress \
  --group-id sg-0abc123 \
  --protocol tcp \
  --port 22 \
  --cidr $(curl -s ifconfig.me)/32
```

Referencing another security group: allow instances in `app-sg` to reach instances in `db-sg` on port 5432:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-db \
  --protocol tcp \
  --port 5432 \
  --source-group sg-app
```

This is more maintainable than using IP ranges that change as instances scale.

---

## EBS (Elastic Block Store)

EBS provides persistent block storage for EC2. It is the default root volume type for most instances.

Key properties:
- EBS volumes are **AZ-specific** — a volume in `us-east-1a` can only attach to an instance in `us-east-1a`
- Volumes persist independently of instance lifecycle (unless you check "delete on termination")
- You can take **snapshots** (stored in S3, incremental, cross-region copyable)
- Volumes can be resized without downtime

### Volume types

| Type | Use case | Max IOPS | Max throughput |
|------|----------|----------|---------------|
| gp3 | General purpose (root volumes, most workloads) | 16,000 | 1,000 MB/s |
| gp2 | General purpose (older, avoid for new) | 16,000 | 250 MB/s |
| io2 Block Express | Databases requiring high IOPS | 256,000 | 4,000 MB/s |
| io1 | Databases, low latency | 64,000 | 1,000 MB/s |
| st1 | Sequential reads (data warehouses, log processing) | 500 | 500 MB/s |
| sc1 | Cold data, infrequent access | 250 | 250 MB/s |

**gp3** is the default choice for most workloads. IOPS and throughput are configurable independently (unlike gp2 where IOPS scale with size).

### Snapshots

```bash
# Create a snapshot
aws ec2 create-snapshot \
  --volume-id vol-0abc123 \
  --description "Before migration"

# Copy snapshot cross-region
aws ec2 copy-snapshot \
  --source-region us-east-1 \
  --source-snapshot-id snap-0abc123 \
  --region eu-west-1

# Create volume from snapshot (must be same region)
aws ec2 create-volume \
  --snapshot-id snap-0abc123 \
  --availability-zone us-east-1a \
  --volume-type gp3
```

### EBS Encryption

When you enable EBS encryption:
- Data at rest is encrypted with AES-256
- Data in transit between the instance and volume is encrypted
- Snapshots of encrypted volumes are encrypted
- Volumes created from encrypted snapshots are encrypted

Encryption uses KMS keys. You can use the AWS managed key or your own CMK.

---

## Instance Store

Instance store volumes are **ephemeral** — data is lost when the instance stops, hibernates, or fails. They are physically attached NVMe SSDs on the host machine.

When to use instance store:
- Temporary files, buffers, caches
- Scratch space for batch jobs
- Anything you can reconstruct (swap, build artifacts)

Never store persistent data on instance store. The performance (millions of IOPS) is useful for databases that handle their own replication (like Cassandra or Kafka brokers).

---

## EFS (Elastic File System)

EFS is a managed NFS file system that multiple EC2 instances can mount simultaneously — even across AZs.

| | EBS | EFS |
|--|-----|-----|
| Protocol | Block | NFS |
| Concurrency | 1 instance | Thousands of instances |
| AZ scope | Single AZ | Multi-AZ (regional) |
| Size | Provisioned | Grows/shrinks automatically |
| OS | Linux + Windows | Linux only |
| Cost | ~$0.08–0.10/GB/month | ~$0.30/GB/month (Standard) |

Use EFS for shared filesystems: CMS media files, shared application config, machine learning training data accessed by multiple instances.

---

## Elastic Load Balancers

### Types

| Type | Layer | Use case |
|------|-------|---------|
| ALB (Application Load Balancer) | Layer 7 (HTTP/HTTPS) | Web apps, microservices, WebSocket |
| NLB (Network Load Balancer) | Layer 4 (TCP/UDP/TLS) | Ultra-high performance, static IP, gaming |
| GWLB (Gateway Load Balancer) | Layer 3 | Third-party network appliances |
| CLB (Classic) | Layer 4+7 | Legacy only, avoid |

**ALB** is the default choice for web applications. It supports:
- Host-based routing: `api.example.com` → API target group; `www.example.com` → web target group
- Path-based routing: `/api/*` → API servers; `/static/*` → S3
- Authentication via Cognito or OIDC
- WebSocket and HTTP/2
- Sticky sessions (via cookies)

**NLB** when you need: static Elastic IPs per AZ, TCP/UDP pass-through, millions of connections per second.

### Target groups

A target group is a set of targets (EC2 instances, IPs, Lambda functions, or another ALB). The load balancer routes traffic to the group; the group performs health checks.

```bash
# Create target group
aws elbv2 create-target-group \
  --name web-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-0abc123 \
  --health-check-path /health \
  --health-check-interval-seconds 30

# Register targets
aws elbv2 register-targets \
  --target-group-arn arn:aws:elasticloadbalancing:... \
  --targets Id=i-0abc123 Id=i-0def456
```

---

## Auto Scaling Groups

An ASG automatically launches and terminates EC2 instances based on load, maintaining a desired number of healthy instances.

### Configuration

- **Launch template** — defines what instance to launch (AMI, type, SG, user data, IAM role)
- **Min / Desired / Max** — floor, target, and ceiling for instance count
- **VPC and subnets** — which AZs to distribute across (always use multiple AZs)
- **Health check** — EC2 (instance status) or ELB (the load balancer's health check)

### Scaling policies

| Policy | Trigger | Use case |
|--------|---------|---------|
| Target tracking | Keep a metric at a target (e.g., CPU 50%) | Most workloads |
| Step scaling | Add N instances when CPU > 70%, add 2N when > 90% | Variable load |
| Scheduled | Scale at specific times | Predictable daily patterns |
| Predictive | ML forecast based on history | Recurring patterns |

Target tracking is the easiest to configure and works well for most cases:

```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-asg \
  --policy-name cpu-tracking \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 50.0
  }'
```

### Lifecycle hooks

Lifecycle hooks pause instance launch or termination so you can run custom logic:

- **Launch hook**: pull config from Secrets Manager, run smoke tests before joining the ELB
- **Termination hook**: drain connections, flush cache, deregister from service discovery

!!! tip "Exam tip"
    For high availability, always spread ASG instances across **at least 2 AZs** and attach the ASG to an ALB. The ALB health check is more reliable than the EC2 health check for web workloads — the EC2 check only verifies the instance is running, not that your application is responding.

!!! tip "Exam tip"
    EBS is the most common distractor. Remember: **one EBS volume → one instance at a time** (with Multi-Attach on io1/io2 as an exception). For shared storage, use **EFS**. For temporary high-IOPS scratch space, use **Instance Store**.

!!! tip "Exam tip"
    Spot instance + Spot fleet questions often appear. Spot fleet can mix instance types and purchase options to maintain a target capacity. Use `allocation_strategy: capacity-optimized` to minimise interruptions.
