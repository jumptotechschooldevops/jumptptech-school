---
title: "Kubernetes"
description: "1. What Problem Kubernetes Solves   When we run applications in containers, we need to..."
published: 2025-11-11
source: "https://dev.to/jumptotech/kubernetes-g9p"
tags: []
---

# Kubernetes



## 1. What Problem Kubernetes Solves

When we run applications in **containers**, we need to handle:

| Task                                  | Problem                                        | Example                          |
| ------------------------------------- | ---------------------------------------------- | -------------------------------- |
| Running many containers               | Who will start them? Restart them if they die? | `docker run` many times (manual) |
| Scaling up/down                       | What if traffic increases 10x?                 | Need auto-scaling                |
| Load Balancing                        | How to route traffic across containers?        | Need a load balancer             |
| Updates with zero downtime            | How to release new versions safely?            | Need rolling updates             |
| Manage containers across many servers | Need centralized control                       | Need orchestration               |

**Kubernetes is an Orchestrator.**
It **automatically manages containers** across **multiple servers**.

Kubernetes = **Robot Manager** for your Docker containers.

---

## 2. Kubernetes Architecture (Simple)

```
+---------------------------------------------------+
|                    CLUSTER                        |
|                                                   |
|  +--------------------+    +--------------------+ |
|  |  WORKER NODE #1    |    |  WORKER NODE #2    | |
|  |                    |    |                    | |
|  |  PODs (containers) |    |  PODs (containers) | |
|  +--------------------+    +--------------------+ |
|                                                   |
|  +--------------------+                           |
|  |  MASTER/CONTROL    |                           |
|  |  (brain of cluster)| -> API Server, Scheduler  |
|  +--------------------+                           |
+---------------------------------------------------+
```

### Key Terms (Very Important)

| Term       | Meaning                             | Think of it as                     |
| ---------- | ----------------------------------- | ---------------------------------- |
| Cluster    | Whole Kubernetes environment        | Company                            |
| Node       | Machine (VM/EC2/Server)             | Employee                           |
| Pod        | Smallest unit; runs container(s)    | Desk                               |
| Deployment | Ensures how many Pods must run      | Manager giving orders              |
| Service    | Exposes your application for access | Door/phone number to reach the app |

---

## 3. Install Kubernetes Locally (Minikube)

Since you already use Docker Desktop → Kubernetes is likely included.

### Step 1: Enable Kubernetes in Docker Desktop

Docker Desktop → Settings → **Kubernetes → Enable** → Apply → Wait.

### Verify installation:

```bash
kubectl version --client
kubectl get nodes
```

You should see:

```
NAME       STATUS   ROLES    AGE   VERSION
docker-desktop   Ready    master   ...
```

If not using Docker Desktop → install Minikube:

```bash
brew install minikube
minikube start
kubectl get nodes
```

---

## 4. First Hands-on Kubernetes Commands

### See the cluster nodes

```bash
kubectl get nodes
```

### Deploy a test application

```bash
kubectl create deployment myapp --image=nginx
```

### Check pods

```bash
kubectl get pods
```

### Expose the application

```bash
kubectl expose deployment myapp --port=80 --type=NodePort
```

### Get service info

```bash
kubectl get svc
```

### Access application (Minikube):

```bash
minikube service myapp
```

---

## 5. Scaling Your App (Zero Downtime)

```bash
kubectl scale deployment myapp --replicas=5
kubectl get pods
```

This runs **5 nginx containers automatically**.

---

## 6. Deploy Using YAML (DevOps Way)

Create a file: `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: nginx
        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f deployment.yaml
kubectl get pods
```

---

## 7. Update Container Version (Rolling Update)

```bash
kubectl set image deployment/myapp myapp=nginx:latest
```

Check rollout status:

```bash
kubectl rollout status deployment/myapp
```

Rollback:

```bash
kubectl rollout undo deployment/myapp
```

---

## 8. Delete Apps

```bash
kubectl delete deployment myapp
kubectl delete svc myapp
```

---

## 9. Summary (Core Concepts to Remember)

| Component      | Purpose                   |
| -------------- | ------------------------- |
| **Pod**        | Runs containers           |
| **Node**       | Server that runs Pods     |
| **Deployment** | Manages scaling + updates |
| **Service**    | Exposes apps              |
| **kubectl**    | Kubernetes command-line   |

