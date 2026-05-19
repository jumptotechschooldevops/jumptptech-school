# Module 07 · Terraform

Infrastructure as Code (IaC) means describing your infrastructure in files that can be version-controlled, reviewed, tested, and applied automatically. Without IaC, infrastructure is managed by people clicking through cloud consoles — configuration drift is inevitable, reproducibility is impossible, and nobody knows who changed what or why.

Terraform is the most widely used IaC tool. It is cloud-agnostic, has providers for every major cloud and many services, and uses a declarative language (HCL) that is readable without prior Terraform experience.

## What you will cover

**Lecture 1 — Infrastructure as Code**
What IaC solves, HCL syntax, providers, resources, variables, outputs, and the plan/apply cycle.

**Lecture 2 — State, Modules & Workspaces**
How Terraform state works, remote backends, module composition, workspace-based environments.

**Lab 1 — Provision AWS Infrastructure**
Provision a VPC, subnets, security groups, and an EC2 instance running nginx. Tear it down cleanly.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 60 min |
| Lecture 2 | 50 min |
| Lab 1 | 90 min |

## Prerequisites

- AWS account (free tier)
- Terraform installed: `brew install terraform` or download from terraform.io
- AWS CLI configured: `aws configure` with an IAM user that has EC2/VPC permissions
