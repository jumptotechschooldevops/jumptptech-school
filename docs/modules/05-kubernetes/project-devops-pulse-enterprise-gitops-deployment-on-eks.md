---
title: "PROJECT: “DevOps Pulse” – Enterprise GitOps Deployment on EKS"
description: "1️⃣ Project Overview   We are building:   A Node.js microservice Dockerized Built in GitLab..."
published: 2026-02-23
source: "https://dev.to/jumptotech/project-devops-pulse-enterprise-gitops-deployment-on-eks-2dgd"
tags: []
---

# PROJECT: “DevOps Pulse” – Enterprise GitOps Deployment on EKS





# 1️⃣ Project Overview

We are building:

* A Node.js microservice
* Dockerized
* Built in GitLab CI
* Pushed to GitLab Container Registry
* Deployed using ArgoCD
* Running on AWS EKS
* Spread across 2 worker nodes
* Exposed via AWS LoadBalancer

This mimics a real enterprise production workflow.

---

# 🏗 2️⃣ Architecture

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2ADLTMyR3zmFu6Q7DpuWGZWw.png)

![Image](https://argo-cd.readthedocs.io/en/stable/assets/argocd_architecture.png)

![Image](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2022/01/27/alb-pathroute-architecture-yellow.jpg)

![Image](https://docs.aws.amazon.com/images/eks/latest/userguide/images/lbc-overview.png)

### Flow:

Developer → GitLab CI → Container Registry → ArgoCD → EKS → LoadBalancer → Users

---

# 👥 Who Does What in a Real Company?

| Role              | Responsibility                  |
| ----------------- | ------------------------------- |
| Developer         | Writes application code         |
| DevOps Engineer   | Builds CI/CD pipeline           |
| Platform Engineer | Manages EKS cluster             |
| SRE               | Monitors health & scaling       |
| Security Engineer | Enforces runAsNonRoot, policies |

In small companies, DevOps does all of this.

---

# 3️⃣ CI Repository (ci-enterprise)

This repository contains:

```
ci-enterprise/
├── app/
│   ├── package.json
│   └── server.js
├── Dockerfile
└── .gitlab-ci.yml
```

---

## ✅ Application Code (server.js)

```js
const express = require("express");
const os = require("os");

const app = express();
const PORT = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.send(`
    <h1>DevOps Pulse</h1>
    <p>Pod: ${os.hostname()}</p>
    <p>Node: ${process.env.NODE_NAME}</p>
  `);
});

app.get("/healthz", (req, res) => res.send("OK"));
app.get("/readyz", (req, res) => res.send("READY"));

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## ✅ Dockerfile (Production Secure)

```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY app/package.json /app/package.json
RUN npm install --omit=dev

COPY app /app

ENV PORT=8080
EXPOSE 8080

USER 1000

CMD ["node", "server.js"]
```

Why `USER 1000`?

Because enterprise Kubernetes clusters enforce:

```yaml
runAsNonRoot: true
```

Security policies block root containers.

---

## ✅ GitLab CI (.gitlab-ci.yml)

```yaml
stages:
  - build
  - push

variables:
  IMAGE: "$CI_REGISTRY_IMAGE/devops-pulse"
  TAG: "$CI_COMMIT_SHORT_SHA-$CI_PIPELINE_ID"

build_image:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: ""
  script:
    - docker build -t "$IMAGE:$TAG" -t "$IMAGE:latest" .
  rules:
    - if: $CI_COMMIT_BRANCH

push_image:
  stage: push
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: ""
  script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login -u "$CI_REGISTRY_USER" --password-stdin "$CI_REGISTRY"
    - docker push "$IMAGE:$TAG"
    - docker push "$IMAGE:latest"
  rules:
    - if: $CI_COMMIT_BRANCH
```

---

# 🔄 Why CI Is Separate From CD?

CI repo:

* Builds
* Tests
* Pushes images

CD repo:

* Controls deployment state
* GitOps source of truth

Enterprise companies separate these responsibilities.

---

# 4️⃣ CD Repository (cd-enterprise-gitops)

```
cd-enterprise-gitops/
├── apps/
│   └── devops-pulse/
│       ├── namespace.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── hpa.yaml
│       └── pdb.yaml
└── argocd/
    └── devops-pulse-app.yaml
```

---

## ✅ namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: devops
```

---

## ✅ deployment.yaml (Final Production Version)

(Using preferred anti-affinity to avoid rollout deadlocks)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-pulse
  namespace: devops
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-pulse
  template:
    metadata:
      labels:
        app: devops-pulse
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              app: devops-pulse

      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app: devops-pulse
                topologyKey: kubernetes.io/hostname

      containers:
        - name: app
          image: registry.gitlab.com/jumptotech/ci-enterprise/devops-pulse:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8080

          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName

          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
```

---

## ✅ service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-pulse
  namespace: devops
spec:
  type: LoadBalancer
  selector:
    app: devops-pulse
  ports:
    - port: 80
      targetPort: 8080
```

---

## ✅ ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: devops-pulse
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://gitlab.com/jumptotech/cd-enterprise-gitops.git
    targetRevision: main
    path: apps/devops-pulse
  destination:
    server: https://kubernetes.default.svc
    namespace: devops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

---

# ☁️ 5️⃣ EKS Setup

You create:

* EKS cluster
* 2 worker nodes
* Install ArgoCD

ArgoCD continuously watches Git repo and applies changes.

---

# 🔄 6️⃣ End-to-End Flow

1. Developer pushes code → CI builds image
2. Image pushed to GitLab registry
3. CD repo references image
4. ArgoCD detects change
5. ArgoCD applies Kubernetes manifests
6. EKS schedules pods
7. LoadBalancer exposes app
8. Users access app

---

# 🔥 Why DevOps Uses GitOps?

Because:

* Git becomes single source of truth
* No manual kubectl in production
* Full audit trail
* Easy rollback
* Declarative infrastructure

This is how companies like Netflix, Spotify, Airbnb deploy.


