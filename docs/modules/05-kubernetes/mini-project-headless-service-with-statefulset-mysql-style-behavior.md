---
title: "MINI PROJECT: Headless Service with StatefulSet (MySQL-style behavior)"
description: "🧪            🎯 Goal   By the end, you will clearly see:   Why ClusterIP hides pod..."
published: 2026-01-15
source: "https://dev.to/jumptotech/mini-project-headless-service-with-statefulset-mysql-style-behavior-a2h"
tags: []
---

# MINI PROJECT: Headless Service with StatefulSet (MySQL-style behavior)



# 🧪 

## 🎯 Goal 

By the end, you will **clearly see**:

* Why **ClusterIP hides pod identity**
* Why **Headless Service exposes pod identity**
* How **StatefulSet + Headless Service** gives **stable DNS per pod**
* Why databases need this

---

## 🧠 Mental model (keep this in mind)

| Setup                  | DNS result                                   |
| ---------------------- | -------------------------------------------- |
| Deployment + ClusterIP | One virtual IP                               |
| Deployment + Headless  | Multiple pod IPs                             |
| StatefulSet + Headless | **Stable pod DNS names** (this is the magic) |

---

## 🧩 Project structure

```text
headless-demo/
├── mysql-headless.yaml
├── mysql-statefulset.yaml
└── dns-test.yaml
```

---

## 1️⃣ Headless Service (NO Cluster IP)

📄 `mysql-headless.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None            # 👈 THIS MAKES IT HEADLESS
  selector:
    app: mysql
  ports:
    - port: 3306
```

📌 Important:

* No virtual IP
* DNS will return **pod IPs**

---

## 2️⃣ StatefulSet (stable pod identity)

📄 `mysql-statefulset.yaml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-headless   # 👈 REQUIRED
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
              value: root
          ports:
            - containerPort: 3306
```

📌 What StatefulSet guarantees:

* Pods named:

  ```
  mysql-0
  mysql-1
  mysql-2
  ```
* Names NEVER change
* Identity is stable

---

## 3️⃣ DNS test pod (to observe behavior)

📄 `dns-test.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
spec:
  containers:
    - name: dns
      image: busybox:1.28
      command: ["sleep", "3600"]
```

---

## 4️⃣ Apply everything (ORDER MATTERS)

```bash
kubectl apply -f mysql-headless.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f dns-test.yaml
```

Wait:

```bash
kubectl get pods
```

You should see:

```
mysql-0   Running
mysql-1   Running
mysql-2   Running
dns-test  Running
```

---

## 5️⃣ 🔥 THE MOST IMPORTANT PART — DNS BEHAVIOR

### Enter the test pod

```bash
kubectl exec -it dns-test -- sh
```

---

### 🔍 DNS lookup of the HEADLESS service

```sh
nslookup mysql-headless
```

✅ You will see **MULTIPLE IPs** (one per pod):

```
Address: 10.244.0.12
Address: 10.244.0.13
Address: 10.244.0.14
```

👉 This is **DNS round-robin**.

---

### 🔥 DNS lookup of INDIVIDUAL PODS (THIS IS THE KEY)

```sh
nslookup mysql-0.mysql-headless
nslookup mysql-1.mysql-headless
nslookup mysql-2.mysql-headless
```

✅ Each one resolves to a **specific pod IP**.

This is what **ClusterIP can NEVER do**.

---

## 6️⃣ Why databases NEED this

Imagine:

| Role       | DNS                      |
| ---------- | ------------------------ |
| Primary DB | `mysql-0.mysql-headless` |
| Replica 1  | `mysql-1.mysql-headless` |
| Replica 2  | `mysql-2.mysql-headless` |

Now:

* Writes → `mysql-0.mysql-headless`
* Reads → replicas
* Replication → stable target

💡 **This is impossible with Deployment + ClusterIP.**

---

## 7️⃣ Visual intuition (what’s happening)

