# Module 09 · AWS (Solutions Architect Associate)

Amazon Web Services is the world's largest cloud platform. As a DevOps engineer you will spend most of your career running workloads on AWS — provisioning compute, managing storage, designing networks, and securing access. This module prepares you for the **AWS Certified Solutions Architect – Associate (SAA-C04)** exam while giving you practical skills you will use on day one of any cloud role.

## What you will cover

**Lecture 1 — Getting Started with AWS**
Global infrastructure (regions, AZs, edge locations), the shared responsibility model, pricing, free tier, and AWS CLI setup.

**Lecture 2 — IAM**
Users, groups, roles, policies, MFA, permission boundaries, and IAM best practices for production accounts.

**Lecture 3 — EC2 & Storage**
Instance types, AMIs, storage options (EBS, EFS, Instance Store), security groups, Auto Scaling Groups, and Elastic Load Balancers.

**Lecture 4 — S3**
Bucket fundamentals, storage classes, versioning, lifecycle policies, encryption, access control, and static website hosting.

**Lecture 5 — Networking (VPC & Route 53)**
VPC architecture, public/private subnets, NAT gateways, NACLs vs security groups, VPC peering, and Route 53 routing policies.

**Lecture 6 — Databases**
RDS multi-AZ and read replicas, Aurora, ElastiCache (Redis & Memcached), and DynamoDB.

**Lecture 7 — Serverless & Containers**
Lambda, API Gateway, SQS, SNS, EventBridge, ECS with Fargate, and ECR.

**Lecture 8 — Security & Encryption**
KMS, Secrets Manager, SSM Parameter Store, WAF, Shield, GuardDuty, CloudTrail, and AWS Config.

**Lab 1 — IAM Setup**
Create a least-privilege IAM user, attach policies, enable MFA, and verify access with the AWS CLI.

**Lab 2 — EC2 Deployment**
Launch an EC2 instance, configure a security group, SSH in, and deploy a simple web server.

**Lab 3 — S3 Static Website**
Host a static site on S3, configure bucket policies, enable versioning, and front it with CloudFront.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 45 min |
| Lecture 2 | 60 min |
| Lecture 3 | 75 min |
| Lecture 4 | 60 min |
| Lecture 5 | 75 min |
| Lecture 6 | 75 min |
| Lecture 7 | 75 min |
| Lecture 8 | 60 min |
| Lab 1 | 45 min |
| Lab 2 | 60 min |
| Lab 3 | 60 min |

## Prerequisites

- AWS account (free tier is enough for all labs)
- AWS CLI v2 installed: `brew install awscli` or [download from AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Module 07 (Terraform) completed — you will provision some resources with Terraform in the labs
- A credit card attached to your AWS account (required to create an account, but free-tier usage stays at $0)

## Exam quick reference

The SAA-C04 exam is 65 questions, 130 minutes. Domain weights:

| Domain | Weight |
|--------|--------|
| Design Resilient Architectures | 26% |
| Design High-Performing Architectures | 24% |
| Design Secure Architectures | 30% |
| Design Cost-Optimized Architectures | 20% |

Every lecture in this module maps directly to one or more exam domains. Pay attention to the **Exam tip** callouts — they flag the exact traps and patterns that appear on the test.
