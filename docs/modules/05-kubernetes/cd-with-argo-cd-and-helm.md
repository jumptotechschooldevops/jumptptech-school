---
title: "cd with Argo CD and helm"
description: "GitHub push ≠ Production ready        Enter fullscreen mode            Exit fullscreen mode    ..."
published: 2026-02-13
source: "https://dev.to/jumptotech/cd-with-argo-cd-and-helm-40e0"
tags: []
---

# cd with Argo CD and helm





```
GitHub push ≠ Production ready
```

Code in GitHub is only **source code**.

Production requires:

* Validation
* Testing
* Verification
* Approval
* Stability check

---

# 🧠 Real Software Lifecycle

In real companies, environments are separated:

```
Developer → Dev → QA → Stage → Production
```

Each environment has a purpose.

---

# 🔷 1️⃣ DEV Environment

Purpose:

* First deployment after CI
* Validate Docker image
* Validate Helm chart
* Validate Kubernetes deployment
* Developers test functionality

Why DevOps deploys here first:

Because this is the safest place to catch:

* Broken containers
* Wrong ports
* Wrong env variables
* Wrong image tags
* CrashLoopBackOff
* Misconfigured services

Dev is allowed to break.

Production is not.

---

# 🔷 2️⃣ STAGE / QA Environment

Purpose:

* Full integration testing
* Performance testing
* API validation
* Security scanning
* Regression testing

This environment mimics production closely.

---

# 🔷 3️⃣ PRODUCTION Environment

Purpose:

* Real users
* Real traffic
* Real money
* Real business impact

Mistakes here cost money and reputation.

---

# 🔥 Why Not Deploy Directly to Production?

Imagine this:

Developer pushes code.
Image builds.
Helm deploys to prod.
App crashes.
Users see 500 errors.

What happens?

* Customers angry
* Revenue lost
* Business impact
* You get called at 3AM

This is why we have staged environments.

---

# 🎯 DevOps Philosophy

We reduce risk gradually.

Instead of:

```
Risk = 100% in production
```

We do:

```
Risk in Dev → Risk in Stage → Risk in Prod
```

Each environment lowers uncertainty.

---

# 🔥 How GitOps Works with Environments

You usually have:

```
manual-app-helm/
   ├── values-dev.yaml
   ├── values-stage.yaml
   ├── values-prod.yaml
```

And Argo CD Applications:

* manual-app-dev
* manual-app-stage
* manual-app-prod

Each watches different branch or values file.

---

# 🧠 Professional Architecture

Often companies use:

```
main branch → deploy to dev
release branch → deploy to stage
tag v1.0.0 → deploy to prod
```

Production deployment is usually:

* Manual approval
* Protected branch
* Pull request review
* Change management ticket

---

# 🔥 Important DevOps Principle

CI proves the code builds.

CD proves the system works.

Production proves the business survives.

These are not the same thing.

---

# 🚀 Real Interview Answer

If interviewer asks:

> Why don’t you deploy directly to production after CI?

Answer:

> Because CI validates build integrity, not system stability. We deploy to lower environments first to validate integration, configuration, and runtime behavior before exposing real users to risk.

That’s senior-level answer.

---



Dev environment = experimentation
Stage environment = verification
Production = stability





## Goal (DevOps view)

Build a working Kubernetes cluster on AWS with:

* **EKS Control Plane** (managed by AWS)
* **Worker Nodes** (EC2 instances that run pods)
* **Networking** (VPC/Subnets/Security Groups)
* **IAM + RBAC access** (so kubectl works)

---

# Part A — Create IAM Roles (who is allowed to do what)

## 1) Create Cluster Role (Control Plane Role)

**Console:** IAM → Roles → Create role
**Trusted entity:** **AWS service**
**Service:** **EKS** (or “EKS - Cluster”)

### Attach policies (typical minimum for standard EKS cluster):

* `AmazonEKSClusterPolicy`
  (If console shows “Auto Mode policies missing”, ignore if you disable Auto Mode.)

