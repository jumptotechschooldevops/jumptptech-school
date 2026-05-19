---
title: "A controller in Kubernetes is a control loop that:"
description: "Watches the current state of the cluster (from the API server),  Compares it with the desired..."
published: 2025-11-12
source: "https://dev.to/jumptotech/a-controller-in-kubernetes-is-a-control-loop-that-23d3"
tags: []
---

# A controller in Kubernetes is a control loop that:




![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2etio5zo3mjvs1v1l5mh.png)




* **Watches** the current state of the cluster (from the API server),
* **Compares** it with the desired state (from YAML manifests),
* **Acts** to fix differences (create/update/delete resources).

Example:

> You define “3 Pods” → if only 2 are running, the controller starts 1 more.

---

## 🧩 2. Main Categories of Controllers

There are 3 broad categories:

| Category                          | Description                                       | Examples                                                                    |
| --------------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------- |
| **Workload Controllers**          | Manage Pods and how applications run.             | Deployment, ReplicaSet, StatefulSet, DaemonSet, Job, CronJob                |
| **Infrastructure Controllers**    | Manage nodes, networking, namespaces, etc.        | Node Controller, Service Controller, Namespace Controller                   |
| **Custom / Operator Controllers** | Created by users to manage specific apps or CRDs. | Prometheus Operator, Argo CD Operator, AWS Controllers for Kubernetes (ACK) |

---

## ⚙️ 3. Core Workload Controllers (Most Common)

These are the controllers you’ll use daily.

| Controller      | Purpose                                                           | Typical Use Case                                                      |
| --------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------- |
| **Deployment**  | Manages ReplicaSets and performs rolling updates/rollbacks.       | Stateless web apps, APIs                                              |
| **ReplicaSet**  | Ensures a specific number of identical Pods are running.          | Low-level controller used by Deployment                               |
| **StatefulSet** | Ensures unique, ordered Pods with stable storage and network IDs. | Databases (MySQL, MongoDB), Kafka, Zookeeper                          |
| **DaemonSet**   | Ensures one Pod runs on each node (or selected nodes).            | Log collectors, monitoring agents (Prometheus Node Exporter, Fluentd) |
| **Job**         | Runs Pods to completion.                                          | Batch tasks, data processing                                          |
| **CronJob**     | Runs Jobs on a schedule.                                          | Backups, cleanup jobs, periodic reports                               |







# **1. Deployment (Stateless App)**

Runs scalable, stateless microservices.

### **Example: Nginx Web App**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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

---

# **2. ReplicaSet (Maintain Pod Count)**

Ensures a fixed number of pods. (Usually created by a Deployment.)

### **Example: 4 backend pods**

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: backend-rs
spec:
  replicas: 4
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: my-backend:1.0
```

---

# **3. StatefulSet (Stateful Apps + Stable Identity)**

Each pod gets a sticky identity + persistent volumes.

### **Example: Kafka Broker Pod**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kafka
spec:
  serviceName: kafka
  replicas: 3
  selector:
    matchLabels:
      app: kafka
  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
      - name: kafka
        image: confluentinc/cp-kafka:7.6.1
        volumeMounts:
        - name: data
          mountPath: /var/lib/kafka
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 20Gi
```

---

# **4. DaemonSet (Run on Every Node)**

Runs exactly one pod per node (or selected nodes).

### **Example: Node exporter for monitoring**

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter
```

---

# **5. Job (Run Once Until Success)**

Runs a task one time and stops.

### **Example: Database migration**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: myapp:migrate
        command: ["python", "manage.py", "migrate"]
      restartPolicy: Never
```

---

# **6. CronJob (Scheduled Jobs)**

Runs a job on a schedule, like Linux cron.

### **Example: Backup database every night at 2 AM**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-backup
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: myapp:backup
          restartPolicy: Never
```

---

# **7. ReplicationController (Deprecated)**

Old way to keep pods alive. Rarely used now.

### **Example: Old-style replication**

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: rc-example
spec:
  replicas: 2
  selector:
    app: rc-app
  template:
    metadata:
      labels:
        app: rc-app
    spec:
      containers:
      - name: rc-container
        image: busybox
        command: ["sleep", "3600"]
```





# **What is YAML?**

**YAML** stands for:

### **Y**AML **A**in’t **M**arkup **L**anguage

It is a **human-readable data format** used to write configuration files.
Kubernetes uses YAML to define **Pods, Deployments, Services, Ingress, Secrets, ConfigMaps**, and more.

---

# **Why YAML?**

Because it is:

* **Easy to read**
* **Easy to write**
* **Structured**
* **Supports hierarchy**
* **Supports lists, maps, and key-value pairs**

---

# **Where is YAML used?**

In DevOps everywhere:

* **Kubernetes manifests**
* **Docker Compose**
* **GitHub Actions CI/CD**
* **Ansible**
* **Terraform Cloud configuration**
* **AWS CloudFormation**

---

# **Basic YAML Rules**

