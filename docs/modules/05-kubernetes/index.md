# Module 05 · Kubernetes

Kubernetes (often abbreviated to k8s) is the dominant container orchestration platform. If Docker lets you run one container on one machine, Kubernetes lets you run thousands of containers across hundreds of machines — with automatic scheduling, self-healing, scaling, and rolling updates.

This module covers the concepts and day-to-day operations that a DevOps engineer needs. Not the entire Kubernetes API surface — that is too large to cover in one module — but the subset you will use constantly.

## What you will cover

**Lecture 1 — Architecture & Core Objects**
The control plane and worker nodes, the reconciliation loop, Pods, ReplicaSets, Deployments, and the kubectl basics.

**Lecture 2 — Workloads & Config**
Jobs, CronJobs, DaemonSets, StatefulSets, ConfigMaps, Secrets, resource requests and limits.

**Lecture 3 — Networking & Storage**
Services (ClusterIP, NodePort, LoadBalancer), Ingress, PersistentVolumes, PersistentVolumeClaims, StorageClasses.

**Lab 1 — Deployments & Rolling Updates**
Deploy an application, perform rolling updates, roll back, and observe the reconciliation loop.

**Lab 2 — Services & Ingress**
Expose your app externally, configure path-based routing with Ingress.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 60 min |
| Lecture 2 | 50 min |
| Lecture 3 | 50 min |
| Lab 1 | 75 min |
| Lab 2 | 75 min |

## Setup

Use one of these local Kubernetes options:

```bash
# Option A: minikube
minikube start --cpus=2 --memory=4096
kubectl cluster-info

# Option B: kind (Kubernetes IN Docker)
kind create cluster --name devops-lab
kubectl cluster-info --context kind-devops-lab

# Option C: Docker Desktop
# Enable in Docker Desktop Settings → Kubernetes

# Verify kubectl
kubectl version --client
kubectl get nodes
```
