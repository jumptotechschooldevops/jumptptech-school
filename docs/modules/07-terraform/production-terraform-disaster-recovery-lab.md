---
title: "Production Terraform Disaster Recovery Lab"
description: "Lab Goal   Build a “production-ish” AWS stack with Terraform, then simulate an accidental..."
published: 2026-02-19
source: "https://dev.to/jumptotech/production-terraform-disaster-recovery-lab-36ap"
tags: []
---

# Production Terraform Disaster Recovery Lab



## Lab Goal

Build a “production-ish” AWS stack with Terraform, then simulate an accidental `terraform apply` that deletes/changes networking and breaks traffic. You will:

1. Detect outage fast
2. Identify what changed and why
3. Restore service safely
4. Fix / repair Terraform state (imports, state surgery if needed)
5. Add guardrails so it can’t happen again
6. Explain **state drift** with real examples

---

## Architecture

* **VPC**: public + private subnets across 2 AZs, NAT, IGW
* **EKS**: private nodes, cluster endpoint public/private (your choice)
* **ALB**: created by **AWS Load Balancer Controller** via Kubernetes Ingress
* **RDS**: MySQL in private subnets (not publicly accessible)
* **Terraform Remote State**: S3 backend + DynamoDB lock
* Optional: **CI/CD gate** (GitHub Actions or Jenkins) that prevents apply on main without approvals

Important note: In real production, **ALB should be created by Kubernetes ingress controller** (not Terraform) OR managed by Terraform consistently. This lab teaches both and shows what happens when you mix ownership.

---

## Prerequisites

### Local tools

* AWS CLI configured (`aws sts get-caller-identity` must work)
* Terraform v1.5+
* kubectl
* helm
* eksctl (optional)

### AWS prerequisites

* One AWS account (or use separate dev/prod accounts if you want extra realism)
* Route53 domain optional (not required)

---

## Step 0 — Create Remote State (S3 + DynamoDB)

Create a bootstrap Terraform project (or do it manually once).

### 0.1 Create `bootstrap/` project

`bootstrap/main.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.region
}

variable "region" { type = string }
variable "state_bucket_name" { type = string }
variable "lock_table_name" { type = string }

resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute { name = "LockID" type = "S" }
}
```

Run:

```bash
cd bootstrap
terraform init
terraform apply
```

---

## Step 1 — Create “Production” Terraform Repo Structure

Create repo like this:

```
infra/
  envs/
    prod/
      main.tf
      backend.tf
      providers.tf
      variables.tf
      outputs.tf
      terraform.tfvars
  modules/
    network/
    eks/
    rds/
    iam/
```

### 1.1 Remote backend config (prod)

`infra/envs/prod/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "YOUR_STATE_BUCKET"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "YOUR_LOCK_TABLE"
    encrypt        = true
  }
}
```

### 1.2 Providers + tags

`providers.tf`

```hcl
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "prod-lab"
      Env     = "prod"
      Owner   = "jumptotech"
    }
  }
}
```

---

## Step 2 — Build VPC Module (Production-ish)

**Module requirements**

* 2 public subnets
* 2 private subnets
* NAT gateway
* Route tables

(You can use `terraform-aws-modules/vpc/aws` to save time. In production, teams do.)

Example `modules/network/main.tf` using the VPC module:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

Outputs:

* vpc_id
* public_subnet_ids
* private_subnet_ids

---

## Step 3 — Build EKS Module (Production-ish)

Use `terraform-aws-modules/eks/aws` module.

Key points for a senior-level lab:

* Node groups in **private subnets**
* Cluster logs enabled
* IAM roles clean
* Add-ons (coredns, vpc-cni, kube-proxy)

After apply, set kubeconfig:

```bash
aws eks update-kubeconfig --region us-east-2 --name prod-lab-eks
kubectl get nodes
```

---

## Step 4 — Install AWS Load Balancer Controller (ALB via Ingress)

### 4.1 Create IAM policy + IRSA

* Create OIDC provider for cluster (module can do)
* Create service account with role

Then:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=prod-lab-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

Verify:

```bash
kubectl -n kube-system get deploy aws-load-balancer-controller
kubectl -n kube-system logs deploy/aws-load-balancer-controller --tail=50
```

---

## Step 5 — Deploy App + Ingress to Create ALB

### 5.1 Sample app

Deploy nginx or your Node app. Example nginx:

```bash
kubectl create ns prod
kubectl -n prod create deploy web --image=nginx
kubectl -n prod expose deploy web --port 80
```

### 5.2 Ingress (creates ALB)

`ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: prod
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 80
```

Apply:

```bash
kubectl apply -f ingress.yaml
kubectl -n prod get ingress web
```

You should see an ALB DNS name.

---

## Step 6 — Add RDS (Private)

Create RDS in private subnets, security group allows MySQL from EKS nodes (or app SG).

Test connectivity from a temporary pod:

```bash
kubectl -n prod run mysql-client --rm -it --image=mysql:8 -- bash
mysql -h <rds-endpoint> -u admin -p
```

