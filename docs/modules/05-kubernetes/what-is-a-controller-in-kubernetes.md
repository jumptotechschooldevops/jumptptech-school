---
title: "What Is a Controller in Kubernetes?"
description: "🚀 1. What Is a Deployment?   A Deployment is a controller in Kubernetes that manages..."
published: 2025-11-12
source: "https://dev.to/jumptotech/what-is-a-controller-in-kubernetes-51jk"
tags: []
---

# What Is a Controller in Kubernetes?





## 🚀 1. What Is a Deployment?

A **Deployment** is a **controller** in Kubernetes that manages **ReplicaSets** and **Pods** to ensure your application runs reliably and can be easily updated.

It defines **how many replicas** (copies) of your Pod you want, and **how to update** them (rolling updates, rollbacks, etc.).

In short:

> A Deployment automates creating, updating, and scaling Pods.

---

## 🧠 2. The Relationship

Here’s the hierarchy:

```
Deployment → ReplicaSet → Pods
```

* **Deployment** = defines the desired state.
* **ReplicaSet** = maintains the correct number of Pods.
* **Pods** = run your containerized app.

---

## 🧩 3. Deployment YAML Example

Let’s look at a simple example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 3   # how many Pods to run
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
        image: nginx:latest
        ports:
        - containerPort: 80
```

---

## ⚙️ 4. Explanation of Each Section

| Field                        | Meaning                                                   |
| ---------------------------- | --------------------------------------------------------- |
| **apiVersion: apps/v1**      | Deployment is part of the `apps` API group.               |
| **kind: Deployment**         | Specifies the object type.                                |
| **metadata.name**            | Name of the Deployment.                                   |
| **spec.replicas**            | Desired number of Pod replicas.                           |
| **spec.selector**            | Labels used to find which Pods belong to this Deployment. |
| **spec.template**            | Template to create Pods.                                  |
| **template.metadata.labels** | Labels applied to the Pods. Must match the selector.      |
| **template.spec.containers** | Defines the container(s) inside each Pod.                 |
| **image**                    | The Docker image (here `nginx`).                          |
| **ports**                    | The port your container exposes.                          |

---

## 🔁 5. Create and Manage the Deployment

### Step 1: Apply the Deployment

```bash
kubectl apply -f deployment.yaml
```

### Step 2: Check the Deployment

```bash
kubectl get deployments
kubectl get pods
kubectl get rs
```

### Step 3: Describe the Deployment

```bash
kubectl describe deployment myapp-deployment
```

---

## ⚡ 6. Rolling Updates

If you change the image version (for example `nginx:1.25` → `nginx:1.26`):

```bash
kubectl set image deployment/myapp-deployment myapp=nginx:1.26
```

Kubernetes will:

1. Create new Pods (with new image).
2. Wait until they are ready.
3. Then delete old Pods.

This is called a **rolling update**, and it ensures **zero downtime**.

---

## 🕐 7. Rollback to Previous Version

If your new version breaks the app, rollback:

```bash
kubectl rollout undo deployment myapp-deployment
```

Check the status:

```bash
kubectl rollout status deployment myapp-deployment
kubectl rollout history deployment myapp-deployment
```

---

## ⚖️ 8. Scaling the Deployment

You can easily scale up/down the number of Pods.

### Manually:

```bash
kubectl scale deployment myapp-deployment --replicas=5
```

### Automatically (Horizontal Pod Autoscaler):

```bash
kubectl autoscale deployment myapp-deployment --min=2 --max=10 --cpu-percent=70
```

---

## 🔍 9. Verify Deployment Health

```bash
kubectl get pods -o wide
kubectl get deployment myapp-deployment -o yaml
kubectl describe rs
```

Look for:

* **Desired Replicas** = number you set
* **Current Replicas** = actual number
* **Available Replicas** = healthy running pods

---

## 🧹 10. Delete Deployment

```bash
kubectl delete deployment myapp-deployment
```

This automatically deletes ReplicaSets and Pods created by it.

---

## 🧠 11. Summary

| Feature           | Description                                       |
| ----------------- | ------------------------------------------------- |
| **Purpose**       | Manage ReplicaSets and Pods                       |
| **Benefits**      | Rolling updates, rollbacks, scaling               |
| **Replaces**      | ReplicaController                                 |
| **Command**       | `kubectl create deployment` or `kubectl apply -f` |
| **Zero Downtime** | Yes, during rolling updates                       |
| **Used For**      | Stateless applications                            |

---

## 💡 12. Quick Demo Commands (for practice)

```bash
# Create a deployment
kubectl create deployment nginx-deployment --image=nginx:latest --replicas=3

