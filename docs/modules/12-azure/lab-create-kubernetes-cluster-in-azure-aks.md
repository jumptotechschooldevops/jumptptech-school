---
title: "Lab: Create Kubernetes Cluster in Azure (AKS)"
description: "Architecture we will create:    Internet    │ Azure Load Balancer    │ AKS Cluster    │ Pods /..."
published: 2026-03-04
source: "https://dev.to/jumptotech/lab-create-kubernetes-cluster-in-azure-aks-5cbh"
tags: []
---

# Lab: Create Kubernetes Cluster in Azure (AKS)



 

Architecture we will create:

```
Internet
   │
Azure Load Balancer
   │
AKS Cluster
   │
Pods / Deployments
```

---

# Step 1 — Install Azure CLI on Your VM (or Mac)

Since you already have your **Azure VM**, SSH into it:

```bash
ssh -i vm-lab-1_key.pem azureuser@20.83.170.33
```

Install Azure CLI:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Verify:

```bash
az version
```

---

# Step 2 — Login to Azure

Run:

```bash
az login
```

A browser login link will appear.
Authenticate using your Azure account.

Verify subscription:

```bash
az account show
```

---

# Step 3 — Create Resource Group

All AKS resources will live inside this group.

```bash
az group create \
--name aks-lab-rg \
--location eastus
```

Verify:

```bash
az group list
```

---

# Step 4 — Create AKS Cluster

Now create the Kubernetes cluster.

```bash
az aks create \
--resource-group aks-lab-rg \
--name aks-lab-cluster \
--node-count 2 \
--enable-addons monitoring \
--generate-ssh-keys
```

Explanation:

```
--node-count 2 → number of worker nodes
--generate-ssh-keys → auto creates SSH keys
--enable-addons monitoring → enables Azure Monitor
```

Creation takes **5–10 minutes**.

---

# Step 5 — Install kubectl

If kubectl is not installed:

```bash
sudo az aks install-cli
```

Verify:

```bash
kubectl version --client
```

---

# Step 6 — Connect kubectl to AKS

Download cluster credentials:

```bash
az aks get-credentials \
--resource-group aks-lab-rg \
--name aks-lab-cluster
```

Test:

```bash
kubectl get nodes
```

Expected output:

```
NAME                                STATUS   ROLES
aks-nodepool1-xxxxxx-vmss000000     Ready    agent
aks-nodepool1-xxxxxx-vmss000001     Ready    agent
```

---

# Step 7 — Deploy an Application

Create deployment:

```bash
kubectl create deployment nginx \
--image=nginx
```

Check pods:

```bash
kubectl get pods
```

---

# Step 8 — Expose Service

Expose using LoadBalancer:

```bash
kubectl expose deployment nginx \
--type=LoadBalancer \
--port=80
```

Check service:

```bash
kubectl get svc
```

Wait until EXTERNAL-IP appears.

Example:

```
nginx   LoadBalancer   20.80.x.x
```

---

# Step 9 — Access Application

Open browser:

```
http://EXTERNAL-IP
```

You should see:

```
Welcome to nginx
```

---

# Step 10 — Useful AKS Commands

Check cluster info:

```bash
kubectl cluster-info
```

List nodes:

```bash
kubectl get nodes
```

List pods:

```bash
kubectl get pods -A
```

Scale deployment:

```bash
kubectl scale deployment nginx --replicas=3
```

Delete resources:

```bash
kubectl delete deployment nginx
```

---

# Azure AKS Architecture

```
Azure Resource Group
        │
        ▼
Azure Kubernetes Service
        │
        ▼
Node Pool (VM Scale Set)
        │
        ▼
Pods
        │
        ▼
Azure Load Balancer
```



