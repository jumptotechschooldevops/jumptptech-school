---
title: "Project: Understanding Kubernetes Volume Types"
description: "🎯 Goal   By the end, you will viscerally know:   why some data disappears why some data..."
published: 2026-01-15
source: "https://dev.to/jumptotech/project-understanding-kubernetes-volume-types-39dd"
tags: []
---

# Project: Understanding Kubernetes Volume Types

  

## 🎯 Goal 

By the end, you will **viscerally know**:

* why some data disappears
* why some data survives pod restarts
* when to use each volume
* why databases require PVCs

---

## 🧠 The 3 volume types we will test

| Volume     | Data survives pod restart? | Use case                  |
| ---------- | -------------------------- | ------------------------- |
| `emptyDir` | ❌ NO                       | temp files, cache         |
| `hostPath` | ⚠️ SOMETIMES               | node-specific (dangerous) |
| `PVC`      | ✅ YES                      | databases, user data      |

---

## 📁 Project structure

```
k8s-volumes-lab/
├── emptydir.yaml
├── hostpath.yaml
├── pvc.yaml
└── pod-pvc.yaml
```

---

# 🧩 PART 1 — emptyDir (DATA DIES WITH POD)

## 📄 emptydir.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-demo
spec:
  containers:
    - name: app
      image: busybox
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      emptyDir: {}
```

### ▶️ Apply

```bash
kubectl apply -f emptydir.yaml
kubectl exec -it emptydir-demo -- sh
```

### ✍️ Create data

```sh
echo "HELLO FROM EMPTYDIR" > /data/file.txt
cat /data/file.txt
```

### ❌ Kill the pod

```bash
kubectl delete pod emptydir-demo
kubectl apply -f emptydir.yaml
kubectl exec -it emptydir-demo -- cat /data/file.txt
```

### 💥 Result

```
No such file or directory
```

### 🧠 Lesson

> emptyDir lives **only as long as the pod lives**



# 📘 PROJECT: Understanding `hostPath` in Kubernetes 

---




### What is a Node?

> A **Node** is a real machine (VM or physical server) with its **own disk**.

* Examples: `kind-worker`, `kind-worker2`
* Each node has **its own filesystem**
* Nodes do **NOT share disks**

---

### What is a Pod?

> A **Pod** is a temporary runtime object that runs containers **on a node**.

* Pods are **ephemeral**
* Pods can be deleted and recreated
* Pods can move between nodes

---

### 🔑 Key Rule 

> **Pods move. Nodes don’t share storage.**

---

## 🖼️ Visual Diagram — Where `hostPath` Lives

![Image](https://drek4537l1klr.cloudfront.net/luksa/Figures/06fig04_alt.jpg)

![Image](https://miro.medium.com/1%2A34_SfcEcC9guWzfQkEtbpQ.png)

![Image](https://miro.medium.com/0%2AS1rEm3QvYDcfrgGy.jpg)

```
Node A (kind-worker)
└── /tmp/hostpath-demo/data.txt   ← REAL FILE (on disk)

Pod
└── /data  ───────────────┘
```

Another node:

```
Node B (kind-worker2)
└── /tmp/hostpath-demo/   ← EMPTY (different disk)
```

---

## 🧩 Why does `hostPath` exist?

### Why Kubernetes allows `hostPath`

`hostPath` exists for **special cases only**:

* Log collectors (DaemonSets)
* Node-level monitoring agents
* Debugging
* Single-node clusters
* Learning / labs

👉 It gives containers **direct access to node disk**.

---

## ⚠️ Important Warning 

> **hostPath bypasses Kubernetes storage safety.**
> Kubernetes does NOT protect, replicate, or move this data.

---

# 🧪 HANDS-ON LAB (FULL PROJECT)

---

## STEP 0 — Preconditions



* `kind` or any **multi-node** cluster
* At least **2 worker nodes**

Verify:

```bash
kubectl get nodes
```

---

## STEP 1 — Create Pod with `hostPath`

### 📄 `hostpath.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-demo
spec:
  containers:
    - name: app
      image: busybox
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: host
          mountPath: /data
  volumes:
    - name: host
      hostPath:
        path: /tmp/hostpath-demo
        type: DirectoryOrCreate
