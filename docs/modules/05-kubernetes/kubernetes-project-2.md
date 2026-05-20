---
title: "Kubernetes Project #2"
description: "“Production Basics: Deployment + Service + Rolling Update”            What you will..."
published: 2026-01-04
source: "https://dev.to/jumptotech/kubernetes-project-2-4805"
tags: []
---

# Kubernetes Project #2





## “Production Basics: Deployment + Service + Rolling Update”

### What you will build

```
Browser → Service (NodePort) → Deployment → Pods (replicas=2) → nginx containers
```

### What you will learn (DevOps core)

* Why **Deployments** exist (self-healing + rolling updates)
* How **replicas** work (high availability)
* Why **Service + selectors** are critical
* How to **scale**
* How to do a **rolling update**
* How to **troubleshoot** when things don’t work

---

## Prerequisites

* Minikube running
* kubectl working

Start/verify:

```bash
minikube start
kubectl get nodes
```

---

# Step 0 — Clean up from Project #1 (if you ran it)

This prevents conflicts and confusion.

```bash
kubectl delete pod hello-pod --ignore-not-found
kubectl delete svc hello-service --ignore-not-found
```

Check nothing left:

```bash
kubectl get pods
kubectl get svc
```

---

# Step 1 — Create a Deployment (NOT a Pod)

A **Deployment** is a “manager” that ensures the desired number of Pods are always running.

Create file: `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

Apply it:

```bash
kubectl apply -f deployment.yaml
```

### What each part means (important)

* **replicas: 2** → Kubernetes will keep **2 Pods** running.
* **selector.matchLabels** → how Deployment knows which Pods belong to it.
* **template** → the actual Pod blueprint.
* **labels app: hello** → key for Service routing.

### Verify

```bash
kubectl get deployments
kubectl get pods -o wide
```

Expected:

* Deployment `hello-deploy` READY `2/2`
* Two pods with names like `hello-deploy-xxxxx`

---

# Step 2 — Understand what Deployment created

A Deployment automatically creates:

1. **ReplicaSet** (the low-level controller)
2. **Pods** (the running instances)

Check:

```bash
kubectl get rs
```

Explain:

* Deployment = rollout strategy + versioning
* ReplicaSet = “keep N pods running”
* Pod = actual workload

---

# Step 3 — Expose it using a Service (stable access)

Pods get replaced and IPs change, so we use a Service.

Create file: `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  type: NodePort
  selector:
    app: hello
  ports:
  - port: 80
    targetPort: 80
```

Apply:

```bash
kubectl apply -f service.yaml
```

### What this does

* `selector: app: hello` → finds pods with that label
* `port: 80` → service port
* `targetPort: 80` → container port
* `NodePort` → opens a port on the node so your browser can reach it

Verify:

```bash
kubectl get svc
kubectl describe svc hello-service
```

**Key thing to check** inside `describe`:

* Endpoints should show **2 pod IPs**

  * If Endpoints is empty → selector mismatch or pods not ready.

---

# Step 4 — Open in the Browser

Run:

```bash
minikube service hello-service --url
```

It prints something like:

```
http://127.0.0.1:5xxxx
```

Open that URL in a browser → you should see **Welcome to nginx!**

Why this is best:

* avoids dealing with NodePort/IP differences on Mac

---

# Step 5 — Prove High Availability (Replica behavior)

Delete one Pod manually:

1. list pods:

```bash
kubectl get pods
```

2. delete one pod:

```bash
kubectl delete pod <one-pod-name>
```

3. watch what happens:

```bash
kubectl get pods -w
```

What you will observe:

* Pod terminates
* Deployment/ReplicaSet immediately creates a **new Pod**
* You still have **2 running pods**

Explain to students:

> This is Kubernetes self-healing. You don’t “restart containers” manually in prod. The controller does it.

---

# Step 6 — Scale Up (simulate traffic growth)

Scale to 5 replicas:

```bash
kubectl scale deployment hello-deploy --replicas=5
```

Check:

```bash
kubectl get pods
kubectl get deployment hello-deploy
```

Expected: 5 pods running.

Explain:

> Scaling is a normal DevOps operation during peak traffic.

Scale back down:

```bash
kubectl scale deployment hello-deploy --replicas=2
```

---

# Step 7 — Rolling Update (Zero-downtime deployment)

Now you will change the image version and watch Kubernetes update pods gradually.

Update to a newer nginx (example):

```bash
kubectl set image deployment/hello-deploy nginx=nginx:1.26
```

Watch rollout:

```bash
kubectl rollout status deployment/hello-deploy
kubectl get pods -w
```

What you’ll see:

* Kubernetes creates new pods
* then deletes old pods
* keeps service available (no downtime) if replicas > 1

Check rollout history:

```bash
kubectl rollout history deployment/hello-deploy
```

Rollback (very important skill):

```bash
kubectl rollout undo deployment/hello-deploy
```

Explain:

> Rollback is what you do when a release breaks production.

---

# Step 8 — Troubleshooting Checklist (Most important for DevOps)

## Case A: Service exists but website doesn’t open

Run in this order:

1. Are pods running?

```bash
kubectl get pods
```

2. Are pods ready?

```bash
kubectl describe pod <pod>
```

3. Does service have endpoints?

```bash
kubectl describe svc hello-service
```

Look for:

* `Endpoints: <ip1>:80, <ip2>:80`
  If endpoints empty → selector mismatch.

4. Are labels correct?

```bash
kubectl get pods --show-labels
kubectl get svc hello-service -o yaml
```

Check:

* service selector matches pod labels

## Case B: Pods stuck in Pending

```bash
kubectl describe pod <pod>
```

Typical reasons:

* not enough CPU/memory
* cluster not started properly

## Case C: CrashLoopBackOff

```bash
kubectl logs <pod>
kubectl describe pod <pod>
```

Look for:

* app error
* wrong command/args
* missing env vars

---

# What you should be able to explain after Project #2

If you can explain these, you’re at a strong DevOps level:

1. Why Deployment is production standard, not Pod
2. What ReplicaSet does
3. How Service routes traffic (selector → endpoints → pods)
4. How scaling works
5. How rolling updates work
6. How to rollback
7. How to troubleshoot “service up but not reachable”

---

# Clean up (end of lab)

```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
```


