---
title: "HELM — COMPLETE CORE CONCEPTS & CHART EXPLANATION"
description: "Production-grade, based on existing chart                    1. What Helm Is (CORE IDEA)   Helm is..."
published: 2026-01-26
source: "https://dev.to/jumptotech/helm-complete-core-concepts-chart-explanation-dmk"
tags: []
---

# HELM — COMPLETE CORE CONCEPTS & CHART EXPLANATION







*Production-grade, based on existing chart*

![Image](https://devopscube.com/content/images/2025/03/helm-chart-drawio-1.png)

![Image](https://cdn.prod.website-files.com/67f18e860e54dbf2b97a05c6/6828e94cc207ec8e35f83566_image-10.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AqWnOjj1AqDA8x51zRnKh1g.png)

---

## 1. What Helm Is (CORE IDEA)

Helm is **not Kubernetes** and **not a deployment engine**.

> **Helm is a package manager and release manager for Kubernetes.**

Helm does **two things only**:

1. **Renders Kubernetes YAML** from templates and values
2. **Tracks deployment history (revisions)**

Everything else is Kubernetes.

---

## 2. Helm Core Concepts (ABSOLUTELY REQUIRED)

Helm has **four core concepts**.


### 2.1 Chart (CORE OBJECT)

A **chart** is a **versioned, reusable application package**.

In your case, the chart is the **entire directory**:

```
chart/
```

A chart:

* lives for years
* evolves
* is not recreated per deployment
* represents **one application**

> In real companies:
> **One microservice = one Helm chart**

---

### 2.2 Values (CONFIGURATION LAYER)

Values are **input parameters** for templates.

They define:

* replicas
* ports
* image tags
* resources
* environment behavior

Your chart already uses **multi-environment values**:

```
values.yaml        → defaults
values-dev.yaml    → dev overrides
values-prod.yaml   → prod overrides
```

This is **exactly how production charts are built**.

---

### 2.3 Templates (YAML GENERATORS)

Templates are **Kubernetes manifests with variables**.

Kubernetes **cannot read templates**.

Example:

```yaml
replicas: {{ .Values.replicaCount }}
```

Helm replaces variables → produces valid YAML → sends to Kubernetes.

---

### 2.4 Release (RUNTIME OBJECT)

A **release** is a **deployed instance of a chart**.

From your cluster:

```
demo-app-dev  (namespace: demo)
demo-app-prod (namespace: prod)
```

Key rule:

> **Release name + namespace = Helm identity**

Helm tracks:

* installs
* upgrades
* failures
* rollbacks

Kubernetes does not.

---

## 3. Rendering (MOST IMPORTANT HELM MECHANISM)

> **Rendering = converting templates + values into plain Kubernetes YAML**

Command:

```bash
helm template demo-app . -f values-dev.yaml
```

What happens internally:

1. Helm reads `Chart.yaml`
2. Helm loads values
3. Helm processes templates
4. Helm outputs **pure YAML**
5. Kubernetes API receives YAML

Helm **stops** here.

> Helm never runs containers
> Helm never manages pods

---

## 4. Helm Chart Structure — FILE BY FILE (DETAILED)

 real structure:

```
chart/
├── Chart.yaml
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl
├── values.yaml
├── values-dev.yaml
└── values-prod.yaml
```

Below is **exactly what each file is and why it exists**.

---

## 5. `Chart.yaml` — METADATA (NOT DEPLOYMENT)

📍 File:

```
chart/Chart.yaml
```

Purpose:

* chart identity
* versioning
* ownership
* dependency declaration

Example:

```yaml
apiVersion: v2
name: chart
version: 0.1.0
appVersion: "1.16.0"
```

### Important distinctions:

* `version` → chart version (Helm logic)
* `appVersion` → application version (informational)

> Helm upgrades track **chart version**, not appVersion.

---

## 6. `values.yaml` — DEFAULT CONFIGURATION

📍 File:

```
chart/values.yaml
```

Purpose:

* base configuration
* safe defaults
* common settings

Example:

```yaml
replicaCount: 1

image:
  repository: nginx
  tag: "1.25"

service:
  type: ClusterIP
  port: 80
```

This file:

* should work everywhere
* should not be environment-specific

---

## 7. `values-dev.yaml` & `values-prod.yaml` — ENVIRONMENT CONTROL

📍 Files:

```
chart/values-dev.yaml
chart/values-prod.yaml
```

Purpose:

* override defaults
* avoid YAML duplication
* separate environments

### Dev example:

```yaml
replicaCount: 1
service:
  type: NodePort
  nodePort: 30081
```

### Prod example:

```yaml
replicaCount: 3
service:
  type: ClusterIP
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
```

> **Same chart, different behavior**
> This is Helm’s biggest value.

---

## 8. `templates/deployment.yaml` — CORE WORKLOAD

📍 File:

```
chart/templates/deployment.yaml
```

Purpose:

* defines **Pod lifecycle**
* describes **containers**
* uses values for customization

Key sections to explain to students:

### Replica control

```yaml
replicas: {{ .Values.replicaCount }}
```

### Image control

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

### ConfigMap injection

```yaml
envFrom:
  - configMapRef:
      name: app-config
```

> Helm does not care what’s inside the container
> Helm only controls how it’s deployed

---

## 9. `templates/service.yaml` — NETWORKING

📍 File:

```
chart/templates/service.yaml
```

Purpose:

* expose pods
* define access model

Example:

```yaml
type: {{ .Values.service.type }}
ports:
  - port: {{ .Values.service.port }}
    nodePort: {{ .Values.service.nodePort }}
```

### Why NodePort failed earlier

* Kubernetes validates NodePort range
* Helm only renders YAML
* Invalid value caused **revision 1 failure**

This is a **real production lesson**.

---

## 10. `templates/configmap.yaml` — CONFIG SEPARATION

📍 File:

```
chart/templates/configmap.yaml
```

Purpose:

* externalize configuration
* avoid image rebuilds
* environment-specific config

Example:

```yaml
data:
  APP_ENV: {{ .Values.env }}
```

> Helm promotes **12-factor app design**

---

## 11. `_helpers.tpl` — REUSABLE LOGIC (ADVANCED CORE)

📍 File:

```
chart/templates/_helpers.tpl
```

Purpose:

* avoid duplication
* standardize naming
* enforce labels

Example:

```yaml
{{- define "demo.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
{{- end }}
```

Used as:

```yaml
labels:
  {{- include "demo.labels" . | nindent 4 }}
```

> `_helpers.tpl` is **mandatory in production charts**

---

## 12. Helm Lifecycle (WHAT DEVOPS USES DAILY)

### Install

```bash
helm install demo-app-dev . -n demo -f values-dev.yaml
```

### Upgrade

```bash
helm upgrade demo-app-dev . -n demo -f values-dev.yaml
```

### History

```bash
helm history demo-app-dev -n demo
```

### Rollback

```bash
helm rollback demo-app-dev 1 -n demo
```

> `kubectl apply` cannot do this.

---

## 13. Helm History & Failures (PRODUCTION CORE)

Your real output:

* revision 1 → failed (NodePort)
* revision 2 → deployed

Key point:

> **Helm never deletes failed revisions**

Why:

* audit
* traceability
* compliance
* rollback safety

---

## 14. Bitnami Charts — WHAT THEY TEACH

You installed:

```bash
helm install redis bitnami/redis
```

Bitnami charts include:

* StatefulSets
* PVCs
* Secrets
* Probes
* RBAC
* SecurityContext


Commands:

```bash
kubectl get sts
kubectl get pvc
kubectl describe pod redis-master-0
```

> Bitnami shows **how production charts are built**

---

## 15. Who Manages Helm in Production

| Role          | Responsibility       |
| ------------- | -------------------- |
| Platform team | charts               |
| DevOps        | values & releases    |
| Developers    | images               |
| SRE           | rollback & incidents |

Golden rule:

> ❌ Never kubectl apply Helm-managed resources

---

## 16. Troubleshooting Helm (REAL FLOW)

### Helm-side

```bash
helm lint .
helm template .
helm get manifest demo-app-dev -n demo
helm get values demo-app-dev -n demo
```

### Kubernetes-side

```bash
kubectl describe pod
kubectl logs pod
kubectl get events
```

Rule:

> Helm problems = template/value
> Pod problems = Kubernetes/runtime

---

## 17. Final Project (STUDENTS MUST DO)

### Task

1. Take existing chart
2. Add:

   * resource limits
   * probes
   * `_helpers.tpl` labels
3. Deploy:

   * dev (NodePort)
   * prod (ClusterIP)
4. Trigger failure
5. Fix via `helm upgrade`
6. Rollback

This **proves Helm mastery**.

---

## FINAL CORE MESSAGE

> Helm is not about convenience.
> Helm is about **control, safety, audit, and scale**.












# 🚀 HELM PROJECT

## **Production-Ready Helm Deployment Using Existing Chart**

---

## 🎯 Project Goal (What This Proves)

By completing this project, a student demonstrates that they:

* Understand **Helm core concepts**
* Can manage **multiple environments (dev/prod)**
* Can troubleshoot **real Helm failures**
* Can safely **upgrade & rollback**
* Can extend a chart to **production quality**
* Understand **who manages Helm in real companies**

---

## 🧩 Starting Point (Already Done)

You already have:

```
chart/
├── Chart.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl
├── values.yaml
├── values-dev.yaml
└── values-prod.yaml
```

And running releases:

```
demo-app-dev   → namespace demo
demo-app-prod  → namespace prod
```

---

## 📌 PROJECT SCENARIO (REALISTIC)

> Your company runs a web application called **demo-app**.
> The same application must run in **DEV** and **PROD** with different behavior.
>
> Helm is the **only allowed deployment tool**.

---

# 🧪 PROJECT TASKS (STEP-BY-STEP)

---

## 🔹 TASK 1 — Prove Helm Rendering (Core Understanding)

### Goal

Show that Helm **only generates YAML**.

### Commands

```bash
helm template demo-app . -f values-dev.yaml
helm template demo-app . -f values-prod.yaml
```

### Deliverable

Explain:

* Why outputs are different
* Why Kubernetes never sees templates

---

## 🔹 TASK 2 — Environment Separation (Dev vs Prod)

### Requirements

| Environment | Behavior              |
| ----------- | --------------------- |
| DEV         | NodePort, 1 replica   |
| PROD        | ClusterIP, 3 replicas |

### Files to edit

📄 `values-dev.yaml`

```yaml
replicaCount: 1
service:
  type: NodePort
  nodePort: 30081
```

📄 `values-prod.yaml`

```yaml
replicaCount: 3
service:
  type: ClusterIP
```

### Apply

```bash
helm upgrade demo-app-dev . -n demo -f values-dev.yaml
helm upgrade demo-app-prod . -n prod -f values-prod.yaml
```

---

## 🔹 TASK 3 — Helm History & Failure Simulation (CRITICAL)

### Goal

Demonstrate Helm **failure tracking**.

### Step 1 — Break DEV on purpose

📄 `values-dev.yaml`

```yaml
service:
  type: NodePort
  nodePort: 28000   # INVALID
```

```bash
helm upgrade demo-app-dev . -n demo -f values-dev.yaml
```

### Step 2 — Inspect failure

```bash
helm history demo-app-dev -n demo
helm get manifest demo-app-dev -n demo --revision 1
```

### Step 3 — Fix & recover

```yaml
nodePort: 30082
```

```bash
helm upgrade demo-app-dev . -n demo -f values-dev.yaml
```

### Deliverable

Explain:

* Why Helm kept the failed revision
* Why Kubernetes rejected it
* Why Helm did not delete history

---

## 🔹 TASK 4 — Rollback (Production Safety)

### Goal

Prove safe rollback.

```bash
helm history demo-app-dev -n demo
helm rollback demo-app-dev 1 -n demo
```

Verify:

```bash
kubectl get pods -n demo
```

### Deliverable

Explain:

* What rollback actually does
* Why this is safer than kubectl

---

## 🔹 TASK 5 — Production Hardening (Chart Expansion)

### Goal

Make the chart **production-ready**.

---

### 5.1 Add Resource Limits

📄 `templates/deployment.yaml`
Add under container spec:

```yaml
resources:
  requests:
    cpu: {{ .Values.resources.requests.cpu }}
    memory: {{ .Values.resources.requests.memory }}
  limits:
    cpu: {{ .Values.resources.limits.cpu }}
    memory: {{ .Values.resources.limits.memory }}
```

📄 `values-prod.yaml`

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

---

### 5.2 Add Readiness & Liveness Probes

📄 `templates/deployment.yaml`

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5

livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 15
```

### Deliverable

Explain:

* Why probes are Kubernetes responsibility
* Why Helm only injects configuration

---

## 🔹 TASK 6 — `_helpers.tpl` (Professional Helm)

### Goal

Standardize labels and naming.

📄 `templates/_helpers.tpl`

```yaml
{{- define "demo.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end }}
```

Use in all templates:

```yaml
labels:
  {{- include "demo.labels" . | nindent 4 }}
```

---

## 🔹 TASK 7 — Bitnami Comparison (Enterprise Learning)

### Goal

Understand **production-grade charts**.

```bash
helm install redis bitnami/redis
helm install nginx bitnami/nginx
```

Inspect:

```bash
kubectl get sts
kubectl get pvc
kubectl describe pod redis-master-0
```

### Deliverable

Explain:

* Why Bitnami uses StatefulSets
* Why PVCs are mandatory
* What you’d copy into your own charts

---

## 🔹 TASK 8 — Ownership & Workflow (DevOps Reality)

### Explain in words (no code):

* Who owns charts?
* Who changes values?
* Who triggers upgrades?
* Why `kubectl apply` is forbidden?

Expected answer:

> Platform team owns charts, DevOps manages releases, developers only change images.

---

## 🔹 TASK 9 — Troubleshooting Checklist

Student must demonstrate:

```bash
helm lint .
helm template .
helm status demo-app-dev -n demo
helm get values demo-app-dev -n demo
kubectl describe pod
kubectl logs pod
```

Explain:

* Helm error vs Kubernetes error
* Where to look first



# 🎓 WHAT THIS PROJECT PROVES



> “ use of Helm in production, manage environments, failures, rollbacks, and chart evolution.”

This is **real DevOps skill**, not theory.


