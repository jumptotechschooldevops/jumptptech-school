---
title: "How ArgoCD Deploys Dev Staging Prod in Real Companies"
description: "🔹 What Is argocd Namespace For?   When you installed ArgoCD, you  did:    kubectl create..."
published: 2026-02-17
source: "https://dev.to/jumptotech/how-argocd-deploys-dev-staging-prod-in-real-companies-2hf0"
tags: []
---

# How ArgoCD Deploys Dev Staging Prod in Real Companies






# 🔹 What Is `argocd` Namespace For?

When you installed ArgoCD, you  did:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f install.yaml
```

That namespace is ONLY for:

* argocd-server
* argocd-repo-server
* argocd-application-controller
* argocd-dex
* argocd-redis

It is ArgoCD’s own system namespace.

Think of it like:

```
kube-system → Kubernetes system components
argocd → GitOps system components
```

---

# 🔹 Where Do We Deploy Applications?

Applications should be deployed into:

* dev
* staging
* prod
* or application-specific namespaces

Example:

```bash
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
```

Then in ArgoCD Application YAML:

```yaml
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
```

That means:

Deploy app into `dev` namespace.

---

# 🔹 Why Not Deploy Into `argocd` Namespace?

Because:

* `argocd` is system namespace
* Mixing system + business apps is bad practice
* Harder to manage RBAC
* Harder to secure
* Not production standard

Professional rule:

> One namespace = one logical boundary.

---

# 🔹 What Happens Technically?

ArgoCD runs in:

```
argocd namespace
```

But it can deploy applications to:

```
any namespace in cluster
```

As long as it has RBAC permissions.

---

# 🔹 Example Architecture

Cluster:

```
argocd namespace → ArgoCD components
dev namespace → app-dev
staging namespace → app-staging
prod namespace → app-prod
```

ArgoCD watches Git and applies manifests to those namespaces.

---

# 🔹 Very Important Concept

ArgoCD is NOT limited to its own namespace.

It talks to Kubernetes API server.

API server can create resources anywhere.

---

# 🔹 How To Check Where Your App Is Deployed

Run:

```bash
kubectl get pods -A | grep task
```

You will see something like:

```
task-app   task-manager-api-xxxxx
```

That `task-app` is the namespace.

---

# 🔥 Final Clear Rule 

`argocd` namespace → GitOps system
`dev/staging/prod` namespaces → business workloads

Never mix them.





# 🔹 There Are 3 Different Things

### 1️⃣ Helm Chart

Defines **Kubernetes resources**

* Deployment
* Service
* Ingress
* HPA
* ConfigMap
* etc.

Helm does NOT decide:

* Which cluster
* Which namespace

It only defines WHAT to deploy.

Example (`service.yaml` in Helm):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: task-manager-api
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
    app: task-manager-api
```

This defines how traffic reaches pod.
Nothing about environment here.

---

### 2️⃣ ArgoCD Application YAML

Defines WHERE to deploy

Example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: task-manager-api-dev
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/company/app-helm
    targetRevision: main
    path: charts/app

  destination:
    server: https://kubernetes.default.svc
    namespace: dev
```

👉 `destination` is here.

Not in Helm.
Not in Service.
Not in Deployment.

---

### 3️⃣ Kubernetes Namespace

Namespace is environment boundary.

Example:

```
dev
staging
prod
```

---

# 🔹 Who Decides What?

| Component  | Decides                  |
| ---------- | ------------------------ |
| Helm       | What resources look like |
| ArgoCD     | Where they go            |
| Kubernetes | Where pods run           |

---

# 🔹 Mental Model

Helm = Blueprint
ArgoCD = Delivery truck
Kubernetes = Factory

Helm describes building.
ArgoCD delivers blueprint to factory.
Factory builds it in correct room (namespace).

---

# 🔹 Why This Separation Is Important

Because:

You can use SAME Helm chart for:

* dev
* staging
* prod

Only change:

* values-dev.yaml
* values-prod.yaml

ArgoCD controls which environment receives which values file.

---

# 🔹 Real Professional Structure

CD Repo:

```
charts/task-manager/
  Chart.yaml
  templates/
  values.yaml
  values-dev.yaml
  values-prod.yaml
