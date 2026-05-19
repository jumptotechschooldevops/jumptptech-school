---
title: "Kubernetes Core • Pod Lifecycle & Health • Networking From DevOps Production & Interview Perspective"
description: "1. Kubernetes works on intent, not execution   Kubernetes does one thing only:   It..."
published: 2026-01-11
source: "https://dev.to/jumptotech/kubernetes-core-pod-lifecycle-health-networking-from-devops-production-interview-4eei"
tags: []
---

# Kubernetes Core • Pod Lifecycle & Health • Networking From DevOps Production & Interview Perspective





## 1. Kubernetes works on **intent**, not execution

Kubernetes does **one thing only**:

> It continuously reconciles **Desired State (YAML)** with **Current State (runtime)**.

Everything else (pods, services, probes, networking) exists **only to support this reconciliation**.

DevOps responsibility:

* Define intent correctly
* Let Kubernetes enforce it
* Debug when reality does not match intent

---

## 2. Pods are the **real runtime units**

* A Pod:

  * Has **one real IP**
  * Runs on **one node**
  * Is **ephemeral**
* Pods **do not self-heal**
* Controllers (ReplicaSet / Deployment) heal **by replacing Pods**

**Key truth**

> Pod IP = real network identity

---

## 3. Kubernetes networking is a **flat network (no NAT between Pods)**

When we say:

> “Pods communicate without NAT”

It means:

* Pod A talks **directly** to Pod B’s **real Pod IP**
* No IP translation
* No port mapping
* No Docker-style forwarding

```
Pod A (10.244.1.5)  →  Pod B (10.244.2.8)
```

This is required by Kubernetes networking rules.

Why this matters:

* Apps behave like they are on real VMs
* Source IP is preserved
* NetworkPolicy and security work correctly

---

## 4. Services exist because Pods are unstable

Pods:

* Die
* Restart
* Change IPs

So Kubernetes introduces **Service** as an abstraction.

**Important correction**
❌ Pods do NOT communicate with ClusterIP
✅ Pods communicate with **Pod IPs**
✅ Services only decide **which Pod IP gets traffic**

---

## 5. What ClusterIP really is (this is the key)

### ClusterIP is:

* A **virtual IP**
* NOT a Pod
* NOT a server
* NOT “the cluster”

ClusterIP exists **only as routing rules** on every node.

Think of it as:

> “A fake IP that kube-proxy listens for”

---

## 6. Labels vs runtime traffic (CRITICAL DISTINCTION)

### Labels are used ONLY at control-plane time

When you define a Service:

```yaml
selector:
  app: backend
```

Kubernetes does this ONCE (or when things change):

1. Finds Pods with matching labels
2. Builds **Endpoints / EndpointSlices**
3. Stores **Pod IPs** in endpoints

After that:

* Labels are no longer involved
* Runtime traffic uses **only Pod IPs**

**Important sentence**

> Labels choose Pods, endpoints store Pod IPs, kube-proxy routes traffic.

---

## 7. kube-proxy’s real job (very precise)

kube-proxy:

* Watches Services and Endpoints
* Programs routing rules on each node

Conceptually, kube-proxy says:

> “If traffic goes to this ClusterIP:Port → forward it to one of these Pod IPs”

kube-proxy does NOT:

* Look at labels
* “Send traffic to the cluster”
* Make smart application decisions

---

## 8. Where “ClusterIP load balancing” fits

When we say:

> “ClusterIP provides load balancing”

We mean **this exact thing**:

* A Service usually has **multiple Pod IPs**
* Traffic arrives at **one virtual IP (ClusterIP)**
* kube-proxy must choose **one Pod IP**
* That choice = **load balancing**

This load balancing is:

* Layer 4 (TCP/UDP)
* Per connection (not per request)
* Simple and fast

**Important interview point**

> ClusterIP does not balance HTTP requests — it balances connections.

---

## 9. Why readiness probe is critical here

Only **Ready Pods** appear in endpoints.

So kube-proxy load-balances traffic across:

```
READY Pod IPs only
```

If readiness fails:

* Pod is removed from endpoints
* kube-proxy stops routing traffic to it
* No restart happens

This connects probes + services + networking.

---

## 10. Full traffic flow (no confusion)

### Internal traffic

