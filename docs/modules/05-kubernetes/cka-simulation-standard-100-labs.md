---
title: "CKA-SIMULATION STANDARD 100 labs"
description: "📦 LAB FORMAT   Every lab will look like this:    lab-XX/ ├── README.md        # exam-style..."
published: 2026-01-26
source: "https://dev.to/jumptotech/cka-simulation-standard-100-labs-2ba4"
tags: []
---

# CKA-SIMULATION STANDARD 100 labs







# 📦 LAB FORMAT 

Every lab will look like this:

```
lab-XX/
├── README.md        # exam-style task
├── broken.yaml      # applied by student
├── resources/       # extra manifests
└── verify.md        # what must work (NO HOW)
```

---

# 🧪 PART 1 — LABS 1–10 (CLUSTER ARCHITECTURE)

**Official CKA Domain:** Cluster Architecture, Installation & Configuration (25%)

---

## 🔹 LAB 1 — Create Multi-Node Cluster (kind)

**Objective:** Install and configure a Kubernetes cluster

### Files

**lab-01/kind-config.yaml**

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

### Task (README.md)

* Create a Kubernetes cluster named `cka`
* Verify all nodes are Ready

### Verify

```bash
kubectl get nodes
```

---

## 🔹 LAB 2 — Cluster with Broken Networking

**Objective:** Install and configure networking

**lab-02/kind-broken.yaml**

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
nodes:
- role: control-plane
- role: worker
```

### Task

* Create cluster
* Observe node status
* Restore pod networking

### Verify

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 🔹 LAB 3 — Control Plane Inspection

**Objective:** Understand cluster components

### Task

* Identify kube-apiserver, scheduler, controller-manager
* Determine where they run

### Verify

```bash
kubectl get pods -n kube-system
```

---

## 🔹 LAB 4 — API Server Failure Simulation

**Objective:** Troubleshoot cluster components

### Task

* Stop kube-apiserver container
* Observe cluster behavior
* Restore functionality

### Verify

```bash
kubectl get nodes
```

---

## 🔹 LAB 5 — RBAC: Namespace Role

**Objective:** RBAC configuration

**lab-05/role.yaml**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### Task

* Create namespace `dev`
* Apply role
* Bind it to ServiceAccount

### Verify

```bash
kubectl auth can-i list pods --as system:serviceaccount:dev:sa -n dev
```

---

## 🔹 LAB 6 — ClusterRole Binding

**Objective:** Cluster-wide RBAC

**lab-06/clusterrole.yaml**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: view-nodes
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
```

### Task

* Bind role to a user
* Validate access

---

## 🔹 LAB 7 — Node Taint

**Objective:** Scheduling control

### Task

* Taint a node as unschedulable
* Deploy a pod
* Observe scheduling behavior

### Verify

```bash
kubectl describe pod
```

---

## 🔹 LAB 8 — Remove Taint

**Objective:** Restore scheduling

### Task

* Remove taint
* Verify pod scheduling resumes

---

## 🔹 LAB 9 — Helm Installation

**Objective:** Package management

### Task

* Install Helm v3
* Add official Helm repo
* Verify chart search works

---

## 🔹 LAB 10 — Helm Chart Deployment

**Objective:** Deploy applications using Helm

### Task

* Install nginx using Helm
* Deploy into namespace `web`

### Verify

```bash
kubectl get pods -n web
```









# LAB 11 — Create and Run a Simple Pod

**Objective (CKA):** Create and configure basic Pods

## Folder

`lab-11/`

## Task (README)

1. Create a Pod named `web-pod` in namespace `wkld`.
2. Image: `nginx:1.25`
3. Container port: `80`
4. Pod must be Running.

## Verify

```bash
kubectl get ns wkld
kubectl -n wkld get pod web-pod -o wide
kubectl -n wkld describe pod web-pod
```

---

# LAB 12 — Multi-Container Pod (Sidecar)

**Objective (CKA):** Create multi-container Pods

## Folder

`lab-12/`

## Files

**lab-12/pod.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo
  namespace: wkld
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","while true; do date >> /var/log/app.log; sleep 2; done"]
    volumeMounts:
    - name: shared
      mountPath: /var/log
  - name: sidecar
    image: busybox:1.36
    command: ["sh","-c","tail -n+1 -F /var/log/app.log"]
    volumeMounts:
    - name: shared
      mountPath: /var/log
  volumes:
  - name: shared
    emptyDir: {}
```

## Task (README)

1. Create namespace `wkld` if not present.
2. Apply the manifest.
3. Confirm both containers run and logs are flowing.

## Verify

```bash
kubectl -n wkld get pod sidecar-demo
kubectl -n wkld get pod sidecar-demo -o jsonpath='{.status.containerStatuses[*].ready}'; echo
kubectl -n wkld logs sidecar-demo -c sidecar --tail=10
```

---

# LAB 13 — Deployment with 3 Replicas

**Objective (CKA):** Deploy and scale applications

## Folder

`lab-13/`

## Files

**lab-13/deploy.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: wkld
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: nginx:1.25
        ports:
        - containerPort: 80
```

## Task

1. Apply the Deployment.
2. Ensure 3 pods are Running and Ready.

## Verify

```bash
kubectl -n wkld get deploy api
kubectl -n wkld get rs -l app=api
kubectl -n wkld get pods -l app=api
```

---

# LAB 14 — Scale Deployment and Confirm Distribution

**Objective (CKA):** Scale workloads

## Folder

`lab-14/`

## Task

1. Scale Deployment `api` to **5 replicas**.
2. Confirm 5 pods exist and are Ready.

## Verify

```bash
kubectl -n wkld scale deploy api --replicas=5
kubectl -n wkld get pods -l app=api -o wide
```

---