```

ArgoCD DEV app:

```yaml
source:
  path: charts/task-manager
  helm:
    valueFiles:
      - values-dev.yaml

destination:
  namespace: dev
```

ArgoCD PROD app:

```yaml
source:
  path: charts/task-manager
  helm:
    valueFiles:
      - values-prod.yaml

destination:
  namespace: prod
```

Same chart.
Different environment.
Different namespace.

---

# 🔥 Very Important DevOps Insight

Helm does NOT know environment.

ArgoCD defines environment.

Kubernetes executes environment.




You need a **separate ArgoCD Application YAML** that tells ArgoCD:

* What repo to read
* What path to use
* Which values file
* Which cluster
* Which namespace (dev / staging / prod)

Helm does NOT decide where to deploy.
ArgoCD Application does.

Now let’s explain clearly where and how you create it.

---

# 🔹 Where Do We Create ArgoCD Application YAML?

There are 2 professional ways.

---

# 🟢 OPTION 1 — Create Application From ArgoCD UI 

In ArgoCD UI:

New App → Fill form:

* Repo URL
* Path (charts/task-manager)
* Cluster: in-cluster
* Namespace: dev

ArgoCD stores this Application CR inside Kubernetes.

If you run:

```bash
kubectl get applications -n argocd
```

You’ll see it.

But this is not fully GitOps (because config is manual).

---

# 🟢 OPTION 2 — Store Application YAML In Git (Professional Way)

Best practice: store Application YAML inside Git repo.

Example repo structure:

```
gitops-repo/
  applications/
    task-api-dev.yaml
    task-api-staging.yaml
    task-api-prod.yaml
```

Example `task-api-dev.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: task-api-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourorg/app-helm
    targetRevision: main
    path: charts/task-manager
    helm:
      valueFiles:
        - values-dev.yaml

  destination:
    server: https://kubernetes.default.svc
    namespace: dev

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Then you apply it once:

```bash
kubectl apply -f task-api-dev.yaml
```

Now ArgoCD manages that app automatically.

---

# 🔹 Where Is This YAML Created?

You create it:

* On your laptop
* Inside your GitOps repo
* Then commit & push
* Then apply it once

After that, ArgoCD controls everything.

---

# 🔹 What Happens Internally?

When you apply:

```bash
kubectl apply -f task-api-dev.yaml
```

Kubernetes creates a Custom Resource:

```
Application
```

ArgoCD controller watches for that CR.

When it sees it:

* It pulls repo
* Reads Helm chart
* Deploys to namespace you defined

---

# 🔹 Real Enterprise Architecture

