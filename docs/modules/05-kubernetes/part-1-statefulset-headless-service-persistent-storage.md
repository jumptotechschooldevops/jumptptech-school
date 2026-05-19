---
title: "PART 1 — StatefulSet + Headless Service + Persistent Storage"
description: "Goal: Deploy a stateful MySQL cluster correctly in Kubernetes and understand every moving..."
published: 2026-01-12
source: "https://dev.to/jumptotech/part-1-statefulset-headless-service-persistent-storage-2hfh"
tags: []
---

# PART 1 — StatefulSet + Headless Service + Persistent Storage




> Goal: Deploy a **stateful MySQL cluster** correctly in Kubernetes and **understand every moving part**.

---

## LAB PREREQUISITES (DO NOT SKIP)

You need **one working Kubernetes cluster**:

* Minikube 


Verify:

```bash
kubectl get nodes
```

You must see **Ready**.

---

## STEP 0 — WHAT WE ARE BUILDING (VISUAL FIRST)

![Image](https://cdn.prod.website-files.com/68ad5281556da93bd7179b0e/68b79e89467a1671c297eebe_65de71956dc5c95b82c68bb0_stateful-set-bp-5.png)

![Image](https://i0.wp.com/theithollow.com/wp-content/uploads/2019/03/k8s-statefulsets1.png?resize=907%2C832\&ssl=1)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2APfDk2uYy2f_IkmvJQTtttA.png)

**Final architecture**

* 1 Headless Service (identity)
* 1 StatefulSet (mysql pods)
* 3 Pods: `mysql-0`, `mysql-1`, `mysql-2`
* 1 PVC per pod
* Stable DNS names
* Data survives restarts

---

## STEP 1 — CREATE A NAMESPACE (CLEAN ISOLATION)

```bash
kubectl create namespace mysql-lab
kubectl config set-context --current --namespace=mysql-lab
```

Verify:

```bash
kubectl get ns
```

---

## STEP 2 — HEADLESS SERVICE (MOST IMPORTANT FILE)

### File: `mysql-headless.yaml`

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
      name: mysql
```

Apply:

```bash
kubectl apply -f mysql-headless.yaml
```

Verify:

```bash
kubectl get svc
```

You must see:

```
mysql-headless   ClusterIP   None
```

---

### 🔍 WHAT THIS DOES (VISUAL)

![Image](https://www.plural.sh/blog/content/images/2025/04/image-79.png)

![Image](https://miro.medium.com/1%2AgH3xRHqAzoQRY_AAMtS1wg.png)

* ❌ No virtual IP
* ✅ DNS returns **individual pod IPs**
* ❌ No kube-proxy load balancing
* ✅ Enables pod-level DNS

⚠️ Alone this is **NOT ENOUGH** — identity still missing

---

## STEP 3 — STATEFULSET (THE CORE)

### File: `mysql-statefulset.yaml`

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
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: rootpass
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
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

---

## STEP 4 — WATCH POD CREATION (ORDER MATTERS)

```bash
kubectl get pods -w
```

You will see:

```
mysql-0  → Running
mysql-1  → Running
mysql-2  → Running
```

### 🔍 IMPORTANT

* Pods start **one by one**
* NOT parallel
* This is **guaranteed by StatefulSet**

---

## STEP 5 — VERIFY STABLE POD NAMES

```bash
kubectl get pods
```

Expected:

```
mysql-0
mysql-1
mysql-2
```

Restart one pod:

```bash
kubectl delete pod mysql-1
```

Watch:

```bash
kubectl get pods -w
```

Result:

* `mysql-1` comes back
* **Same name**
* **Same identity**

---

### VISUAL: DEPLOYMENT VS STATEFULSET

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2Ay02_WQcb6DUugimnodPSxw.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AHlgT4PgRsjrHj30vihI5Fw.png)

This is **why Deployments are unsafe for databases**.

---

## STEP 6 — VERIFY PERSISTENT STORAGE

```bash
kubectl get pvc
```

Expected:

```
data-mysql-0
data-mysql-1
data-mysql-2
```

Each pod has:

* Its own disk
* Independent lifecycle
* Data survives pod deletion

---

### VISUAL: VOLUMECLAIMTEMPLATES

![Image](https://www.bluematador.com/hs-fs/hubfs/blog/new/An%20Introduction%20to%20Kubernetes%20StatefulSet/StatefulSets.png?name=StatefulSets.png\&width=770)

![Image](https://refine.ams3.cdn.digitaloceanspaces.com/blog/2023-12-14-k8s-persistent-volumes/image3.PNG)

---

## STEP 7 — VERIFY DNS (CRITICAL STEP)

Run a temporary client pod:

```bash
kubectl run dns-test --image=busybox:1.36 -it --rm --restart=Never -- sh
```

Inside the pod:

```sh
nslookup mysql-0.mysql-headless
nslookup mysql-1.mysql-headless
nslookup mysql-2.mysql-headless
```

Each resolves to a **different IP**.

Exit:

```sh
exit
```

---

### VISUAL: POD DNS NAMES

![Image](https://i0.wp.com/theithollow.com/wp-content/uploads/2019/03/k8s-statefulsets1.png?resize=907%2C832\&ssl=1)

![Image](https://miro.medium.com/1%2AL7ubANy6JIPcKCBo7E4JcA.png)

Format:

```
<pod-name>.<headless-service>.<namespace>.svc.cluster.local
```

---

## STEP 8 — CONNECT TO MYSQL (REAL TEST)

```bash
kubectl exec -it mysql-0 -- mysql -uroot -prootpass
```

Inside MySQL:

```sql
CREATE DATABASE labdb;
USE labdb;
CREATE TABLE test (id INT);
INSERT INTO test VALUES (1);
SELECT * FROM test;
```

Exit:

```sql
exit
```

---

## STEP 9 — DELETE POD, DATA MUST SURVIVE

```bash
kubectl delete pod mysql-0
```

Wait until it comes back:

```bash
kubectl get pods -w
```

Reconnect:

```bash
kubectl exec -it mysql-0 -- mysql -uroot -prootpass
```

Check:

```sql
USE labdb;
SELECT * FROM test;
```

✅ Data is still there.

---

### VISUAL: DATA SURVIVES POD DELETION

![Image](https://cdn.prod.website-files.com/626a25d633b1b99aa0e1afa7/671fa86f86c5fc2e66cadf4c_671fa580fd31ec659ca5c3e6_image2.jpeg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AXNi3BmD6wfm3fvob7863Yw.png)

---

## STEP 10 — WHAT THIS LAB PROVES (LOCK THIS IN)

### Kubernetes guarantees:

* Stable pod identity
* Ordered startup & shutdown
* Persistent storage
* Predictable DNS

### Kubernetes does NOT:

* Replicate MySQL data
* Promote replicas
* Manage DB internals

---

## SENIOR DEVOPS MENTAL MODEL (INTERVIEW READY)

> “StatefulSets are required for databases because they provide stable pod identities and ordered lifecycle management. Headless services expose pod-level DNS so clients can target specific replicas. VolumeClaimTemplates ensure each pod has persistent storage that survives restarts.”