---

## Next Step You Should Learn (We will do next):

1. Namespaces
2. Ingress
3. ConfigMap & Secrets
4. Persistent Volumes
5. Helm
6. OPA Gatekeeper (Your goal)





# **PROJECT: Secure Kubernetes with OPA Gatekeeper**

**Goal:**
Deploy a sample application to Kubernetes and enforce **security policies** using **OPA Gatekeeper** so users cannot deploy insecure workloads.

---

## **1. What is OPA (Open Policy Agent)?** (Beginner Explanation)

| Concept        | Meaning                       | Example                                |
| -------------- | ----------------------------- | -------------------------------------- |
| **OPA**        | Policy Engine                 | Like a security officer checking rules |
| **Rego**       | Policy Language (used by OPA) | The rules themselves                   |
| **Gatekeeper** | OPA plugin for Kubernetes     | Enforces policies on Kubernetes API    |

### In simple words:

Kubernetes lets anyone deploy anything unless we restrict it.
OPA **acts like a security guard** at the API level:

```
kubectl apply manifest.yaml
          |
          v
   +-------------------+
   | OPA Gatekeeper    |  <-- Checks rules
   +-------------------+
          |
 Allow or Deny
```

---

## **2. Common Real-World Policies OPA Enforces**

| Policy                                     | Why                            |
| ------------------------------------------ | ------------------------------ |
| No containers run as root                  | Security Best Practice         |
| Each pod must have limits/requests         | Prevent cluster resource abuse |
| Only approved container registries allowed | Prevent malware images         |
| Block privileged containers                | Prevent host takeover          |

We will **apply these**.

---

## **3. Setup Kubernetes Cluster (Local Minikube or Docker Desktop)**

Verify cluster:

```bash
kubectl get nodes
```

If using Minikube:

```bash
minikube start
```

---

## **4. Install OPA Gatekeeper**

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```

Wait for pods:

```bash
kubectl get pods -n gatekeeper-system
```

Expected:

```
NAME                                      READY   STATUS    AGE
gatekeeper-controller-manager-xxxx        1/1     Running   1m
```

---

## **5. Deploy a Sample Application (Without Policy Yet)**

```bash
kubectl create deployment insecure-app --image=nginx
kubectl expose deployment insecure-app --port=80 --type=NodePort
kubectl get pods
```

This will work normally.

---

## **6. Apply a Security Policy (Block Running as Root)**

OPA policies are created in two parts:

| File                   | Purpose                       |
| ---------------------- | ----------------------------- |
| **ConstraintTemplate** | Defines the rule logic (Rego) |
| **Constraint**         | Applies rule to the cluster   |

### Step 6.1 Create the ConstraintTemplate

Create file: `disallow-root-template.yaml`

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sdisallowroot
spec:
  crd:
    spec:
      names:
        kind: K8sDisallowRoot
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sdisallowroot

      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        container.securityContext.runAsUser == 0
        msg := "Running containers as root is not allowed"
      }
```

Apply it:

```bash
kubectl apply -f disallow-root-template.yaml
```

### Step 6.2 Create the Constraint

Create file: `disallow-root-constraint.yaml`

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDisallowRoot
metadata:
  name: no-root-users
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
```

Apply it:

```bash
kubectl apply -f disallow-root-constraint.yaml
```

---

## **7. Test the Policy (Deploy a Root Pod) — It Should Fail**

```bash
kubectl run test-root --image=nginx --command -- sleep 3600
```

Expected Output:

```
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: Running containers as root is not allowed
```

✅ **OPA is working. Policy is enforced.**

---

## **8. Deploy a Secure Pod (Non-root) — It Should Work**

Create `secure-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      runAsUser: 1000
```

Apply:

```bash
kubectl apply -f secure-pod.yaml
kubectl get pods
```

✅ **This pod runs successfully** — Policy allows it.

---

## **9. What We Have Built**

| Component      | Result                          |
| -------------- | ------------------------------- |
| Kubernetes App | Running                         |
| OPA Gatekeeper | Installed                       |
| Policy         | Blocks root containers          |
| Enforcement    | Verified (blocked insecure pod) |

This is **real production knowledge**.

---

## **10. Real DevOps Interview Explanation**

> “We use OPA Gatekeeper in Kubernetes to enforce governance and security policies at admission time. Policies are written in Rego and applied using ConstraintTemplates and Constraints. For example, we enforce that no container runs as root and that resource limits are mandatory. This prevents insecure workloads before they are deployed into the cluster.”





We will add **3 more critical security policies**:

| Policy                                       | Purpose                                                     | Real Impact                |
| -------------------------------------------- | ----------------------------------------------------------- | -------------------------- |
| **Require Resource Limits**                  | Prevent cluster from crashing due to a single bad container | Protects cluster stability |
| **Disallow Privileged Pods**                 | Prevent pods from gaining host-level access                 | Security compliance        |
| **Allow Images Only from Approved Registry** | Prevent malware or unknown container images                 | Supply chain protection    |

---

# 1) **Policy: Require CPU/Memory Limits**

Pods **must** include `resources.limits`.

### Step 1: Create Template

`require-limits-template.yaml`:

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequirelimits
spec:
  crd:
    spec:
      names:
        kind: K8sRequireLimits
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8srequirelimits

      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        not container.resources.limits
        msg := "Container must have CPU and memory limits set"
      }
```