```

### Who creates this directory?

👉 **kubelet on the node** creates:

```
/tmp/hostpath-demo
```

---

## STEP 2 — Find the RIGHT NODE

```bash
kubectl apply -f hostpath.yaml
kubectl get pod hostpath-demo -o wide
```

Example:

```
NODE: kind-worker
```



> This node’s disk is where data will be written.

---

## STEP 3 — Write Data (Inside Pod)

```bash
kubectl exec -it hostpath-demo -- sh
```

Inside container:

```sh
echo "HOSTPATH DATA" > /data/data.txt
cat /data/data.txt
exit
```

### Where is the file REALLY stored?

```
kind-worker:/tmp/hostpath-demo/data.txt
```

Not in Kubernetes.
Not in etcd.
Not in the Pod.

---

## STEP 4 — Delete the Pod (DATA STAYS)

```bash
kubectl delete pod hostpath-demo
kubectl apply -f hostpath.yaml
```

Check node again:

```bash
kubectl get pod hostpath-demo -o wide
```

👉 Pod lands again on **same node**.

Verify:

```bash
kubectl exec -it hostpath-demo -- cat /data/data.txt
```

### ✅ Result:

```
HOSTPATH DATA
```

---



> Deleting a Pod does NOT delete node files.
> The data stays because the **node did not change**.

---

## STEP 5 — Delete / Drain the NODE (DATA IS LOST)

### Drain the node where Pod is running

```bash
kubectl drain kind-worker \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force
```

---

## STEP 6 — Recreate Pod

```bash
kubectl apply -f hostpath.yaml
kubectl get pod hostpath-demo -o wide
```

Now Pod runs on:

```
kind-worker2
```

---

## STEP 7 — Check Data Again (FAIL EXPECTED)

```bash
kubectl exec -it hostpath-demo -- cat /data/data.txt
```

### ❌ Output:

```
No such file or directory
```

---

## 🧠 WHY DATA IS GONE (Explain Clearly)

* Data still exists on **old node disk**
* New node has a **different disk**
* Kubernetes does **not copy hostPath data**

---

## 🆚 Pod vs Node (CLEAR DIFFERENCE TABLE)

| Concept              | Pod                       | Node         |
| -------------------- | ------------------------- | ------------ |
| What it is           | Runtime container wrapper | Real machine |
| Lifetime             | Short                     | Long         |
| Can be deleted       | Yes                       | Yes          |
| Moves around         | Yes                       | No           |
| Has disk             | ❌                         | ✅            |
| hostPath stored here | ❌                         | ✅            |

---

## ❌ Why `hostPath` is NOT for Production



* Node failure = data loss
* Pod reschedule = data loss
* No replication
* No HA
* No backups
* Security risk

> **hostPath = node disk, not Kubernetes storage**

---

## ✅ FINAL  TAKEAWAYS 

1. `hostPath` data lives on the **node filesystem**
2. Pod deletion does **not** delete node data
3. Node deletion or Pod movement **loses data**
4. `hostPath` is unsafe for databases
5. Use **PVC** for real applications

---

## 🎤 Interview-Ready One-Liner

> “hostPath mounts node-local storage into a Pod. Data survives Pod deletion but is lost when the Pod moves to another node, which breaks high availability.”






## 1️⃣ The Core Problem (Why PV & PVC Exist)

Pods are **ephemeral**.

If a Pod:

* restarts
* gets rescheduled
* node dies

👉 **ALL data inside the container filesystem is LOST**

Databases, uploads, logs, stateful apps **cannot survive this**.

So Kubernetes introduced **Persistent Storage Abstraction**.

---

## 2️⃣ Mental Model (THIS is what to remember)

Think **like DevOps**, not YAML first.

| Role                            | Think of it as | Who owns it     |
| ------------------------------- | -------------- | --------------- |
| **PV (PersistentVolume)**       | Actual disk    | Cluster / Infra |
| **PVC (PersistentVolumeClaim)** | Disk request   | Application     |
| **Pod**                         | Uses disk      | Runtime         |

---

## 3️⃣ PersistentVolume (PV) — What It Really Is

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2APyGq82fNPZFMxbzAH5Btuw.png)

![Image](https://miro.medium.com/0%2Av7-cw-1KYxQHGjVa.png)

![Image](https://yqintl.alicdn.com/fb0172ae52bd2481b12b362d0412fa4b8c71562d.png)

### PV = **Real Storage**

A PV represents:

* EBS
* EFS
* NFS
* Local disk
* Cloud disk

**Created by:**

* Admin
* StorageClass (dynamic)

### Key properties:

* Capacity (10Gi, 100Gi)
* Access mode (RWO, RWX)
* Reclaim policy (Retain / Delete)
* Backed by **real storage**

🔴 **Apps NEVER talk to PV directly**

---

## 4️⃣ PersistentVolumeClaim (PVC) — What Apps Use

![Image](https://miro.medium.com/0%2A0uoVehyP1LbbrU_4.png)

![Image](https://miro.medium.com/1%2AKKMCuz-BdOV8Ni-80L1c0g.png)

![Image](https://blog.nashtechglobal.com/wp-content/uploads/2024/01/1_keV2VBkCHb7cn_Rib0huYg-1.png)

### PVC = **Request for Storage**

PVC says:

> “I need 10Gi, ReadWriteOnce, fast disk”

Kubernetes:

* Finds a matching PV
* Binds PVC → PV
* Locks it (exclusive)

Pod only knows:

* volume name
* mount path

✅ Pod does NOT know:

* disk type
* cloud provider
* node location

---

## 5️⃣ Binding Flow (VERY IMPORTANT)

![Image](https://yqintl.alicdn.com/5db4c75acbd7ddf0f0cadc0637fd09002fdbb026.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2APyGq82fNPZFMxbzAH5Btuw.png)

### Order of events

1. PV exists (or StorageClass ready)
2. PVC is created
3. Kubernetes binds PVC → PV
4. Pod mounts PVC
5. Pod reads/writes data

❗ If PVC is not bound → **Pod stuck Pending**

---

# 🔥 FULL HANDS-ON PROJECT 

## 🎯 Goal

Prove that:

* Pod dies ❌
* Data survives ✅

---

## 📁 Project Structure

```
pv-pvc-lab/
├── pv.yaml
├── pvc.yaml
├── pod.yaml
```

---

## STEP 1️⃣ Create a PersistentVolume (PV)

```yaml
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: demo-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/demo-data
```

Apply:

```bash
kubectl apply -f pv.yaml
kubectl get pv
```

Expected:

```
STATUS: Available
```

---

## STEP 2️⃣ Create a PersistentVolumeClaim (PVC)

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Apply:

```bash
kubectl apply -f pvc.yaml
kubectl get pvc
```

Expected:

```
STATUS: Bound
```

🔴 If not bound → size / accessMode mismatch

---

## STEP 3️⃣ Create Pod Using the PVC

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-demo-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - mountPath: /data
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: demo-pvc
```