### Why DevOps cares

The EKS control plane needs permissions to call AWS APIs (create ENIs, talk to VPC, etc.).
Without this role, cluster creation fails.

---

## 2) Create Node Role (Worker Node IAM Role)

**Console:** IAM → Roles → Create role
**Trusted entity:** **AWS service**
**Service/use case:** **EC2**

### Attach these policies (standard worker node set)

* `AmazonEKSWorkerNodePolicy`
* `AmazonEKS_CNI_Policy`  (or new VPC CNI equivalent if console suggests)
* `AmazonEC2ContainerRegistryReadOnly`

### Why DevOps cares

Nodes must:

* join EKS cluster
* create pod networking (CNI)
* pull images from ECR

Without these, nodes will not join or pods won’t get networking / images won’t pull.

---

# Part B — Create the EKS Cluster (Control Plane)

## 3) EKS → Create cluster

You saw two choices:

### Option: Quick configuration

* Faster, less control
* Can enable “Auto Mode” (AWS manages node pools, etc.)

### Option: Custom configuration (what you used)

* More control, better for learning/teaching

 

## 4) Cluster basic settings

**Name:** `jum-eks`
**Kubernetes version:** 1.34
**Cluster IAM role:** choose your `eks-admin-role` (cluster role you created)

### Why DevOps cares

Cluster role = permissions for control plane to operate inside AWS.

---

## 5) EKS Auto Mode

You **disabled** Auto Mode.

### Why DevOps cares

Auto Mode adds extra requirements/policies and hides details.
For learning and interviews, “managed node group” is clearer.

---

# Part C — Networking (where cluster will live)

## 6) Choose VPC + subnets

You selected default VPC `vpc-0691...` and 3 subnets (multi-AZ).

### Why DevOps cares

* VPC is the network boundary
* Subnets decide where control plane ENIs and worker nodes exist
* Multi-AZ improves availability

---

## 7) Cluster endpoint access

You used **Public and private**.

### Why DevOps cares

This directly affects whether `kubectl` can reach the API server:

* **Public**: reachable from internet (if allowed)
* **Private**: reachable only inside VPC

You later hit a timeout to a **172.31.x.x** address → that means your kubeconfig was pointing to a private IP endpoint but your route/security wasn’t right yet.

---

# Part D — Observability (optional)

## 8) Observability page

You left Prometheus/CloudWatch unchecked.

### Why DevOps cares

This costs money + adds complexity.


# Part E — Add-ons (Kubernetes system components)

## 9) Add-ons selected (you had 4)

* VPC CNI
* CoreDNS
* kube-proxy
* node monitoring agent

### Why DevOps cares

These are required for a healthy cluster:

* **CNI**: pod networking
* **CoreDNS**: service discovery (DNS)
* **kube-proxy**: service networking rules

---

# Part F — Create the Worker Nodes (Managed Node Group)

## 10) EKS → Cluster → Compute → Add node group

You created node group named `nodes`

### Node role

 clicked **Create recommended role** → it took you to IAM role creation.
You selected:

* **Trusted entity = AWS service**
* **Use case = EC2**

✅ That is correct for node role.

### Scaling

You set desired/min/max = **2 nodes**

### Why DevOps cares

Control plane alone runs nothing.
Workers are what run pods.

---

# Part G — Connect from EC2 (kubectl)

## 11) Configure kubeconfig

On EC2:

```bash
rm -rf ~/.kube/config
aws eks update-kubeconfig --region us-east-2 --name jum-eks
kubectl config current-context
```

### Why DevOps cares

kubeconfig tells kubectl:

* which cluster endpoint to call
* how to authenticate (AWS token)

---

# Part H — The 3 problems you hit (real DevOps troubleshooting)

## Problem 1: DNS “no such host”

That usually happens when:

* kubeconfig endpoint is wrong/old
* DNS cannot resolve the endpoint

 fixed it by regenerating kubeconfig:

```bash
aws eks update-kubeconfig ...
```

