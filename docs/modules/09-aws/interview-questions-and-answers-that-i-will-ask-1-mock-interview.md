---
title: "interview questions and answers that I will ask #1 Mock interview"
description: "1. What is Kubernetes and why do we need it?   Answer: Kubernetes is a container..."
published: 2026-01-11
source: "https://dev.to/jumptotech/interview-questions-and-answers-that-i-will-ask-1-mock-interview-31a4"
tags: []
---

# interview questions and answers that I will ask #1 Mock interview


## 1. What is Kubernetes and why do we need it?

**Answer:**
Kubernetes is a container orchestration platform that automates **deployment, scaling, self-healing, networking, and configuration** of containers. It solves problems like manual container restarts, scaling, service discovery, and zero-downtime deployments.

---

## 2. What is a Pod?

**Answer:**
A Pod is the **smallest deployable unit** in Kubernetes. It can contain **one or more containers** that share:

* the same IP
* the same network namespace
* volumes

---

## 3. What is the difference between Pod and Deployment?

**Answer:**
A Pod is a single instance.
A Deployment manages Pods and provides:

* replica management
* rolling updates
* self-healing
* rollback

In production, **never deploy bare Pods**.

---

## 4. What is a Service in Kubernetes?

**Answer:**
A Service provides a **stable IP and DNS name** to access Pods. Since Pods are ephemeral, Services abstract Pod IP changes and enable load balancing.

---

## 5. Difference between ClusterIP, NodePort, and LoadBalancer?

**Answer:**

* **ClusterIP** – internal access only (default)
* **NodePort** – exposes service on node IP + port
* **LoadBalancer** – cloud provider creates external LB

---

## 6. What is Ingress?

**Answer:**
Ingress manages **external HTTP/HTTPS access** to services using:

* host-based routing
* path-based routing
* TLS

It requires an **Ingress Controller** (NGINX, ALB, Traefik).

---

## 7. What is the difference between Ingress and LoadBalancer?

**Answer:**

* LoadBalancer exposes **one service**
* Ingress exposes **multiple services** through one endpoint using routing rules
  Ingress is more **cost-effective and scalable**.

---

## 8. What are liveness and readiness probes?

**Answer:**

* **Liveness probe** → Is the container alive? (restart if fails)
* **Readiness probe** → Is the container ready for traffic? (remove from Service)

Wrong probes can cause **CrashLoopBackOff** or **downtime**.

---

## 9. What is a ConfigMap?

**Answer:**
ConfigMap stores **non-sensitive configuration** like environment variables, config files, or app settings, decoupled from the container image.

---

## 10. What is a Secret and how is it different from ConfigMap?

**Answer:**
Secrets store **sensitive data** (passwords, tokens, keys).
They are base64-encoded and can be:

* mounted as files
* injected as environment variables

Never hardcode secrets in images or YAML.

---

## 11. What is a Namespace and why is it used?

**Answer:**
Namespaces provide **logical isolation** inside a cluster:

* separate teams
* separate environments (dev, stage, prod)
* resource limits & access control

---

## 12. What happens if a Pod crashes?

**Answer:**
Kubernetes automatically:

* restarts the Pod (kubelet)
* creates a new Pod (Deployment/ReplicaSet)
  This is **self-healing**.

---

## 13. What is a rolling update?

**Answer:**
A rolling update gradually replaces old Pods with new ones without downtime, controlled by:

* `maxUnavailable`
* `maxSurge`

Default strategy in Deployments.

---

## 14. How do you troubleshoot a Pod that is not running?

**Answer (steps):**

1. `kubectl get pods`
2. `kubectl describe pod <pod>`
3. `kubectl logs <pod>`
4. Check:

   * image name
   * probes
   * resource limits
   * events

---

## 15. What is etcd?

**Answer:**
etcd is the **key-value store** that holds **entire cluster state**:

* Pods
* Services
* Secrets
* ConfigMaps

If etcd is down → cluster is effectively down.







## 16. What happens internally when you run `kubectl apply -f deployment.yaml`?