![Image](https://www.atatus.com/blog/content/images/size/w600/2023/08/kubernetes-statefulset.png)

![Image](https://www.plural.sh/blog/content/images/2025/04/image-79.png)

---

## 8️⃣ One-line interview answer (remember this)

> “A headless service removes the virtual IP and exposes pod identities via DNS. Combined with StatefulSets, it enables stable per-pod DNS, which is required for databases and leader-follower architectures.”








# 🔥 SAME APP, TWO SERVICES 




# 🟦 CASE 1 — ClusterIP Service (DEFAULT BEHAVIOR)

## YAML (normal service)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-clusterip
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
```

### What Kubernetes does

* Creates **ONE virtual IP**
* Hides all pod IPs
* kube-proxy load balances traffic

### DNS behavior

Inside the cluster:

```bash
nslookup mysql-clusterip
```

Result:

```
Name: mysql-clusterip
Address: 10.96.120.15   <-- ONE IP
```

That IP is **NOT a pod**.
It’s a **virtual service IP**.

---

## 🔁 What happens to traffic

```
todo-app
   |
   v
mysql-clusterip (10.96.120.15)
   |
   +--> mysql-0
   +--> mysql-1
   +--> mysql-2
```

Kubernetes decides where each request goes.

---

## ❌ Why this breaks databases

Let’s say:

1. Signup request → mysql-2 (write happens there)
2. Login request → mysql-0 (no data)
3. ❌ login fails

Because:

* write and read hit **different pods**
* pod identity is hidden
* you cannot say “always go to mysql-0”

ClusterIP is **stateless-friendly**, **stateful-hostile**.

---

# 🟨 CASE 2 — Headless Service (NO CLUSTER IP)

Now we change **only one line**.

## YAML (headless service)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None   # 👈 THIS IS EVERYTHING
  selector:
    app: mysql
  ports:
    - port: 3306
```

---

## 🔍 DNS behavior (this is the key difference)

Inside a pod:

```bash
nslookup mysql-headless
```

Result:

```
Address: 10.244.0.10   (mysql-0)
Address: 10.244.0.11   (mysql-1)
Address: 10.244.0.12   (mysql-2)
```

⚠️ No virtual IP
⚠️ DNS returns **pod IPs directly**

This is **DNS round-robin**, not kube-proxy load balancing.

---

## 🧠 Still not enough alone (important)

If you stop here and use:

```
mysql-headless
```

Your app may still hit different pods, because DNS answers rotate.

So **headless alone is not the full solution**.

---

# 🟩 ENTER STATEFULSET (THIS IS THE MISSING PIECE)

StatefulSet guarantees **stable pod names**:

```
mysql-0
mysql-1
mysql-2
```

And Kubernetes automatically creates DNS records like:

```
mysql-0.mysql-headless
mysql-1.mysql-headless
mysql-2.mysql-headless
```

---

## 🔥 THIS IS THE MOMENT IT CLICKS

Now you can do this:

### Write traffic

```
mysql-0.mysql-headless
```

### Read traffic

```
mysql-1.mysql-headless
mysql-2.mysql-headless
```

No guessing. No randomness.

---

## 📊 SIDE-BY-SIDE SUMMARY (MEMORIZE THIS)

| Feature            | ClusterIP | Headless             |
| ------------------ | --------- | -------------------- |
| Has virtual IP     | ✅         | ❌                    |
| Hides pod identity | ✅         | ❌                    |
| DNS returns        | 1 IP      | Multiple pod IPs     |
| Pod-specific DNS   | ❌         | ✅                    |
| Good for web apps  | ✅         | ❌                    |
| Good for databases | ❌         | ✅ (with StatefulSet) |

---

## 🧪 Why we used `dns-test` pod

You cannot “see DNS” from your laptop.

So we create a pod just to ask:

```bash
nslookup <service-name>
```

That’s how SREs debug **real prod issues**.

---

## 🎯 ONE-LINE INTERVIEW ANSWER (IMPORTANT)

> “ClusterIP services hide pod identity and load balance traffic, which is unsuitable for databases. Headless services expose pod IPs via DNS, and when combined with StatefulSets, provide stable per-pod DNS required for stateful workloads.”

---



![Image](https://www.plural.sh/blog/content/images/2025/04/image-79.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fd6kqul2st1elt4nijwce.png)