---

## Problem 2: i/o timeout to 172.31.x.x:443

That means:

* kubectl tried to reach API server through **private endpoint**
* security group / routing blocked access

Fix approach:

* Ensure cluster endpoint mode fits your access (public/private)
* Ensure your EC2 is in same VPC and SG rules allow required traffic

---

## Problem 3: “server asked for credentials” / Forbidden RBAC

 progressed to:

* Authentication works (IAM role is used)
* But Kubernetes RBAC still blocks you

You confirmed IAM role works:

```bash
aws sts get-caller-identity
```

 created **EKS access entry** + access policy:
EKS → Cluster → **Access** → Create access entry
Added access policy (Cluster admin) to your role.

That fixed:

```bash
kubectl get nodes
```

✅ Now kubectl works.

---

# Final Verification (success criteria)

## 12) Verify nodes

```bash
kubectl get nodes
```

You got:

* 2 nodes Ready

That proves:

* cluster is reachable
* IAM auth works
* RBAC authorization works
* worker nodes successfully joined

---


### EKS has 3 layers:

1. **Networking** (can my laptop/EC2 reach Kubernetes API endpoint?)
2. **Authentication** (who am I? IAM role/user)
3. **Authorization** (what can I do? RBAC permissions)

 errors followed that exact order.




# Part: GitOps CD on EKS (Argo CD + Helm + GitHub)

## What you already have (starting point)

* EKS cluster exists
* 2 worker nodes are **Ready**
* `kubectl get nodes` works from your machine/EC2

Why DevOps checks this first:
If the cluster isn’t reachable, nothing else will work.

---

## STEP 1 — Verify EKS is healthy

Run:

```bash
kubectl get nodes
kubectl get pods -A
```

Expected:

* nodes: `Ready`
* kube-system pods running: `coredns`, `aws-node`, `kube-proxy`

Why DevOps does it:
These are the “engine” of Kubernetes. If CoreDNS or CNI is broken, apps will fail.

---

# STEP 2 — Install Argo CD in EKS

### 2.1 Create namespace

```bash
kubectl create namespace argocd
```

Why:
Namespaces separate tools/apps. We keep Argo CD isolated from business apps.

### 2.2 Install Argo CD

```bash
kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Why DevOps does it:
Argo CD is the **CD engine**. It reads Git and deploys to Kubernetes automatically.

### 2.3 Wait until it’s ready

```bash
kubectl get pods -n argocd
```

Expected: all `Running` (server, repo-server, controller, redis, dex)

Why:
If Argo components aren’t running, it can’t sync from Git.

---

# STEP 3 — Access Argo CD UI 

Argo CD service is inside the cluster. We expose it safely using port-forward.

### 3.1 Run port-forward on EC2 (or where kubectl is configured)

```bash
kubectl port-forward svc/argocd-server -n argocd 8086:443
```

Why:
Port-forward exposes the service only on localhost (safe for labs).

### 3.2 If you are opening UI from your laptop (Mac)

You must tunnel your laptop to EC2:

```bash
ssh -i key.pem -L 8086:localhost:8086 ubuntu@18.223.98.78
```

Then open browser:

```
https://localhost:8086
```

Why DevOps does it:
This avoids exposing Argo CD publicly (security best practice).

### 3.3 Get admin password

```bash
kubectl get secret argocd-initial-admin-secret \
-n argocd \
-o jsonpath="{.data.password}" | base64 -d
```

Login:

* username: `admin`
* password: output above

---

# STEP 4 — Create GitHub Repo for CD (Helm repo)

You created a second repo:

```
manual-app-helm
```

Why DevOps creates a separate repo:

* App repo = CI (code changes)
* Helm repo = CD (deployment desired state)
  This is real GitOps separation.

---

# STEP 5 — Create Helm chart in CD repo

In your `manual-app-helm` repo you used Helm chart structure.

A valid Helm repo for Argo CD must contain:

* `Chart.yaml`
* `values.yaml`
* `templates/`

Your repo ended up with chart files at **repo root**, like:

```
Chart.yaml
values.yaml
templates/
```

Why DevOps uses Helm:
Helm makes deployments configurable (image tag, replicas, service type) without rewriting YAML.

---

# STEP 6 — Make chart SIMPLE  (important)

The default `helm create` chart is complex and references many values.
You simplified template logic.

### 6.1 templates/deployment.yaml (simple version)

Use this exact file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: manual-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: manual-app
  template:
    metadata:
      labels:
        app: manual-app
    spec:
      containers:
        - name: manual-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 3000
```

