---
title: "Argo CD Dashboard — Complete Explanation (GitOps Control Center)"
description: "1️⃣ As a DevOps engineer — what do we actually do in Argo CD?   DevOps does NOT push..."
published: 2026-01-28
source: "https://dev.to/jumptotech/argo-cd-dashboard-complete-explanation-gitops-control-center-1plo"
tags: []
---

# Argo CD Dashboard — Complete Explanation (GitOps Control Center)



![Image](https://miro.medium.com/1%2AaEP4g-JqLTGkUL_9QYyvTA.png)

![Image](https://cdn-ak.f.st-hatena.com/images/fotolife/c/cybozuinsideout/20191119/20191119215535.png)

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fqxx6wveco1gxp5gua5p6.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A0MpcMgFb4hkcqXtflGSYNQ.png)


## 1️⃣ As a DevOps engineer — what do we actually do in Argo CD?

**DevOps does NOT push code to production directly.**

DevOps responsibilities with Argo CD:

* Design **GitOps workflow**
* Create **separate environments** (dev / stage / prod)
* Control **who can deploy where**
* Make deployments **safe, auditable, and reversible**
* Troubleshoot when deployments fail

Argo CD is **NOT just history storage**.
It is a **continuous reconciler**.

---

## 2️⃣ Does everything pushed to GitHub `main` go to production?

❌ **NO — this is the biggest misunderstanding**

### Real-world setup (always in production companies)

You have **multiple repos or branches**:

```
App repo (developers)
  └── main (code)

GitOps repo (DevOps owned)
  ├── dev/
  ├── stage/
  └── prod/
```

Or:

```
GitOps repo
  ├── overlays/dev
  ├── overlays/stage
  └── overlays/prod
```

**Argo CD does NOT watch the app repo.**
It watches the **GitOps repo only**.

---

## 3️⃣ What actually happens step-by-step (REAL FLOW)

### STEP 1 — Developer

* Writes code
* Pushes to GitHub
* Opens PR → `main`

### STEP 2 — CI (GitHub Actions / Jenkins)

* Builds Docker image
* Runs tests
* Pushes image to registry
* **Does NOT deploy**

Example:

```
myapp:1.2.3
```

---

### STEP 3 — GitOps update (controlled)

CI or DevOps:

* Updates **dev environment only**

```yaml
image:
  repository: myapp
  tag: 1.2.3
```

📌 This goes into:

```
gitops/dev/myapp.yaml
```

---

### STEP 4 — Argo CD (DEV)

* Argo CD sees Git change
* Syncs **only DEV**
* App runs in DEV cluster/namespace

✅ Customers DO NOT see this

---

### STEP 5 — Promotion (manual / approved)

After validation:

* DevOps promotes same image to **stage**
* Later promotes to **prod**

🚨 **No rebuild**
🚨 **Same image hash**

This is **release promotion**, not redeployment.

---

## 4️⃣ Why Argo CD ≠ “just history”?

Argo CD:

* Stores **desired state**
* Detects **drift**
* Enforces **immutability**
* Shows **who changed what**
* Supports **rollback**
* Prevents **manual kubectl abuse**

History exists because **Git is the history**, not Argo CD.

---

## 5️⃣ Why not just give Docker container to testers or devs?

Because **containers alone don’t solve**:

❌ Config drift
❌ Secrets handling
❌ Networking
❌ Scaling
❌ Rollbacks
❌ Audit trail
❌ Environment parity

A container without GitOps:

* Runs differently everywhere
* Cannot be traced
* Cannot be safely promoted

---

## 6️⃣ Why do we teach Argo CD fully (not just basics)?

Because **real companies use GitOps**, not ad-hoc Docker pushes.

Interviewers expect you to know:

* Why GitOps exists
* Why Argo CD is safer than manual deploy
* How prod deployments are controlled
* How rollback works
* How to debug failures

---

## 7️⃣ What a DevOps engineer MUST know in Argo CD

### Core concepts (mandatory)

* Application
* Project
* Sync policy (manual vs auto)
* Desired vs live state
* Drift
* Rollback
* Multi-env structure

---

## 8️⃣ Troubleshooting Argo CD (REAL scenarios)

### ❌ App not syncing

Check:

```
argocd app get myapp
```

Look for:

* Git auth issue
* Path wrong
* YAML invalid

---

### ❌ Image updated but app not changed

Cause:

* GitOps repo not updated
* Argo CD watches Git, NOT registry

---

### ❌ Sync OK but app broken

Check:

```
kubectl logs
kubectl describe pod
kubectl get events
```

Argo CD is **not runtime debugger**.

---

### ❌ Someone ran kubectl apply

Argo CD:

* Shows **OutOfSync**
* Reverts change (if auto-sync)

This is **self-healing**.

---

## 9️⃣ One-paragraph interview answer (gold)

> “As a DevOps engineer, I use Argo CD to enforce GitOps by separating build and deploy responsibilities, managing multiple environments through Git, promoting immutable images across dev, stage, and prod, preventing configuration drift, and enabling safe rollbacks and auditability. Production deployments are controlled through Git approvals, not direct code pushes.”

---

## 10️⃣ Why Argo CD is worth a full lecture

Because it teaches:

* Real production workflows
* Safe releases
* Dev/Prod separation
* Debugging skills
* Compliance thinking
* Modern DevOps mindset





## 1️⃣ What Is the Argo CD Dashboard?

The **Argo CD Dashboard** is the **visual control plane of GitOps**.

It answers one critical question continuously:

> ❓ *Does the Kubernetes cluster match what is defined in Git?*

If the answer is **NO**, Argo CD reacts.

This dashboard is **not just UI** — it is a **live view of Git vs Kubernetes state reconciliation**.

---

## 2️⃣ What the Dashboard Represents Conceptually

Before understanding buttons and fields, must understand **what Argo CD really is**.

### Argo CD is:

* A **continuous reconciliation engine**
* A **GitOps controller**
* A **Kubernetes-native CD system**

### Argo CD is NOT:

* Not CI
* Not kubectl
* Not a build tool
* Not Helm (but works with Helm)

---

## 3️⃣ Dashboard Layout Overview

The dashboard is divided into **three logical areas**:

1. **Left Sidebar** – Control & navigation
2. **Top Toolbar** – Application management
3. **Application Tiles** – Real-time GitOps state

---

# 🔹 PART 1: LEFT SIDEBAR (ARGO CD CONTROL PLANE)

---

## 3.1 Applications (Most Important Section)

This section lists **all GitOps-managed applications**.

### Key idea:

> One Argo CD Application = One Git → One Kubernetes desired state

Each application:

* Points to a Git repo
* Points to a cluster
* Points to a namespace
* Continuously reconciles state

If an application is not here → **Argo does not manage it**.

---

## 3.2 Settings

This is where **platform-level configuration** lives.

Includes:

* Repositories
* Clusters
* Projects
* RBAC
* Accounts

### Real-world meaning:

* Platform team controls **what repos can deploy**
* Controls **which clusters are allowed**
* Controls **who can deploy to prod**

In production, most engineers **never touch Settings**.

---

## 3.3 User Info

Shows:

* Logged-in user
* Permissions

In real companies:

* Integrated with SSO (GitHub, Okta, Azure AD)
* No shared admin passwords

---

## 3.4 Application Filters (Left Bottom)

You see filters like:

* Synced
* OutOfSync
* Healthy
* Degraded
* Progressing

### Why this matters:

This allows operators to answer instantly:

> “Is production stable right now?”

If **OutOfSync > 0**, something changed outside Git.

---

# 🔹 PART 2: TOP TOOLBAR (APPLICATION MANAGEMENT)

---

## 4.1 Create Application (+)

This button allows **manual creation** of applications.

But in advanced GitOps:

* Applications are created via YAML
* Stored in Git
* Managed declaratively

This is already what **you did**, which is advanced.

---

## 4.2 Refresh Button

Forces Argo to:

* Re-pull Git
* Re-check cluster state

Important concept:

> Argo normally polls Git automatically — refresh is just manual trigger.

---

## 4.3 Search Bar

Used in large environments:

* Hundreds of apps
* Microservices
* Multi-team platforms

---

# 🔹 PART 3: APPLICATION TILE (CORE OF THE DASHBOARD)

Now we explain **everything inside one tile**, because this is where **GitOps becomes real**.

---

## 5️⃣ Application Tile Explained (grade-api)

---

## 5.1 Application Name

Example:

```
grade-api
```

This is a **logical GitOps object**.

It represents:

* Git repository
* Kubernetes namespace
* Deployment ownership

Deleting this application deletes **everything it manages**.

---

## 5.2 Project

```
Project: default
```

Projects are **security and governance boundaries**.

In production:

* dev-project
* staging-project
* prod-project

Each project can:

* Restrict namespaces
* Restrict clusters
* Restrict Git repos

---

## 5.3 Status (MOST IMPORTANT FIELD)

### Example:

```
Status: Healthy | Synced
```

This is the **heart of GitOps**.

---

### 🟢 Synced

Means:

* Git desired state == Kubernetes live state
* No drift
* No manual changes

If someone runs `kubectl edit`:

* Status becomes **OutOfSync**

---

### 🟢 Healthy

Means:

* Kubernetes resources are functioning correctly
* Pods running
* No CrashLoopBackOff
* Readiness probes passing

Very important distinction:

| Case                  | Meaning                 |
| --------------------- | ----------------------- |
| Synced + Healthy      | Perfect                 |
| Synced + Unhealthy    | Git correct, app broken |
| OutOfSync + Healthy   | Manual change detected  |
| OutOfSync + Unhealthy | Chaos                   |

---

## 5.4 Repository

```
https://github.com/jumptotechschooldevops/grade-api-gitops
```

This proves:

* Argo deploys **from Git**
* Not from laptop
* Not from CI artifacts

---

## 5.5 Target Revision

```
main
```

Means:

* Argo tracks `main` branch
* Any commit to main becomes desired state

This is why:

* Branch protection
* Pull request reviews

Are critical in GitOps.

---

## 5.6 Path

```
Path: .
```

Means:

* Kubernetes manifests are at repo root

In real systems:

```
/dev
/stage
/prod
```

Each path can map to **different Argo applications**.

---

## 5.7 Destination (Cluster)

```
Destination: in-cluster
```

Means:

* Argo deploys to the same cluster it runs in

In enterprises:

* Argo deploys to multiple remote clusters (EKS, AKS, GKE)

---

## 5.8 Namespace

```
Namespace: grade
```

This is where:

* Pods run
* Services exist

Argo created it automatically because:

```yaml
CreateNamespace=true
```

---

## 5.9 Created / Last Sync Time

Shows:

* When the application was created
* Last reconciliation time

This provides:

* Auditability
* Deployment history
* Compliance evidence

---

## 5.10 Sync / Refresh / Delete Buttons

---

### SYNC

* Manually apply Git → cluster
* Used when auto-sync is disabled

---

### REFRESH

* Re-check Git and cluster
* Does not deploy anything

---

### DELETE

⚠️ Very dangerous in production.

Deletes:

* Deployment
* Pods
* Services
* ConfigMaps
* Secrets
  (Everything owned by the app)

---

# 🔹 PART 4: WHAT THIS DASHBOARD PROVES

This dashboard proves **five production-level truths**:

---

## ✅ 1. Git Is the Source of Truth

No Git change → no deployment.

---

## ✅ 2. Humans Cannot Permanently Change Prod

Manual kubectl changes are reverted.

---

## ✅ 3. Drift Is Detectable

Any mismatch is visible immediately.

---

## ✅ 4. Rollbacks Are Git-Based

`git revert` = production rollback.

---

## ✅ 5. Kubernetes Is Declarative

Desired state is enforced continuously.

---

# 🔹 PART 5: ONE-SENTENCE SUMMARY 



> “The Argo CD dashboard shows whether Kubernetes is obeying Git — and if not, Argo forces it to.”

---

# 🔹 PART 6: COMMON INTERVIEW QUESTIONS FROM THIS DASHBOARD

**Q: What does Synced mean in Argo CD?**
A: Git and live cluster state match.

**Q: What happens if someone edits prod manually?**
A: Argo detects drift and reverts it.

**Q: Can Argo deploy without CI?**
A: Yes — CI only builds artifacts, Argo deploys from Git.

**Q: Is Argo replacing Kubernetes?**
A: No — Argo controls desired state, Kubernetes executes it.