**Answer:**

1. kubectl sends request to **API Server**
2. API Server validates YAML & auth
3. Object stored in **etcd**
4. **Controller Manager** detects desired state
5. **Scheduler** assigns Pod to a node
6. **kubelet** pulls image & starts container
7. Pod becomes Ready → Service sends traffic

---

## 17. Difference between Deployment, ReplicaSet, and StatefulSet?

**Answer:**

* **Deployment** – stateless apps, rolling updates
* **ReplicaSet** – low-level controller (used by Deployment)
* **StatefulSet** – stateful apps (DBs), stable pod names & volumes

---

## 18. Why should you not use `latest` tag in production?

**Answer:**

* Non-deterministic deployments
* Rollbacks impossible
* Image cache issues
* Breaks GitOps & reproducibility

Always use **immutable tags** or digests.

---

## 19. What causes `CrashLoopBackOff`?

**Answer:**
Common reasons:

* App exits immediately
* Wrong command/args
* Bad environment variables
* Failing liveness probe
* Missing config/secret

Debug with:

```
kubectl logs
kubectl describe pod
```

---

## 20. Difference between readiness and liveness probes in rollout?

**Answer:**

* **Readiness** prevents traffic to unready pods (NO restart)
* **Liveness** restarts container if unhealthy

Bad liveness = infinite restarts
Missing readiness = traffic hits broken pods

---

## 21. How does Kubernetes perform service discovery?

**Answer:**

* Internal DNS (CoreDNS)
* Service name resolves to ClusterIP
* kube-proxy routes traffic to Pods

Example:

```
backend.default.svc.cluster.local
```

---

## 22. What is kube-proxy and what does it do?

**Answer:**
kube-proxy manages **network rules** (iptables/ipvs) to route:

```
Service IP → Pod IPs
```

Without kube-proxy, Services do not work.

---

## 23. What is HPA and how does it work?

**Answer:**
Horizontal Pod Autoscaler:

* Scales Pods based on CPU / memory / custom metrics
* Uses Metrics Server
* Works with Deployments & StatefulSets

HPA ≠ cluster autoscaling.

---

## 24. Difference between HPA and Cluster Autoscaler?

**Answer:**

* **HPA** → scales Pods
* **Cluster Autoscaler** → scales Nodes

Both usually work **together**.

---

## 25. What happens if a node goes down?

**Answer:**

1. Node marked `NotReady`
2. Pods evicted
3. New Pods scheduled on healthy nodes
4. Services update endpoints

This is Kubernetes **self-healing**.

---

## 26. What is taint and toleration?

**Answer:**
Taints repel Pods from nodes.
Tolerations allow Pods to schedule on tainted nodes.

Used for:

* dedicated nodes
* system workloads
* isolation

---

## 27. What is a NetworkPolicy?

**Answer:**
NetworkPolicy controls **Pod-to-Pod traffic**.
Default behavior = **allow all**.

Without NetworkPolicy:

* Any Pod can talk to any Pod (security risk)

---

## 28. How do you securely manage secrets in production?

**Answer:**
Best practices:

* Use Kubernetes Secrets (minimum)
* Encrypt etcd at rest
* Restrict RBAC access
* Prefer external secret managers (AWS Secrets Manager, Vault)

Never store secrets in Git.

---

## 29. What is the difference between rolling update and recreate strategy?

**Answer:**

* **RollingUpdate** – zero downtime (default)
* **Recreate** – all Pods stopped, then started (downtime)

Recreate used only for special cases.

---

## 30. How do you debug traffic not reaching a Pod?

**Answer (production steps):**

1. Check Pod Ready state
2. Check Service selectors
3. Check Endpoints
4. Check Ingress rules
5. Check NetworkPolicy
6. Check container port vs service port

Most failures are **selector or readiness issues**.

---

### Final Interview Tip (very important)

If asked **“How does Kubernetes keep apps highly available?”**, say:

> “Using replicas, readiness probes, Services, rolling updates, and self-healing via controllers.”

That sentence hits **multiple concepts at once**.