Apply:

```bash
kubectl apply -f require-limits-template.yaml
```

### Step 2: Create Constraint

`require-limits-constraint.yaml`:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequireLimits
metadata:
  name: enforce-resource-limits
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
```

Apply:

```bash
kubectl apply -f require-limits-constraint.yaml
```

### Test (Should Fail):

```bash
kubectl run no-limits --image=nginx
```

### Test (Correct Pod):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-limits
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      limits:
        cpu: "500m"
        memory: "256Mi"
```

---

# 2) **Policy: Disallow Privileged Pods**

### Template

`no-privileged-template.yaml`:

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sdisallowprivileged
spec:
  crd:
    spec:
      names:
        kind: K8sDisallowPrivileged
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sdisallowprivileged

      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        container.securityContext.privileged == true
        msg := "Privileged containers are not allowed"
      }
```

Apply:

```bash
kubectl apply -f no-privileged-template.yaml
```

### Constraint

`no-privileged-constraint.yaml`:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDisallowPrivileged
metadata:
  name: prevent-privileged-containers
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
```

Apply:

```bash
kubectl apply -f no-privileged-constraint.yaml
```

### Test (Should **Fail**):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  containers:
  - name: alpine
    image: alpine
    securityContext:
      privileged: true
```

---

# 3) **Policy: Only Allow Containers from Approved Registry**

**Your company typically uses:**

* AWS ECR → `*.amazonaws.com`
* GCR → `gcr.io/*`
* DockerHub private `mycompany/*`

### Template

`allowed-registries-template.yaml`:

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sallowedregistries
spec:
  crd:
    spec:
      names:
        kind: K8sAllowedRegistries
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sallowedregistries

      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        approved := input.parameters.allowedRegistries[_]
        not startswith(container.image, approved)
        msg := sprintf("Container image '%v' is not from an approved registry", [container.image])
      }
```

Apply:

```bash
kubectl apply -f allowed-registries-template.yaml
```

### Constraint

`allowed-registries-constraint.yaml`:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRegistries
metadata:
  name: only-approved-registries
spec:
  parameters:
    allowedRegistries:
    - "gcr.io"
    - "docker.io/library"
    - "registry.k8s.io"
```

Apply:

```bash
kubectl apply -f allowed-registries-constraint.yaml
```

### Test (Should Fail):

```bash
kubectl run hacked --image=badimage.com/virus
```

✅ Rejected.

---

# ✅ What You Have Now (This is Enterprise-Ready)

| Policy                        | Status     |
| ----------------------------- | ---------- |
| No running as root            | ✅ Enforced |
| Must define memory/CPU limits | ✅ Enforced |
| No privileged pods            | ✅ Enforced |
| Only approved registry images | ✅ Enforced |

You now have **security and governance** enforced exactly like:

* Google Cloud SRE teams
* AWS Well-Architected security controls
* Bank / fintech regulated clusters

---

# ✅ Real Interview Answer

> “We use OPA Gatekeeper to enforce Kubernetes security best practices. We define policies as ConstraintTemplates in Rego, and apply them as Constraints to namespaces or cluster-wide. Our policies prevent privileged containers, require resource limits, enforce non-root execution, and restrict images to approved registries. This ensures strong governance, reduces attack surface, and prevents misconfiguration before deployment.”