# LAB 15 — Broken Rolling Update (ImagePullBackOff)

**Objective (CKA):** Perform rolling updates and rollbacks

## Folder

`lab-15/`

## Files

**lab-15/deploy-broken.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rollout-app
  namespace: wkld
spec:
  replicas: 2
  selector:
    matchLabels:
      app: rollout-app
  template:
    metadata:
      labels:
        app: rollout-app
    spec:
      containers:
      - name: app
        image: nginx:9.99   # intentionally invalid
        ports:
        - containerPort: 80
```

## Task

1. Apply the Deployment.
2. Identify the failure.
3. Fix so both replicas are Running.

## Verify

```bash
kubectl -n wkld get deploy rollout-app
kubectl -n wkld get pods -l app=rollout-app
kubectl -n wkld describe pod -l app=rollout-app
```

---

# LAB 16 — Rollback a Deployment Revision

**Objective (CKA):** Roll back updates

## Folder

`lab-16/`

## Task

1. Update `rollout-app` to a working image.
2. Then update it again to a different valid image tag.
3. Roll back to the previous working revision.

## Verify

```bash
kubectl -n wkld rollout history deploy/rollout-app
kubectl -n wkld rollout status deploy/rollout-app
kubectl -n wkld rollout undo deploy/rollout-app
```

---

# LAB 17 — Probes Misconfigured (Readiness Fails)

**Objective (CKA):** Configure probes

## Folder

`lab-17/`

## Files

**lab-17/probe-broken.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-pod
  namespace: wkld
spec:
  containers:
  - name: web
    image: nginx:1.25
    readinessProbe:
      httpGet:
        path: /healthz   # nginx has no /healthz by default
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3
```

## Task

1. Apply pod.
2. Pod will run but not become Ready.
3. Fix readiness so Ready becomes True.

## Verify

```bash
kubectl -n wkld get pod probe-pod
kubectl -n wkld describe pod probe-pod
```

---

# LAB 18 — Job that Must Complete

**Objective (CKA):** Run Jobs

## Folder

`lab-18/`

## Files

**lab-18/job.yaml**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: calc-job
  namespace: wkld
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: calc
        image: busybox:1.36
        command: ["sh","-c","echo $((7*8)) > /output/result.txt; cat /output/result.txt; sleep 1"]
        volumeMounts:
        - name: out
          mountPath: /output
      volumes:
      - name: out
        emptyDir: {}
  backoffLimit: 1
```

## Task

1. Run the Job.
2. Ensure it reaches **Completed**.
3. Capture the output from logs.

## Verify

```bash
kubectl -n wkld get job calc-job
kubectl -n wkld get pods -l job-name=calc-job
kubectl -n wkld logs -l job-name=calc-job
```

---

# LAB 19 — CronJob Mis-scheduled

**Objective (CKA):** Schedule workloads

## Folder

`lab-19/`

## Files

**lab-19/cron-broken.yaml**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: ping-cron
  namespace: wkld
spec:
  schedule: "*/0 * * * *"   # invalid schedule
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: ping
            image: busybox:1.36
            command: ["sh","-c","date; echo cron-ok"]
```

## Task

1. Apply CronJob.
2. Identify why it never runs.
3. Fix schedule so it runs once per minute.

## Verify

```bash
kubectl -n wkld get cronjob ping-cron
kubectl -n wkld describe cronjob ping-cron
kubectl -n wkld get jobs --watch
```

---

# LAB 20 — Scheduling with Node Selector (Broken)

**Objective (CKA):** Control scheduling

## Folder

`lab-20/`

## Files

**lab-20/pod-selector-broken.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-select
  namespace: wkld
spec:
  nodeSelector:
    disktype: ssd   # label not present initially
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","echo scheduled; sleep 3600"]
```

## Task

1. Apply Pod and observe it stays Pending.
2. Fix scheduling by adjusting node labels and/or pod spec.
3. Pod must become Running.

## Verify

```bash
kubectl -n wkld get pod node-select
kubectl -n wkld describe pod node-select
kubectl get nodes --show-labels
```




















# LAB 21 — ClusterIP Service (Baseline)

**Objective (CKA):** Expose applications internally

## Folder

`lab-21/`

## Files

**lab-21/deploy.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: net
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

**lab-21/svc.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: net
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
```

## Task

1. Create namespace `net`.
2. Deploy application and Service.
3. Confirm Service routes traffic to Pods.

## Verify

```bash
kubectl -n net get svc web-svc
kubectl -n net get endpoints web-svc
```

---

# LAB 22 — Service with No Endpoints (Broken Selector)

**Objective (CKA):** Troubleshoot Services

## Folder

`lab-22/`

## Files

**lab-22/svc-broken.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: broken-svc
  namespace: net
spec:
  selector:
    app: wronglabel
  ports:
  - port: 80
```

## Task

1. Apply Service.
2. Identify why Service has no endpoints.
3. Fix routing so traffic reaches Pods from LAB 21.

## Verify

```bash
kubectl -n net get endpoints broken-svc
kubectl -n net describe svc broken-svc
```

---

# LAB 23 — NodePort Service

**Objective (CKA):** Expose applications externally

## Folder

`lab-23/`

## Files

**lab-23/svc-nodeport.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
  namespace: net
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

## Task

1. Apply Service.
2. Access application from local machine.
3. Confirm traffic reaches Pods.

## Verify

```bash
kubectl -n net get svc web-nodeport
kubectl get nodes -o wide
```

---

# LAB 24 — Headless Service + DNS

**Objective (CKA):** Service discovery

## Folder

`lab-24/`

## Files

**lab-24/svc-headless.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-headless
  namespace: net
spec:
  clusterIP: None
  selector:
    app: web
  ports:
  - port: 80
```

