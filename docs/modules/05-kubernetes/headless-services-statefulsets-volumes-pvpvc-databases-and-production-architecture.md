---
title: "Headless Services, StatefulSets, Volumes, PV/PVC, Databases, and Production Architecture"
description: "(What Kubernetes really does, what it does NOT do, and what DevOps engineers must own)             ..."
published: 2026-01-15
source: "https://dev.to/jumptotech/headless-services-statefulsets-volumes-pvpvc-databases-and-production-architecture-12k6"
tags: []
---

# Headless Services, StatefulSets, Volumes, PV/PVC, Databases, and Production Architecture



*(What Kubernetes really does, what it does NOT do, and what DevOps engineers must own)*

---

## PART 1 — THE MOST IMPORTANT QUESTION

### “What should live inside a pod, and what should NOT?”

This single question separates **junior** from **senior** DevOps engineers.

### A pod is:

* a **runtime environment**
* **temporary**
* **replaceable**
* **stateless by default**

Kubernetes was built assuming:

> Pods WILL die.
> Pods WILL move.
> Pods WILL be recreated.

So Kubernetes **intentionally discourages** putting anything **precious** inside a pod.

---

## PART 2 — WHY “JUST PUT THE DATABASE IN A POD” IS DANGEROUS

### The container filesystem is EPHEMERAL

When a pod:

* restarts
* is rescheduled
* is recreated during rollout

👉 **its filesystem can be wiped**

If your database stores data **inside the container filesystem**, then:

```
kubectl delete pod mysql
= DATA LOSS
```

That is unacceptable in production.

This is why Kubernetes **separates compute from storage**.

---

## PART 3 — STATELESS vs STATEFUL (FOUNDATIONAL CONCEPT)

### Stateless workloads

Examples:

* Frontend
* API
* Nginx
* Auth services

Properties:

* Any instance can serve any request
* No user data stored locally
* Horizontal scaling is safe

✅ Use:

* Deployment
* ClusterIP / Ingress
* No persistent storage

---

### Stateful workloads

Examples:

* MySQL
* PostgreSQL
* MongoDB
* Kafka
* Elasticsearch
* ZooKeeper

Properties:

* Data must survive restarts
* Writes must be consistent
* Identity matters
* Replication needs stable peers

❌ Deployment alone is NOT enough
❌ ClusterIP alone is NOT enough

---

## PART 4 — SERVICES: WHAT THEY REALLY DO

### ClusterIP Service (default)

* Creates **one virtual IP**
* kube-proxy load balances traffic
* Pod identity is **hidden**

```
App → ClusterIP → random pod
```

This is **perfect** for stateless apps.

But for databases:

* Write goes to pod A
* Read goes to pod B
* Data inconsistency
* Login failures
* Corruption risk

---

## PART 5 — HEADLESS SERVICE (WHAT IT ACTUALLY MEANS)

A **Headless Service** is just a Service with:

```yaml
clusterIP: None
```

That one line tells Kubernetes:

> “Do NOT give me a virtual IP.
> Give clients the real pod endpoints.”

### What changes:

* No kube-proxy load balancing
* DNS returns **pod IPs directly**
* Identity is exposed

### DNS behavior:

```
nslookup mysql-headless
→ pod-ip-1
→ pod-ip-2
→ pod-ip-3
```

This is **DNS round-robin**, not service-level load balancing.

⚠️ Important:
Headless does **NOT** mean “no load balancing”
It means **Kubernetes stops hiding pods behind a virtual IP**

---

## PART 6 — WHY HEADLESS ALONE IS NOT ENOUGH

Pod IPs:

* change on restart
* change on reschedule
* are NOT stable identifiers

So how does a replica always find the primary?

This is why **StatefulSet exists**.

---

## PART 7 — STATEFULSET (THE DATABASE CONTROLLER)

StatefulSet is designed for workloads that need:

1. **Stable identity**
2. **Stable network names**
3. **Stable storage**

### What StatefulSet guarantees:

| Feature         | Deployment | StatefulSet |
| --------------- | ---------- | ----------- |
| Pod name        | random     | stable      |
| Pod order       | none       | ordered     |
| Identity        | ❌          | ✅           |
| Per-pod storage | ❌          | ✅           |

Pods are named:

```
mysql-0
mysql-1
mysql-2
```

These names:

* NEVER change
* Survive restarts
* Survive rescheduling

---

## PART 8 — STATEFULSET + HEADLESS (THE DATABASE PATTERN)

When you combine:

* StatefulSet
* Headless Service

Kubernetes automatically creates **stable DNS records**:

```
mysql-0.mysql-headless.default.svc.cluster.local
mysql-1.mysql-headless.default.svc.cluster.local
```

Now you can:

* Write → mysql-0
* Read → mysql-1 / mysql-2
* Replicate reliably

