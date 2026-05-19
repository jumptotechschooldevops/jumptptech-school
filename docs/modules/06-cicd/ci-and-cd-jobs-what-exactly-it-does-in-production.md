---
title: "CI and CD JOBs – What Exactly It Does in Production"
description: "1️⃣   CI job runs when:   Developer pushes code to GitHub Pull Request is created Merge..."
published: 2026-02-13
source: "https://dev.to/jumptotech/ci-and-cd-jobs-what-exactly-it-does-in-production-3l6b"
tags: []
---

# CI and CD JOBs – What Exactly It Does in Production



# 1️⃣ 

CI job runs when:

* Developer pushes code to GitHub
* Pull Request is created
* Merge happens to main branch

CI Job Responsibility = Validate & Package Application

## CI Job Stages (Real Production Flow)

### 1️⃣ Checkout Stage

Pull latest code from GitHub.

```
checkout scm
```

Purpose:

* Get source code
* Ensure correct branch

---

### 2️⃣ Code Quality & Security Scan

Production CI always includes:

* SonarQube (code quality)
* Snyk / Trivy (security scan)
* Dependency scanning
* Secret scanning

Purpose:
Prevent vulnerable code from going to production.

---

### 3️⃣ Build Stage

Compile application (if needed):

* Maven (Java)
* npm build (NodeJS)
* Python packaging
* Go build

Example:

```
mvn clean package
```

Purpose:
Convert source code → runnable artifact

---

### 4️⃣ Unit Tests

Run automated tests:

```
mvn test
```

If tests fail → pipeline stops.

---

### 5️⃣ Build Docker Image

```
docker build -t app:v1 .
```

Now we containerize the app.

---

### 6️⃣ Tag Image Properly (Production Best Practice)

Use:

* Git commit SHA
* Build number
* Semantic version

Example:

```
app:1.0.5
app:build-152
app:commit-a92bd1c
```

Never use only `latest` in production.

---

### 7️⃣ Push Image to ECR

```
docker push <aws_account>.dkr.ecr.us-east-2.amazonaws.com/app:1.0.5
```

CI ENDS HERE.

At this moment:

* Code is tested
* Image is built
* Image is stored in registry (ECR)

But application is NOT deployed yet.

---

# 2️⃣ CD JOB – What Exactly It Does in Production

CD job takes the built image and deploys it to environment.

CD Responsibility = Release Application

---

## Two Common Production Models

---

# 🔵 Model 1 – Jenkins Does CD (Classic Way)

After pushing image, Jenkins continues:

### CD Stage in Jenkins:

1️⃣ Update Kubernetes manifest with new image tag
2️⃣ Run:

```
kubectl apply -f k8s/
```

or

```
helm upgrade app ./helm-chart
```

3️⃣ Kubernetes Deployment gets updated
4️⃣ ReplicaSet created
5️⃣ New Pods created
6️⃣ Rolling update happens
7️⃣ Old Pods terminated gradually

Traffic never stops.

In this model:

Jenkins = CI + CD

---

# 🟢 Model 2 – GitOps Model (Modern Production Way)

This is what companies use now.

CI and CD are separated.

## Repo Structure

Repo 1 → Application code
Repo 2 → Kubernetes manifests

---

## Flow

Developer pushes code
↓
CI job builds image
↓
Push image to ECR
↓
CI job updates image tag in Kubernetes repo
↓
Argo CD detects change
↓
Argo CD deploys to EKS
↓
Kubernetes performs rolling update

In this case:

Jenkins = CI
Argo CD = CD

---

# 3️⃣ What CD Job Does Internally in Production

CD job performs:

### 1️⃣ Pull Latest Deployment Config

Helm chart / YAML / Kustomize

### 2️⃣ Replace Image Tag

Old:

```
image: app:1.0.4
```

New:

```
image: app:1.0.5
```

### 3️⃣ Deploy to Cluster

```
kubectl apply
```

or

```
helm upgrade
```

---

### 4️⃣ Monitor Deployment

CD job checks:

```
kubectl rollout status deployment/app
```

If rollout fails → mark deployment failed.

---

### 5️⃣ Post-Deployment Checks

* Health check endpoint
* Smoke test
* Validate service availability

---

# 4️⃣ Full Production Flow Example (Step by Step)

Let’s simulate real life:

Developer pushes code → main branch

### CI Pipeline Runs:

