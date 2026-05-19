---
title: "kubernetes project #1"
description: "“Run ONE Web App in Kubernetes and Access It”    If someone understands this project,..."
published: 2026-01-04
source: "https://dev.to/jumptotech/kubernetes-project-1-1hg7"
tags: []
---

# kubernetes project #1




## “Run ONE Web App in Kubernetes and Access It”

> If someone understands **this project**, Kubernetes will finally *click*.

---

## What you will build 

You will run **one containerized web app** in Kubernetes and access it from your browser.

![Image](https://k21academy.com/wp-content/uploads/2020/11/KubernetesPods_Diagram-47.png)

![Image](https://devtron.ai/blog/content/images/2024/10/service-request-flow.gif)

![Image](https://images.clickittech.com/2020/wp-content/uploads/2022/04/13202329/Diagram-55.jpg)

```
Browser → Service → Pod → Container
```


---

## here we see:



* What a **Pod** is
* Why Kubernetes exists
* How traffic reaches a container
* Why Kubernetes networking is different from Docker

If this is not clear → nothing else will be clear.

---

# PROJECT GOAL

✔ Run an app in Kubernetes
✔ Expose it
✔ Open it in a browser
✔ Understand each step

---

# REQUIREMENTS

* Minikube (local Kubernetes)
* kubectl
* Docker installed

---

# STEP 1 — Start Kubernetes (Minikube)

```bash
minikube start
```

Verify:

```bash
kubectl get nodes
```

Expected:

```
NAME       STATUS   ROLES    AGE   VERSION
minikube   Ready    control-plane   ...
```

Why:

> Kubernetes always runs workloads on **nodes**.

---

# STEP 2 — Create a Pod (Smallest Kubernetes unit)

Create file: `pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
  labels:
    app: hello
spec:
  containers:
  - name: hello-container
    image: nginx
    ports:
    - containerPort: 80
```

Apply it:

```bash
kubectl apply -f pod.yaml
```

Check:

```bash
kubectl get pods
```

Why:

> A **Pod** is the smallest thing Kubernetes runs — not a container.

---

# STEP 3 — Verify Pod is Running

```bash
kubectl describe pod hello-pod
```

Key things to notice:

* Pod IP
* Container status
* Events

Explain to students:

> Kubernetes assigned an IP, started the container, and is monitoring it.

---

# STEP 4 — Create a Service (Expose the Pod)

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
    nodePort: 30007
```

Apply:

```bash
kubectl apply -f service.yaml
```

Check:

```bash
kubectl get svc
```

Why:

> Pod IPs are **not stable**.
> Services provide **stable access**.

---

# STEP 5 — Access from Browser

Run:

```bash
minikube ip
```

Open browser:

```
http://<MINIKUBE_IP>:30007
```

You should see:

```
Welcome to nginx!
```

 **This is Kubernetes working.**

---

# STEP 6 — Prove Kubernetes Self-Healing (Key Concept)

Delete the Pod:

```bash
kubectl delete pod hello-pod
```

Check:

```bash
kubectl get pods
```

Result:
❌ Pod is gone
❌ Service has nothing to route to

Explain:

> This is why Pods alone are NOT production-ready.

---

# WHAT YOU LEARNED (This is huge)

| Concept               | You now understand     |
| --------------------- | ---------------------- |
| Pod                   | Smallest unit          |
| Service               | Stable networking      |
| NodePort              | External access        |
| Labels                | How Services find Pods |
| Why Deployments exist | Pods die               |

---

# VERY IMPORTANT REALIZATION

 Kubernetes **did not recreate** the Pod
 That’s why we need **Deployments** next


