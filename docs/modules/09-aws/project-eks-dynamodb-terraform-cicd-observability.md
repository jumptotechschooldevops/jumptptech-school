---
title: "Project: EKS + DynamoDB + Terraform + CI/CD + Observability"
description: "0) Repo layout      profile-service/ ├─ terraform/ │  ├─ providers.tf │  ├─ variables.tf │ ..."
published: 2025-11-07
source: "https://dev.to/jumptotech/project-eks-dynamodb-terraform-cicd-observability-1cfe"
tags: []
---

# Project: EKS + DynamoDB + Terraform + CI/CD + Observability





## 0) Repo layout

```
profile-service/
├─ terraform/
│  ├─ providers.tf
│  ├─ variables.tf
│  ├─ vpc.tf
│  ├─ eks.tf
│  ├─ iam-irsa.tf
│  ├─ dynamodb.tf
│  ├─ ecr.tf
│  ├─ outputs.tf
├─ k8s/
│  ├─ namespace.yaml
│  ├─ deployment.yaml
│  ├─ service.yaml
│  ├─ ingress.yaml
├─ app/
│  ├─ app.py
│  ├─ requirements.txt
│  ├─ Dockerfile
├─ cicd/
│  └─ github-actions.yaml
├─ scripts/
│  └─ validate_config.py
├─ observability/
│  ├─ kube-prometheus-stack-values.yaml
│  └─ slo-alerts.yaml
└─ README.md
```

---

## 1) Terraform (IaC)

### terraform/providers.tf

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.29" }
    helm = { source = "hashicorp/helm", version = "~> 2.12" }
  }
}

provider "aws" {
  region = "us-east-2"
}

# These two providers will be configured after EKS is created (via outputs)
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_caller_identity" "current" {}
```

### terraform/variables.tf

```hcl
variable "project" { default = "profile-service" }
variable "vpc_cidr" { default = "10.30.0.0/16" }
variable "private_subnets" { default = ["10.30.1.0/24","10.30.2.0/24"] }
variable "public_subnets"  { default = ["10.30.10.0/24","10.30.11.0/24"] }
```

### terraform/vpc.tf

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-public-${each.key}", "kubernetes.io/role/elb" = "1" }
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
  tags = { Name = "${var.project}-private-${each.key}", "kubernetes.io/role/internal-elb" = "1" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "default_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}
```

### terraform/eks.tf

```hcl
resource "aws_eks_cluster" "this" {
  name     = "${var.project}-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = concat([for s in aws_subnet.private : s.id], [for s in aws_subnet.public : s.id])
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.project}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}

data "aws_iam_policy_document" "eks_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["eks.amazonaws.com"] }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project}-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]
  scaling_config  { desired_size = 2, min_size = 2, max_size = 4 }
  instance_types  = ["t3.large"]
  depends_on      = [aws_iam_role_policy_attachment.eks_worker_AmazonEKSWorkerNodePolicy]
}

resource "aws_iam_role" "eks_node" {
  name = "${var.project}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_trust.json
}

data "aws_iam_policy_document" "eks_nodes_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type="Service", identifiers=["ec2.amazonaws.com"] }
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_eks_cluster" "cluster" { name = aws_eks_cluster.this.name }
data "aws_eks_cluster_auth" "cluster" { name = aws_eks_cluster.this.name }
```

### terraform/iam-irsa.tf (IRSA for DynamoDB access)

```hcl
resource "aws_iam_role" "irsa_role" {
  name = "${var.project}-irsa-dynamodb"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Federated = aws_iam_openid_connect_provider.eks.arn },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:profile:app-sa"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "dynamo_rw" {
  name   = "${var.project}-dynamo-rw"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:*"],
      Resource = [aws_dynamodb_table.profiles.arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_rw" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.dynamo_rw.arn
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"] # (AWS published for OIDC, OK for demo)
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
```

### terraform/dynamodb.tf

```hcl
resource "aws_dynamodb_table" "profiles" {
  name         = "${var.project}-profiles"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute { name = "userId"; type = "S" }

  server_side_encryption { enabled = true } # KMS-managed
  point_in_time_recovery { enabled = true } # backups/DR
  tags = { Environment = "prod", Project = var.project }
}
```

