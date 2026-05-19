---
title: "Argo CD – Full Power Demonstration (Already Deployed App)part#2"
description: "GIT VS HUMAN (DRIFT &amp; SELF-HEALING)               🧩 Task 1: Prove Humans Cannot Change..."
published: 2026-01-28
source: "https://dev.to/jumptotech/argo-cd-full-power-demonstration-already-deployed-app-165b"
tags: []
---

# Argo CD – Full Power Demonstration (Already Deployed App)part#2






# GIT VS HUMAN (DRIFT & SELF-HEALING)

---

## 🧩 Task 1: Prove Humans Cannot Change Production

### Action (Human tries to scale):

```bash
kubectl -n grade scale deployment grade-submission-api --replicas=3
```

### Observe:

* Argo CD → App becomes **OutOfSync**
* Seconds later → Argo reverts to replicas: `1`



> Kubernetes accepts human commands.
> Argo **rejects human authority**.

---

## 🧩 Task 2: Manual Image Change (Hotfix Attempt)

```bash
kubectl -n grade edit deployment grade-submission-api
```

Change:

```yaml
image: nginx:latest
```

### Observe:

* Pod restarts
* Argo detects image drift
* Reverts back to Git image



> Emergency hotfixes without Git are **temporary illusions**.

---

## 🧩 Task 3: Delete Pod Manually

```bash
kubectl -n grade delete pod -l app=grade-submission-api
```

### Observe:

* Pod recreated automatically
* Same image, same config

### Teaching Point:

> Kubernetes heals pods.
> Argo heals configuration.



* Git = authority
* Humans = temporary actors
* Argo = enforcer

---

#  FAILURE, ROLLBACK, SYNC CONTROL

---

## 🧩 Task 4: Break App via Git (Controlled Failure)

### In CI repo (`app.js`):

```js
throw new Error("Production crash");
```

Commit & push.

### Observe:

* CI builds image
* GitOps repo updated
* Argo deploys broken version
* Pod enters CrashLoopBackOff



> GitOps does NOT prevent bugs.
> It makes them **traceable**.

---

## 🧩 Task 5: Diagnose via Argo CD UI

Inside app view:

* Health → Degraded
* Click Pod → Logs

Show:

* Crash error
* Image SHA



> Argo CD shows **what is broken**, not why code is bad.

---

## 🧩 Task 6: Rollback Using Git Only

```bash
git revert <bad_commit>
git push
```

### Observe:

* CI triggers
* GitOps updated
* Argo redeploys previous version
* App recovers



> Rollback is **Git history**, not kubectl.

---

## 🧩 Task 7: Disable Auto-Sync (Manual Control Mode)

Edit Application:

```yaml
syncPolicy: {}
```

Apply change.

Now:

* Git changes
* App becomes **OutOfSync**
* Deployment waits

Click **SYNC** manually.



| Mode      | Use  |
| --------- | ---- |
| Auto-sync | Dev  |
| Manual    | Prod |



#  PRODUCTION SAFETY & GOVERNANCE

---

## 🧩 Task 8: Prune (Delete via Git)

Delete deployment from GitOps repo:

```bash
git rm deployment.yaml
git commit -m "remove app"
git push
```

### Observe:

* Argo deletes Deployment
* Pods disappear



> If it’s not in Git, it must not exist.

---

## 🧩 Task 9: Re-Add Deployment (Recovery)

Restore file:

```bash
git checkout HEAD~1 deployment.yaml
git commit -m "restore app"
git push
```

### Observe:

* Argo recreates everything


> Git is both destruction and recovery.

---

## 🧩 Task 10: Add Resource via Git Only

Add Service manifest.

Commit & push.

### Observe:

* Argo creates Service
* No kubectl used



> Git is the **only deployment interface**.

---

## 🧩 Task 11: Simulate Unauthorized Change

```bash
kubectl -n grade delete svc <service-name>
```

### Observe:

* Argo recreates it



> Argo enforces compliance automatically.

---

## 🧩 Task 12: Governance Discussion (No Commands)

Discuss:

* Remove kubectl access
* Read-only prod access
* Argo audit logs
* PR approvals



> “How would you safely deploy a hotfix in production?”

Expected answer:

* Create PR
* Review
* Merge
* Argo deploys

---


> “You are no longer deploying applications.
> You are managing **desired state**.”

---

# 📦 WHAT THIS LAB PROVES

✅ GitOps authority
✅ Drift detection
✅ Self-healing
✅ Rollback via Git
✅ Production safety
✅ Enterprise patterns





second project:

# MODULE 1 — Argo Rollouts (Progressive Delivery)

## Goal

Show that:

* Deployment ≠ Release
* Argo CD deploys
* **Argo Rollouts controls traffic**

This is **next-level DevOps**.

