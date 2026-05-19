---
title: "Kubernetes CI/CD with GitOps & Argo CD part#1"
description: "Hands-On Class (Using Real Repositories)               🎯 Class Objective    Understand..."
published: 2026-01-27
source: "https://dev.to/jumptotech/kubernetes-cicd-with-gitops-argo-cd-2mj7"
tags: []
---

# Kubernetes CI/CD with GitOps & Argo CD part#1



### **Hands-On Class (Using Real Repositories)**

---

## 🎯 Class Objective


* Understand **GitOps**
* Install **Argo CD**
* Build a **real CI/CD pipeline**
* Use **GitHub Actions for CI**
* Use **Argo CD for CD**
* Debug **real-world failures** (ImagePullBackOff, secrets, pipelines)

This is **exactly how production systems work**.

---

## 🧠 CORE IDEA 

### ❓ Why GitOps?

Traditional deployment:



❌ Manual
❌ Not auditable
❌ Not scalable

### ✅ GitOps approach:



* Git = **Single Source of Truth**
* No manual `kubectl apply`
* Rollback = `git revert`

---

## 🧩 ARCHITECTURE OVERVIEW

```
Developer
   |
   v
GitHub (CI Repo)
   |
   v
GitHub Actions (CI)
   |
   v
GitHub Container Registry (GHCR)
   |
   v
GitHub (GitOps Repo)
   |
   v
Argo CD (CD)
   |
   v
Kubernetes (Minikube)
```

---


📌 **Clone this repository**

```bash
git clone https://github.com/jumptotechschooldevops/k8s-ci-build.git
cd k8s-ci-build
```

📂 Structure:

```
k8s-ci-build/
├── Dockerfile
├── src/
│   ├── app.js
│   ├── package.json
│   └── package-lock.json
└── .github/workflows/ci-cd.yml
```

📌 Purpose:

* Build Docker image
* Push image to GHCR
* Update GitOps repo

---

### 2️⃣ GitOps Repository (Deployment Only)

📌 **Clone this repository**

```bash
git clone https://github.com/jumptotechschooldevops/grade-api-gitops.git
cd grade-api-gitops
```

📂 Structure:

```
grade-api-gitops/
└── deployment.yaml
```

📌 Purpose:

* Contains **only Kubernetes manifests**
* Argo CD watches this repo
* CI modifies this repo
* Humans do NOT deploy manually

---

## 🧰 REQUIRED TOOLS (INSTALLATION)

### 1️⃣ Docker Desktop

Required for:

* Docker builds
* Minikube driver

Verify:

```bash
docker version
```

---

### 2️⃣ kubectl

Verify:

```bash
kubectl version --client
```

---

### 3️⃣ Minikube

```bash
minikube start
kubectl get nodes
```

Expected:

```
STATUS: Ready
```

---

## 🚀 INSTALL ARGO CD

### Step 1: Create namespace

```bash
kubectl create namespace argocd
```

---

### Step 2: Install Argo CD

```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

### Step 3: Wait for pods

```bash
kubectl get pods -n argocd -w
```

Explain to students:

* `Init` containers
* Controllers starting
* Normal startup delays

---

### Step 4: Access Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open browser:

```
https://localhost:8080
```

Ignore SSL warning.

---

### Step 5: Login to Argo CD

Get password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

Login:

* Username: `admin`
* Password: decoded value

---

## 📦 CREATE ARGO CD APPLICATION

📄 **Create file:** `grade-api-app.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grade-api
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/jumptotechschooldevops/grade-api-gitops.git
    targetRevision: main
    path: .

  destination:
    server: https://kubernetes.default.svc
    namespace: grade

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply:

```bash
kubectl apply -f grade-api-app.yaml
```

---

## 🧾 GITOPS DEPLOYMENT FILE (IMPORTANT)

📄 **File:**
`grade-api-gitops/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grade-submission-api
  namespace: grade
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grade-submission-api
  template:
    metadata:
      labels:
        app: grade-submission-api
    spec:
      imagePullSecrets:
        - name: ghcr-secret
      containers:
        - name: grade-submission-api
          image: ghcr.io/jumptotechschooldevops/k8s-ci-build:PLACEHOLDER
          ports:
            - containerPort: 3000
```

⚠️ 
`PLACEHOLDER` is intentional — CI will replace it.

---

## 🔐 CREATE GHCR IMAGE PULL SECRET

### GitHub PAT requirements:

* `read:packages`

Create secret:

```bash
kubectl -n grade create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=jumptotechschooldevops \
  --docker-password=<YOUR_GITHUB_PAT> \
  --docker-email=devnull@example.com
```

---

## ⚙️ CI PIPELINE (GitHub Actions)

📄 **File:**
`k8s-ci-build/.github/workflows/ci-cd.yml`

```yaml
name: CI - Build Image and Update GitOps

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.CR_PAT }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/jumptotechschooldevops/k8s-ci-build:${{ github.sha }}

      - name: Checkout GitOps repo
        uses: actions/checkout@v4
        with:
          repository: jumptotechschooldevops/grade-api-gitops
          token: ${{ secrets.GITOPS_PAT }}
          path: gitops

      - name: Update image tag
        run: |
          cd gitops
          sed -i "s/PLACEHOLDER/${{ github.sha }}/g" deployment.yaml

      - name: Commit and push
        run: |
          cd gitops
          git config user.name "GitHub Actions"
          git config user.email "ci@jumptotech.dev"
          git add deployment.yaml
          git commit -m "Update image to ${{ github.sha }}" || echo "No changes"
          git push
```

---

## 🔑 REQUIRED GITHUB SECRETS (CI REPO)

**Repo:** `k8s-ci-build → Settings → Secrets → Actions`

| Secret Name  | Purpose             |
| ------------ | ------------------- |
| `CR_PAT`     | Push image to GHCR  |
| `GITOPS_PAT` | Push to GitOps repo |

---

## 🧨 TROUBLESHOOTING (REAL ISSUES WE FACED)

### ❌ ImagePullBackOff

Cause:

* Image tag = `PLACEHOLDER`

Fix:

* CI replaces it with commit SHA

---

### ❌ CI error: `Password required`

Cause:

* Missing `CR_PAT`

Fix:

* Create GitHub PAT
* Add to repo secrets

---

### ❌ CI error: `nothing to commit`

Cause:

* File unchanged

Fix:

```bash
git commit ... || echo "No changes"
```

---

### ❌ Argo CD shows Synced but pod fails

Cause:

* Missing `imagePullSecret`

Fix:

* Create `ghcr-secret`
* Restart pod

---

## ✅ FINAL VERIFICATION

```bash
kubectl get pods -n grade
```

Expected:

```
READY   STATUS
1/1     Running
```

🎉 **PIPELINE COMPLETE**