Why DevOps did this:
Simple chart = less failure, faster learning.
You can add advanced parts (probes, resources, autoscaling) later.

### 6.2 templates/service.yaml (simple version)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: manual-app
spec:
  type: {{ .Values.service.type }}
  selector:
    app: manual-app
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 3000
```

Why:
Service gives a stable name and port to reach pods.

---

# STEP 7 — Configure values.yaml (very important)

This file is what Jenkins will update later.

Your correct values.yaml:

```yaml
replicaCount: 1

image:
  repository: aisalkyn85/manual-app
  tag: "9"
  pullPolicy: Always

service:
  type: ClusterIP
  port: 3000

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 3
```

Why DevOps does it:

* `repository` + `tag` = deploy exact image version
* Git becomes the source of truth for what runs in cluster

---

# STEP 8 — Push Helm repo to GitHub

From repo root:

```bash
git add .
git commit -m "Helm chart for manual-app"
git push
```

Why:
Argo CD can only deploy what exists in Git.

---

# STEP 9 — Create Argo CD Application (the GitOps “connection”)

UI sometimes breaks through port-forward, so you created it using YAML (best practice).

### 9.1 Create `manual-app-argocd.yaml`

On your kubectl machine:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: manual-app
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/jumptotechschooldevops/manual-app-helm.git
    targetRevision: HEAD
    path: .

  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 9.2 Apply it

```bash
kubectl apply -f manual-app-argocd.yaml
```

Why DevOps does it:

* This makes Argo CD “watch” Git
* **Automated** = deploy without humans
* **SelfHeal** = if someone changes cluster manually, Argo fixes it
* **Prune** = if something removed from Git, Argo removes it from cluster

That is real GitOps.

---

# STEP 10 — Troubleshooting 

## 10.1 Error: “app path does not exist”

Cause:
Argo path was wrong (`manual-app` vs `.`)

Fix:
Your Helm chart is at repo root → set:

```yaml
path: .
```

Why DevOps cares:
Argo must know where chart is stored in repo.

---

## 10.2 Error: Helm template failed (autoscaling nil pointer)

Cause:
Deployment template referenced values missing from values.yaml.

Fix:
You simplified the deployment template.

Why:
Broken templates stop production deploys. GitOps protects cluster from bad YAML.

---

## 10.3 Error: ImagePullBackOff

Cause:
Helm values used wrong image name:

Tried:

```
aisalkyn85/manual-k8s-app:9
```

But real pushed image was:

```
aisalkyn85/manual-app:9
```

Fix:
Update values.yaml repository to correct image, commit, push.

Why DevOps cares:
If CI and CD disagree on image name/tag → cluster cannot run.

---

# STEP 11 — Verify deployment works

Run:

```bash
kubectl get applications -n argocd
kubectl get pods
kubectl get svc
```

Expected:

* application: `Synced`
* pod: `Running`
* service: `ClusterIP`

Why DevOps checks:
This confirms GitOps is working end-to-end.

---

# What you achieved 

## Old method (not GitOps)

Jenkins runs kubectl → deploys directly.

Problems:

* Jenkins needs cluster admin access
* Deployments aren’t “declared” in Git
* Harder to rollback

## New method (GitOps)

Jenkins builds image and updates Git.
Argo CD deploys from Git.

Benefits:

* Git is the source of truth
* Rollback = git revert
* Self-healing
* No kubectl access needed in Jenkins












