---
title: "project: deployment strategy types in k8s"
description: "Common commands (use for every strategy)      kubectl get deploy,pods,rs,svc kubectl rollout..."
published: 2026-01-05
source: "https://dev.to/jumptotech/project-deployment-strategy-types-in-k8s-1n90"
tags: []
---

# project: deployment strategy types in k8s



## Common commands (use for every strategy)

```bash
kubectl get deploy,pods,rs,svc
kubectl rollout status deploy/<name>
kubectl rollout history deploy/<name>
kubectl describe pod <pod>
kubectl logs <pod>
kubectl get events --sort-by=.lastTimestamp | tail -30
```

If you need a quick request loop to see behavior:

```bash
URL="<your service url>"
while true; do curl -s --max-time 1 "$URL" || echo "DOWN"; echo; sleep 0.3; done
```

---

# 1) RollingUpdate (most used)

## Why it’s used most

* It is the **default** Kubernetes Deployment behavior.
* It provides **continuous availability** when configured correctly.
* It’s simple to operate (built-in rollback/history).

## Behavior

* Old and new Pods exist at the same time.
* Replacement happens in steps controlled by:

  * `maxSurge` (extra Pods allowed above desired replicas)
  * `maxUnavailable` (Pods allowed to be unavailable during rollout)
* If readiness is correct, traffic only goes to ready Pods.

##  (Deployment + Service)

`rolling.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: rolling}
spec:
  replicas: 3
  selector: {matchLabels: {app: rolling}}
  strategy:
    type: RollingUpdate
    rollingUpdate: {maxSurge: 1, maxUnavailable: 1}
  template:
    metadata: {labels: {app: rolling}}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:5678","-text=ROLLING v1"]
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: rolling-svc}
spec:
  selector: {app: rolling}
  ports: [{port: 80, targetPort: 5678}]
  type: NodePort
```

## How to use (demo flow)

```bash
kubectl apply -f rolling.yaml
kubectl get pods -w
kubectl rollout status deploy/rolling
```

Get URL:

```bash
minikube service rolling-svc --url
```

Update “version” (triggers rollout):

```bash
kubectl patch deploy rolling --type='json' -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/args/1","value":"-text=ROLLING v2"}
]'
kubectl rollout status deploy/rolling
```

## Troubleshooting (production style)

**Symptom: rollout stuck / never completes**

1. Check rollout:

```bash
kubectl rollout status deploy/rolling
kubectl get rs
kubectl get pods
```

2. Find failing Pod and inspect:

```bash
kubectl describe pod <new-pod>
kubectl logs <new-pod>
kubectl get events --sort-by=.lastTimestamp | tail -30
```

Common causes:

* Image pull error (`ErrImagePull`, `ImagePullBackOff`)
* App crashes (`CrashLoopBackOff`)
* Readiness would fail (in real apps); traffic may route to bad pods if probes missing

**Fast rollback**

```bash
kubectl rollout undo deploy/rolling
kubectl rollout status deploy/rolling
```

**Operational note**
In production you nearly always add readiness checks, but they are omitted here to keep YAML minimal.

---

# 2) Recreate (rarely used)

## Why it’s rarely used

* It introduces **downtime**: old Pods stop before new ones are ready.
* Most services can’t tolerate that, so it’s avoided.

## When it’s used

* Workloads that **cannot run two versions simultaneously** (hard constraints).
* Maintenance-window deployments.
* Certain stateful/legacy patterns (still better handled with careful rolling + app-level compatibility when possible).

## Behavior

* All old Pods terminate first.
* Then new Pods start.
* A period of “no endpoints” is expected.

## 

`recreate.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: recreate}
spec:
  replicas: 3
  strategy: {type: Recreate}
  selector: {matchLabels: {app: recreate}}
  template:
    metadata: {labels: {app: recreate}}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:5678","-text=RECREATE v1"]
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: recreate-svc}
spec:
  selector: {app: recreate}
  ports: [{port: 80, targetPort: 5678}]
  type: NodePort
```

## How to use

```bash
kubectl apply -f recreate.yaml
URL=$(minikube service recreate-svc --url)
```

Trigger change:

```bash
kubectl patch deploy recreate --type='json' -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/args/1","value":"-text=RECREATE v2"}
]'
```

## Troubleshooting

**Symptom: brief outage during deploy**

* That’s the expected behavior. The correct response is strategy choice + maintenance window + comms.

**Symptom: service never returns**

* Same checks as rolling:

```bash
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
kubectl get events --sort-by=.lastTimestamp | tail -30
```

---

# 3) Blue–Green (common for critical releases)

## Why it’s used

* **Very safe cutover**: new environment runs fully before traffic switch.
* **Instant rollback**: switch traffic back immediately.
* Great when you need deterministic release control.

## Tradeoffs

* You run two environments (cost/capacity).
* You must manage data migrations carefully; schema changes can still be risky.

## Behavior

* Both “blue” and “green” run side-by-side.
* A Service points to one of them.
* Switching the Service selector flips traffic immediately.