```
Pod
 → Service DNS
   → ClusterIP (virtual)
     → kube-proxy rule
       → Pod IP
```

### External traffic

```
Internet
 → LoadBalancer / Ingress
   → Service (ClusterIP)
     → Pod IP
```

**Traffic never goes “to the cluster”.**
It always ends at a **Pod IP**.

---

## 11. Where NAT exists vs does NOT exist

* ❌ Pod ↔ Pod → NO NAT
* ❌ Service → Pod → NO NAT between Pods
* ✅ External → Node → Pod → NAT MAY exist

This is why Kubernetes networking feels different from Docker.

---

## 12. DevOps debugging mindset (final connection)

If traffic fails, DevOps does NOT think:

* “ClusterIP is broken”
* “Kubernetes networking is magic”

DevOps thinks:

1. Is Service selecting Pods?
2. Are endpoints present?
3. Are Pods Ready?
4. Is kube-proxy running?
5. Is NetworkPolicy blocking?

Because:

> If endpoints exist, ClusterIP routing **will work**.



# Kubernetes Networking — ONE Clear Mental Model 

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A-ze224LkGbwRbgIC-7w5dg.jpeg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AKIVa4hUVZxg-8Ncabo8pdg.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AXfH2wlj2SpJe5ZWerpbSsA.png)

### Kubernetes answers **ONLY ONE question**:

> **How should traffic be routed once it is INSIDE the cluster?**

❗ **Kubernetes does NOT provide internet infrastructure**
❗ **Kubernetes does NOT create real load balancers**
❗ **Kubernetes does NOT own external IPs**

That is the **cloud provider’s job**.

---

## Who Does What? (Very Important)

| Component                    | Who Provides It                    | Responsibility               |
| ---------------------------- | ---------------------------------- | ---------------------------- |
| Pod networking               | Kubernetes                         | Pod-to-pod routing           |
| Service (ClusterIP/NodePort) | Kubernetes                         | Internal traffic abstraction |
| Load Balancer                | **Cloud provider (AWS/GCP/Azure)** | External IP + HA             |
| Ingress                      | Kubernetes (config)                | HTTP routing rules           |
| Ingress Controller           | Runs in Kubernetes                 | Implements ingress rules     |
| Egress                       | Kubernetes + cloud NAT             | Outbound traffic             |

👉 Kubernetes **ORCHESTRATES**, cloud **PROVIDES INFRASTRUCTURE**

---

# PART 1 — Kubernetes Service (What K8s REALLY Gives)

## What a Service Is (Truth)

A **Service** is:

* A **virtual IP**
* Inside the cluster
* Backed by kube-proxy rules

It gives:

* Stable endpoint
* Pod IP abstraction
* Internal load balancing

🚫 It does **NOT**:

* Expose internet
* Create load balancers
* Allocate public IPs

---

## Service Types (What They ACTUALLY Mean)

| Type         | What K8s Does         | What It Does NOT Do       |
| ------------ | --------------------- | ------------------------- |
| ClusterIP    | Internal virtual IP   | No external access        |
| NodePort     | Opens a port on nodes | No routing, no HA         |
| LoadBalancer | **Requests cloud LB** | Does not create LB itself |

---

# PART 2 — NodePort (Why It Is NOT External Routing)

