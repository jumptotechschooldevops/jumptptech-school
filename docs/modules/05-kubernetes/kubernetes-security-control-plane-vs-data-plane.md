---
title: "Kubernetes Security Control Plane vs Data Plane"
description: "Before details, lock this mental model:     Area What it controls Kubernetes feature     Control..."
published: 2026-01-30
source: "https://dev.to/jumptotech/kubernetes-security-control-plane-vs-data-plane-14c8"
tags: []
---

# Kubernetes Security Control Plane vs Data Plane




Before details, lock this mental model:

| Area                       | What it controls                  | Kubernetes feature |
| -------------------------- | --------------------------------- | ------------------ |
| **Control Plane Security** | Who can do what in Kubernetes API | **RBAC**           |
| **Data Plane Security**    | Who can talk to whom over network | **NetworkPolicy**  |
| **Runtime Identity**       | Who the pod *is*                  | ServiceAccount     |
| **Traffic Flow**           | Pod → Pod / Pod → Service         | CNI + kube-proxy   |

If you mix these up, you fail interviews and break prod.

---

# PART 1 — RBAC (Role-Based Access Control)

## What RBAC Is 

**RBAC answers ONE question only:**

> “Who is allowed to do WHAT on WHICH Kubernetes resource?”

RBAC **does NOT**:

* Control network traffic
* Control pod-to-pod access
* Control OS permissions

RBAC only protects **Kubernetes API access**.