### terraform/ecr.tf

```hcl
resource "aws_ecr_repository" "app" {
  name = "${var.project}-api"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}
```

### terraform/outputs.tf

```hcl
output "cluster_name" { value = aws_eks_cluster.this.name }
output "ecr_repo_url" { value = aws_ecr_repository.app.repository_url }
output "dynamodb_table" { value = aws_dynamodb_table.profiles.name }
```

> **Apply steps**
>
> ```
> cd terraform
> terraform init
> terraform apply -auto-approve
> aws eks update-kubeconfig --region us-east-2 --name profile-service-eks
> ```

> **Install AWS Load Balancer Controller via Helm (creates ALBs)**
> (after `terraform apply`)
>
> ```
> helm repo add eks https://aws.github.io/eks-charts
> kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -
> helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
>   -n kube-system \
>   --set clusterName=profile-service-eks \
>   --set serviceAccount.create=true \
>   --set region=us-east-2 \
>   --set vpcId=$(aws eks describe-cluster --name profile-service-eks --region us-east-2 --query "cluster.resourcesVpcConfig.vpcId" --output text)
> ```

---

## 2) App (Flask API)

### app/app.py

```python
from flask import Flask, request, jsonify
import boto3, os

app = Flask(__name__)

TABLE = os.getenv("TABLE_NAME")
REGION = os.getenv("AWS_REGION", "us-east-2")

dynamo = boto3.resource("dynamodb", region_name=REGION)
table = dynamo.Table(TABLE)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/profile")
def upsert_profile():
    body = request.get_json()
    if not body or "userId" not in body:
        return {"error": "userId required"}, 400
    table.put_item(Item=body)
    return {"ok": True, "userId": body["userId"]}

@app.get("/profile/<user_id>")
def get_profile(user_id):
    resp = table.get_item(Key={"userId": user_id})
    return jsonify(resp.get("Item") or {}), 200

if __name__ == "__main__":
    app.run("0.0.0.0", 8080)
```

### app/requirements.txt

```
flask==3.0.0
boto3==1.34.0
gunicorn==21.2.0
```

### app/Dockerfile

```Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
```

---

## 3) Kubernetes Manifests (IRSA + ALB Ingress)

### k8s/namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: profile
```

### k8s/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: profile-api
  namespace: profile
spec:
  replicas: 2
  selector: { matchLabels: { app: profile-api } }
  template:
    metadata: { labels: { app: profile-api } }
    spec:
      serviceAccountName: app-sa
      containers:
      - name: api
        image: REPLACE_WITH_ECR_URL:latest
        ports: [{containerPort: 8080}]
        env:
        - name: TABLE_NAME
          value: "profile-service-profiles"
        - name: AWS_REGION
          value: "us-east-2"
        resources:
          requests: { cpu: "200m", memory: "256Mi" }
          limits:   { cpu: "500m", memory: "512Mi" }
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: profile
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::REPLACE_ACCOUNT_ID:role/profile-service-irsa-dynamodb
```

> Replace `REPLACE_WITH_ECR_URL` and `REPLACE_ACCOUNT_ID` with your values (`terraform output`).

### k8s/service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: profile-api-svc
  namespace: profile
spec:
  type: ClusterIP
  selector: { app: profile-api }
  ports:
    - port: 80
      targetPort: 8080
```

### k8s/ingress.yaml  (public HTTPS via ALB)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: profile-api-ing
  namespace: profile
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    # For simple demo, HTTP. For real prod, attach ACM cert & force HTTPS.
spec:
  rules:
    - http:
        paths:
          - path: /health
            pathType: Prefix
            backend:
              service:
                name: profile-api-svc
                port:
                  number: 80
          - path: /profile
            pathType: Prefix
            backend:
              service:
                name: profile-api-svc
                port:
                  number: 80
```