## Task

1. Apply Headless Service.
2. Validate DNS entries per Pod.

## Verify

```bash
kubectl -n net get svc web-headless
kubectl -n net get pods -l app=web
```

---

# LAB 25 — DNS Resolution Test Pod

**Objective (CKA):** Validate CoreDNS

## Folder

`lab-25/`

## Files

**lab-25/dns-test.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
  namespace: net
spec:
  restartPolicy: Never
  containers:
  - name: dns
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
```

## Task

1. Run DNS test pod.
2. Resolve:

   * `web-svc.net`
   * `web-headless.net`

## Verify

```bash
kubectl -n net exec dns-test -- nslookup web-svc.net
kubectl -n net exec dns-test -- nslookup web-headless.net
```

---

# LAB 26 — kube-proxy Inspection

**Objective (CKA):** Understand service routing

## Folder

`lab-26/`

## Task

1. Identify kube-proxy mode (iptables or IPVS).
2. Locate kube-proxy configuration.
3. Inspect logs.

## Verify

```bash
kubectl -n kube-system get pods -l k8s-app=kube-proxy
kubectl -n kube-system logs -l k8s-app=kube-proxy
```

---

# LAB 27 — NetworkPolicy: Deny All Ingress

**Objective (CKA):** Secure network traffic

## Folder

`lab-27/`

## Files

**lab-27/deny-all.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: net
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

## Task

1. Apply policy.
2. Test connectivity to `web` Pods.
3. Observe blocked traffic.

## Verify

```bash
kubectl -n net get networkpolicy
```

---

# LAB 28 — NetworkPolicy: Allow App Traffic

**Objective (CKA):** Selective access

## Folder

`lab-28/`

## Files

**lab-28/allow.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-dns
  namespace: net
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: tester
    ports:
    - protocol: TCP
      port: 80
```

## Task

1. Create test Pod with label `role=tester`.
2. Validate allowed vs denied access.

## Verify

```bash
kubectl -n net get pod -l role=tester
kubectl -n net describe networkpolicy allow-from-dns
```

---

# LAB 29 — Port Forwarding

**Objective (CKA):** Debug services

## Folder

`lab-29/`

## Task

1. Use `kubectl port-forward` to access web app.
2. Validate response locally.

## Verify

```bash
kubectl -n net port-forward svc/web-svc 8080:80
```

---

# LAB 30 — Broken DNS (CoreDNS Misconfig)

**Objective (CKA):** Troubleshoot cluster networking

## Folder

`lab-30/`

## Files

**lab-30/coredns-broken.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        forward . 1.1.1.1
    }
```

## Task

1. Apply ConfigMap.
2. Observe DNS failure.
3. Restore cluster DNS functionality.

## Verify

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n net exec dns-test -- nslookup kubernetes.default
```














# LAB 31 — PersistentVolume (hostPath)

**Objective (CKA):** Configure persistent storage

## Folder

`lab-31/`

## Files

**lab-31/pv.yaml**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv1
  persistentVolumeReclaimPolicy: Retain
```

## Task

1. Create the PV.
2. Verify PV status.

## Verify

```bash
kubectl get pv pv-hostpath
kubectl describe pv pv-hostpath
```

---

# LAB 32 — PersistentVolumeClaim (Bind)

**Objective (CKA):** Claim persistent storage

## Folder

`lab-32/`

## Files

**lab-32/pvc.yaml**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-app
  namespace: store
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

## Task

1. Create namespace `store`.
2. Apply PVC.
3. Ensure it binds to PV from LAB 31.

## Verify

```bash
kubectl -n store get pvc pvc-app
kubectl get pv
```

---

# LAB 33 — Pod Using PVC

**Objective (CKA):** Mount storage into Pods

## Folder

`lab-33/`

## Files

**lab-33/pod.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
  namespace: store
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","echo hello > /data/hello.txt; sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: pvc-app
```

## Task

1. Run Pod.
2. Verify file is written to the volume.

## Verify

```bash
kubectl -n store get pod pvc-pod
kubectl -n store exec pvc-pod -- ls /data
```

---

# LAB 34 — Pod Deletion, Data Persistence

**Objective (CKA):** Understand data persistence

## Folder

`lab-34/`

## Task

1. Delete Pod from LAB 33.
2. Recreate the Pod.
3. Confirm data still exists.

## Verify

```bash
kubectl -n store exec pvc-pod -- cat /data/hello.txt
```

---

# LAB 35 — PVC Pending (Broken)

**Objective (CKA):** Troubleshoot storage

## Folder

`lab-35/`

## Files

**lab-35/pvc-broken.yaml**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-broken
  namespace: store
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 1Gi
```

## Task

1. Apply PVC.
2. Diagnose why it stays Pending.
3. Fix binding.

## Verify

```bash
kubectl -n store get pvc pvc-broken
kubectl describe pvc pvc-broken
```

---

# LAB 36 — StorageClass Creation

**Objective (CKA):** Dynamic provisioning

## Folder

`lab-36/`

## Files

**lab-36/sc.yaml**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

## Task

1. Create StorageClass.
2. Confirm it is available.

## Verify

```bash
kubectl get storageclass
```

---

# LAB 37 — PVC with StorageClass

**Objective (CKA):** Use dynamic volumes

## Folder

`lab-37/`

## Files

**lab-37/pvc-dynamic.yaml**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
  namespace: store
spec:
  storageClassName: local-path
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 512Mi
```

## Task

1. Apply PVC.
2. Ensure dynamic PV is created and bound.

## Verify

```bash
kubectl -n store get pvc pvc-dynamic
kubectl get pv
```

---

# LAB 38 — StatefulSet (Broken DNS)

**Objective (CKA):** Stateful workloads

## Folder

