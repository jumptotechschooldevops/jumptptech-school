# Lecture 1 · Architecture & Core Objects

## How Kubernetes works

Kubernetes is a **declarative system**. You describe the desired state — "I want 3 replicas of this app running" — and Kubernetes continuously works to make reality match your description.

This is fundamentally different from imperative systems where you say "start this container on that machine". In Kubernetes, you say what you want and the system figures out how to get there.

The engine behind this is the **reconciliation loop** (also called the control loop):

```
Desired state (what you declared)
        ↓
   Controller observes
        ↓
   Actual state (what is running)
        ↓
If actual ≠ desired → take action to close the gap
        ↓
   Repeat forever
```

This is why Kubernetes is self-healing. If a node crashes and takes three pods with it, the controller notices the actual count dropped below the desired count, and schedules replacement pods on healthy nodes. You did not have to do anything.

---

## The cluster architecture

```
┌─────────────────────────── Control Plane ────────────────────────────┐
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  ┌───────────┐ │
│  │  kube-api-   │  │  etcd        │  │  kube-     │  │  kube-    │ │
│  │  server      │  │  (state DB)  │  │  scheduler │  │  controller│ │
│  └──────────────┘  └──────────────┘  └────────────┘  │  manager  │ │
│                                                        └───────────┘ │
└───────────────────────────────────────────────────────────────────────┘
              ↑ API calls (kubectl, apps, controllers)
┌─────────────────────────── Worker Nodes ─────────────────────────────┐
│                                                                       │
│  Node 1:                  Node 2:                  Node 3:           │
│  ┌────────┐               ┌────────┐               ┌────────┐        │
│  │kubelet │               │kubelet │               │kubelet │        │
│  │kube-   │               │kube-   │               │kube-   │        │
│  │proxy   │               │proxy   │               │proxy   │        │
│  │ Pod A  │               │ Pod B  │               │ Pod C  │        │
│  │ Pod D  │               │ Pod E  │               │        │        │
│  └────────┘               └────────┘               └────────┘        │
└───────────────────────────────────────────────────────────────────────┘
```

### Control plane components

| Component | Role |
|-----------|------|
| **kube-apiserver** | The only component you (and other components) talk to. All state changes go through the API. |
| **etcd** | Distributed key-value store. The single source of truth for all cluster state. |
| **kube-scheduler** | Watches for new pods with no node assigned. Selects a suitable node based on resources and constraints. |
| **kube-controller-manager** | Runs all built-in controllers (deployment controller, replicaset controller, node controller, etc). |

### Worker node components

| Component | Role |
|-----------|------|
| **kubelet** | Agent on each node. Ensures containers described in PodSpecs are running. |
| **kube-proxy** | Manages network rules (iptables/ipvs) for Services. |
| **Container runtime** | Actually runs containers (containerd, CRI-O). |

---

## Pods

A Pod is the smallest deployable unit in Kubernetes. A Pod wraps one or more containers that share:

- Network (same IP address and port space)
- Storage (can share mounted volumes)
- Lifecycle (start and stop together)

Most pods have one container. Multi-container pods are used for the **sidecar** pattern: a main container plus a helper (log shipper, proxy, auth agent).

### Pod definition

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
    - name: app
      image: nginx:1.25
      ports:
        - containerPort: 80
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "500m"
      livenessProbe:
        httpGet:
          path: /health
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 30
      readinessProbe:
        httpGet:
          path: /ready
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 10
```

**You almost never create pods directly.** Pods are created by higher-level objects. If you create a pod manually and it crashes, nothing recreates it — it is simply gone.

---

## Labels and selectors

Labels are key-value pairs attached to objects. Selectors filter objects by labels. This is how Kubernetes resources refer to each other.

```yaml
# Labels on a pod
metadata:
  labels:
    app: myapp
    version: v2
    environment: production

# Selector that matches the pod
selector:
  matchLabels:
    app: myapp
```

Labels are not just metadata — Services and Deployments use selectors to find their pods. Change a pod's labels and it disappears from the Service's view.

---

## ReplicaSets

A ReplicaSet ensures a specified number of identical pods are running at all times. This is the reconciliation loop in action.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-rs
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
        - name: app
          image: nginx:1.25
```

If a pod dies, the ReplicaSet creates a replacement. If you delete a pod from a ReplicaSet, another appears. You cannot delete a ReplicaSet's pods without removing the ReplicaSet itself.

**You also almost never create ReplicaSets directly.** You create Deployments.

---

## Deployments

A Deployment manages a ReplicaSet. It adds:

- **Rolling updates** — update pods gradually, not all at once
- **Rollback** — revert to a previous version if the update fails
- **Update strategies** — fine control over how updates proceed

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1           # create at most 1 extra pod during update
      maxUnavailable: 0     # never reduce below desired count
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: app
          image: myapp:v1
          ports:
            - containerPort: 8000
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
```

---

## Namespaces

Namespaces provide logical isolation within a cluster. Resources in different namespaces can have the same name.

```bash
# Common namespaces
kubectl get namespaces
# default          — where your resources go if you don't specify
# kube-system      — Kubernetes system components
# kube-public      — public cluster info
# kube-node-lease  — node heartbeat objects

# Create a namespace
kubectl create namespace staging

# Run everything in a namespace
kubectl apply -f deployment.yml -n staging
kubectl get pods -n staging

# Switch default namespace (avoids -n flag on every command)
kubectl config set-context --current --namespace=staging
```

---

## Essential kubectl commands

```bash
# Get resources
kubectl get pods
kubectl get pods -o wide          # show node and IP
kubectl get pods -w               # watch for changes
kubectl get all                   # pods, services, deployments, replicasets
kubectl get deployments

# Describe (detailed view)
kubectl describe pod my-pod
kubectl describe deployment myapp

# Logs
kubectl logs my-pod
kubectl logs my-pod -f            # follow
kubectl logs my-pod --previous    # logs from previous (crashed) container
kubectl logs deployment/myapp -c app  # specific container in multi-container pod

# Execute
kubectl exec -it my-pod -- bash
kubectl exec -it my-pod -- sh    # if bash is not installed

# Apply configuration (create or update)
kubectl apply -f deployment.yml
kubectl apply -f ./k8s/           # apply entire directory

# Delete
kubectl delete -f deployment.yml
kubectl delete pod my-pod
kubectl delete deployment myapp

# Scale
kubectl scale deployment myapp --replicas=5

# Rollout
kubectl rollout status deployment/myapp
kubectl rollout history deployment/myapp
kubectl rollout undo deployment/myapp        # rollback
kubectl rollout undo deployment/myapp --to-revision=2
```

---

## Summary

- Kubernetes is declarative — you describe desired state, controllers make it happen.
- The control plane stores state in etcd. The kube-apiserver is the central API.
- kubelet on each node ensures pods are running as declared.
- Pods share networking and storage. Almost always managed by higher-level objects.
- Labels and selectors are how resources reference each other.
- Deployments manage ReplicaSets and add rolling updates and rollback.
- Namespaces provide logical isolation within a cluster.
