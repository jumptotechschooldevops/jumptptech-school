---
title: "project: StatefulSet with replica's"
description: "statefulset-read-write-lab/ │ ├── 01-mysql-headless.yaml ├── 02-mysql-init-configmap.yaml ├──..."
published: 2026-01-21
source: "https://dev.to/jumptotech/project-statefulset-with-replicas-4hhd"
tags: []
---

# project: StatefulSet with replica's

statefulset-read-write-lab/
│
├── 01-mysql-headless.yaml
├── 02-mysql-init-configmap.yaml
├── 03-mysql-statefulset.yaml
├── 04-label-primary.sh
├── 05-mysql-write-service.yaml
├── 06-mysql-read-service.yaml
├── 07-mysql-client.yaml
│
└── apply-all.sh




![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AcP1jagadz0rTOlwg.png)

![Image](https://i0.wp.com/theithollow.com/wp-content/uploads/2019/03/k8s-statefulsets1.png?resize=907%2C832\&ssl=1)

![Image](https://platform9.com/media/kubernetes-constructs-concepts-architecture.jpg)

```
                ┌─────────────┐
                │  App / User │
                └──────┬──────┘
                       │
        ┌──────────────┴──────────────┐
        │                              │
 WRITE Service                    READ Service
(mysql-write)                  (mysql-read)
        │                              │
   mysql-0 (Primary)       mysql-1, mysql-2
        │                              │
        └───────── Persistent Volumes ─┘
```

---



---

# 1️⃣ WHY StatefulSet + Headless (Concept)

### Why StatefulSet?

Databases need:

* Stable hostname
* Stable storage
* Ordered pods

StatefulSet gives:

```
mysql-0 (Primary)
mysql-1 (Replica)
mysql-2 (Replica)
```

---

### Why Headless Service?

StatefulSet **cannot work correctly without it**.

Headless gives DNS like:

```
mysql-0.mysql-headless
mysql-1.mysql-headless
mysql-2.mysql-headless
```

This is **mandatory**.

---

# 2️⃣ Headless Service (Step 1)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
```

### What this means

* `clusterIP: None` → no load balancing
* DNS is created **per pod**
* Required for StatefulSet identity

Apply:

```bash
kubectl apply -f mysql-headless.yaml
```

---

# 3️⃣ StatefulSet – 3 Pods (Step 2)

### ConfigMap (Init DB)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-init
data:
  init.sql: |
    CREATE DATABASE appdb;
```

---

### StatefulSet YAML

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-headless
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
        role: replica
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: root
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
        - name: init
          mountPath: /docker-entrypoint-initdb.d
      volumes:
      - name: init
        configMap:
          name: mysql-init
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

Apply:

```bash
kubectl apply -f mysql-statefulset.yaml
```

Check:

```bash
kubectl get pods
```

You will see:

```
mysql-0
mysql-1
mysql-2
```

---

# 4️⃣ Define PRIMARY vs REPLICAS (Step 3)

### Make mysql-0 PRIMARY

```bash
kubectl label pod mysql-0 role=primary --overwrite
```

### Replicas already labeled:

```
role=replica
```

Verify:

```bash
kubectl get pods --show-labels
```

---

# 5️⃣ WRITE Service (Primary Only)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-write
spec:
  selector:
    app: mysql
    role: primary
  ports:
  - port: 3306
```

### Meaning

* Only **mysql-0** matches
* All WRITE traffic goes to Primary
* Safe & correct DB pattern

---

# 6️⃣ READ Service (Replicas Only)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
spec:
  selector:
    app: mysql
    role: replica
  ports:
  - port: 3306
```

### Meaning

* Load balances across mysql-1 & mysql-2
* Scales reads
* Protects primary from overload

---

# 7️⃣ Test Pod (Client)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-client
spec:
  containers:
  - name: client
    image: mysql:8.0
    command: ["sleep", "3600"]
```

---

# 8️⃣ CONNECT & SWITCH (IMPORTANT PART)

### WRITE (Primary)

```bash
kubectl exec -it mysql-client -- \
mysql -h mysql-write -uroot -proot
```

```sql
CREATE TABLE appdb.test (id INT);
```

✔ Goes ONLY to mysql-0

---

### READ (Replicas)

```bash
kubectl exec -it mysql-client -- \
mysql -h mysql-read -uroot -proot
```

```sql
SELECT * FROM appdb.test;
```

✔ Load-balanced across mysql-1 & mysql-2

---

# 9️⃣ How Switching Works (Explain Clearly)

| Action          | Service Used | Pod               |
| --------------- | ------------ | ----------------- |
| Insert / Update | mysql-write  | mysql-0           |
| Select          | mysql-read   | mysql-1 / mysql-2 |

---

# 🔥 Interview Explanation (Must Say This)

> **We use StatefulSet for stable DB identity**
> **Headless Service for pod-level DNS**
> **Write Service points only to Primary**
> **Read Service load balances replicas**
> **PVC ensures no data loss**