`lab-38/`

## Files

**lab-38/stateful.yaml**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-sts
  namespace: store
spec:
  serviceName: web
  replicas: 2
  selector:
    matchLabels:
      app: web-sts
  template:
    metadata:
      labels:
        app: web-sts
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
```

## Task

1. Apply StatefulSet.
2. Observe Pod behavior and DNS resolution issues.
3. Fix networking so pods have stable DNS.

## Verify

```bash
kubectl -n store get pods
```

---

# LAB 39 — Headless Service for StatefulSet

**Objective (CKA):** Stable identities

## Folder

`lab-39/`

## Files

**lab-39/headless.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: store
spec:
  clusterIP: None
  selector:
    app: web-sts
  ports:
  - port: 80
```

## Task

1. Apply Service.
2. Validate DNS names for StatefulSet pods.

## Verify

```bash
kubectl -n store get svc web
kubectl -n store exec web-sts-0 -- hostname
```

---

# LAB 40 — Ordered Pod Startup & Termination

**Objective (CKA):** StatefulSet guarantees

## Folder

`lab-40/`

## Task

1. Scale StatefulSet up and down.
2. Observe startup and shutdown order.
3. Validate ordinal guarantees.

## Verify

```bash
kubectl -n store scale sts web-sts --replicas=3
kubectl -n store scale sts web-sts --replicas=1
kubectl -n store get pods -w
```




















# LAB 41 — Ingress Resource WITHOUT Controller (Broken)

**Objective (CKA):** Understand Ingress requirements

## Folder

`lab-41/`

## Files

**lab-41/ingress.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: net
spec:
  rules:
  - host: web.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

## Task

1. Apply the Ingress.
2. Observe behavior.
3. Determine why traffic does not work.

## Verify

```bash
kubectl -n net get ingress web-ingress
kubectl -n net describe ingress web-ingress
```

---

# LAB 42 — Install Ingress Controller

**Objective (CKA):** Expose applications via Ingress

## Folder

`lab-42/`

## Files

**lab-42/controller.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingress-nginx
  template:
    metadata:
      labels:
        app: ingress-nginx
    spec:
      containers:
      - name: controller
        image: registry.k8s.io/ingress-nginx/controller:v1.10.1
        args:
        - /nginx-ingress-controller
```

## Task

1. Create namespace `ingress-nginx`.
2. Deploy controller.
3. Validate controller pod is running.

## Verify

```bash
kubectl -n ingress-nginx get pods
```

---

# LAB 43 — IngressClass Misconfiguration

**Objective (CKA):** Ingress routing control

## Folder

`lab-43/`

## Files

**lab-43/ingress-broken.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress-class
  namespace: net
spec:
  ingressClassName: wrong-class
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

## Task

1. Apply Ingress.
2. Identify why traffic is not routed.
3. Fix class configuration.

## Verify

```bash
kubectl -n net describe ingress web-ingress-class
```

---

# LAB 44 — Path-Based Routing

**Objective (CKA):** Advanced Ingress rules

## Folder

`lab-44/`

## Files

**lab-44/ingress-paths.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-ingress
  namespace: net
spec:
  rules:
  - http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: web-nodeport
            port:
              number: 80
```

## Task

1. Apply Ingress.
2. Validate both paths route correctly.

## Verify

```bash
kubectl -n net get ingress path-ingress
```

---

# LAB 45 — TLS Ingress (Broken Secret)

**Objective (CKA):** Secure networking

## Folder

`lab-45/`

## Files

**lab-45/ingress-tls.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  namespace: net
spec:
  tls:
  - hosts:
    - secure.local
    secretName: tls-secret
  rules:
  - host: secure.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

## Task

1. Apply Ingress.
2. Diagnose TLS failure.
3. Restore secure access.

## Verify

```bash
kubectl -n net describe ingress tls-ingress
```

---

# LAB 46 — ExternalName Service

**Objective (CKA):** Service types

## Folder

`lab-46/`

## Files

**lab-46/external.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-google
  namespace: net
spec:
  type: ExternalName
  externalName: google.com
```

## Task

1. Apply Service.
2. Resolve DNS from inside cluster.

## Verify

```bash
kubectl -n net exec dns-test -- nslookup external-google.net
```

---

# LAB 47 — Service Session Affinity

**Objective (CKA):** Traffic behavior

## Folder

`lab-47/`

## Files

**lab-47/svc-affinity.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-affinity
  namespace: net
spec:
  selector:
    app: web
  sessionAffinity: ClientIP
  ports:
  - port: 80
```

## Task

1. Apply Service.
2. Observe client-to-pod stickiness.

## Verify

```bash
kubectl -n net describe svc web-affinity
```

---

# LAB 48 — Service with Multiple Ports

**Objective (CKA):** Multi-port Services

## Folder

`lab-48/`

## Files

**lab-48/svc-multiport.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-svc
  namespace: net
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: metrics
    port: 9113
    targetPort: 9113
```

## Task

1. Apply Service.
2. Inspect endpoints and ports.

## Verify

```bash
kubectl -n net get svc multi-svc
kubectl -n net describe svc multi-svc
```

---

# LAB 49 — NetworkPolicy Egress Block

**Objective (CKA):** Secure outbound traffic

## Folder

`lab-49/`

## Files

**lab-49/egress-deny.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-egress
  namespace: net
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

## Task

1. Apply policy.
2. Observe outbound traffic failure.
3. Restore required access.

## Verify

```bash
kubectl -n net get networkpolicy
```

---

# LAB 50 — End-to-End Networking Failure

**Objective (CKA):** Diagnose complex networking issues

## Folder

`lab-50/`

## Task

A deployed application is unreachable.

Student must:

1. Inspect Pods
2. Inspect Service
3. Inspect Endpoints
4. Inspect NetworkPolicies
5. Restore full connectivity

## Verify

```bash
kubectl -n net get pods
kubectl -n net get svc
kubectl -n net get endpoints
kubectl -n net get networkpolicy
```



















# LAB 51 — Resource Requests Cause Pending Pod

**Objective (CKA):** Resource management & scheduling

## Folder

`lab-51/`

## Files

**lab-51/pod-high-requests.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: heavy-pod
  namespace: sched
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
    resources:
      requests:
        cpu: "4000m"
        memory: "8Gi"
```

