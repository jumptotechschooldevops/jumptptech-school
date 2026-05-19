---
title: "Lab: Multi-Environment GitOps Platform"
description: "Goal   Build a production-ready platform that:   Provisions infra with..."
published: 2026-02-23
source: "https://dev.to/jumptotech/lab-multi-environment-gitops-platform-1hen"
tags: []
---

# Lab: Multi-Environment GitOps Platform



### Goal

Build a production-ready platform that:

* Provisions infra with **Terraform**
* Builds/pushes images with **GitLab CI**
* Deploys to **EKS** using **Helm + ArgoCD**
* Supports **dev, stage, prod** with **promotion** (no manual kubectl)
* Uses **App-of-Apps**, environment isolation, and safe rollout

---

# 1) Repositories (enterprise layout)

## Repo A — `platform-infra` (Terraform)

Purpose: provision AWS infrastructure + cluster add-ons.

```
platform-infra/
  terraform/
    envs/
      dev/
      stage/
      prod/
    modules/
      vpc/
      eks/
      addons/
```

## Repo B — `app-ci` (Application + GitLab CI)

Purpose: code, tests, Docker build, push image, publish Helm chart version.

```
app-ci/
  app/
  Dockerfile
  .gitlab-ci.yml
  helm/
    chart/   (optional if you keep chart in CD repo)
```

## Repo C — `gitops-delivery` (CD GitOps)

Purpose: ArgoCD Applications and Helm values per environment.

```
gitops-delivery/
  argocd/
    projects/
      dev-project.yaml
      stage-project.yaml
      prod-project.yaml
    app-of-apps/
      dev.yaml
      stage.yaml
      prod.yaml
  apps/
    devops-pulse/
      Chart.yaml
      templates/
      values/
        dev.yaml
        stage.yaml
        prod.yaml
```

---

# 2) “Moving image” (animated frames for your README)

Paste this into your README. Students “see movement” by reading frames top-to-bottom:

```text
FRAME 1: Developer pushes code
[Dev Laptop] --> [GitLab app-ci repo] --> (pipeline starts)

FRAME 2: CI builds & pushes image
[GitLab Runner] --> build --> test --> docker push --> [GitLab Container Registry]

FRAME 3: Promotion PR created
[CI] --> opens MR to [gitops-delivery] changing:
  - image.tag: <sha>
  - chart version: <x.y.z>

FRAME 4: ArgoCD detects change (dev)
[ArgoCD-dev] --> sync --> [EKS dev namespace] --> pods running

FRAME 5: Promote dev -> stage
[Approver] merges MR (stage) --> [ArgoCD-stage] sync --> stage runs

FRAME 6: Promote stage -> prod (with guardrails)
[Release Manager] merges MR (prod) --> [ArgoCD-prod] sync
  --> rollout strategy (canary) --> full prod
```



# 3) Terraform: provision multi-env EKS (dev/stage/prod)

## Terraform decisions (teach “why”)

* Separate **state per env** (S3 backend + DynamoDB lock)
* Separate **namespaces** per env if sharing one cluster, or separate clusters if budget allows
* Use **IRSA** for add-ons (external-dns, cert-manager, external-secrets)

### Example: env folder

`terraform/envs/dev/main.tf` (pattern)

* VPC (or reuse default VPC for lab)
* EKS cluster
* node group (2 nodes)
* add-ons:

  * ArgoCD (helm_release or kubectl_manifest)
  * metrics-server (HPA)
  * AWS Load Balancer Controller
  * ExternalDNS (optional)
  * External Secrets Operator (optional)


```bash
cd platform-infra/terraform/envs/dev
terraform init
terraform apply
```

Repeat for stage/prod or reuse same cluster with different nodegroups/namespaces.

---

# 4) Helm chart for app (real production fields)

In `gitops-delivery/apps/devops-pulse/Chart.yaml`:

```yaml
apiVersion: v2
name: devops-pulse
type: application
version: 1.2.0
appVersion: "1.2.0"
```

### Values per environment

`values/dev.yaml`

```yaml
replicaCount: 1
image:
  repository: registry.gitlab.com/jumptotech/app-ci/devops-pulse
  tag: "dev"
ingress:
  enabled: false
resources:
  requests:
    cpu: 50m
    memory: 128Mi
```

`values/stage.yaml`

```yaml
replicaCount: 2
image:
  tag: "stage"
resources:
  requests:
    cpu: 100m
    memory: 256Mi
hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 4
```

`values/prod.yaml`

```yaml
replicaCount: 2
image:
  tag: "prod"
pdb:
  enabled: true
  minAvailable: 1
strategy:
  type: RollingUpdate
  maxSurge: 1
  maxUnavailable: 0
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

---

# 5) ArgoCD: App-of-Apps for dev/stage/prod

## ArgoCD Projects (RBAC boundaries)

`argocd/projects/prod-project.yaml`

* restrict repo URLs
* restrict destinations to `prod` namespace
* restrict cluster-scoped resources

## App-of-Apps

`argocd/app-of-apps/prod.yaml` points to `apps/devops-pulse` with `values/prod.yaml`.

This becomes your “production control plane”.

---

# 6) GitLab CI: build, push, and create promotion MR

## Key idea

CI does not `kubectl apply` to prod.
CI only:

1. builds and pushes image tags (immutable)
2. updates GitOps repo via MR (promotion)

### Recommended tags

* `dev: <shortsha>-<pipeline>`
* `stage: <shortsha>-<pipeline>`
* `prod: <shortsha>-<pipeline>`

Or keep a single immutable tag and promote by changing GitOps values.

### Pipeline stages (outline)

* test
* build
* push
* update-gitops-dev (auto MR)
* promote-to-stage (manual approval)
* promote-to-prod (manual approval, protected)

---

# 7) Deployment safety: canary in prod (advanced)

Add **Argo Rollouts** in prod:

* stage still uses rolling update
* prod uses canary (10% → 50% → 100%)
* metrics check (Prometheus) before promoting weight


---



### Infra

* Terraform apply for dev/stage/prod (or dev only + namespaces)
* outputs: kubeconfig context, LB controller, ArgoCD endpoint

### CI

* pipeline passing
* images in registry with immutable tags
* MR automation to GitOps repo

### GitOps

* ArgoCD app-of-apps deployed
* env isolation (namespaces + projects)
* dev deploy auto-sync
* stage/prod promotion via MR approvals

### Verification

* browser endpoint per env
* confirm different replica counts per env
* show ArgoCD history and rollback

---

# 9) What you can demo live (high impact)

* Break prod by changing a value → ArgoCD self-heals
* Rollback prod by reverting Git commit
* Show canary steps in Argo Rollouts UI
* Show stage/prod approvals in GitLab protected environments


