---
title: "Azure AKS"
description: "0) Before you start (important)   Because your subscription is low quota, do this..."
published: 2026-03-04
source: "https://dev.to/jumptotech/azure-aks-k0j"
tags: []
---

# Azure AKS


## 0) Before you start (important)

Because your subscription is low quota, do this first:

1. Go to **Virtual machines**
2. **Stop** any VM that is running (your D2s_v3 VM uses your vCPU quota)

   * Select VM → **Stop**

If you don’t stop it, AKS creation will fail with “0 vCPUs remaining”.

---

## 1) Open AKS creation

1. Azure Portal → search: **Kubernetes services**
2. Open **Kubernetes services**
3. Click **Create**
4. Choose **Kubernetes cluster**

---

## 2) Basics tab

Fill exactly like this:

1. **Subscription**: your subscription
2. **Resource group**: select existing (example: `devops-azure-lab`) or create new
3. **Cluster preset / configuration** (if shown): choose **Dev/Test**
4. **Kubernetes version**: leave default
5. **Cluster name**: `aks-lab-1`
6. **Region**: pick the one where you have quota (you tested: Central US / East US / West US 2).

   * If one region fails quota, switch region.
7. **Availability zones**: **None** (important for small quotas)

Click **Next: Node pools**

---

## 3) Node pools tab (most important)

You must choose a size that is allowed + fits your quota.

1. **Enable node auto-provisioning**: **OFF**
2. In the `agentpool` row click **(change)** next to Node size
3. In “Select a VM size” window:

   * set filter **vCPUs = 2**
   * pick one of these if available:

     * **Standard_D2s_v5** (best if quota exists)
     * **Standard_D2s_v4**
     * **Standard_D2s_v3** (older but usually available)
     * **Standard_DS2_v2** (common fallback)
   * Click the row → **Select**
4. **Scale method**:

   * choose **Manual**
5. **Node count**: set to **1**
6. **Enable virtual nodes**: **OFF**

If you still see “0 vCPUs remaining for DSv5 family”, that means:

* you must **change node size to another family** (v3/v4/DS2v2), OR
* you must **request quota increase**, OR
* you must **stop more running resources**.

Click **Next: Networking**

---

## 4) Networking tab (simple defaults)

For first lab, keep defaults:

1. **Network configuration**: default
2. **Network plugin**: leave default
3. **DNS name prefix**: auto or `aks-lab-1`
4. **Outbound type**: default

Click **Next** (Integrations)

---

## 5) Integrations tab

Keep defaults.

* (Optional later: enable Container Registry integration, Key Vault, etc.)

Click **Next: Monitoring**

---

## 6) Monitoring tab

For beginner lab:

* **Enable Container insights**: optional (cost). You can keep OFF to save money.

Click **Next: Security**

---

## 7) Security tab

Keep defaults.

* RBAC usually ON by default (good)

Click **Next: Advanced** → **Next: Tags** → **Next: Review + create**

---

## 8) Review + create

1. Fix any red validation errors.
2. Click **Create**
3. Wait until deployment finishes.

---

## 9) Connect to AKS (UI method)

After AKS is created:

1. Open your cluster → **Overview**
2. Click **Connect**
3. Choose:

   * **Azure CLI**
4. Copy the commands Azure shows (usually):

   * `az login`
   * `az aks get-credentials ...`
   * `kubectl get nodes`

On Mac, you run those in Terminal (Azure CLI + kubectl must be installed).