---



Traditional Deployment:

* Replace pods
* Users immediately see new version

Argo Rollouts:

* Canary
* Blue-Green
* Pause, approve, rollback
* Metrics-driven decisions



> “Kubernetes deploys pods.
> Argo Rollouts deploys **risk-controlled releases**.”

---

## Lab 1.1 — Install Argo Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts \
  -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
```

Verify:

```bash
kubectl get pods -n argo-rollouts
```

---

## Lab 1.2 — Convert Deployment → Rollout (GitOps)

In **GitOps repo**, replace `Deployment` with `Rollout`.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: grade-submission-api
  namespace: grade
spec:
  replicas: 3
  strategy:
    canary:
      steps:
        - setWeight: 20
        - pause: { duration: 30 }
        - setWeight: 50
        - pause: {}
  selector:
    matchLabels:
      app: grade-submission-api
  template:
    metadata:
      labels:
        app: grade-submission-api
    spec:
      containers:
      - name: app
        image: ghcr.io/jumptotechschooldevops/k8s-ci-build:PLACEHOLDER
```

Commit & push.

---

## Lab 1.3 — Observe Rollout via Argo CD

Show:

* Rollout object in tree
* ReplicaSets
* Pause state

Use CLI:

```bash
kubectl argo rollouts get rollout grade-submission-api -n grade
```

Resume:

```bash
kubectl argo rollouts promote grade-submission-api -n grade
```

---



* Canary != Deployment
* Rollouts are **Git-driven**
* Promotion is **controlled**, not automatic
* Rollbacks are instant

Interview takeaway:

> “We use Argo CD for GitOps and Argo Rollouts for progressive delivery.”

---

# MODULE 2 — Helm + Argo CD (Real-World GitOps)

## Goal

Show that:

* Helm is NOT a deploy tool
* Argo CD is NOT a template engine
* Together they form **production GitOps**

---



Helm:

* Templates YAML

Argo CD:

* Applies and enforces YAML

Correct mental model:

> “Helm renders.
> Argo enforces.”

---

## Lab 2.1 — Helm-Based GitOps Repo

Restructure GitOps repo:

```
grade-api-gitops/
├── chart/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       └── rollout.yaml
```

Put Rollout YAML into `templates/`.

---

## Lab 2.2 — Argo Application with Helm Source

```yaml
spec:
  source:
    repoURL: https://github.com/jumptotechschooldevops/grade-api-gitops
    targetRevision: main
    path: chart
    helm:
      valueFiles:
        - values.yaml
```

Apply:

```bash
kubectl apply -f grade-api-app.yaml
```

---

## Lab 2.3 — Change Values Only (No YAML Change)

Change image tag via CI → GitOps values.yaml.

Observe:

* Helm renders new YAML
* Argo detects diff
* Argo applies change

---



* Why Helm is still used
* Why kubectl helm upgrade is dangerous
* Why Argo + Helm is the industry standard

Interview sentence:

> “Helm handles templating, Argo CD handles reconciliation.”

---

# MODULE 3 — RBAC LOCK-DOWN (PRODUCTION SAFETY LAB)

## Goal

Show:

* Humans cannot touch prod
* Git is the only interface
* Argo enforces governance

This is **platform engineering**.

---

## Lab 3.1 — Create Read-Only Kubernetes Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: read-only
  namespace: grade
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "watch"]
```

Bind it:

```yaml
kind: RoleBinding
subjects:
- kind: User
  name: dev-user
roleRef:
  kind: Role
  name: read-only
```

---

## Lab 3.2 — Prove kubectl Is Blocked

```bash
kubectl -n grade scale deployment grade-submission-api --replicas=5
```

Result:

```
Error: forbidden
```

Explain:

> Even if Argo didn’t exist, humans are locked out.

---

## Lab 3.3 — Argo CD RBAC (App-Level)

Edit `argocd-rbac-cm`:

```yaml
policy.csv: |
  p, role:readonly, applications, get, *, allow
  p, role:readonly, applications, sync, *, deny
```

Map users to role.

---

## Lab 3.4 — Demo UI Restrictions

Log in as:

* Read-only user

Show:

* Cannot Sync
* Cannot Delete
* Cannot Edit

But:

* Can view state
* Can view logs

---



* Prod safety is **designed**, not hoped
* kubectl access is removed
* Git approvals replace manual changes

Interview sentence:

> “In production, engineers don’t deploy — Argo does.”

---



| Topic                | Skill Level |
| -------------------- | ----------- |
| Argo CD Dashboard    | Core GitOps |
| Drift & Self-Healing | Mid         |
| Rollouts             | Advanced    |
| Helm + Argo          | Senior      |
| RBAC Lockdown        | Platform    |
| Governance           | Staff/Lead  |


