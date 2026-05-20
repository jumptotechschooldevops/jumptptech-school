---
title: "CKA PRACTICE LAB"
description: "🧩 TASK 1 — Pod Fails to Start (ImagePullBackOff)            Setup (run first)      kubectl..."
published: 2026-01-08
source: "https://dev.to/jumptotech/cka-related-tasks-29ke"
tags: []
---

# CKA PRACTICE LAB








## 🧩 TASK 1 — Pod Fails to Start (ImagePullBackOff)

### Setup (run first)

```bash
kubectl run broken-pod --image=nginx:1.250
```

### Task

A pod named `broken-pod` exists.

The pod is not in a Running state.

Fix the issue so the pod reaches the **Running** state.

---

## 🧩 TASK 2 — Service Has No Endpoints

### Setup (run first)

```bash
kubectl create deployment web --image=nginx
kubectl expose deployment web --port=80 --target-port=80
kubectl patch svc web -p '{"spec":{"selector":{"app":"wrong"}}}'
```

### Task

A Deployment and Service named `web` exist.

Pods are running, but traffic sent to the Service does not reach the application.

Fix the issue so the Service routes traffic correctly.

---

## 🧩 TASK 3 — CrashLoopBackOff Deployment (Command Issue)

### Setup (run first)

```bash
kubectl create deployment api --image=nginx
kubectl patch deployment api -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "nginx",
            "image": "nginx",
            "command": ["wrong-command"]
          }
        ]
      }
    }
  }
}'
```

### Task

A Deployment named `api` exists.

One or more Pods are in **CrashLoopBackOff**.

Fix the Deployment so all Pods are running and stable.

---

## 🧩 TASK 4 — Pods Running but Not Ready

### Setup (run first)

```bash
kubectl create deployment frontend --image=nginx
kubectl expose deployment frontend --port=80 --target-port=80
kubectl patch deployment frontend -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "nginx",
            "image": "nginx",
            "readinessProbe": {
              "tcpSocket": {
                "port": 9999
              },
              "initialDelaySeconds": 5,
              "periodSeconds": 5
            }
          }
        ]
      }
    }
  }
}'
```

### Task

Pods created by the Deployment are running but **not Ready**.

Traffic sent to the Service does not reach the application.

Fix the issue so Pods become Ready and traffic flows correctly.

---

## 🧩 TASK 5 — CrashLoopBackOff Due to ConfigMap

### Setup (run first)

```bash
kubectl create configmap app-config --from-literal=PORT=8080

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: nginx
        env:
        - name: APP_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_PORT
EOF
```

### Task

A Deployment named `app` exists.

Pods are in **CrashLoopBackOff**.

The application depends on configuration from a ConfigMap.

Fix the configuration so the Pods run successfully.

---

## 🧩 TASK 6 — Deployment Rollout Not Progressing

### Setup (run first)

```bash
kubectl create deployment rollout --image=nginx
kubectl patch deployment rollout -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "nginx",
            "image": "nginx",
            "command": ["bad-command"]
          }
        ]
      }
    }
  }
}'
```

### Task

A Deployment named `rollout` exists.

The Deployment shows available replicas, but one or more Pods are unhealthy.

Fix the Deployment so the rollout completes successfully.

---

## 🧹 Cleanup (Optional)

```bash
kubectl delete pod broken-pod
kubectl delete deployment web api frontend app rollout
kubectl delete svc web frontend
kubectl delete configmap app-config
```

---

## ✅ Completion Check

For each task, confirm:

```bash
kubectl get pods
```

Expected final state:

```
READY   1/1
STATUS  Running
```


