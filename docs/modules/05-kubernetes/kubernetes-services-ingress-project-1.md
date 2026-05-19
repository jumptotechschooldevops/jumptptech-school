---
title: "Kubernetes Services & Ingress. project #1"
description: "PREREQUISITES (ONCE)      minikube start kubectl get nodes        Enter fullscreen mode    ..."
published: 2026-01-11
source: "https://dev.to/jumptotech/kubernetes-services-ingress-project-1-knl"
tags: []
---

# Kubernetes Services & Ingress. project #1



## PREREQUISITES (ONCE)

```bash
minikube start
kubectl get nodes
```

Expected:

```
minikube   Ready
```

---

# BASE APP (USED FOR ALL PROJECTS)

> One app. Same Pods. Only networking changes.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=HELLO FROM POD"
        ports:
        - containerPort: 8080
```

```bash
kubectl apply -f deployment.yaml
kubectl get pods
```

---

# PROJECT 1 — **ClusterIP (Internal Only)**

![Image](https://zesty.co/wp-content/uploads/2025/02/clusterIP.png)

![Image](https://kubernetes.io/blog/2022/12/30/advancements-in-kubernetes-traffic-engineering/service-internal-traffic-policy-cluster.png)

## What This Proves

✔ Services give **stable internal networking**
✔ Pod IPs change — Service never changes

---

### Create ClusterIP

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-clusterip
spec:
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 8080
```

```bash
kubectl apply -f svc-clusterip.yaml
kubectl get svc
```

---

### Test (Correct Way)

```bash
kubectl run test --rm -it --image=busybox -- sh
wget -qO- demo-clusterip
```

---

### PROD ISSUE #1 — No endpoints

```bash
kubectl get endpoints demo-clusterip
```

**Cause**

* Selector ≠ Pod labels

**Fix**

```bash
kubectl get pods --show-labels
kubectl edit svc demo-clusterip
```

---

### DevOps Takeaway

> **ClusterIP is the backbone of Kubernetes.
> If this fails — nothing works.**

---

# PROJECT 2 — **NodePort (Why It Is Dangerous)**

## What This Proves

✔ NodePort opens ports
❌ Does NOT provide routing, HA, or stable IP

---

### Create NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-nodeport
spec:
  type: NodePort
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

```bash
kubectl apply -f svc-nodeport.yaml
kubectl get svc
```

---

### Access

```bash
minikube ip
curl http://<MINIKUBE-IP>:30080
```

---

### PROD ISSUE #1 — Random failures

```bash
kubectl delete pod -l app=demo
```

Still works?
YES → kube-proxy reroutes

Now imagine **node deleted in cloud** → ❌ DEAD

---

### PROD ISSUE #2 — Port blocked

In Minikube:
✔ works

In cloud:
❌ security group missing port

---

### DevOps Verdict

| Use        | Verdict |
| ---------- | ------- |
| Learning   | ✅       |
| Debug      | ✅       |
| Production | ❌       |

---

# PROJECT 3 — **LoadBalancer (Minikube Style)**

![Image](https://www.densify.com/wp-content/uploads/article-k8s-capacity-kubernetes-service-overview.svg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AYD81KTIu3PFjd7-uWvJyBw.jpeg)

## What This Proves

✔ Kubernetes **requests** LB
✔ Minikube **simulates** cloud LB

---

### Create LoadBalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-lb
spec:
  type: LoadBalancer
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 8080
```

```bash
kubectl apply -f svc-lb.yaml
kubectl get svc
```

---

### VERY IMPORTANT (Minikube Only)

```bash
minikube tunnel
```

Keep terminal open.

Now:

```bash
kubectl get svc demo-lb
```

You will see:

```
EXTERNAL-IP: 127.0.0.1
```

```bash
curl http://127.0.0.1
```

---

### PROD ISSUE #1 — EXTERNAL-IP pending

**Cause**

* No tunnel

**Fix**

```bash
minikube tunnel
```

---

### PROD ISSUE #2 — LB exists but no traffic

```bash
kubectl describe svc demo-lb
kubectl get endpoints demo-lb
```

**Cause**

* Pods not Ready

---

### DevOps Verdict

✔ Simple external apps
❌ Expensive in real cloud
❌ One LB per service

---

# PROJECT 4 — **Ingress (REAL PRODUCTION MODEL)**

![Image](https://vocon-it.com/wp-content/uploads/2018/12/2018-12-31-14_07_57-Minikube-and-Kubeadm-Google-Pr%C3%A4sentationen.png)

![Image](https://tetrate.io/.netlify/images?h=549\&q=90\&url=_astro%2Fimage-1024x549.Dst0COpw.png\&w=1024)

## What This Proves

✔ Ingress is **external traffic brain**
✔ One IP → many apps

---

## STEP 1 — Enable Ingress in Minikube

```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
```

Wait until:

```
ingress-nginx-controller Running
```

---

## STEP 2 — ClusterIP for Ingress

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-ingress-svc
spec:
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 8080
```

---

## STEP 3 — Ingress Rule

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
spec:
  rules:
  - host: demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo-ingress-svc
            port:
              number: 80
```

---

## STEP 4 — DNS (Local)

```bash
minikube ip
sudo nano /etc/hosts
```

Add:

```
<MINIKUBE-IP> demo.local
```

---

## Test

```bash
curl http://demo.local
```

---

### PROD ISSUE #1 — 404 from Ingress

```bash
kubectl describe ingress demo-ingress
```

**Cause**

* Wrong service name
* Wrong port

---

### PROD ISSUE #2 — Ingress OK, app broken

```bash
kubectl get endpoints demo-ingress-svc
kubectl get pods
```

**Cause**

* No Ready pods

---

### PROD ISSUE #3 — Ingress controller down

```bash
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx <controller-pod>
```

---

# FINAL DEVOPS MENTAL MODEL (MINIKUBE OR PROD)

```
Client
 |
 v
Ingress (routing rules)
 |
 v
Service (ClusterIP)
 |
 v
Pod
```

---

# FINAL SUMMARY TABLE

| Component    | Purpose             | Who Provides It  |
| ------------ | ------------------- | ---------------- |
| ClusterIP    | Internal networking | Kubernetes       |
| NodePort     | Port exposure       | Kubernetes       |
| LoadBalancer | External IP         | Cloud / Minikube |
| Ingress      | Routing + TLS       | Kubernetes       |
| Egress       | Outbound traffic    | Cloud / NAT      |