# List deployments
kubectl get deployment

# View pods
kubectl get pods -l app=nginx-deployment

# Update image
kubectl set image deployment/nginx-deployment nginx=nginx:1.27

# Rollback
kubectl rollout undo deployment nginx-deployment
```






## 🌐 PROJECT: Deploy a Web App with Deployment + Service + Ingress

### 🧱 Architecture Overview

```
Browser → Ingress → Service → Pods (via Deployment)
```

---

## 🪜 STEP 1 — Create the Deployment

Save this as `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
  labels:
    app: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:latest
        ports:
        - containerPort: 80
```

**Apply it:**

```bash
kubectl apply -f deployment.yaml
```

**Verify:**

```bash
kubectl get deployments
kubectl get pods -o wide
```

You should see **3 pods running**.

---

## 🪜 STEP 2 — Create a Service

Pods have internal IPs that change — so we need a **Service** to provide stable access.

Save as `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

**Apply it:**

```bash
kubectl apply -f service.yaml
```

**Check:**

```bash
kubectl get svc
```

---

## 🪜 STEP 3 — Create an Ingress (Entry Point)

Ingress exposes your app to the outside world via HTTP/HTTPS.

First, ensure your cluster has an **Ingress controller**:

* On **Minikube**, enable it:

  ```bash
  minikube addons enable ingress
  ```
* On **EKS**, use the **AWS Load Balancer Controller** (if not, I can show steps).

Now create `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: webapp.local   # (for Minikube)
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
```

**Apply it:**

```bash
kubectl apply -f ingress.yaml
```

**Check ingress:**

```bash
kubectl get ingress
```

---

## 🧪 STEP 4 — Test the Application

### For Minikube:

1. Add the hostname to your `/etc/hosts`:

   ```bash
   echo "$(minikube ip) webapp.local" | sudo tee -a /etc/hosts
   ```
2. Then open in browser:

   ```
   http://webapp.local
   ```

You should see the **Nginx welcome page**!

---

## 🧰 STEP 5 — Modify and Rollout Update

Now, let’s simulate a new version.
Edit `deployment.yaml` to use a custom page:

```yaml
        image: nginx:1.27
```

Apply the update:

```bash
kubectl apply -f deployment.yaml
```

Check rollout progress:

```bash
kubectl rollout status deployment webapp-deployment
```

If something breaks:

```bash
kubectl rollout undo deployment webapp-deployment
```

---

## 🧹 STEP 6 — Cleanup

```bash
kubectl delete -f ingress.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
```

---

## 🧠 Summary

| Component           | Role                                                      |
| ------------------- | --------------------------------------------------------- |
| **Deployment**      | Ensures 3 replicas of Nginx Pods are always running       |
| **Service**         | Provides stable internal access to those Pods             |
| **Ingress**         | Provides external access (via domain name / LoadBalancer) |
| **Controller Loop** | Keeps everything in desired state automatically           |



A **controller** is a control loop in Kubernetes that **monitors the current state** of cluster objects (like Pods, ReplicaSets, etc.) and **adjusts them** to match the **desired state** defined in your YAML manifests.

**Think of it like this:**

> You tell Kubernetes what you *want*, and the controller keeps checking reality to make sure it matches.

Example:

* You define a Deployment that says “I want 3 replicas of my app”.
* The **Deployment Controller** ensures there are always 3 Pods running.
* If one Pod crashes → controller creates a new one.

---

## ⚙️ 2. How Controllers Work (Control Loop)

Each controller follows this loop:

1. **Watch** → The controller watches the API server for changes in objects (like Pods, Deployments).
2. **Compare** → It compares the actual cluster state vs. desired state (YAML spec).
3. **Act** → If they differ, the controller takes corrective action (create/delete/update resources).