## Task

1. Create namespace `sched`.
2. Apply Pod.
3. Diagnose why it stays Pending.
4. Restore schedulability.

## Verify

```bash
kubectl -n sched get pod heavy-pod
kubectl -n sched describe pod heavy-pod
kubectl describe node
```

---

# LAB 52 — Limits vs Requests (Container Killed)

**Objective (CKA):** Resource limits behavior

## Folder

`lab-52/`

## Files

**lab-52/pod-oom.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: oom-pod
  namespace: sched
spec:
  containers:
  - name: stress
    image: polinux/stress
    args: ["--vm","1","--vm-bytes","512M","--vm-hang","1"]
    resources:
      limits:
        memory: "128Mi"
```

## Task

1. Apply Pod.
2. Observe container behavior.
3. Fix so Pod remains Running.

## Verify

```bash
kubectl -n sched get pod oom-pod
kubectl -n sched describe pod oom-pod
kubectl -n sched logs oom-pod
```

---

# LAB 53 — LimitRange Enforced

**Objective (CKA):** Namespace resource governance

## Folder

`lab-53/`

## Files

**lab-53/limitrange.yaml**

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit
  namespace: sched
spec:
  limits:
  - default:
      memory: 256Mi
    defaultRequest:
      memory: 128Mi
    type: Container
```

## Task

1. Apply LimitRange.
2. Create a Pod without specifying resources.
3. Inspect applied defaults.

## Verify

```bash
kubectl -n sched describe limitrange mem-limit
kubectl -n sched describe pod
```

---

# LAB 54 — Node Affinity Mismatch

**Objective (CKA):** Node affinity scheduling

## Folder

`lab-54/`

## Files

**lab-54/pod-affinity.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
  namespace: sched
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values:
            - ssd
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
```

## Task

1. Apply Pod.
2. Diagnose Pending state.
3. Fix node affinity or labels.

## Verify

```bash
kubectl -n sched get pod affinity-pod
kubectl -n sched describe pod affinity-pod
kubectl get nodes --show-labels
```

---

# LAB 55 — Pod Anti-Affinity (Unbalanced)

**Objective (CKA):** Pod placement control

## Folder

`lab-55/`

## Files

**lab-55/deploy-antiaff.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: anti
  namespace: sched
spec:
  replicas: 3
  selector:
    matchLabels:
      app: anti
  template:
    metadata:
      labels:
        app: anti
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: anti
            topologyKey: kubernetes.io/hostname
      containers:
      - name: app
        image: nginx:1.25
```

## Task

1. Apply Deployment.
2. Observe scheduling behavior.
3. Adjust cluster or workload so all replicas run.

## Verify

```bash
kubectl -n sched get pods -o wide
```

---

# LAB 56 — Taints Prevent Scheduling

**Objective (CKA):** Taints & tolerations

## Folder

`lab-56/`

## Task

1. Taint a worker node with `NoSchedule`.
2. Deploy a Pod without toleration.
3. Observe Pending state.
4. Restore scheduling.

## Verify

```bash
kubectl describe node
kubectl -n sched get pod
kubectl -n sched describe pod
```

---

# LAB 57 — Tolerations Allow Scheduling

**Objective (CKA):** Override taints

## Folder

`lab-57/`

## Files

**lab-57/pod-tolerate.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-pod
  namespace: sched
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "test"
    effect: "NoSchedule"
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
```

## Task

1. Apply Pod.
2. Confirm it schedules onto tainted node.

## Verify

```bash
kubectl -n sched get pod tolerate-pod -o wide
```

---

# LAB 58 — HPA Without Metrics Server (Broken)

**Objective (CKA):** Horizontal Pod Autoscaling

## Folder

`lab-58/`

## Files

**lab-58/hpa.yaml**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  namespace: sched
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

## Task

1. Apply HPA.
2. Observe errors.
3. Restore autoscaling functionality.

## Verify

```bash
kubectl -n sched get hpa web-hpa
kubectl -n sched describe hpa web-hpa
```

---

# LAB 59 — HPA Scales Incorrectly

**Objective (CKA):** Diagnose autoscaling behavior

## Folder

`lab-59/`

## Task

1. Generate load on Deployment.
2. Observe scaling behavior.
3. Correct scaling logic.

## Verify

```bash
kubectl -n sched get deploy
kubectl -n sched get hpa
```

---

# LAB 60 — PriorityClass Preemption

**Objective (CKA):** Pod priority and preemption

## Folder

`lab-60/`

## Files

**lab-60/priority.yaml**

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "Critical workloads"
```

**lab-60/pod-priority.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-pod
  namespace: sched
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
```

## Task

1. Apply PriorityClass.
2. Deploy critical Pod.
3. Observe preemption behavior.

## Verify

```bash
kubectl -n sched get pod critical-pod
kubectl describe pod critical-pod
```














# LAB 61 — ServiceAccount Used by Pod (Broken Access)

**Objective (CKA):** Authentication with ServiceAccounts

## Folder

`lab-61/`

## Files

**lab-61/pod-sa.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
  namespace: sec
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
```

## Task

1. Create namespace `sec`.
2. Apply Pod.
3. Diagnose why Pod cannot start.
4. Restore correct authentication.