> Deploy:
>
> ```
> kubectl apply -f k8s/namespace.yaml
> kubectl apply -f k8s/deployment.yaml
> kubectl apply -f k8s/service.yaml
> kubectl apply -f k8s/ingress.yaml
> ```
>
> Find the ALB DNS:
>
> ```
> kubectl get ingress -n profile
> ```

---

## 4) CI/CD (GitHub Actions)

### cicd/github-actions.yaml

```yaml
name: ci-cd

on:
  push:
    branches: [ "main" ]

env:
  AWS_REGION: us-east-2
  ECR_REPO: ${{ secrets.ECR_REPO }}  # set in repo secrets
  CLUSTER: profile-service-eks

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Validate Config (Python)
    - run: python scripts/validate_config.py

    - name: Configure AWS
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id:     ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to ECR
      id: ecr
      uses: aws-actions/amazon-ecr-login@v2

    - name: Build & Push Image
      run: |
        IMAGE_URI=${{ steps.ecr.outputs.registry }}/${{ env.ECR_REPO }}:latest
        docker build -t $IMAGE_URI ./app
        docker push $IMAGE_URI
        echo "IMAGE_URI=$IMAGE_URI" >> $GITHUB_ENV

    - name: Update K8s image
      run: |
        aws eks update-kubeconfig --name $CLUSTER --region $AWS_REGION
        sed -i "s|REPLACE_WITH_ECR_URL|${IMAGE_URI}|g" k8s/deployment.yaml
        kubectl apply -f k8s/deployment.yaml
```

### scripts/validate_config.py

```python
import sys, json, os
# simple check (expand as needed)
required = ["AWS_REGION"]
missing = [k for k in required if not os.getenv(k)]
if missing:
    print(f"Missing env vars: {missing}")
    sys.exit(1)  # Fail pipeline
print("Config looks good.")
```

> **Pipeline behavior if script fails:** exits non-zero → job fails → **deployment stops.**

---

## 5) Observability (Prometheus/Grafana + SLO Alerts)

### Install kube-prometheus-stack (once)

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f observability/kube-prometheus-stack-values.yaml
```

### observability/kube-prometheus-stack-values.yaml (minimal)

```yaml
grafana:
  adminPassword: "admin"
  service:
    type: LoadBalancer
prometheus:
  prometheusSpec:
    retention: 7d
```

### observability/slo-alerts.yaml (example alert on 5xx rate)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: slo-alerts
  namespace: monitoring
spec:
  groups:
  - name: api-availability
    rules:
    - alert: HighErrorRate
      expr: sum(rate(container_cpu_usage_seconds_total{pod=~"profile-api.*"}[5m])) > 1
      for: 10m
      labels: { severity: warning }
      annotations:
        summary: "High error or CPU indicating potential SLI breach"
        description: "Investigate app logs / throttling / DB."
```

> **Interview line:**
> *“SLI = success/latency, SLO = 99.9% success, SLA = 99.5% public. Alerts watch error/latency against SLO.”*

---

## 6) Encryption

* **In transit:** Put the ALB behind HTTPS (attach ACM cert to the Ingress/ALB; in demo we used HTTP for speed).
* **At rest:** DynamoDB KMS enabled (already in Terraform).
* **Secrets:** Prefer AWS Secrets Manager/SSM Parameter Store with IRSA.

**Interview line:** *“TLS to ALB/mTLS if zero-trust; KMS at-rest; no plaintext secrets.”*

---

## 7) DR (optional stretch)

* Turn the DynamoDB table into **Global Table** (add region `us-east-1`), and put **Route 53 latency routing** in front of two regional ALBs.
* Result: **Active-Active**. If us-east-2 fails, traffic flows to us-east-1.

---

## 8) Quick test

After CI/CD deploys:

```
ING=$(kubectl get ing -n profile -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
curl http://$ING/health
curl -X POST http://$ING/profile -H "Content-Type: application/json" -d '{"userId":"123","name":"Aisalkyn"}'
curl http://$ING/profile/123
```

---

## 9) Troubleshooting runbook (read this fast in interviews)

