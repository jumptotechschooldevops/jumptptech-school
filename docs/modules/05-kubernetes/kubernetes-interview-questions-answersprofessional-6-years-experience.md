---
title: "Kubernetes Interview Questions & Answers (Professional – 6 Years Experience)"
description: "1. Kubernetes Architecture            Q1. What happens when you run kubectl apply -f..."
published: 2025-12-29
source: "https://dev.to/jumptotech/kubernetes-interview-questions-answersprofessional-6-years-experience-14h5"
tags: []
---

# Kubernetes Interview Questions & Answers (Professional – 6 Years Experience)




## 1. Kubernetes Architecture

### Q1. What happens when you run `kubectl apply -f deployment.yaml`?

**Answer:**
When I run `kubectl apply`, the request goes to the **kube-apiserver**.
The API server validates the YAML, checks authentication and authorization, and stores the desired state in **etcd**.
Then controllers notice the new desired state and create a **ReplicaSet**.
The **scheduler** decides on which node the pods should run.
Finally, the **kubelet** on that node pulls the image and starts the container.

---

### Q2. What is etcd and why is it critical?

**Answer:**
etcd is a **distributed key-value store** that holds the entire cluster state.
If etcd is down or corrupted, Kubernetes cannot function correctly.
That’s why backups, encryption, and HA etcd setups are very important in production.

---

## 2. Workloads & Controllers

### Q3. Difference between Deployment, StatefulSet, and DaemonSet?

**Answer:**

* **Deployment** → Stateless apps like web services
* **StatefulSet** → Stateful apps like databases or Kafka (stable network ID, persistent storage)
* **DaemonSet** → One pod per node, used for logging, monitoring, or security agents

---

### Q4. When would you use a Job or CronJob?

**Answer:**

* **Job** is used for one-time tasks like database migration.
* **CronJob** is used for scheduled tasks like backups or cleanup jobs.

---

## 3. Networking (Very Important)

### Q5. How does traffic reach a pod from the internet?

**Answer:**
Traffic usually flows like this:
**Internet → Load Balancer → Ingress → Service → Pod**

The Ingress handles routing rules, the Service load-balances traffic, and the Pod serves the request.

---

### Q6. Difference between Service types?

**Answer:**

* **ClusterIP** → Internal only
* **NodePort** → Exposes service on node IP and port
* **LoadBalancer** → Cloud load balancer (used in production)

---

### Q7. What is a NetworkPolicy?

**Answer:**
NetworkPolicy controls **which pods can talk to which pods**.
By default, everything is open.
In production, we usually restrict traffic for security (zero-trust).

---

## 4. Configuration & Secrets

### Q8. How do you manage secrets in production?

**Answer:**
I avoid storing secrets directly in Kubernetes when possible.
Usually we integrate with:

* AWS Secrets Manager
* AWS SSM
* HashiCorp Vault

Secrets are injected at runtime using external-secrets or CSI drivers.

---

### Q9. Are Kubernetes secrets encrypted?

**Answer:**
By default, secrets are only **base64 encoded**, not encrypted.
In production, we enable **encryption at rest** and restrict access using RBAC.

---

## 5. Storage & Stateful Apps

### Q10. Explain PV, PVC, and StorageClass.

**Answer:**

* **PV** → Actual storage resource
* **PVC** → Request for storage
* **StorageClass** → Defines how storage is dynamically created

Developers use PVCs; infrastructure handles PVs.

---

### Q11. Would you run databases in Kubernetes?

**Answer:**
Yes, but carefully.
For production databases, I ensure:

* StatefulSets
* Persistent storage
* Backup strategy
* Anti-affinity rules

Sometimes managed databases are a better choice.

---

## 6. Resource Management & Scaling

### Q12. Difference between requests and limits?

**Answer:**

* **Requests** → Guaranteed resources
* **Limits** → Maximum allowed resources

If a pod exceeds memory limit, it gets **OOMKilled**.

---

### Q13. How does HPA work?

**Answer:**
HPA scales pods based on metrics like CPU, memory, or custom metrics from Prometheus.

---

### Q14. Why is my pod restarting even though the node has memory?

**Answer:**
Because the pod exceeded its **memory limit**, not the node’s memory.
Kubernetes enforces limits per container.

---

## 7. Security (Senior-Level)

### Q15. How do you secure a Kubernetes cluster?

**Answer:**

* RBAC with least privilege
* Run containers as non-root
* Pod Security Standards
* NetworkPolicies
* Image scanning
* Admission controllers like OPA/Gatekeeper

---

### Q16. What is RBAC?

**Answer:**
RBAC controls **who can do what** in Kubernetes using Roles and RoleBindings.

---

### Q17. How do you prevent privileged containers?

**Answer:**
Using Pod Security policies or OPA Gatekeeper rules that block privileged settings.

---

## 8. Helm

### Q18. Why do we use Helm?

**Answer:**
Helm helps manage Kubernetes applications as **packages**.
It allows versioning, templating, and environment-specific configurations.

---

### Q19. How do you manage multiple environments with Helm?

**Answer:**
Using:

* `values-dev.yaml`
* `values-stage.yaml`
* `values-prod.yaml`

And override values per environment.

---

## 9. GitOps & Argo CD

### Q20. What is GitOps?

**Answer:**
GitOps means **Git is the single source of truth**.
The cluster state is always synced with Git.

---

### Q21. What does Argo CD do?

**Answer:**
Argo CD continuously compares the desired state in Git with the live cluster and:

* Syncs changes
* Detects drift
* Rolls back if needed

---

### Q22. What is App-of-Apps pattern?

**Answer:**
A parent Argo CD application manages multiple child applications.
This helps manage large environments cleanly.

---

## 10. Troubleshooting & Operations

### Q23. Pod is in CrashLoopBackOff. What do you do?

**Answer:**

1. Check logs
2. Describe the pod
3. Check events
4. Verify config/secrets
5. Test container locally if needed

---

### Q24. Production is down. First steps?

**Answer:**

* Check alerts
* Check pod status
* Check recent deployments
* Roll back if needed
* Communicate status to team

---

## 11. Cloud Kubernetes (EKS example)

### Q25. What is IRSA in EKS?

**Answer:**
IRSA allows pods to assume IAM roles securely without storing AWS credentials inside containers.

---

### Q26. Difference between node groups and Fargate?

**Answer:**

* **Node groups** → You manage EC2
* **Fargate** → Serverless pods, less control, higher cost

---

## 12. Design & Architecture

### Q27. How would you design Kubernetes for multiple teams?

**Answer:**

* Separate namespaces
* RBAC per team
* Resource quotas
* Network policies
* GitOps per environment

---

### Q28. Single cluster or multiple clusters?

**Answer:**

* Small teams → Single cluster
* Large org / compliance → Multiple clusters

Depends on risk, cost, and isolation needs.

---

## Final Interview Tip (Very Important)

Interviewers listen for:

* **Clear thinking**
* **Production experience**
* **Trade-offs**
* **Security mindset**