## Verify

```bash
kubectl -n sec get pod sa-pod
kubectl -n sec describe pod sa-pod
```

---

# LAB 62 — Role Allows Read-Only Pods

**Objective (CKA):** Namespace RBAC

## Folder

`lab-62/`

## Files

**lab-62/role.yaml**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: sec
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]
```

## Task

1. Apply Role.
2. Bind Role to ServiceAccount.
3. Test list vs get permissions.

## Verify

```bash
kubectl auth can-i list pods --as system:serviceaccount:sec:app-sa -n sec
kubectl auth can-i get pods --as system:serviceaccount:sec:app-sa -n sec
```

---

# LAB 63 — RoleBinding Missing Subject (Broken)

**Objective (CKA):** Troubleshoot RBAC

## Folder

`lab-63/`

## Files

**lab-63/rolebinding-broken.yaml**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-bind
  namespace: sec
subjects: []
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
```

## Task

1. Apply RoleBinding.
2. Observe authorization failure.
3. Fix binding so permissions apply.

## Verify

```bash
kubectl auth can-i get pods --as system:serviceaccount:sec:app-sa -n sec
```

---

# LAB 64 — ClusterRole Read Nodes

**Objective (CKA):** Cluster-wide RBAC

## Folder

`lab-64/`

## Files

**lab-64/clusterrole.yaml**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get","list"]
```

## Task

1. Apply ClusterRole.
2. Bind to ServiceAccount.
3. Validate node visibility.

## Verify

```bash
kubectl auth can-i get nodes --as system:serviceaccount:sec:app-sa
```

---

# LAB 65 — Forbidden Error Diagnosis

**Objective (CKA):** AuthZ troubleshooting

## Folder

`lab-65/`

## Task

1. Attempt to delete a Pod as ServiceAccount.
2. Capture forbidden error.
3. Adjust permissions to allow delete.

## Verify

```bash
kubectl auth can-i delete pods --as system:serviceaccount:sec:app-sa -n sec
```

---

# LAB 66 — Kubeconfig Context Misuse

**Objective (CKA):** kubeconfig usage

## Folder

`lab-66/`

## Task

1. Create a new kubeconfig context.
2. Switch context incorrectly.
3. Diagnose unexpected authorization errors.
4. Restore correct context.

## Verify

```bash
kubectl config get-contexts
kubectl config current-context
```

---

# LAB 67 — Certificate Authentication Failure

**Objective (CKA):** Authentication troubleshooting

## Folder

`lab-67/`

## Task

1. Use an invalid client certificate in kubeconfig.
2. Observe authentication failure.
3. Restore valid authentication.

## Verify

```bash
kubectl get nodes
```

---

# LAB 68 — API Access Denied (ClusterRoleBinding Missing)

**Objective (CKA):** Cluster RBAC diagnosis

## Folder

`lab-68/`

## Task

1. Attempt cluster-wide access.
2. Observe denial.
3. Restore access using ClusterRoleBinding.

## Verify

```bash
kubectl auth can-i list pods --all-namespaces --as system:serviceaccount:sec:app-sa
```

---

# LAB 69 — ServiceAccount Token Inspection

**Objective (CKA):** Understand authentication mechanics

## Folder

`lab-69/`

## Task

1. Inspect ServiceAccount secrets.
2. Identify token used by Pods.
3. Validate mounted credentials.

## Verify

```bash
kubectl -n sec get sa app-sa -o yaml
kubectl -n sec get secret
```

---

# LAB 70 — Security Context Misconfiguration

**Objective (CKA):** Pod security settings

## Folder

`lab-70/`

## Files

**lab-70/pod-secctx.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: sec
spec:
  securityContext:
    runAsUser: 0
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","id; sleep 3600"]
```

## Task

1. Apply Pod.
2. Identify security risk.
3. Adjust security context to meet best practices.

## Verify

```bash
kubectl -n sec get pod secure-pod
kubectl -n sec exec secure-pod -- id
```















# LAB 71 — Pod Stuck in Pending (No Nodes Available)

**Objective (CKA):** Troubleshoot scheduling failures

## Folder

`lab-71/`

## Task

1. Make all worker nodes unschedulable.
2. Deploy a Pod in namespace `trbl`.
3. Observe Pod remains Pending.
4. Restore scheduling so Pod runs.

## Verify

```bash
kubectl -n trbl get pod
kubectl -n trbl describe pod
kubectl get nodes
```

---

# LAB 72 — Node NotReady (kubelet stopped)

**Objective (CKA):** Node failure diagnosis

## Folder

`lab-72/`

## Task

1. Stop kubelet on one worker node (inside kind container).
2. Observe node transitions to NotReady.
3. Identify root cause.
4. Restore node to Ready.

## Verify

```bash
kubectl get nodes
kubectl describe node
```

---

# LAB 73 — Pods Evicted Due to Disk Pressure

**Objective (CKA):** Node conditions & eviction

## Folder

`lab-73/`

## Task

1. Simulate disk pressure on a node.
2. Observe Pod eviction events.
3. Identify affected Pods.
4. Restore node health.

## Verify

```bash
kubectl get pods -A
kubectl describe node
kubectl get events -A
```

---

# LAB 74 — CrashLoopBackOff Investigation

**Objective (CKA):** Application troubleshooting

## Folder

`lab-74/`

## Files

**lab-74/pod-crash.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: crash-pod
  namespace: trbl
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","exit 1"]
```

## Task

1. Apply Pod.
2. Diagnose CrashLoopBackOff.
3. Restore Pod stability.

## Verify

```bash
kubectl -n trbl get pod crash-pod
kubectl -n trbl describe pod crash-pod
kubectl -n trbl logs crash-pod
```

---

# LAB 75 — Service Unreachable (Wrong TargetPort)

**Objective (CKA):** Service troubleshooting

## Folder

`lab-75/`

## Files

**lab-75/svc-broken.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-svc
  namespace: trbl
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080   # container listens on 80
```