1. **Can’t reach DB:** `nslookup`, `nc -zv host port`, check IRSA role, VPC Flow Logs.
2. **Pods CrashLoop:** `kubectl logs -n profile deploy/profile-api`, check env vars.
3. **Ingress not coming up:** check ALB controller logs, subnets tags, security groups.
4. **Throttling:** DynamoDB metrics; adjust access patterns or add GSI.

---

## 10) Mini Q&A (mapped to this project)

* **DevOps vs SRE?** DevOps = delivery & automation; SRE = reliability (SLI/SLO/SLA, incident response, error budgets).
* **DR for Netflix-scale?** Active-Active multi-region, Global Tables, Route 53/GGA, automated failover.
* **DynamoDB active-active?** Yes, **Global Tables** (multi-region read/write).
* **Encryption?** TLS/mTLS in transit, KMS at rest, Secrets Manager, IRSA.
* **If pipeline script fails?** Non-zero exit → pipeline fails → no deploy → logs/alerts → fix → rerun.
* **External service to EKS app?** ALB/Ingress; VPC routing or TGW/peering; SG-to-SG rules; Route 53 DNS.

---

### What to say in your summary (closing line)

**“I built a small but production-style stack in us-east-2 with Terraform: EKS, DynamoDB, IRSA, ALB Ingress, ECR, CI/CD with Python validation, Prometheus/Grafana observability, encryption in transit/at rest, and an optional multi-region DR extension. I can demo deploys, run tests, and walk through troubleshooting and SRE practices end-to-end.”**




2nd part:

# 1) HTTPS with ACM on the ALB Ingress

## 1.1 Request an ACM cert (in **us-east-2**)

```bash
aws acm request-certificate \
  --domain-name api.example.com \
  --validation-method DNS \
  --region us-east-2
```

Get the validation CNAME from:

```bash
aws acm list-certificates --region us-east-2
aws acm describe-certificate --certificate-arn <CERT_ARN> --region us-east-2
```

Create that CNAME in Route 53 (see 2.2). When ACM shows **ISSUED**, proceed.

## 1.2 Update Ingress for HTTPS + redirect

Replace `<CERT_ARN>` and keep your namespace/service names:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: profile-api-ing
  namespace: profile
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: <CERT_ARN>
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: profile-api-svc
                port:
                  number: 80
```

Apply:

```bash
kubectl apply -f k8s/ingress.yaml
```

---

# 2) Route 53 DNS → ALB

## 2.1 Get ALB hostname created by the Ingress

```bash
kubectl get ingress profile-api-ing -n profile -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
# example: k8s-profile-...us-east-2.elb.amazonaws.com
```

## 2.2 Create Route 53 record

Replace `<HOSTED_ZONE_ID>` and domain:

```bash
cat > r53.json <<'JSON'
{
  "Comment": "api.example.com → ALB",
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "api.example.com",
      "Type": "CNAME",
      "TTL": 60,
      "ResourceRecords": [{ "Value": "ALB_HOSTNAME_HERE" }]
    }
  }]
}
JSON

aws route53 change-resource-record-sets \
  --hosted-zone-id <HOSTED_ZONE_ID> \
  --change-batch file://r53.json
```

When ACM validation CNAME is also present (from 1.1), HTTPS will be valid for `https://api.example.com`.

---

# 3) DynamoDB Global Tables (Active–Active)

Add **us-east-1** as a replica of your table provisioned in **us-east-2**.

## 3.1 Terraform (preferred)

Update `terraform/dynamodb.tf`:

```hcl
resource "aws_dynamodb_table" "profiles" {
  name         = "${var.project}-profiles"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute { name = "userId"; type = "S" }

  server_side_encryption { enabled = true }
  point_in_time_recovery { enabled = true }

  # Global Table replicas (v2 style)
  replica {
    region_name = "us-east-1"
  }

  tags = { Environment = "prod", Project = var.project }
}

# Provider alias for us-east-1 required for replicas
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
```

Also tell Terraform that DynamoDB may use the alias provider:

```hcl
# In dynamodb.tf (top) or providers.tf
# Ensures the provider alias exists; some modules need explicit link
```

Re-apply:

```bash
terraform apply -auto-approve
```