```bash
Desired State: 3 Pods
Current State: 2 Pods running
Action: Create 1 more Pod
```

This continuous feedback mechanism is what makes Kubernetes *self-healing*.

---

## 🧠 3. Major Built-In Controllers in Kubernetes

Kubernetes comes with **many built-in controllers** that manage various resource types.
Here are the main ones:

| Controller                   | Purpose                                                                                                             |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **ReplicationController**    | Ensures a specified number of Pod replicas are running. (Legacy — replaced by ReplicaSet)                           |
| **ReplicaSet**               | Maintains a stable set of replica Pods at any time.                                                                 |
| **Deployment**               | Manages ReplicaSets and handles rolling updates & rollbacks.                                                        |
| **StatefulSet**              | Manages Pods that need **stable network IDs**, **persistent storage**, and **ordered deployment** (like databases). |
| **DaemonSet**                | Ensures one Pod runs **on each node** (e.g., logging or monitoring agents).                                         |
| **Job**                      | Runs Pods until they **successfully complete**. Used for batch tasks.                                               |
| **CronJob**                  | Runs Jobs **on a schedule** (like cron in Linux).                                                                   |
| **ReplicaController (old)**  | Legacy controller replaced by ReplicaSet.                                                                           |
| **Namespace Controller**     | Cleans up resources when a namespace is deleted.                                                                    |
| **EndpointSlice Controller** | Manages network endpoint updates for Services.                                                                      |
| **Node Controller**          | Detects and responds to node health changes.                                                                        |
| **Service Controller**       | Creates cloud load balancers when you create a Service of type `LoadBalancer`.                                      |

---

## 🧩 4. The Relationship Between Controllers

Controllers often **work together**:

* **Deployment → ReplicaSet → Pods**
  Deployment creates and manages ReplicaSets.
  ReplicaSets manage Pods.

Example YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

Here’s what happens:

* The **Deployment Controller** reads this manifest.
* It creates a **ReplicaSet** with 3 replicas.
* The **ReplicaSet Controller** creates 3 Pods with the label `app=nginx`.

---

## 🔁 5. Controller Manager

All controllers are processes running inside the **kube-controller-manager** component on the **control plane**.

It runs many controllers together:

* Node Controller
* Job Controller
* Deployment Controller
* EndpointSlice Controller
* Namespace Controller
* Replication Controller, etc.

You can see this as a **binary process** running on the master node:

```bash
ps -ef | grep kube-controller-manager
```

---

## 🏗️ 6. Custom Controllers and Operators

You can create your own controllers using **Custom Resource Definitions (CRDs)**.

### Custom Controller

* Watches for your **custom resources**.
* Takes actions to maintain desired state.

### Operator Pattern

An **Operator** is a **custom controller** that encodes **domain-specific logic** (like managing databases, Prometheus, Kafka).

Examples:

* **Prometheus Operator**
* **Argo CD Operator**
* **MongoDB Operator**

---

## 🧩 7. Comparison Between Key Controllers

| Feature            | Deployment     | StatefulSet | DaemonSet      | Job            | CronJob         |
| ------------------ | -------------- | ----------- | -------------- | -------------- | --------------- |
| Pod replicas       | ✅              | ✅           | ✅ (1 per node) | ❌              | ❌               |
| Persistent storage | ❌              | ✅           | ✅              | ✅              | ✅               |
| Rolling updates    | ✅              | ✅ (ordered) | ✅              | ❌              | ❌               |
| Suitable for       | stateless apps | databases   | agents/logging | one-time tasks | scheduled tasks |

---

## 🧰 8. Useful Commands for Working with Controllers

```bash
# List Deployments
kubectl get deployments

# Describe Deployment
kubectl describe deployment nginx-deploy

# Scale Deployment
kubectl scale deployment nginx-deploy --replicas=5

# Check ReplicaSets
kubectl get rs

# Delete a controller (and its Pods)
kubectl delete deployment nginx-deploy
```

---

## 🩺 9. Self-Healing Example

If you delete one Pod manually:

```bash
kubectl delete pod <pod-name>
```

The **ReplicaSet controller** will immediately detect the difference:

* Desired = 3
* Actual = 2
  → Creates a new Pod automatically.