![Image](https://argo-cd.readthedocs.io/en/stable/assets/argocd_architecture.png)

![Image](https://developers.redhat.com/sites/default/files/5-3.png)

![Image](https://miro.medium.com/1%2AaEP4g-JqLTGkUL_9QYyvTA.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AvpAbe13DJ_cBuUW65SZrmQ.png)

---

# 🔹 Important DevOps Rule

Helm chart = reusable
Application YAML = environment specific

You will usually have:

* One Helm chart
* Three Application YAMLs (dev, staging, prod)

---

# 🔥 Advanced Professional Practice

Large companies use:

Application of Applications pattern.

One root app:

```
environments/
  dev/
  staging/
  prod/
```

ArgoCD deploys environments from Git automatically.

---

# 🔹 Final 

Yes — you must create separate ArgoCD Application YAML.

It is created:

* In Git
* Or via UI (not recommended long-term)

It lives:

* Inside `argocd` namespace
* As a Kubernetes custom resource

It defines:

* WHERE deployment happens.

















# 1️⃣ First — Where Is Deployment Defined?

Deployment target is defined inside **ArgoCD Application YAML**.

Example:

```yaml
spec:
  source:
    repoURL: https://github.com/company/app-helm
    targetRevision: main
    path: charts/app

  destination:
    server: https://kubernetes.default.svc
    namespace: dev
```

Key section:

```
destination:
  server:
  namespace:
```

That tells ArgoCD:

* Which cluster
* Which namespace
* Which environment

That is where it is written.

---

# 2️⃣ Where Do Dev / Stage / Prod Come From?

They come from:

* Different namespaces
  OR
* Different clusters

Example structure:

```
DEV cluster
STAGING cluster
PROD cluster
```

OR

```
One cluster:
  dev namespace
  staging namespace
  prod namespace
```

---

# 3️⃣ Complete Enterprise Flow (Real World)

Developer pushes code
↓
CI (Jenkins/GitHub Actions) builds Docker image
↓
Image pushed to ECR
↓
CD repository updated (Helm values file changes image tag)
↓
ArgoCD detects change
↓
Deploy to DEV
↓
QA tests
↓
Promotion to STAGING
↓
Approval
↓
Promotion to PROD

---

# 4️⃣ What Is “Release”?

Release is NOT just:

“Pod running”

Release means:

* Approved change
* Version tagged
* Tested in staging
* Deployed to production
* Communicated to stakeholders

In GitOps:

Release = merge to prod branch

Example:

```
dev branch → auto deploy to dev
staging branch → auto deploy to staging
main branch → auto deploy to prod
```

Or:

Manual promotion by updating image tag.

---

# 5️⃣ How Often Releases Happen?

Depends on company:

Startup:

* Multiple times per day

Enterprise:

* Once per week
* Once per sprint (2 weeks)
* Once per month

Highly regulated:

* Once per month
* With change approval board (CAB)

---

# 6️⃣ Who Is Involved?

Typical production release includes:

* Developer
* DevOps Engineer
* QA Engineer
* Product Manager
* Sometimes Security
* Sometimes Change Approval Board

DevOps does not release alone in enterprise.

---

# 7️⃣ When Does Release Happen?

Common practice:

* During low-traffic hours
* Night time
* Maintenance window
* Or fully automated with blue/green deployment

Modern DevOps:
Deploy anytime (if pipeline is mature)

---

# 8️⃣ Incident Response — What Happens If Production Breaks?

If production fails:

1. Monitoring detects issue (Prometheus / Datadog)
2. Alert sent (Slack / PagerDuty)
3. On-call engineer responds
4. Rollback performed

Rollback in GitOps:

Just revert Git commit.

ArgoCD auto-syncs previous version.

That’s the power of GitOps.

---

# 9️⃣ Does Kubernetes Have To Run 24/7?

If this is production:

YES.

Because:

* Pods are running application
* Service exposes application
* LoadBalancer routes traffic

If nodes stop → app down.

So:

EKS control plane → always on (AWS managed)
Worker nodes → must run 24/7
Load Balancer → must exist

Unless this is dev/test environment.

---

# 🔟 How Clients Reach The Pod

Very important explanation for students.

Client
↓
DNS
↓
Load Balancer
↓
Service
↓
Pod

The pod itself is NOT exposed to internet.

Service exposes pod.

LoadBalancer exposes service.

Helm defines:

* Deployment
* Service
* Ingress
* Autoscaling
* Resources

Yes — everything can be configured in Helm.

---

# 1️⃣1️⃣ Real Production Architecture

![Image](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/assets/images/controller-design.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AU7GKkKYlAjutIeQnoIktVA.jpeg)

![Image](https://developers.redhat.com/sites/default/files/blog/2020/09/cicd-knative.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AJqDUgv6OxS3iikAR_-HKPg.png)

---

# 1️⃣2️⃣ Where Is All This Written?

In real companies:

* Infrastructure as Code repo
* Helm charts
* ArgoCD Application YAML
* Terraform modules
* Change management documentation
* Runbooks
* Incident response playbooks

Everything is version-controlled.

---

# 1️⃣3️⃣ Can Everything Be Configured In Helm?

Yes.

Helm can define:

* Replicas
* Resources
* Service type
* Ingress
* TLS
* Autoscaling
* Environment variables
* Secrets (external references)
* Liveness / readiness probes

Helm = application packaging system.

---

# 1️⃣4️⃣ Summary 

ArgoCD does:

* Enforce Git state

Kubernetes does:

* Run application

Service does:

* Expose pods

LoadBalancer does:

* Connect to internet

Helm does:

* Package configuration

DevOps does:

* Automate pipeline
* Ensure reliability
* Monitor
* Respond to incidents

---

# 1️⃣5️⃣ Final Professional Mindset

Production is not just “pod running”.

Production means:

* High availability
* Monitoring
* Security
* Backups
* Disaster recovery
* Scaling
* On-call support
* Release process

You are now thinking like senior DevOps architect.













