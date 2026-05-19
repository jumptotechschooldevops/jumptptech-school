---
title: "gitlab lab"
description: "Lab prerequisites    AWS account access with permissions for EKS  kubectl, eksctl, helm..."
published: 2026-02-20
source: "https://dev.to/jumptotech/gitlab-lab-2c0k"
tags: []
---

# gitlab lab



## Lab prerequisites

* AWS account access with permissions for EKS
* `kubectl`, `eksctl`, `helm` installed on your laptop (Mac)
* A GitLab account (GitLab.com is fine)

---

# Part A — Create EKS cluster 

### 1) Create cluster (eksctl)

```bash
eksctl create cluster \
  --name gitlab-eks-lab \
  --region us-east-2 \
  --nodes 2 \
  --node-type t3.medium \
  --managed
```

### 2) Confirm cluster access

```bash
aws eks update-kubeconfig --region us-east-2 --name gitlab-eks-lab
kubectl get nodes
```

You should see 2 nodes in `Ready`.

---

# Part B — Create GitLab Project 

### 1) In GitLab UI

1. GitLab → **New project** → **Create blank project**
2. Name: `eks-ci-lab`
3. Visibility: Private (recommended) → Create project

---

# Part C — Install GitLab Runner into EKS (step-by-step)

## 1) Create namespace for runner

```bash
kubectl create namespace gitlab-runner
```

## 2) Get Runner registration token from GitLab

In GitLab project:

1. **Settings** → **CI/CD**
2. Expand **Runners**
3. Find **“Registration token”** (copy it)

Also note your GitLab URL:

* For GitLab.com: `https://gitlab.com/`

## 3) Install runner using Helm

Add chart repo:

```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update
```

Install runner (replace `PASTE_TOKEN_HERE`):

```bash
helm upgrade --install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set gitlabUrl="https://gitlab.com/" \
  --set runnerRegistrationToken="PASTE_TOKEN_HERE" \
  --set rbac.create=true \
  --set serviceAccount.create=true \
  --set serviceAccount.name=gitlab-runner
```

## 4) Confirm runner pod is running

```bash
kubectl get pods -n gitlab-runner
```

## 5) Confirm GitLab sees the runner

Go back to GitLab:

* **Settings → CI/CD → Runners**
  You should see a runner listed as “online/active”.

---

# Part D — Give Runner permission to deploy 



### 1) Create ClusterRoleBinding

```bash
kubectl create clusterrolebinding gitlab-runner-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=gitlab-runner:gitlab-runner
```

Explanation:

* Runner runs inside Kubernetes using a ServiceAccount.
* ServiceAccount needs permissions to create deployments/services.
* For learning, we give it admin to avoid RBAC complexity.

---

# Part E — Add Kubernetes manifests to the GitLab repo 

In your GitLab project, create these files.

## 1) Create folder `k8s/`

### `k8s/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-app
  template:
    metadata:
      labels:
        app: hello-app
    spec:
      containers:
        - name: hello
          image: nginxdemos/hello:latest
          ports:
            - containerPort: 80
```

### `k8s/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-app-svc
  namespace: default
spec:
  type: LoadBalancer
  selector:
    app: hello-app
  ports:
    - port: 80
      targetPort: 80
```

---

# Part F — Add GitLab pipeline file `.gitlab-ci.yml` 

Create `.gitlab-ci.yml` in the root of the repo:

```yaml
stages:
  - deploy
  - verify

deploy_to_eks:
  stage: deploy
  image:
    name: bitnami/kubectl:latest
    entrypoint: [""]
  script:
    - kubectl version --client=true
    - kubectl apply -f k8s/deployment.yaml
    - kubectl apply -f k8s/service.yaml

verify_deploy:
  stage: verify
  image:
    name: bitnami/kubectl:latest
    entrypoint: [""]
  script:
    - kubectl rollout status deployment/hello-app --timeout=120s
    - kubectl get pods -l app=hello-app -o wide
    - kubectl get svc hello-app-svc
```

What  should understand:

* GitLab is only “orchestrating”.
* Runner actually executes `kubectl apply`.
* Each job runs in a clean container (`bitnami/kubectl`).

---

# Part G — Run it 

### 1) Commit and push (or use GitLab Web IDE)

Any commit triggers pipeline.

### 2) Watch the pipeline

GitLab → **CI/CD → Pipelines** → open the latest pipeline:

* `deploy_to_eks` runs
* `verify_deploy` runs

---

# Part H — Open the app in browser 
In terminal (teacher can demo):

```bash
kubectl get svc hello-app-svc
```

Wait until `EXTERNAL-IP` appears (it can take a few minutes).

Then open in browser:

* `http://EXTERNAL-IP`

Students should see an NGINX demo “hello” page.

---

# Part I — Troubleshooting 

## 1) Pipeline stuck “pending”

* GitLab → Settings → CI/CD → Runners
* Runner must be “online”
* If you used tags later, make sure job tags match runner tags

## 2) Pipeline fails: “forbidden”

Runner doesn’t have permissions.
Fix:

```bash
kubectl get sa -n gitlab-runner
kubectl describe sa gitlab-runner -n gitlab-runner
```

And confirm ClusterRoleBinding exists:

```bash
kubectl get clusterrolebinding gitlab-runner-admin
```

## 3) Service has no external IP

* Make sure you are in a public subnet EKS setup (standard eksctl is fine)
* Check service events:

```bash
kubectl describe svc hello-app-svc
```

## 4) Pods not running

```bash
kubectl describe pod -l app=hello-app
kubectl logs -l app=hello-app --tail=50
```

## 5) You deployed but browser doesn’t open

* Confirm port is 80
* Try:

```bash
kubectl get endpoints hello-app-svc
```

---

# Part J — Cleanup (important for AWS cost)

Delete app:

```bash
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
```

Uninstall runner:

```bash
helm uninstall gitlab-runner -n gitlab-runner
kubectl delete namespace gitlab-runner
```

Delete cluster:

```bash
eksctl delete cluster --name gitlab-eks-lab --region us-east-2
```


