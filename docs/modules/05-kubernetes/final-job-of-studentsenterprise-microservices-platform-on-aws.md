---
title: "final job of students:Enterprise Microservices Platform on AWS"
description: "After 7 months of DevOps training, students should build something real, production-style,..."
published: 2026-02-14
source: "https://dev.to/jumptotech/final-job-of-studentsenterprise-microservices-platform-on-aws-2o35"
tags: []
---

# final job of students:Enterprise Microservices Platform on AWS

After 7 months of DevOps training, students should build something **real, production-style, enterprise-level** — not just deploy a container.






# 🎯 PROJECT GOAL

Students must build and deploy a **6-microservice cloud-native application** using full CI/CD + GitOps + Monitoring + Infrastructure as Code.

They must:

• Provision infrastructure with Terraform
• Build Docker images
• Push to ECR
• Create CI pipeline with Jenkins
• Deploy to EKS using Helm
• Use Argo CD for GitOps
• Store secrets in AWS Secrets Manager
• Monitor with Prometheus + Grafana
• Deploy one microservice to ECS (to show orchestration comparison)

---

# 🏗️ ARCHITECTURE OVERVIEW

```
Developer → GitHub
        ↓
      Jenkins (CI)
        ↓
      Docker build
        ↓
      Push to ECR
        ↓
     Argo CD watches GitOps repo
        ↓
      Helm deploys to EKS
        ↓
   Prometheus scrapes metrics
        ↓
      Grafana dashboards
```

Separate:

* 1 microservice deployed to ECS (Fargate)
* 5 microservices deployed to EKS

---

# 📦 APPLICATION STRUCTURE

Students must create:

## 6 Microservices

1. user-service
2. order-service
3. payment-service
4. product-service
5. notification-service
6. gateway-service (API gateway / ingress)

Language: Node.js / Python / Java (your choice)

Each must:

* Have its own Dockerfile
* Expose REST API
* Have health endpoint `/health`
* Expose `/metrics` endpoint (Prometheus format)

---

# 📁 GITHUB REPOSITORY STRUCTURE

They must create 3 repositories:

### 1️⃣ app-repo (Source Code)

```
microservices-platform/
 ├── user-service/
 ├── order-service/
 ├── payment-service/
 ├── product-service/
 ├── notification-service/
 └── gateway-service/
```

---

### 2️⃣ helm-charts-repo

```
helm-charts/
 ├── user-service/
 ├── order-service/
 ├── payment-service/
 ├── product-service/
 ├── notification-service/
 └── gateway-service/
```

Each chart must include:

* Deployment.yaml
* Service.yaml
* values.yaml
* HPA.yaml
* Ingress.yaml (for gateway)

---

### 3️⃣ gitops-repo

```
gitops/
 ├── dev/
 │    ├── user.yaml
 │    ├── order.yaml
 │    └── ...
 └── prod/
```

Argo CD watches this repo.

---

# 🧱 INFRASTRUCTURE TASK (Terraform)

 create Terraform project:

```
terraform/
 ├── vpc.tf
 ├── eks.tf
 ├── ecs.tf
 ├── ecr.tf
 ├── iam.tf
 ├── secrets.tf
 ├── monitoring.tf
 └── outputs.tf
```

Terraform must provision:

• VPC (public + private subnets)
• EKS cluster
• ECS cluster (Fargate)
• 6 ECR repositories
• IAM roles for EKS & ECS
• AWS Secrets Manager secret
• Security groups
• ALB
• Route53 record (optional bonus)

---

# 🔐 SECRETS MANAGEMENT



• Store DB password in AWS Secrets Manager
• Retrieve it in:

* EKS using External Secrets Operator
* ECS using task definition secret reference

They must NOT hardcode passwords.

---

# 🚀 CI TASK (JENKINS)



### Multi-branch pipeline

Pipeline stages:

1. Checkout
2. Unit Test
3. Build Docker image
4. Tag with Git SHA
5. Push to ECR
6. Update GitOps repo image tag
7. Commit & push to GitOps repo

Bonus:

* Add SonarQube scan
* Add Trivy security scan

---

# 🔁 CD TASK (ARGO CD)



• Install Argo CD in EKS
• Connect to GitOps repo
• Create Application CRDs
• Enable auto-sync
• Enable self-heal

 must demonstrate:

* Changing image tag in GitOps repo
* Argo automatically deploys new version

---

# 📊 MONITORING TASK

Install via Helm:

• Prometheus
• Grafana
• kube-state-metrics
• node-exporter

 must:

* Expose metrics endpoint in microservices
* Configure ServiceMonitor
* Create Grafana dashboard:

  * Pod CPU
  * Memory
  * Request rate
  * Error rate

---

# 🐳 ECS TASK (Comparison)

Deploy payment-service to:

• ECS Fargate
• Behind ALB

 explain difference between:

EKS vs ECS:

* Control plane
* Scaling
* Cost
* Flexibility

---

# 📈 SCALING TASK



• Create HPA for at least 2 services
• Demonstrate load test
• Show pods scale up

Bonus:

* Create cluster autoscaler

---

# 🔎 TROUBLESHOOTING SCENARIOS

 random failure scenarios:

1. ImagePullBackOff
2. CrashLoopBackOff
3. Secret not injected
4. Prometheus not scraping
5. ALB health check failing
6. Terraform state lock

You have to able to  debug live.

---

# 📋 FINAL PRESENTATION REQUIREMENT

Each student must explain:

• Architecture diagram
• CI flow
• CD flow
• GitOps model
• Secrets handling
• Monitoring setup
• Scaling behavior
• How rollback works

---

# 🎓 EVALUATION CRITERIA

| Area                     | Weight |
| ------------------------ | ------ |
| Terraform infrastructure | 20%    |
| CI pipeline              | 15%    |
| GitOps + Argo            | 15%    |
| Helm structure           | 10%    |
| Secrets management       | 10%    |
| Monitoring               | 10%    |
| ECS implementation       | 10%    |
| Troubleshooting ability  | 10%    |

---

# 🧠 WHAT THIS PROJECT PROVES


• Mid-level DevOps
• Platform Engineer
• Cloud DevOps
• Kubernetes Engineer

This is real enterprise level.