Terraform will convert your table to a **Global Table (v2)** with replicas in **us-east-1**.

## 3.2 App notes (nothing to change usually)

* Your app keeps using the **regional endpoint** via the standard AWS SDK.
* If you deploy the app in both regions, set `AWS_REGION` accordingly in each Deployment.
* **Conflict resolution:** DynamoDB uses **last-writer-wins**; design idempotent writes for safety.

---

# 4) Optional: Route 53 latency routing for multi-region ALBs

If you deploy the **same app** in `us-east-2` and `us-east-1` (two EKS clusters and two Ingress/ALBs), create **two records** and a **Latency** policy:

```json
{
  "Comment": "Latency-based routing for api.example.com",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.example.com",
        "Type": "A",
        "SetIdentifier": "use2",
        "Region": "us-east-2",
        "AliasTarget": {
          "HostedZoneId": "Z3AADJGX6KTTL2",
          "DNSName": "ALB_USE2_HOSTNAME",
          "EvaluateTargetHealth": true
        }
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.example.com",
        "Type": "A",
        "SetIdentifier": "use1",
        "Region": "us-east-1",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "ALB_USE1_HOSTNAME",
          "EvaluateTargetHealth": true
        }
      }
    }
  ]
}
```

> Note: `HostedZoneId` values above are **examples** for ALB aliases and vary by region. Check AWS docs for the correct alias hosted zone IDs for each region, then substitute.

This gives you **active–active** traffic steering and fast failover.

---

# 5) CI/CD tweaks for HTTPS & image rollout

In your GitHub Actions:

* Add `HOSTNAME=api.example.com` as an env/secret.
* After applying `ingress.yaml`, you can verify:

```bash
curl -I https://api.example.com/health
```

If you want **blue/green** or **canary** rollouts, add a second Deployment and route by path/header using the ALB Ingress Controller annotations, or switch to a Service Mesh later.

---

## Quick “interview lines” you can read

* **HTTPS:** “We use ACM for certs, ALB terminates TLS, and we force redirect from 80→443 at the Ingress.”
* **DNS:** “Route 53 CNAME/Alias maps `api.example.com` to the ALB; health checks enable failover.”
* **Global Tables:** “DynamoDB Global Tables give us multi-region active–active with low RPO/RTO.”
* **End-to-end:** “Users hit `https://api.example.com`, Route 53 resolves to the closest ALB, ALB → EKS pods, pods use IRSA to call DynamoDB over HTTPS; data is encrypted at rest with KMS; observability via Prometheus/Grafana.”


3 part:


This Runbook explains:

* How the system works
* What to check during failures
* Commands to run
* How to respond as SRE.

This becomes *your production playbook*.

---

# ✅ **RUNBOOK — Profile Service (EKS + ALB + DynamoDB + IRSA)**

### **Service Summary**

```
User → Route53 → ALB (HTTPS) → EKS Pods → DynamoDB (Global Table)
```

### Core Components

| Component              | Purpose                                    |
| ---------------------- | ------------------------------------------ |
| ALB (Ingress)          | Handles public HTTPS traffic               |
| EKS Deployment         | Runs the Python API                        |
| Service Account (IRSA) | Grants pod access to DynamoDB (no secrets) |
| DynamoDB Global Table  | Stores profile data (multi-region)         |
| Prometheus + Grafana   | Metrics + Dashboards                       |
| CloudWatch Logs        | Application logs                           |

---

## 1) **Health Check**

Check the ALB endpoint or custom domain:

```bash
curl -I https://api.example.com/health
```

**Expected:** `200 OK` & JSON `{"status": "ok"}`

If **down** → Go to Section **2** (Ingress / ALB).

---

## 2) **ALB / Ingress Debugging**

### Get Ingress status:

```bash
kubectl get ingress profile-api-ing -n profile
```

### Get ALB hostname:

```bash
kubectl get ingress profile-api-ing -n profile -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

### Check targets:

```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET_GROUP_ARN> \
  --region us-east-2