* Checkout
* Lint
* Unit tests
* Security scan
* Build
* Docker build
* Push to ECR

Now Image v1.0.5 exists in ECR.

---

### CD Pipeline Runs:

Option A:
Triggered automatically after CI success.

Option B:
Manual approval required (production safety).

CD does:

* Update image tag
* Deploy to staging
* Run integration tests
* If successful → deploy to production

---

# 5️⃣ In Large Companies Flow Looks Like This

Developer → PR
↓
CI job
↓
Artifact repository (ECR / Nexus)
↓
CD to Dev
↓
QA approval
↓
CD to Staging
↓
Manual approval
↓
CD to Production

---

# 6️⃣ What Each Job Is Responsible For

| CI Job                 | CD Job                |
| ---------------------- | --------------------- |
| Validate code          | Deploy code           |
| Run tests              | Update infrastructure |
| Build artifact         | Manage rollout        |
| Build image            | Control traffic       |
| Push image to registry | Ensure app is running |

---

# 7️⃣ Important Interview Explanation

If interviewer asks:

"What is difference between CI and CD in production?"

Strong Answer:

"CI validates and packages the application into a deployable artifact such as a Docker image. CD is responsible for deploying that artifact into target environments like staging or production using Kubernetes, Helm, or GitOps tools like Argo CD. CI ensures code quality, while CD ensures reliable and automated release management."

---

# 8️⃣ Real Responsibility in Team

In production:

Backend developer → writes code
DevOps engineer → builds CI pipeline
Platform engineer → manages CD / Kubernetes
SRE → monitors deployment health















# Part 0 — Prereqs (one time)

## 0.1 Jenkins EC2 must have these tools

SSH into Jenkins EC2 and verify:

```bash
docker --version
aws --version
kubectl version --client
helm version
```

If missing, install (Ubuntu):

```bash
sudo apt update -y
sudo apt install -y docker.io unzip
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

AWS CLI v2 quick install:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

kubectl (EKS):

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

helm:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

**Result you should see:** versions printed, no “command not found”.

**Why DevOps does this:** Jenkins pipeline runs shell steps; if tools aren’t on the Jenkins agent, the pipeline fails.

---

## 0.2 Jenkins needs AWS credentials (production-style)

Create an IAM user (or role) with permissions to:

* push to ECR
* deploy to EKS (via kubectl/helm)

Minimum managed policies for lab:

* `AmazonEC2ContainerRegistryPowerUser`
* `AmazonEKSClusterPolicy` (for cluster describe)
* plus access needed for kubectl auth (often via `aws eks update-kubeconfig`)

### In Jenkins UI (click path)

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

Add 2 items:

1. **AWS Access Key** (Kind: “AWS Credentials” if plugin exists, otherwise “Username/Password”)

* ID: `aws-creds`
* Username: AccessKeyId
* Password: SecretAccessKey

2. (Optional but helpful) **GitHub token** for pushing GitOps repo

* ID: `github-token`

**Result:** Credentials show in Jenkins.

**Why DevOps does this:** secrets must not be in Jenkinsfile or repo.

---

## 0.3 Create ECR repository (one time)

On your laptop or Jenkins EC2:

```bash
aws ecr create-repository --repository-name demo-app --region us-east-2
```

Get your account id:

```bash
aws sts get-caller-identity
```

Your ECR URI will look like:
`<ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/demo-app`

---

## 0.4 EKS access from Jenkins EC2

On Jenkins EC2:

```bash
aws eks update-kubeconfig --region us-east-2 --name <YOUR_CLUSTER_NAME>
kubectl get nodes
```

**Result:** You see nodes.

**Troubleshoot:**

* If “Unauthorized”: IAM permissions / aws auth configmap / EKS access entry is missing.
* If “cluster not found”: wrong cluster name or region.

---

# Part 1 — Production-level Jenkins CI pipeline (Build/Test → Push to ECR)

## 1.1 App repo structure (GitHub “app repo”)

Example:

```
demo-app/
  src/...
  Dockerfile
  Jenkinsfile
```

A simple Dockerfile (example for Node):

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test
EXPOSE 3000
CMD ["npm","start"]
```

**Why DevOps wants tests inside pipeline:** to stop bad builds early.

---

## 1.2 Create Jenkins Pipeline job (click-by-click)