![Image](https://svg.template.creately.com/SFOexgh5zLz)

![Image](https://developer.okta.com/assets-jekyll/blog/k8s-api-server-oidc/kube-login-oidc-ad4caf57f124e622897e0781fe1e3d6e1ecb5c6099776e6677ca800c4458f1de.jpg)

![Image](https://miro.medium.com/0%2ACwEN-ihGFgWsi-6A.jpeg)

---

## RBAC Core Components

### 1️⃣ Subject (WHO)

* User (human)
* Group
* **ServiceAccount** (most important for DevOps)

### 2️⃣ Resource (WHAT)

* pods
* deployments
* services
* secrets
* configmaps
* nodes

### 3️⃣ Verb (ACTION)

* get
* list
* watch
* create
* update
* patch
* delete

### 4️⃣ Scope (WHERE)

* Namespace → `Role`
* Cluster-wide → `ClusterRole`

---

## RBAC Objects (Must Memorize)

| Object               | Purpose                              |
| -------------------- | ------------------------------------ |
| `Role`               | Permissions inside **one namespace** |
| `ClusterRole`        | Permissions **cluster-wide**         |
| `RoleBinding`        | Bind Role → user/SA                  |
| `ClusterRoleBinding` | Bind ClusterRole → user/SA           |

---

##  Example: Read-only Pods

### Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: dev
subjects:
- kind: ServiceAccount
  name: app-sa
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## Intermediate RBAC (Real DevOps)

### DevOps Golden Rules

* ❌ Never give `*` permissions
* ❌ Never use `cluster-admin`
* ✅ Always use **ServiceAccounts**
* ✅ Scope to namespace whenever possible

---

## Who Writes RBAC in Real Companies?

| Team              | What they write                 |
| ----------------- | ------------------------------- |
| Platform / DevOps | ClusterRoles, baseline policies |
| Security          | Restrictions, audits            |
| App teams         | Rarely (usually request access) |

**DevOps owns RBAC. Developers request permissions.**

---

## Advanced RBAC Topics

### ServiceAccount Identity

```yaml
spec:
  serviceAccountName: app-sa
```

Pods authenticate automatically via:

* `/var/run/secrets/kubernetes.io/serviceaccount/token`

---

### RBAC vs IAM (EKS example)

| Layer           | Controls                        |
| --------------- | ------------------------------- |
| AWS IAM         | Who can call Kubernetes API     |
| Kubernetes RBAC | What they can do inside cluster |

Both are required.

---

### RBAC Debugging (Interview Gold)

```bash
kubectl auth can-i get pods -n dev --as system:serviceaccount:dev:app-sa
```

If you don’t know this → junior.

---

# PART 2 — Pod-to-Pod Communication (Networking Basics)

## Default Kubernetes Behavior 

By default:

* ✅ All Pods can talk to all Pods
* ❌ No isolation
* ❌ No security

This is **intentionally insecure** until you add policies.

![Image](https://opensource.com/sites/default/files/2022-05/1containerandpodnets.jpg)

![Image](https://docs.cloud.google.com/static/kubernetes-engine/distributed-cloud/bare-metal/docs/images/question-marks.svg)

![Image](https://www.tigera.io/app/uploads/2021/12/K8s-CNI-diagram01.png)

---

## How Pod Networking Works

* Every Pod gets its own IP
* Pods communicate directly (no NAT)
* CNI plugin handles routing

Common CNIs:

* Calico
* Cilium
* Weave
* AWS VPC CNI

---

## Services vs Pod IPs

❌ Never connect using Pod IP
✅ Always connect using **Service DNS**

```text
backend.default.svc.cluster.local
```

---

# PART 3 — NetworkPolicy (THIS is Pod-to-Pod Security)

## What NetworkPolicy Is

**NetworkPolicy controls network traffic.**

It answers:

> “Which Pods are allowed to talk to which Pods, on which ports?”

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AAdeOsbIetVPZ2Cmi3hzi7A.gif)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A2sASC4uYBbPm6EG9gLjsdQ.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AxcOIBtIZFbmYwBMS)

---

## Important Truth (Many Miss This)

⚠️ NetworkPolicy only works if:

* Your CNI **supports it**

AWS VPC CNI ❌ (needs Calico/Cilium)

---

## Default Behavior Without NetworkPolicy

| Traffic               | Allowed |
| --------------------- | ------- |
| Pod → Pod             | ✅       |
| Namespace → Namespace | ✅       |
| External → Pod        | Depends |

---

## Default Deny Policy (MOST IMPORTANT)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

This **locks everything**.

---

## Allow Frontend → Backend Only

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
      podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

---

## Key Selectors You MUST Know

| Selector            | Purpose               |
| ------------------- | --------------------- |
| `podSelector`       | Select pods           |
| `namespaceSelector` | Cross-namespace rules |
| `ipBlock`           | External CIDRs        |

---

## Egress Control 

```yaml
egress:
- to:
  - ipBlock:
      cidr: 10.0.0.0/16
  ports:
  - port: 5432
```

Used for:

* DB access
* External APIs
* Compliance

---

# PART 4 — RBAC vs NetworkPolicy (Interview Trap)

| Feature                  | RBAC | NetworkPolicy |
| ------------------------ | ---- | ------------- |
| Controls API access      | ✅    | ❌             |
| Controls network traffic | ❌    | ✅             |
| Blocks kubectl           | ✅    | ❌             |
| Blocks pod traffic       | ❌    | ✅             |

If candidate mixes this → reject.

---

# PART 5 — Real Production Architecture

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AxcOIBtIZFbmYwBMS)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AKyTFegSqM7sldDng762XvA.jpeg)

![Image](https://www.redhat.com/rhdc/managed-files/cl-containers-and-kubernetes-sec-whitepaper-f29820_figure_1.png)

### Production Setup

* Namespace per app
* Default deny NetworkPolicy
* Minimal RBAC
* Separate ServiceAccounts
* No shared secrets
* GitOps enforced

---

# PART 6 — Who Owns What (Real World)

| Area            | Owner             |
| --------------- | ----------------- |
| RBAC            | DevOps / Platform |
| NetworkPolicy   | DevOps + Security |
| ServiceAccounts | DevOps            |
| App labels      | Developers        |
| Access requests | Developers        |

Developers **do NOT** manage security directly.

---

# PART 7 — Common DevOps Failures

❌ Using `cluster-admin`
❌ No NetworkPolicy
❌ One ServiceAccount for all apps
❌ Allow-all traffic
❌ No RBAC audit

---

# PART 8 — Interview-Level Scenarios

### Scenario 1

> App can’t call another service

Check:

* NetworkPolicy
* Namespace labels
* Service selector

---

### Scenario 2

> Dev can deploy but can’t read secrets

Fix:

* RBAC missing `secrets` resource
* Correct namespace

---

### Scenario 3

> Pod can call API but not DB

Fix:

* Egress NetworkPolicy missing
* CIDR not allowed

---

# FINAL DEVOPS SUMMARY

As a DevOps engineer, **your responsibility**:

* Design RBAC
* Enforce least privilege
* Lock down pod traffic
* Create default deny policies
* Enable GitOps enforcement
* Debug access & traffic failures

This is **core DevOps / SRE knowledge**, not optional.