```

**If targets are `unhealthy`:**
Go to Section **3** (Pod / App issues).

---

## 3) **Pod / Application Debugging**

### Check Deployment state:

```bash
kubectl get deploy -n profile
```

### Check running pods:

```bash
kubectl get pods -n profile -o wide
```

### Check logs:

```bash
kubectl logs -n profile deploy/profile-api --tail=100
```

### Restart / redeploy:

```bash
kubectl rollout restart deploy/profile-api -n profile
```

---

## 4) **Database Connectivity Check**

### Exec into pod:

```bash
kubectl exec -it -n profile $(kubectl get pod -n profile -o jsonpath='{.items[0].metadata.name}') -- sh
```

### DNS check:

```bash
nslookup profile-service-profiles.<AWS_region>.amazonaws.com
```

### Network test:

```bash
apk add bind-tools curl # if your base image is minimal
curl $TABLE_ENDPOINT  # should not timeout
```

If **DNS or network fails:**

* Check **VPC routing**, **subnets**, **NACL**, **SG-to-SG rules**

If **authentication fails:**

* Go to Section **5 (IRSA)**.

---

## 5) **IRSA Role Debugging (Pod → DynamoDB Access)**

### Confirm pod has correct IAM role:

```bash
kubectl describe sa app-sa -n profile
```

Look for:

```
eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/profile-service-irsa-dynamodb
```

### Check AWS permissions:

```bash
aws iam get-role --role-name profile-service-irsa-dynamodb
aws iam list-attached-role-policies --role-name profile-service-irsa-dynamodb
```

### If denied DynamoDB:

Check CloudWatch Logs → “AccessDeniedException”

Fix by attaching correct IAM policy:

```bash
aws iam attach-role-policy \
  --role-name profile-service-irsa-dynamodb \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
```

*(For production, use least privilege – the original custom policy.)*

---

## 6) **DynamoDB Data Debugging**

### Check if record exists:

```bash
aws dynamodb get-item \
  --table-name profile-service-profiles \
  --key '{"userId": {"S": "123"}}' \
  --region us-east-2
```

### Write test:

```bash
aws dynamodb put-item \
  --table-name profile-service-profiles \
  --item '{"userId": {"S": "test"}, "name": {"S": "Debug"}}' \
  --region us-east-2
```

If table works → issue is **app config / IRSA**.

---

## 7) **Global Table (DR / Multi-Region)**

### Check replication:

```bash
aws dynamodb describe-table \
  --table-name profile-service-profiles \
  --region us-east-2 \
  --query "Table.Replicas"
```

### If us-east-2 fails:

Change DNS routing to us-east-1:

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id <ZONE_ID> \
  --change-batch file://failover-us-east-1.json
```

> This is **instant failover**.

---

## 8) **SLO / Metrics / Observability Checks**

### App success rate (SLI):

View Grafana dashboard:

```
Grafana → Explore → metric: request_success_rate
```

### Error budget check:

```
If success rate < SLO: 99.9% → trigger alert → stop feature releases, start reliability improvement.
```

---

# ✅ **15-Second Interview Summary Line (Read This)**

**“I built a fully automated EKS + DynamoDB system in us-east-2 with Terraform, IRSA security, ALB HTTPS, Route 53 DNS, Prometheus/Grafana observability, and DynamoDB Global Tables for active-active DR. I have a full Runbook to troubleshoot networking, app, IAM, and database issues in a structured, SRE-driven way.”**

---

\







# **A) VISUAL DIAGRAM SLIDES (Explain Like You’re Presenting)**

Use these as speaking slides or to draw on whiteboard.

---

### **Slide 1 — High-Level Architecture**

```
                +---------------------+
User → Internet →|   Route 53 (DNS)    |
                +----------+----------+
                           |
                           v
                  +--------+--------+
                  |  AWS ALB (HTTPS) |
                  +--------+--------+
                           |
                           v
                +----------+-----------+
                |      EKS Cluster     |
                | (profile namespace)  |
                +----------+-----------+
                           |
        +------------------+-------------------+
        |                                      |
+-------v-------+                       +-------v--------+
| Profile API   | (Python/Flask Pods)   | ServiceAccount |
| Deployment    |---------------------->| IRSA IAM Role  |
+-------+-------+                       +-------+--------+
        |                                      |
        v                                      v
  (boto3 HTTPS)                      IAM Allow DynamoDB Read/Write
        |
        v
+-------+--------------------+
|  DynamoDB Global Table     |
|  (us-east-2 <-> us-east-1) |
+----------------------------+
```

