# Lecture 1 · Getting Started with AWS

## What AWS is and why it matters

AWS is a collection of on-demand infrastructure services — compute, storage, networking, databases, machine learning, and more — accessed over the internet and billed by usage. Instead of buying and racking physical servers, you call an API and resources appear in seconds.

For DevOps engineers the main benefits are:

- **No capacity planning up-front** — scale from 1 server to 10,000 without a procurement process
- **Pay for what you use** — a t3.micro running for 1 hour costs ~$0.01
- **Global reach** — deploy to 30+ regions without owning a single data centre
- **Managed services** — AWS runs the OS, patching, and hardware for services like RDS and Lambda

---

## Global infrastructure

Understanding AWS's physical layout is directly tested on the SAA-C04 exam.

### Regions

A **region** is a geographic area that contains multiple isolated data centres. Examples: `us-east-1` (N. Virginia), `eu-west-1` (Ireland), `ap-southeast-1` (Singapore).

Each region is completely independent. Data in `us-east-1` does not automatically replicate to `eu-west-1`. This is both a compliance feature (data sovereignty) and your responsibility (you must build cross-region DR yourself).

How to choose a region:

1. **Compliance/data residency** — some data must stay in a specific country
2. **Latency** — pick the region closest to your users
3. **Service availability** — not every service is in every region (new services launch in `us-east-1` first)
4. **Pricing** — the same instance type costs different amounts per region

### Availability Zones

Each region contains **two or more Availability Zones (AZs)**. An AZ is one or more physical data centres with independent power, networking, and cooling. AZs in the same region are connected by high-bandwidth, low-latency links.

The practical rule: **deploy across at least two AZs** to survive a single data-centre failure. AWS managed services like RDS Multi-AZ and ALB handle this automatically when you configure them correctly.

`us-east-1` currently has 6 AZs: `us-east-1a` through `us-east-1f`. The letters are randomised per account so that your `us-east-1a` is not the same physical AZ as your colleague's `us-east-1a` — this distributes load automatically across the pool.

### Edge Locations and Regional Edge Caches

**Edge locations** are smaller AWS points of presence used by CloudFront (CDN) and Route 53 (DNS). There are 400+ edge locations in 90+ cities. They cache content and answer DNS queries close to end users.

**Regional edge caches** sit between origin servers and edge locations and hold less-popular content longer.

```
User → Edge Location → Regional Edge Cache → Origin (S3 / ALB / EC2)
```

---

## The Shared Responsibility Model

This is one of the most-tested concepts on the exam.

| AWS is responsible for | You are responsible for |
|------------------------|------------------------|
| Physical hardware | Your data |
| Network infrastructure | Encryption at rest and in transit |
| Hypervisor | OS patching (EC2) |
| Managed service internals | IAM users, roles, policies |
| Global infrastructure | Security group and NACL configuration |
| Hardware failure replacement | Application vulnerabilities |

A simple way to remember it: **AWS is responsible for security *of* the cloud. You are responsible for security *in* the cloud.**

For managed services the line shifts. With RDS, AWS patches the database engine. With EC2, you patch the OS yourself.

---

## AWS pricing model

### Pay-as-you-go

Most services charge by the second or hour. EC2 charges per second (with a 60-second minimum). S3 charges per GB stored and per request.

### Reserved capacity (Savings Plans / Reserved Instances)

Commit to using a resource for 1 or 3 years and get up to 72% discount. For predictable, always-on workloads this is significant.

- **Standard Reserved Instances** — locked to a specific instance type and region
- **Convertible Reserved Instances** — can change instance type; less discount
- **Savings Plans** — commitment to a $/hour spend level; most flexible

### Spot Instances

Unused EC2 capacity sold at up to 90% discount. AWS can reclaim them with a 2-minute warning. Use for batch jobs, stateless web servers, or CI runners — workloads that can tolerate interruption.

### Free Tier

AWS offers a free tier for 12 months from account creation (and some services are always free):

| Service | Free Tier |
|---------|-----------|
| EC2 | 750 hours/month t2.micro or t3.micro |
| S3 | 5 GB storage, 20,000 GET, 2,000 PUT |
| RDS | 750 hours/month db.t2.micro, 20 GB storage |
| Lambda | 1 million requests/month forever |
| CloudFront | 1 TB data transfer/month for 12 months |

All labs in this module stay within the free tier if you destroy resources after use.

---

## AWS CLI setup

The AWS CLI is how you interact with AWS from the terminal. It wraps the same API calls the console makes.

### Installation

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install

# Verify
aws --version
# aws-cli/2.x.x Python/3.x.x ...
```

### Configuration

```bash
aws configure
# AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name [None]: us-east-1
# Default output format [None]: json
```

This writes to `~/.aws/credentials` and `~/.aws/config`. Never commit these files or hardcode credentials in code.

### Named profiles

Use profiles to manage multiple accounts:

```bash
aws configure --profile dev
aws configure --profile prod

# Use a specific profile
aws s3 ls --profile dev

# Or set the environment variable
export AWS_PROFILE=dev
```

### Verify it works

```bash
# Who are you?
aws sts get-caller-identity

# List your S3 buckets
aws s3 ls

# List EC2 instances in your default region
aws ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType}' --output table
```

---

## AWS Management Console

The web console at `console.aws.amazon.com` is useful for exploration and learning but you should automate everything that runs in production. The console has no audit trail for individual clicks, no code review, and no reproducibility.

Use the console to understand a service. Use the CLI, SDK, or Terraform to manage it.

!!! tip "Exam tip"
    Questions ask about global services vs regional services. **IAM, Route 53, CloudFront, and WAF** are global. Almost everything else (EC2, S3, RDS, VPC, Lambda) is regional. S3 bucket names are globally unique but the data lives in the region you choose.

!!! tip "Exam tip"
    Know the difference between AZ, Region, and Edge Location. A common distractor is placing an RDS Multi-AZ instance across regions — Multi-AZ is within a single region. Cross-region replication is a separate feature.