Apply:

```bash
kubectl apply -f pod.yaml
kubectl get pod
```

---

## STEP 4️⃣ Write Data into the Volume

```bash
kubectl exec -it pvc-demo-pod -- sh
```

Inside Pod:

```sh
echo "Kubernetes storage works" > /data/test.txt
cat /data/test.txt
```

---

## STEP 5️⃣ DELETE THE POD (Important)

```bash
kubectl delete pod pvc-demo-pod
```

Now recreate:

```bash
kubectl apply -f pod.yaml
```

Check again:

```bash
kubectl exec -it pvc-demo-pod -- cat /data/test.txt
```

🎉 **DATA IS STILL THERE**

---

## STEP 6️⃣ Delete PVC & Observe Reclaim Policy

```bash
kubectl delete pvc demo-pvc
kubectl get pv
```

Because:

```yaml
persistentVolumeReclaimPolicy: Retain
```

Result:

```
STATUS: Released
```

💡 Data still exists on disk
Admin must manually clean or reuse

---

## 6️⃣ What DevOps MUST Know (Interview GOLD)

### ❓ Why not Deployment for DB?

* Pod identity changes
* Volume attachment breaks
* Ordering not guaranteed

👉 Use **StatefulSet + PVC**

---

### ❓ Why PVC instead of direct disk?

* Decouples app from infra
* Enables portability
* Enables dynamic provisioning

---

### ❓ Why Pod Pending?

Most common reasons:

* PVC not bound
* No matching PV
* Wrong access mode
* StorageClass missing

---

## 7️⃣ Access Modes (Critical)

| Mode | Meaning    | Example       |
| ---- | ---------- | ------------- |
| RWO  | One node   | EBS           |
| RWX  | Many nodes | EFS / NFS     |
| ROX  | Read only  | Shared config |

---

## 8️⃣ Production Mapping (REAL WORLD)

| Kubernetes   | AWS           |
| ------------ | ------------- |
| PV           | EBS / EFS     |
| PVC          | Disk request  |
| StorageClass | Disk template |
| StatefulSet  | Database      |