**How to speak it:**

> “User hits a friendly domain in Route 53. Route 53 points to an ALB that terminates HTTPS. ALB forwards to EKS pods running the Profile API. The pods authenticate to DynamoDB using IRSA, which means no stored credentials. DynamoDB Global Tables replicate data across regions for DR.”

---

### **Slide 2 — Observability & Logs**

```
EKS Pods → stdout/stderr → CloudWatch Logs
EKS Metrics → Prometheus → Grafana Dashboards
SLO Alerts → Prometheus AlertManager → Slack / Email
```

**Speak it:**

> “Logs go to CloudWatch. Metrics go to Prometheus and are visualized in Grafana. Alerts are based on SLOs like request success rate and latency.”

---

### **Slide 3 — Disaster Recovery**

```
Region A (us-east-2) — Active
Region B (us-east-1) — Active (Replica)

DynamoDB Global Tables keep data synced in real time.
Route 53 Latency Routing sends users to nearest healthy region.
If region fails, Route 53 automatically fails over.
```

**Speak it:**

> “We don’t restore from backup; we shift traffic. It’s active-active high availability.”

---

# **B) MOCK INTERVIEW Q&A (Based on This Project)**

### ✅ **1. Tell me about your project.**

**Answer:**

> I built a Profile Service on AWS using EKS, DynamoDB, and Terraform. The application is a Python Flask API that stores user profiles in DynamoDB. Everything is deployed using CI/CD. The pods authenticate to DynamoDB using IRSA, which avoids storing secrets. The system is fronted by an ALB with HTTPS managed through ACM and is exposed via Route 53. I also enabled Prometheus and Grafana for alerts and dashboards and configured DynamoDB Global Tables for multi-region resilience.

---

### ✅ **2. How do you secure communication?**

**Answer:**

* **In Transit:** HTTPS via ALB + TLS certificates from ACM.
* **In Cluster:** All pod-to-pod traffic goes through Kubernetes networking (can add service mesh if needed).
* **To DynamoDB:** boto3 → DynamoDB over TLS (HTTPS).
* **At Rest:** DynamoDB uses KMS-managed encryption.

---

### ✅ **3. How does the application access DynamoDB without storing credentials?**

**Answer:**

> I used IRSA — IAM Role for Service Accounts. The pod’s Kubernetes Service Account is linked to an IAM role that has DynamoDB permissions. So the pod automatically receives short-lived AWS credentials securely, with zero secrets stored.

---

### ✅ **4. What would you do if the app cannot reach DynamoDB?**

**Step-by-step answer:**

1. `kubectl logs` → check app errors
2. `nslookup <dynamodb endpoint>` → DNS
3. `aws iam get-role` → check IRSA role bound correctly
4. `VPC Flow Logs` → verify network
5. `put-item` test → verify DB layer

---

### ✅ **5. Can DynamoDB be active-active?**

**Answer:**

> Yes. Using DynamoDB Global Tables. They replicate in near real-time between multiple AWS regions, enabling active-active applications and fast failover.

---

### ✅ **6. DevOps vs SRE?**

**Answer:**

* **DevOps** focuses on CI/CD, automation, delivery speed.
* **SRE** focuses on reliability, SLOs, error budgets, incident response.

---

### ✅ **7. What metrics are your SLIs/SLOs?**

**Answer:**

* **SLI:** Request success rate & latency.
* **SLO:** 99.9% success.
* **SLA:** 99.5% uptime commitment.
* **Alert:** If success < SLO → trigger investigation & stop releases.

---

### ✅ **8. What is your DR strategy?**

**Answer:**

> DynamoDB Global Tables + Route 53 Latency Routing allows multi-region active-active failover.