![Image](https://zesty.co/wp-content/uploads/2025/02/nodeport.png)

![Image](https://miro.medium.com/1%2AKIVa4hUVZxg-8Ncabo8pdg.png)

### What NodePort REALLY Does

> Kubernetes opens a **port number** on **each node**

That’s it.

### What NodePort does NOT give

❌ No permanent IP
❌ No routing
❌ No failover
❌ No TLS
❌ No DNS

### Reality in Cloud

```
You → random Node IP → NodePort → Pod
```

If that node:

* Restarts → IP changes
* Scales down → gone
* Is unhealthy → traffic dies

⚠️ **Kubernetes does not reroute you to another node**

---

## Correct Statement (Memorize This)

> **NodePort exposes a port, not an endpoint**

That’s why it is **labs only**, not production.

---

# PART 3 — LoadBalancer (Where External IP REALLY Comes From)

![Image](https://docs.aws.amazon.com/images/eks/latest/best-practices/images/networking/lb_target_type_ip.png)

![Image](https://www.densify.com/wp-content/uploads/article-k8s-capacity-kubernetes-service-overview.svg)

### Key Truth (Very Important)

> **Kubernetes does NOT create load balancers**

### What actually happens

1. You create:

```yaml
type: LoadBalancer
```

2. Kubernetes sends a request to:

* AWS API
* GCP API
* Azure API

3. Cloud provider creates:

* ALB / NLB / ELB
* Public IP
* Health checks
* HA

Kubernetes just **registers Pods as targets**

---

### When LoadBalancer Is Used

✅ Simple production apps
✅ Single service exposure
❌ Complex routing (paths/domains)

---

# PART 4 — Ingress (THIS Is Kubernetes External Traffic Control)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20240506105314/Kubernetes-Ingress-Architecture-%281%29.webp)

![Image](https://docs.nginx.com/nic/ic-high-level.png)

## What Ingress REALLY Is

Ingress is:

* **NOT a load balancer**
* **NOT external by itself**

Ingress is:

> A **set of HTTP routing rules**

Ingress needs:

1. **Ingress Controller** (runs in Pods)
2. **Load Balancer** (from cloud)

---

## Real Production Flow (Always)

```
Internet
  |
  v
Cloud Load Balancer (AWS/GCP/Azure)
  |
  v
Ingress Controller (Pod)
  |
  v
ClusterIP Service
  |
  v
Pod
```

### Who owns what

| Layer         | Owner              |
| ------------- | ------------------ |
| Public IP     | Cloud              |
| TLS entry     | Ingress controller |
| Routing logic | Kubernetes         |
| Pod health    | Kubernetes         |

---

## Why DevOps Uses Ingress (Almost Always)

Ingress provides:

* One external IP
* Multiple apps
* Path-based routing
* Host-based routing
* TLS termination
* Cost optimization

---

# PART 5 — Egress (Outbound Traffic)

![Image](https://doimages.nyc3.cdn.digitaloceanspaces.com/006Community/DOKS_Posts_Images_Anish/Crossplane_Gateway_k8s/doks_egress_setup.png)

![Image](https://images.ctfassets.net/ro61k101ee59/4qahu4EL7RPvOQujSwXeqt/04127ba6942ebdb17c2e5a8dbe650459/Untitled__5_.png?q=75\&w=2400)

### What Egress Means

> **Traffic leaving the cluster**

Examples:

* Pod → RDS
* Pod → Internet API
* Pod → SaaS service

### Who handles Egress

| Layer      | Responsibility                 |
| ---------- | ------------------------------ |
| Kubernetes | Pod routing rules              |
| CNI        | Packet forwarding              |
| Cloud      | NAT Gateway / Internet Gateway |

Kubernetes does **NOT** give public outbound IPs
Cloud NAT does.

---

# FINAL — ONE SENTENCE THAT CLEARS ALL CONFUSION

> **Kubernetes does not provide load balancers or public IPs. The cloud provider does. Kubernetes only provides internal traffic abstraction (Services) and routing configuration (Ingress/Egress).**

---

# FINAL DECISION MATRIX (Production Reality)

| Requirement              | Correct Solution   |
| ------------------------ | ------------------ |
| Internal communication   | ClusterIP          |
| Learning / demo          | NodePort           |
| Simple external app      | LoadBalancer       |
| Real production platform | Ingress + Cloud LB |
| Outbound internet        | Cloud NAT (Egress) |

---

## Interview-Perfect Answer 

> *Kubernetes itself does not create load balancers or provide public IPs. In cloud environments, the cloud provider supplies the load balancer infrastructure, while Kubernetes integrates with it through Services and Ingress. NodePort only opens ports and is not suitable for production. Ingress is the correct way to manage external traffic, while egress is handled through cloud NAT and routing.*




## FINAL INTERVIEW-READY CONNECTED STATEMENT (USE THIS)

> **“Kubernetes networking is based on real Pod IPs without NAT. Services provide a stable virtual IP (ClusterIP), and kube-proxy routes traffic from that virtual IP to ready Pod IPs listed in endpoints. Labels are used only to build endpoints, not during runtime. ClusterIP load balancing is Layer 4 and per connection.”**

That sentence **connects everything correctly**.

---

## ONE-LINE MENTAL MODEL (REMEMBER THIS)

> **Pod IP is reality.
> Service is abstraction.
> kube-proxy is routing.
> Probes control traffic.**