---

# INCIDENT LAB: “Terraform Apply Broke Prod”

## Step 7 — Pre-incident checks (baseline)

Save baseline outputs:

* ALB DNS
* EKS nodes
* Ingress status
* RDS endpoint

Commands:

```bash
kubectl -n prod get ingress web -o wide
kubectl -n prod get pods,svc
```

---

## Step 8 — Simulate the Disaster (Accidental Apply)

### Scenario A (very realistic): Network change causes ALB to be destroyed/recreated or unreachable

Example: junior changes VPC public subnet tags or routes.

In VPC module (or your tagging), remove the required tags for ALB controller:

Public subnets must have:

* `kubernetes.io/role/elb = 1`
  Private subnets:
* `kubernetes.io/role/internal-elb = 1`
  Both need:
* `kubernetes.io/cluster/<cluster-name> = shared|owned`

Simulate mistake: remove or rename those tags in Terraform and apply:

```bash
terraform plan
terraform apply
```

### Expected result

* ALB controller can’t find correct subnets or ALB targets go unhealthy
* Traffic becomes slow/503 (or ALB disappears and new one tries to create)

---

# OUTAGE RESPONSE: Senior Troubleshooting Flow

## Step 9 — Detect and Confirm

* Users see 503 / timeouts
* Ingress may show no hostname, or targets unhealthy

Check:

```bash
kubectl -n prod get ingress web -o wide
kubectl -n kube-system logs deploy/aws-load-balancer-controller --tail=200
```

Also check AWS:

* EC2 → Load Balancers
* Target Groups health

---

## Step 10 — Identify What Happened (Terraform Evidence)

### 10.1 Use terraform plan history (best practice)

If you run via CI, you should have the plan artifact. In lab, you simulate by:

* Check git diff:

```bash
git diff
```

* Check Terraform state changes:

```bash
terraform show
```

* Look at AWS CloudTrail (who did it):
  Search `DeleteLoadBalancer`, `ModifySubnetAttribute`, `DeleteRouteTable`, `ReplaceRoute`, etc.

---

## Step 11 — Restore Production Safely

This is where senior engineers separate themselves:

### Option 1: Fastest restore (rollback code)

1. Revert the bad commit:

```bash
git revert <commit>
```

2. Run:

```bash
terraform plan
terraform apply
```

This should restore subnet tags/routes so ALB controller can recreate ALB or recover.

### Option 2: If ALB is gone but cluster is OK

* Fix subnet tags first (Terraform)
* Then force ingress reconcile:

```bash
kubectl -n prod annotate ingress web alb.ingress.kubernetes.io/force-reconcile="$(date +%s)" --overwrite
```

(or delete/recreate ingress in worst case)

### Option 3: If Terraform state is damaged or drifted

* If resource exists in AWS but not in state → **import**
* If resource deleted in AWS but still in state → remove from state and re-apply

Examples:

```bash
terraform state list
terraform import module.network.aws_subnet.public[0] subnet-xxxx
terraform state rm module.something.aws_lb.this
terraform apply
```

---

# STATE MANAGEMENT + DRIFT (must know)

## Step 12 — Demonstrate “State Drift”

Drift = **AWS reality ≠ Terraform state/config**.

### 12.1 Create drift on purpose

Manually change something in AWS Console:

* edit a security group rule
* change a subnet tag
* delete a target group

Then run:

```bash
terraform plan
```

You’ll see Terraform wants to “correct” it back. That’s drift.

Explain to students:

* Drift comes from manual console edits, other tools (CloudFormation), controllers (like ALB controller), or AWS auto-changes.

---

# PREVENTION: Senior Guardrails

## Step 13 — Put in “Production” Controls

### 13.1 No direct apply from laptops

* Only CI/CD can apply to prod
* Engineers create PRs; apply requires approvals

### 13.2 Add “plan” + manual approval gate

If using Jenkins:

* Stage: `terraform fmt`, `validate`, `plan`
* Require manual input step for `apply`
* Apply only from `main` branch

### 13.3 Policy-as-code

Add one:

* **OPA / Conftest** (deny dangerous changes)
* **Checkov** / **tfsec** (security)

Example policy idea:

* Deny deleting public subnets
* Deny changing route tables in prod without approval label
* Deny `0.0.0.0/0` SSH

### 13.4 Terraform protections

* `prevent_destroy = true` on critical resources
* Split state:

  * network state separate from app state
  * blast radius smaller
* Use `-target` only in emergencies (and document)

### 13.5 Separate AWS accounts

* dev / stage / prod accounts
* SCPs on prod to prevent deletion of key resources

---

# Capstone: Incident Review Deliverables (Senior-level)

Students must produce:

1. Incident timeline (when, what, who, impact)
2. Root cause (bad tag/route change)
3. Detection gaps (why monitoring didn’t alert earlier)
4. Fix (rollback + restore + state repair)
5. Prevention (gates, policies, controls)