## Task

1. Deploy Service.
2. Test connectivity.
3. Identify misconfiguration.
4. Restore traffic flow.

## Verify

```bash
kubectl -n trbl get svc api-svc
kubectl -n trbl get endpoints api-svc
```

---

# LAB 76 — Deployment Never Becomes Ready

**Objective (CKA):** Readiness probe troubleshooting

## Folder

`lab-76/`

## Files

**lab-76/deploy-notready.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notready
  namespace: trbl
spec:
  replicas: 2
  selector:
    matchLabels:
      app: notready
  template:
    metadata:
      labels:
        app: notready
    spec:
      containers:
      - name: app
        image: nginx:1.25
        readinessProbe:
          httpGet:
            path: /health
            port: 80
```

## Task

1. Apply Deployment.
2. Observe Ready status never becomes True.
3. Fix readiness behavior.

## Verify

```bash
kubectl -n trbl get deploy notready
kubectl -n trbl describe pod -l app=notready
```

---

# LAB 77 — DNS Resolution Failure

**Objective (CKA):** CoreDNS troubleshooting

## Folder

`lab-77/`

## Task

1. Break CoreDNS configuration.
2. Observe DNS failures in cluster.
3. Identify error source.
4. Restore DNS resolution.

## Verify

```bash
kubectl -n kube-system get pods
kubectl -n trbl exec dns-test -- nslookup kubernetes.default
```

---

# LAB 78 — PersistentVolume Mount Failure

**Objective (CKA):** Storage troubleshooting

## Folder

`lab-78/`

## Files

**lab-78/pod-mount-broken.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mount-fail
  namespace: trbl
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","sleep 3600"]
    volumeMounts:
    - mountPath: /data
      name: data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: missing-pvc
```

## Task

1. Apply Pod.
2. Diagnose why Pod does not start.
3. Restore successful volume mount.

## Verify

```bash
kubectl -n trbl get pod mount-fail
kubectl -n trbl describe pod mount-fail
```

---

# LAB 79 — Helm Release Fails

**Objective (CKA):** Troubleshoot Helm deployments

## Folder

`lab-79/`

## Task

1. Install a Helm chart with invalid values.
2. Observe release failure.
3. Identify misconfiguration.
4. Restore healthy release.

## Verify

```bash
helm list -A
helm status <release-name>
kubectl get pods -A
```

---

# LAB 80 — Multiple Failures (Cluster Triage)

**Objective (CKA):** Real exam-style troubleshooting

## Folder

`lab-80/`

## Task

Cluster exhibits:

* Pods Pending
* Service unreachable
* One node NotReady

Student must:

1. Identify **all** failures.
2. Fix in correct order.
3. Restore full cluster functionality.

## Verify

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
```













# LAB 81 — ConfigMap Used by Pod (Broken Key)

**Objective (CKA):** Configure applications with ConfigMaps

## Folder

`lab-81/`

## Files

**lab-81/configmap.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: cfg
data:
  APP_PORT: "8080"
```

**lab-81/pod.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cfg-pod
  namespace: cfg
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","echo $PORT; sleep 3600"]
    env:
    - name: PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: PORT   # wrong key
```

## Task

1. Create namespace `cfg`.
2. Apply ConfigMap and Pod.
3. Diagnose why env var is empty.
4. Restore correct configuration.

## Verify

```bash
kubectl -n cfg get pod cfg-pod
kubectl -n cfg describe pod cfg-pod
kubectl -n cfg exec cfg-pod -- env
```

---

# LAB 82 — Secret Misused as ConfigMap

**Objective (CKA):** Configure Secrets

## Folder

`lab-82/`

## Files

**lab-82/secret.yaml**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: cfg
type: Opaque
data:
  password: cGFzc3dvcmQ=   # "password"
```

**lab-82/pod.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: cfg
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","echo $PASSWORD; sleep 3600"]
    env:
    - name: PASSWORD
      valueFrom:
        configMapKeyRef:
          name: app-secret
          key: password
```

## Task

1. Apply Secret and Pod.
2. Diagnose configuration error.
3. Restore correct secret usage.

## Verify

```bash
kubectl -n cfg get pod secret-pod
kubectl -n cfg describe pod secret-pod
```

---

# LAB 83 — Secret Volume Mount (Wrong Path)

**Objective (CKA):** Mount Secrets

## Folder

`lab-83/`

## Files

**lab-83/pod-secret-vol.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-vol
  namespace: cfg
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh","-c","cat /secrets/password; sleep 3600"]
    volumeMounts:
    - name: sec
      mountPath: /secret   # wrong path
  volumes:
  - name: sec
    secret:
      secretName: app-secret
```

## Task

1. Apply Pod.
2. Diagnose mount issue.
3. Restore correct secret access.

## Verify

```bash
kubectl -n cfg get pod secret-vol
kubectl -n cfg logs secret-vol
```

---

# LAB 84 — Helm Chart Values Override (Broken)

**Objective (CKA):** Helm configuration

## Folder

`lab-84/`

## Files

**lab-84/values.yaml**

```yaml
image:
  repository: nginx
  tag: doesnotexist
```

## Task

1. Install a Helm chart using these values.
2. Observe failure.
3. Fix deployment using Helm values override.

## Verify

```bash
helm list -A
helm status <release>
kubectl get pods -A
```

---

# LAB 85 — Helm Rollback After Bad Upgrade

**Objective (CKA):** Helm lifecycle management

## Folder

`lab-85/`