part 4:




This lab takes students from **zero → running app on EKS → DynamoDB → CI/CD → Observability**.



# **HANDS-ON LAB: Deploy Profile Service on AWS (EKS + DynamoDB + IRSA + ALB)**

### **Prerequisites**

Students need:

* AWS Account
* IAM user with Admin access (or appropriate roles)
* AWS CLI installed
* Kubectl installed
* Terraform installed
* Docker installed

---

## **STEP 1 — Clone Project Template**

```
git clone https://github.com/your-org/profile-service.git
cd profile-service
```

> If you don’t have a repo yet, I will create the GitHub repo structure next message.

---

## **STEP 2 — Configure AWS CLI**

```
aws configure
```

Enter:

* AWS Access Key
* Secret
* Region → **us-east-2**

---

## **STEP 3 — Create the Infrastructure (Terraform)**

```
cd terraform
terraform init
terraform apply -auto-approve
```

### After it completes:

```
aws eks update-kubeconfig --name profile-service-eks --region us-east-2
```

Check connection:

```
kubectl get nodes
```

✔ If nodes appear → EKS cluster is ready.

---

## **STEP 4 — Deploy AWS Load Balancer Controller**

```
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system --create-namespace \
  --set clusterName=profile-service-eks \
  --set region=us-east-2 \
  --set serviceAccount.create=true \
  --set vpcId=$(aws eks describe-cluster --name profile-service-eks --region us-east-2 --query "cluster.resourcesVpcConfig.vpcId" --output text)
```

Verify:

```
kubectl get pod -n kube-system | grep aws-load-balancer
```

---

## **STEP 5 — Build & Push Application Image**

Replace `<ACCOUNT_ID>`:

```
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com

docker build -t profile-service-api ./app

docker tag profile-service-api:latest <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/profile-service-api:latest

docker push <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/profile-service-api:latest
```

---

## **STEP 6 — Deploy to Kubernetes**

### Replace ECR URL in Deployment:

Open:

```
k8s/deployment.yaml
```

Set:

```
image: <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/profile-service-api:latest
```

### Apply all manifests:

```
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

---

## **STEP 7 — Get the Application URL**

```
kubectl get ingress -n profile
```

Copy the **ALB hostname** and open:

```
http://<ALB_HOSTNAME>/health
```

Expected output:

```
{"status":"ok"}
```

---

## **STEP 8 — Test DynamoDB Integration**

### Create Profile:

```
curl -X POST http://<ALB_HOSTNAME>/profile \
  -H "Content-Type: application/json" \
  -d '{"userId": "student1", "name": "John"}'
```

### Retrieve Profile:

```
curl http://<ALB_HOSTNAME>/profile/student1
```

✔ If you see JSON → App + DB + Network + IAM are working.

---

## **STEP 9 — Add CI/CD Pipeline (GitHub Actions)**

1. Push project to GitHub
2. Go to GitHub → Repo → Settings → Secrets → Add:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
ECR_REPO
```

3. Create `.github/workflows/ci-cd.yaml`

(You already have the file in `cicd/github-actions.yaml`)

Pipeline will:

* Validate config (Python)
* Build Docker image
* Push to ECR
* Deploy to EKS

---

## **STEP 10 — Observability Setup**

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace
```

Then:

```
kubectl port-forward svc/kube-stack-grafana -n monitoring 3000:80
```

Open browser:

```
http://localhost:3000
```

Login:

```
username: admin
password: admin
```

Add dashboard:

* Kubernetes / Compute Resources / Workload

---

# ✅ **LAB COMPLETED — Students Now Understand:**

| Skill                              | Verified |
| ---------------------------------- | :------: |
| Terraform IaC                      |     ✅    |
| EKS Deployment                     |     ✅    |
| ALB Ingress                        |     ✅    |
| IAM IRSA Security                  |     ✅    |
| DynamoDB Integration               |     ✅    |
| CI/CD Automation                   |     ✅    |
| Observability (Grafana/Prometheus) |     ✅    |
| Troubleshooting & SRE Practices    |     ✅    |