## Smallest YAML (blue+green+svc)

`blue-green.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: blue}
spec:
  replicas: 2
  selector: {matchLabels: {app: bg, color: blue}}
  template:
    metadata: {labels: {app: bg, color: blue}}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:5678","-text=BLUE v1"]
        ports: [{containerPort: 5678}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: green}
spec:
  replicas: 2
  selector: {matchLabels: {app: bg, color: green}}
  template:
    metadata: {labels: {app: bg, color: green}}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:5678","-text=GREEN v2"]
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: bg-svc}
spec:
  selector: {app: bg, color: blue}
  ports: [{port: 80, targetPort: 5678}]
  type: NodePort
```

## How to use

```bash
kubectl apply -f blue-green.yaml
URL=$(minikube service bg-svc --url)
curl -s $URL && echo
```

Switch to green:

```bash
kubectl patch svc bg-svc -p '{"spec":{"selector":{"app":"bg","color":"green"}}}'
curl -s $URL && echo
```

Rollback to blue:

```bash
kubectl patch svc bg-svc -p '{"spec":{"selector":{"app":"bg","color":"blue"}}}'
```

## Troubleshooting

**Symptom: after switch you still hit old version**

1. Check Service selector and endpoints:

```bash
kubectl get svc bg-svc -o yaml | sed -n '1,80p'
kubectl get endpoints bg-svc -o wide
```

2. Verify labels match:

```bash
kubectl get pods --show-labels | grep bg
```

Most common root cause:

* selector typo or missing label

**Symptom: green is unhealthy**

* Validate green before switch:

```bash
kubectl rollout status deploy/green
kubectl logs deploy/green
```

Operational best practice:

* Run smoke checks on green (health endpoint, critical flows) before switching.

---

# 4) Canary (highly used in mature production setups)

## Why it’s used

* Reduces blast radius: a small portion of traffic sees the new version first.
* Lets you validate with real traffic + monitoring before full rollout.

## Tradeoffs

* Requires **observability** (metrics/alerts) and clear abort criteria.
* True weighted traffic splitting is usually done via ingress/service mesh; here we demonstrate the core idea with replicas.

## Behavior

* Stable and canary versions run simultaneously.
* Traffic is distributed roughly proportional to replica counts (not precise, but effective for demonstration).

## 

`canary.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: stable}
spec:
  replicas: 3
  selector: {matchLabels: {app: canary, track: stable}}
  template:
    metadata: {labels: {app: canary, track: stable}}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:5678","-text=STABLE v1"]
        ports: [{containerPort: 5678}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: canary}
spec:
  replicas: 1
  selector: {matchLabels: {app: canary, track: canary}}
  template:
    metadata: {labels: {app: canary, track: canary}}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:5678","-text=CANARY v2"]
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: canary-svc}
spec:
  selector: {app: canary}
  ports: [{port: 80, targetPort: 5678}]
  type: NodePort
```

## How to use

```bash
kubectl apply -f canary.yaml
URL=$(minikube service canary-svc --url)
for i in {1..25}; do curl -s $URL; echo; done
```

Promote (increase canary):

```bash
kubectl scale deploy/canary --replicas=2
```

Abort (remove canary immediately):

```bash
kubectl scale deploy/canary --replicas=0
```

## Troubleshooting

**Symptom: canary never receives traffic**

* Service selector not matching both sets:

```bash
kubectl get svc canary-svc -o yaml | grep -A3 selector
kubectl get pods --show-labels | grep canary
```

**Symptom: canary causing errors**

* Immediate mitigation is scaling canary to 0 while investigating:

```bash
kubectl scale deploy/canary --replicas=0
kubectl logs deploy/canary
kubectl describe pod <canary-pod>
```

Operational best practice:

* Define SLO-based abort rules (error rate, latency, saturation) and automate promotion/abort (Argo Rollouts/Flagger).

---

# 5) A/B (specialized; product-driven)

## Why it’s not “default”

* It’s primarily for experimentation (feature comparison), not just safe rollout.
* Requires request-based routing (headers/cookies/users).
* DevOps provides the routing/infra and guardrails.

## Behavior

* Specific requests go to version B, others to version A.
* Commonly implemented via Ingress/service mesh.

## Minimal A/B in pure Kubernetes (no ingress) isn’t truly possible

Without ingress/mesh you can’t route by headers; you can only do replica-based canary. In production, A/B is usually NGINX Ingress / Istio / Linkerd.

If you want the **smallest A/B that is real**, it needs ingress + annotations. I can give that minimal manifest as a separate block (it will still be longer than others because routing rules require extra objects).

---

# Summary: what is used more vs rarely (and why)

* **Most used:** RollingUpdate
  Default, reliable, simplest operationally.

* **Highly used in mature orgs:** Canary
  Lower risk, progressive delivery, relies on monitoring.

* **Common for high-stakes releases:** Blue–Green
  Deterministic cutover + instant rollback, higher cost.

* **Rare:** Recreate
  Downtime; only used when two versions cannot coexist or downtime is acceptable.


