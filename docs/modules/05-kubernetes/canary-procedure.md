---
title: "canary procedure"
description: "1) Install Argo Rollouts on the cluster      kubectl create namespace argo-rollouts  kubectl..."
published: 2026-02-18
source: "https://dev.to/jumptotech/canary-procedure-2052"
tags: []
---

# canary procedure



## 1) Install Argo Rollouts on the cluster

```bash
kubectl create namespace argo-rollouts

kubectl apply -n argo-rollouts -f \
https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

kubectl get pods -n argo-rollouts
```

Wait until the rollout controller pod is **Running (1/1)**.

---

## 2) Install the Rollouts kubectl plugin (on your EC2/Jenkins box)

```bash
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

kubectl argo rollouts version
```

---

## 3) Update the CD repo Helm chart: Deployment → Rollout

Clone your Helm repo (CD repo):

```bash
git clone https://github.com/jumptotechschooldevops/manual-app-helm.git
cd manual-app-helm
```

Remove the Deployment template:

```bash
rm -f templates/deployment.yaml
```

Create `templates/rollout.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: manual-app
spec:
  replicas: 5
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: manual-app
  template:
    metadata:
      labels:
        app: manual-app
    spec:
      containers:
        - name: manual-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 3000

  strategy:
    canary:
      steps:
        - setWeight: 20
        - pause: { duration: 30 }
        - setWeight: 50
        - pause: { duration: 30 }
        - setWeight: 100
```

Make sure your `templates/service.yaml` still selects:

```yaml
selector:
  app: manual-app
```

Commit & push CD repo:

```bash
git add .
git commit -m "Add canary rollout"
git push
```

---

## 4) ArgoCD syncs the new Rollout

In ArgoCD UI:

* App goes **OutOfSync**
* Click **Sync** (or auto-sync will do it)

Verify rollout exists:

```bash
kubectl get rollouts
```

---

## 5) Canary trigger rule (important)

Canary starts ONLY when the **pod template changes**, usually because the **image tag changes**.

**Do NOT** put `${BUILD_NUMBER}` in `values.yaml` (ArgoCD/Helm won’t resolve it).
`values.yaml` must always contain a real tag like `"13"`.

---

## 6) Make CI automatically update CD repo tag (the automation)

### 6.1 Create GitHub token in Jenkins credentials

In Jenkins:

* Manage Jenkins → Credentials → Global → Add Credentials
* Kind: **Username with password**
* ID: `github-creds`
* Username: your GitHub username
* Password: GitHub PAT token (with `repo` permission)

### 6.2 Use this Jenkinsfile in your CI repo

This is what you ended up running successfully:

```groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "aisalkyn85/manual-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        CD_REPO = "jumptotechschooldevops/manual-app-helm"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Install Dependencies') { steps { sh 'npm install' } }

        stage('Build Docker Image') {
            steps { sh 'docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .' }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps { sh 'docker push ${DOCKER_IMAGE}:${IMAGE_TAG}' }
        }

        stage('Update CD Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-creds',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh """
                    rm -rf cd-repo
                    git clone https://${GIT_USER}:${GIT_PASS}@github.com/${CD_REPO}.git cd-repo
                    cd cd-repo
                    sed -i 's/tag:.*/tag: "${IMAGE_TAG}"/' values.yaml
                    git config user.email "jenkins@jumptotech.com"
                    git config user.name "jenkins"
                    git add values.yaml
                    git commit -m "Update image tag to ${IMAGE_TAG}" || true
                    git push
                    """
                }
            }
        }
    }
}
```

---

## 7) Run the pipeline (this triggers canary)

When Jenkins runs:

1. Builds image `aisalkyn85/manual-app:<BUILD_NUMBER>`
2. Pushes it to DockerHub
3. Updates `values.yaml` in CD repo to that tag
4. Pushes CD repo change
5. ArgoCD detects Git change and syncs
6. Rollout controller starts canary steps

---

## 8) Watch the canary progress

Live watch:

```bash
kubectl argo rollouts get rollout manual-app --watch
```

You’ll see:

* 20% → pause → 50% → pause → 100%

Check pods’ images during rollout:

```bash
kubectl get pods -o=jsonpath="{.items[*].spec.containers[*].image}"
```

---

## 9) Confirm success

```bash
kubectl argo rollouts get rollout manual-app
kubectl get rs
kubectl get pods
```

Success looks like:

* `Status: Healthy`
* `SetWeight: 100`
* `Images: ...:13 (stable)`
* Older ReplicaSets show `ScaledDown`

---

## 10) Common failure you hit (and the fix)

### ImagePullBackOff

Cause: CD repo tag pointed to an image tag that didn’t exist in DockerHub.
Fix: run Jenkins to push that tag (or change tag to one that exists).

### Git push failed

Cause: Jenkins lacked GitHub credentials.
Fix: create `github-creds` in Jenkins and use `withCredentials`.