### 1. **Indentation matters**

Use **spaces**, not tabs.

### 2. **Key: value**

Everything is a key-value pair.

Example:

```yaml
name: nginx
image: nginx:latest
```

### 3. **Lists**

Represented with `-`

Example:

```yaml
ports:
  - 80
  - 443
```

### 4. **Hierarchy**

Indent to show structure:

```yaml
spec:
  containers:
    - name: app
      image: myapp:1.0
```

---

# **Simple Example**

A Kubernetes Pod defined in YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mycontainer
      image: nginx
```

---

# **In one line:**

**YAML is a structured configuration language used to tell Kubernetes what you want to create or run.**




## 🏗️ 4. Cluster & Infrastructure Controllers

These are **system-level controllers** running in the **kube-controller-manager** (on the control plane).

| Controller                         | Description                                                                               |
| ---------------------------------- | ----------------------------------------------------------------------------------------- |
| **Node Controller**                | Detects when nodes go down and manages node lifecycle.                                    |
| **Service Controller**             | Creates or removes cloud load balancers when Services of type `LoadBalancer` are created. |
| **Namespace Controller**           | Cleans up resources when a namespace is deleted.                                          |
| **EndpointSlice Controller**       | Maintains network endpoints for Services efficiently.                                     |
| **PersistentVolume Controller**    | Manages PersistentVolume and PersistentVolumeClaim binding.                               |
| **PersistentVolumeBinder**         | Handles dynamic provisioning of storage.                                                  |
| **ServiceAccount Controller**      | Creates default service accounts and API tokens.                                          |
| **ReplicationController (Legacy)** | Older controller replaced by ReplicaSet.                                                  |
| **Job Controller**                 | Manages Pod creation for Job resources.                                                   |
| **CronJob Controller**             | Manages Job scheduling for CronJobs.                                                      |

All these run inside one process:

```bash
kube-controller-manager
```

---

## 🧰 5. Cloud-Specific Controllers (on Managed Clusters)

When you use **EKS, GKE, or AKS**, additional controllers integrate Kubernetes with the cloud provider:

| Controller                       | Role                                                       |
| -------------------------------- | ---------------------------------------------------------- |
| **Cloud Controller Manager**     | Connects Kubernetes with the underlying cloud APIs.        |
| **Route Controller**             | Manages networking routes between cluster nodes.           |
| **AWS Load Balancer Controller** | Provisions AWS ALB/NLB for Ingress or Services.            |
| **External DNS Controller**      | Automatically manages DNS records in Route53 or Cloud DNS. |

---

## 🧬 6. Custom Controllers

Developers can create their own controllers to automate any workflow.

Example:
You define a **Custom Resource Definition (CRD)** called `Database`, and a **custom controller** ensures that:

* When a `Database` object is created → a Pod and PVC are provisioned.
* When it’s deleted → resources are cleaned up.

This is how **Operators** are built.

---

## 🧠 7. Operator Controllers (Advanced)

**Operators** are custom controllers that encode domain-specific operational logic.

| Example Operator                         | What It Manages                                                |
| ---------------------------------------- | -------------------------------------------------------------- |
| **Prometheus Operator**                  | Deploys and configures Prometheus and Alertmanager             |
| **Argo CD Operator**                     | Manages Argo CD GitOps setup                                   |
| **Kafka Operator**                       | Manages Kafka clusters                                         |
| **PostgreSQL Operator**                  | Automates PostgreSQL database deployment                       |
| **AWS Controllers for Kubernetes (ACK)** | Manages AWS resources (S3, RDS, etc.) directly from Kubernetes |

Operators use:

* Custom Resources (CRDs)
* Custom Controllers (logic)
* Often written in Go, Python, or with frameworks like Kubebuilder.

---

## 🧮 8. Summary Table — All Controller Types

| Type                     | Example Controllers                                | Purpose                         |
| ------------------------ | -------------------------------------------------- | ------------------------------- |
| **Workload Controllers** | Deployment, StatefulSet, DaemonSet, Job, CronJob   | Manage Pods and app workloads   |
| **System Controllers**   | Node, Namespace, Service, Endpoints, PV/PVC        | Maintain cluster infrastructure |
| **Cloud Controllers**    | AWS Load Balancer, Route, Cloud Controller Manager | Integrate with cloud provider   |
| **Custom Controllers**   | CRD-based logic                                    | Extend Kubernetes               |
| **Operators**            | Prometheus Operator, Argo CD Operator              | Automate complex apps           |

---

## 🧩 9. Where They Run

All default controllers (like Deployment, StatefulSet, etc.) are part of the **kube-controller-manager** process on the **control plane**.

Custom and Operator controllers run as **Pods** inside the cluster.

---

## 🧠 10. How to See Active Controllers

You can check which controllers are running:

```bash
kubectl get pods -n kube-system | grep controller
```

You might see:

```
kube-controller-manager-minikube
aws-load-balancer-controller-xxxx
ingress-nginx-controller-xxxx
```