## Task

1. Perform a Helm upgrade with bad values.
2. Observe degraded release.
3. Roll back to last working revision.

## Verify

```bash
helm history <release>
helm rollback <release>
```

---

# LAB 86 — Helm Template Debugging

**Objective (CKA):** Helm rendering

## Folder

`lab-86/`

## Task

1. Render Helm templates locally.
2. Identify invalid Kubernetes objects.
3. Fix values so manifests are valid.

## Verify

```bash
helm template <release> .
```

---

# LAB 87 — ConfigMap Reload Failure

**Objective (CKA):** Application config updates

## Folder

`lab-87/`

## Task

1. Update ConfigMap value.
2. Observe app does not reload config.
3. Restore behavior without deleting Deployment.

## Verify

```bash
kubectl -n cfg get cm
kubectl -n cfg get pods
```

---

# LAB 88 — Pod Logs Missing

**Objective (CKA):** Logging troubleshooting

## Folder

`lab-88/`

## Task

1. Attempt to fetch logs from terminated container.
2. Observe error.
3. Restore access to logs.

## Verify

```bash
kubectl -n trbl logs <pod>
kubectl -n trbl describe pod <pod>
```

---

# LAB 89 — Debug with Ephemeral Container

**Objective (CKA):** Advanced debugging

## Folder

`lab-89/`

## Task

1. Add ephemeral container to a running Pod.
2. Inspect filesystem and processes.
3. Capture diagnostic output.

## Verify

```bash
kubectl debug <pod> -it --image=busybox
```

---

# LAB 90 — Multi-Resource Failure (Helm + Config)

**Objective (CKA):** Real exam-style debugging

## Folder

`lab-90/`

## Task

Application is broken due to:

* Wrong ConfigMap
* Bad Helm values
* Restart loop

Student must:

1. Identify all failures.
2. Restore application health.

## Verify

```bash
helm status <release>
kubectl get pods
kubectl describe pod
```








# LAB 91 — etcd Data Inspection (Read-Only)

**Objective (CKA):** Understand cluster state storage

## Folder

`lab-91/`

## Task

1. Locate etcd running in the cluster.
2. Identify where etcd stores cluster data.
3. Inspect etcd pod/container configuration.

## Verify

```bash
kubectl -n kube-system get pods | grep etcd
kubectl -n kube-system describe pod etcd-*
```

---

# LAB 92 — etcd Backup (Snapshot)

**Objective (CKA):** Backup cluster state

## Folder

`lab-92/`

## Task

1. Create an etcd snapshot file.
2. Store snapshot locally on the control plane node.
3. Verify snapshot integrity.

## Verify

```bash
ls -lh *.db
```

---

# LAB 93 — etcd Restore (Broken Cluster)

**Objective (CKA):** Restore cluster state

## Folder

`lab-93/`

## Task

1. Delete a critical namespace and its resources.
2. Restore cluster state from snapshot.
3. Confirm deleted resources are recovered.

## Verify

```bash
kubectl get ns
kubectl get pods -A
```

---

# LAB 94 — API Server Misconfiguration

**Objective (CKA):** Control-plane troubleshooting

## Folder

`lab-94/`

## Task

1. Modify kube-apiserver manifest with an invalid flag.
2. Observe API server failure.
3. Restore API server functionality.

## Verify

```bash
kubectl get nodes
kubectl -n kube-system get pods
```

---

# LAB 95 — Scheduler Failure

**Objective (CKA):** Scheduler troubleshooting

## Folder

`lab-95/`

## Task

1. Stop kube-scheduler.
2. Deploy a new Pod.
3. Observe scheduling behavior.
4. Restore scheduler and confirm Pod schedules.

## Verify

```bash
kubectl get pods -A
kubectl describe pod
```

---

# LAB 96 — Controller Manager Failure

**Objective (CKA):** Core component recovery

## Folder

`lab-96/`

## Task

1. Stop kube-controller-manager.
2. Scale a Deployment.
3. Observe lack of reconciliation.
4. Restore controller manager.

## Verify

```bash
kubectl get deploy
kubectl get pods
```

---

# LAB 97 — Certificate Expiration Simulation

**Objective (CKA):** Security & maintenance

## Folder

`lab-97/`

## Task

1. Simulate expired client or server certificate.
2. Observe authentication failures.
3. Renew certificates and restore access.

## Verify

```bash
kubectl get nodes
```

---

# LAB 98 — Node Removal & Rejoin

**Objective (CKA):** Node lifecycle management

## Folder

`lab-98/`

## Task

1. Remove a worker node from the cluster.
2. Verify workloads reschedule.
3. Rejoin node to the cluster.
4. Confirm Ready status.

## Verify

```bash
kubectl get nodes
kubectl get pods -o wide
```

---

# LAB 99 — Full Cluster Health Audit

**Objective (CKA):** Production readiness validation

## Folder

`lab-99/`

## Task

Student must audit:

* Nodes
* Pods
* Services
* Networking
* Storage
* RBAC

Cluster must end in **healthy state**.

## Verify

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get pvc -A
kubectl auth can-i --list
```

---

# LAB 100 — FINAL MOCK CKA EXAM (2 HOURS)

**Objective (CKA):** Full exam simulation

## Folder

`lab-100/`

## Scenario

Cluster has **multiple simultaneous failures**:

* One node NotReady
* Pods Pending
* One Deployment CrashLoopBackOff
* Service unreachable
* Broken NetworkPolicy
* Failed Helm release
* Missing ConfigMap
* PVC Pending
* RBAC denial

## Task

Within **2 hours**, student must:

1. Identify all failures.
2. Fix in correct order.
3. Restore full cluster functionality.

## Verify (FINAL STATE)

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get pvc -A
helm list -A
```