This is **the canonical Kubernetes database pattern**.

---

## PART 9 — STORAGE: WHY VOLUMES EXIST

Pods die.
Data must not.

Kubernetes solves this by **decoupling storage from pods**.

---

## PART 10 — TYPES OF VOLUMES (WHAT A DEVOPS MUST KNOW)

### 1️⃣ emptyDir

* Lives as long as pod lives
* Deleted when pod dies

✅ Use for:

* cache
* temp files

❌ NEVER for databases

---

### 2️⃣ hostPath

* Mounts node filesystem

❌ Dangerous in production
❌ Breaks portability
❌ Ties pod to a node

Used only for:

* demos
* debugging
* very specific system agents

---

### 3️⃣ Persistent Volumes (PV)

A **PV** represents **real storage**:

* EBS (AWS)
* PD (GCP)
* Azure Disk
* NFS
* Ceph

Cluster-level resource.

---

### 4️⃣ Persistent Volume Claim (PVC)

A **PVC** is:

* a request for storage
* namespace-scoped
* bound to a PV

Pods use PVCs — not PVs directly.

### Mental model (MEMORIZE THIS):

```
Pod → PVC → PV → Physical Disk
```

---

## PART 11 — STORAGECLASS (PRODUCTION ESSENTIAL)

A **StorageClass** defines:

* disk type (SSD / HDD)
* IOPS
* replication
* reclaim policy

Dynamic provisioning means:

> “Create disk when PVC is created”

Production clusters ALWAYS define StorageClasses.

---

## PART 12 — STATEFULSET + PVC (PER-POD DISKS)

StatefulSet can create:

```
pvc-mysql-0
pvc-mysql-1
pvc-mysql-2
```

Each pod gets:

* its own disk
* its own data
* no overlap

This is REQUIRED for:

* databases
* Kafka brokers
* Elasticsearch nodes

---

## PART 13 — SHOULD DATABASES RUN IN KUBERNETES?

### The senior DevOps answer:

👉 **It depends on maturity and risk**

### When YES:

* Strong SRE team
* Backup automation
* Monitoring in place
* Storage tuned
* Operators (MySQL Operator, etc.)

### When NO:

* Small team
* No DB expertise
* High SLA requirements

Many companies:

* Use RDS in production
* Use StatefulSet DBs in dev/test

This is a **business decision**, not a technical limitation.

---

## PART 14 — PRODUCTION CLUSTER ARCHITECTURE (BIG PICTURE)

```
User
 ↓
Load Balancer / Ingress
 ↓
Stateless App Pods (Deployment)
 ↓
Stateful DB (StatefulSet + Headless)
 ↓
Persistent Storage (PVC → PV)
```

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AeUpYUJz3bTBAcyMCI6ThOw.png)

![Image](https://cdn.prod.website-files.com/68ad5281556da93bd7179b0e/68b79e89467a1671c297eebe_65de71956dc5c95b82c68bb0_stateful-set-bp-5.png)

---

## PART 15 — WHAT GOES INSIDE A POD (AND WHAT DOES NOT)

### Put INSIDE the pod:

* Application code
* Runtime dependencies
* ConfigMaps
* Secrets (mounted as files)

### NEVER put inside the pod:

* User data
* Database files
* Anything you can’t lose

---

## PART 16 — HOW DEVOPS ENGINEERS TROUBLESHOOT (REAL LIFE)

### App cannot connect to DB

Checklist:

1. Is DB pod running?
2. Does Service have endpoints?
3. DNS resolution inside cluster?
4. Port reachable?

### PVC Pending

Checklist:

* StorageClass exists?
* Default StorageClass?
* Cloud permissions?

### Data lost after restart

Red flags:

* emptyDir
* no PVC
* wrong mount path

---

## PART 17 — WHAT A 6+ YEAR DEVOPS ENGINEER MUST KNOW

### Architecture

* Stateless vs Stateful
* Deployment vs StatefulSet
* Headless vs ClusterIP

### Storage

* PV / PVC / StorageClass
* Reclaim policies
* Per-pod volumes

### Networking

* DNS behavior
* Service selectors
* Pod FQDNs

### Operations

* Backups
* Restores
* Safe upgrades
* Scaling rules

---

## PART 18 — INTERVIEW-READY SUMMARY (MEMORIZE)

> “Databases in Kubernetes require StatefulSets for stable identity, headless services for pod-level DNS, and PVCs for persistent storage. Pods are ephemeral and must never own critical data. Kubernetes manages lifecycle, not database correctness.”

---

## FINAL ANSWER TO YOUR CORE QUESTION

### “If we don’t put everything in the pod, how do users get data?”

Users NEVER talk to pods directly.

Users talk to:

* Ingress
* Services

Pods talk to:

* Stable DB endpoints
* Persistent storage

Pods are **delivery mechanisms**, not **data owners**.