1. Jenkins → **New Item**
2. Name: `demo-app-ci`
3. Type: **Pipeline**
4. Click **OK**
5. In job config:

   * **Build Triggers** → check **GitHub hook trigger for GITScm polling**
   * **Pipeline** → Definition: **Pipeline script from SCM**
   * SCM: **Git**
   * Repo URL: your GitHub repo
   * Credentials: your GitHub credentials
   * Branch: `*/main`
   * Script Path: `Jenkinsfile`
6. **Save**

**Result:** job is ready, and GitHub webhook triggers it.

---

## 1.3 Jenkinsfile (CI) — copy/paste

Put this in `demo-app/Jenkinsfile`:

```groovy
pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-2"
    ECR_REPO   = "demo-app"
    // We will compute ECR_URI at runtime
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("Unit Tests") {
      steps {
        sh '''
          if [ -f package.json ]; then
            npm ci
            npm test
          else
            echo "No package.json found - skip npm tests"
          fi
        '''
      }
    }

    stage("Login to ECR") {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
            ECR_URI="$ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com"
            echo "ECR_URI=$ECR_URI" > ecr.env

            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $ECR_URI
          '''
        }
      }
    }

    stage("Build & Push Image") {
      steps {
        sh '''
          source ecr.env
          IMAGE_TAG=${BUILD_NUMBER}
          FULL_IMAGE="$ECR_URI/${ECR_REPO}:${IMAGE_TAG}"

          echo "Building $FULL_IMAGE"
          docker build -t "$FULL_IMAGE" .

          echo "Pushing $FULL_IMAGE"
          docker push "$FULL_IMAGE"

          echo "$FULL_IMAGE" > image.txt
        '''
      }
    }
  }

  post {
    success {
      archiveArtifacts artifacts: "image.txt", fingerprint: true
      echo "CI complete: image pushed to ECR."
    }
    failure {
      echo "CI failed. Check console logs."
    }
  }
}
```

### What result you should see

* Jenkins console shows: **tests → docker build → docker push**
* ECR shows a new image tag (build number)

### Common CI troubleshooting

* **docker: not found** → install docker on Jenkins EC2 + restart Jenkins + add jenkins user to docker group.
* **denied: User not authorized** → IAM lacks ECR permissions.
* **no basic auth credentials** → ECR login step failed.
* **npm test fails** → fix tests (that’s CI doing its job).

---

# Part 2 — Full CD pipeline using Helm + EKS (Deploy image from ECR)

## 2.1 Create Helm chart (in app repo OR separate repo)

Recommended for beginners: keep chart inside app repo:

```
helm/demo-app/
  Chart.yaml
  values.yaml
  templates/deployment.yaml
  templates/service.yaml
```

**values.yaml**

```yaml
image:
  repository: REPLACE_ME
  tag: "1"
service:
  port: 3000
```

**templates/deployment.yaml** (minimal)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
      - name: demo-app
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: {{ .Values.service.port }}
```

**templates/service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-app
spec:
  selector:
    app: demo-app
  ports:
  - port: 80
    targetPort: {{ .Values.service.port }}
  type: ClusterIP
```

---

## 2.2 Create Jenkins CD job

Jenkins → **New Item** → `demo-app-cd` → **Pipeline**.

This job will deploy a given image tag.

### CD Jenkinsfile (deploy with Helm)

Create another Jenkinsfile or reuse same pipeline with a deploy stage.

Example `Jenkinsfile-cd`:

```groovy
pipeline {
  agent any

  parameters {
    string(name: 'IMAGE_TAG', defaultValue: '1', description: 'ECR image tag to deploy')
  }

  environment {
    AWS_REGION = "us-east-2"
    ECR_REPO   = "demo-app"
    K8S_NAMESPACE = "dev"
    RELEASE_NAME = "demo-app"
    CLUSTER_NAME = "<YOUR_CLUSTER_NAME>"
  }

  stages {
    stage("Checkout") {
      steps { checkout scm }
    }

    stage("Configure kubeconfig") {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
            kubectl get ns ${K8S_NAMESPACE} || kubectl create ns ${K8S_NAMESPACE}
          '''
        }
      }
    }

    stage("Helm Deploy") {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
            ECR_URI="$ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com"
            IMAGE_REPO="$ECR_URI/${ECR_REPO}"

            helm upgrade --install ${RELEASE_NAME} helm/demo-app \
              -n ${K8S_NAMESPACE} \
              --set image.repository=${IMAGE_REPO} \
              --set image.tag=${IMAGE_TAG}

            kubectl rollout status deploy/demo-app -n ${K8S_NAMESPACE}
            kubectl get pods -n ${K8S_NAMESPACE} -o wide
          '''
        }
      }
    }
  }
}
```

### What to type / do

* In Jenkins CD job → **Build with Parameters** → set `IMAGE_TAG` to a number that exists in ECR (like the CI build number).

### What result you should see

* `helm upgrade --install ...` success
* `kubectl get pods` shows 2 Running pods
* `kubectl rollout status` completes

### Common CD troubleshooting

* **ImagePullBackOff**:

  * wrong repository/tag
  * EKS nodes can’t pull from ECR (usually node role permissions or private networking issues)
* **Unauthorized kubectl**:

  * Jenkins IAM not granted EKS access
* **Rollout stuck**:

  * app crashed (check logs)
  * missing port, wrong container command

Useful commands:

```bash
kubectl describe pod <pod> -n dev
kubectl logs <pod> -n dev
kubectl get events -n dev --sort-by=.lastTimestamp
```

---

# Part 3 — GitOps lab with Argo CD (CD handled by Argo)

## 3.1 What changes in GitOps

* Jenkins **does NOT run kubectl/helm apply to cluster**
* Jenkins updates a **GitOps repo** (manifests/Helm values)
* Argo CD watches GitOps repo and deploys automatically

This is production-modern.

---

## 3.2 Create GitOps repo (GitHub)

Create a new repo: `demo-app-gitops`

Structure:

```
demo-app-gitops/
  helm/demo-app/   (or just values files)
  envs/
    dev/values.yaml
    prod/values.yaml
```

Example `envs/dev/values.yaml`:

```yaml
image:
  repository: <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/demo-app
  tag: "1"
service:
  port: 3000
```

---

## 3.3 Install Argo CD on EKS (one time)

From your laptop or Jenkins EC2:

```bash
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
```

Expose Argo CD (simple for lab):

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Get initial password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
```

Login: `admin`

**Result:** Argo UI opens via localhost:8080 (on the machine you port-forwarded from).

---

## 3.4 Create Argo CD Application (UI steps)

In Argo UI:

1. **NEW APP**
2. Application Name: `demo-app-dev`
3. Project: `default`
4. Sync Policy: choose **Automatic** (for demo)
5. Repo URL: your `demo-app-gitops` repo
6. Path: `.` or `envs/dev` (depending on how you structure)
7. Destination Cluster: in-cluster
8. Namespace: `dev`
9. Create

**Result:** Argo shows the app, and after sync you see resources in EKS.

Check:

```bash
kubectl get pods -n dev
```

---

## 3.5 Jenkins CI updates GitOps repo (this is the “bridge”)

In CI pipeline after pushing image to ECR:

* update `envs/dev/values.yaml` tag
* git commit + push to GitOps repo
* Argo detects change and deploys

### Example “Update GitOps” stage (concept)

* Use `github-token` credential
* Edit YAML (sed)
* Commit and push

**Troubleshooting GitOps**

* Argo says “OutOfSync” → repo path wrong or values invalid
* Argo sync fails → check events/logs in Argo UI
* manifests don’t apply → YAML errors, missing namespace, chart path wrong

---

# Part 4 — Enterprise multi-environment flow diagram 



```
Developer
  |
  | PR -> main
  v
GitHub (App Repo)
  |
  | webhook
  v
Jenkins CI
  - checkout
  - lint + unit tests
  - security scan
  - docker build
  - push to ECR (tag=commitSHA)
  |
  +--> (Optional) Deploy to DEV automatically
  |
  v
GitOps Repo (K8s/Helm values)
  - envs/dev values.yaml updated automatically
  - envs/stage updated after tests
  - envs/prod updated ONLY after approval
  |
  v
Argo CD
  - sync dev automatically
  - sync stage automatically
  - sync prod after manual approval
  |
  v
EKS
  - namespace: dev / stage / prod
  - Helm release per env
```

**Why DevOps does multi-env:** you never push untested changes straight to prod.

**Where troubleshooting happens most:**

* CI fails (tests/build)
* ECR push auth
* Argo sync errors
* Kubernetes rollout issues (ImagePullBackOff/CrashLoopBackOff)



