---
title: "what problem solve Jenkins"
description: "1️⃣ First – What Problem Are We Solving?   Before tools existed:  👩‍💻 Developer workflow..."
published: 2026-02-12
source: "https://dev.to/jumptotech/what-problem-solve-jenkins-2dmh"
tags: []
---

# what problem solve Jenkins



# 1️⃣ First – What Problem Are We Solving?

Before tools existed:

👩‍💻 Developer workflow (OLD DAYS)

1. Developer writes code
2. Sends ZIP file or pushes to server manually
3. Ops team manually:

   * Compiles code
   * Copies files
   * Restarts server
4. Sometimes production breaks
5. No automation
6. No rollback
7. No audit history

Everything was **manual and risky**.

That is why CI/CD was born.

---

# 2️⃣ What is CI and CD?

## ✅ Continuous Integration (CI)

**CI = Automatically test and build code when developer pushes code**

Example:

```
Developer pushes code to GitHub
↓
Jenkins automatically:
   - Pulls code
   - Runs tests
   - Builds Docker image
   - Fails if tests fail
```

Goal:
✔ Catch bugs early
✔ Ensure code compiles
✔ Avoid broken code in main branch

---

## ✅ Continuous Delivery (CD)

**CD = Automatically prepare application for deployment**

Example:

```
After CI succeeds:
   - Build Docker image
   - Push to ECR
   - Update Kubernetes manifest
```

Human clicks “Deploy” to production.

---

## ✅ Continuous Deployment

**Fully automatic deployment to production without human approval**

Push → Build → Test → Deploy → Live

---

# 3️⃣ What is Jenkins?

Jenkins is a:

> CI/CD automation server

It does NOT run containers.
It does NOT manage clusters.

It **automates steps**.

Think of Jenkins like:

🧠 “Automation Brain”

It runs commands for you.

---

# 4️⃣ What is Docker?

Docker:

> Packages application into a container.

It solves:

“It works on my machine but not on server.”

Docker creates portable environment.

Example:

```
Docker build
Docker run
```

---

# 5️⃣ What is Kubernetes?

Kubernetes:

> Manages containers in production

It solves:

* Scaling
* Load balancing
* Self-healing
* Rolling updates

Example:

```
kubectl apply -f deployment.yaml
```

---

# 6️⃣ Why you Think Jenkins = Kubernetes?

Because both are used in pipeline.

But they do different jobs.

---

# 🔥 SIMPLE COMPARISON TABLE

| Tool       | What It Does              |
| ---------- | ------------------------- |
| Jenkins    | Automates pipeline steps  |
| Docker     | Packages application      |
| Kubernetes | Runs & manages containers |
| GitHub     | Stores code               |

---

# 7️⃣ Real Production Flow (Very Important)

```
Developer pushes code
        ↓
Jenkins (CI)
   - Run tests
   - Build Docker image
   - Push image to registry
        ↓
Jenkins (CD)
   - Deploy to Kubernetes
        ↓
Kubernetes
   - Runs containers
   - Scales
   - Self-heals
```

Jenkins = Automation
Kubernetes = Container manager

They are NOT the same.

---

# 8️⃣ What Does DevOps Set Up in Jenkins?

In real company DevOps engineers:

✅ Install Jenkins (EC2 / Docker / Kubernetes)
✅ Configure agents
✅ Connect GitHub webhooks
✅ Create Jenkinsfiles
✅ Integrate:

* Docker
* ECR
* Kubernetes
* Terraform
* SonarQube
* Security scanners
  ✅ Configure credentials securely
  ✅ Setup RBAC
  ✅ Setup backups
  ✅ Monitor disk usage
  ✅ Upgrade Jenkins safely

Developers:

* Write application code
* Sometimes write simple Jenkinsfile

DevOps:

* Owns CI/CD platform

---

# 9️⃣ What Did Companies Do Before Jenkins?

Before CI tools:

* Night builds (manual builds at night)
* FTP deployment
* SSH into production
* Manually restart services
* Copy files with SCP
* Many production outages
* No pipeline visibility

It was chaos.

---







# 1️⃣1️⃣ The Biggest Confusion 



“Jenkins deploys applications.”

No.

Jenkins runs commands like:

```
kubectl apply -f deployment.yaml
```

But Kubernetes actually deploys.

Jenkins only tells Kubernetes what to do.

---

# 1️⃣2️⃣ Very Simple One-Line Definitions

Jenkins → Automation engine
Docker → Container builder
Kubernetes → Container orchestrator
CI → Auto test & build
CD → Auto release

---

# 


👉 Jenkins does not run production applications
👉 Kubernetes does not build code
👉 Docker does not automate pipelines

Each tool has one responsibility.













# 🔥 LAB: DevOps Before Jenkins vs With Jenkins



# 🧨 PART 1 — BEFORE JENKINS (Manual DevOps)



“You are DevOps in 2012. No Jenkins.”

---

## 🧩 Scenario

Developer says:

“New feature is ready.”

What do you do?

---

## Step 1 — Dev Sends Code

Developer pushes to GitHub.

DevOps logs into server manually:

```
ssh ubuntu@server-ip
```

---

## Step 2 — Checkout (Manual)

What is checkout?

👉 Getting code from Git

Manual:

```
git clone https://github.com/demo/app.git
cd app
```

Explain:

Checkout = pulling latest source code.

No automation. You manually pull.

---

## Step 3 — Build (Manual)

What is build?

👉 Compile / prepare application

Example Node app:

```
npm install
```

For Java:

```
mvn clean package
```

Explain:

Build = convert source code into runnable artifact.

Still manual.

---

## Step 4 — Test (Manual)

```
npm test
```

If tests fail?

DevOps must manually inform developer.

No pipeline stopping automatically.

---

## Step 5 — Docker Build (Manual)

```
docker build -t myapp:v1 .
```

---

## Step 6 — Deploy (Manual)

Stop old container:

```
docker stop myapp
docker rm myapp
```

Start new one:

```
docker run -d -p 80:3000 myapp:v1
```

OR Kubernetes:

```
kubectl apply -f deployment.yaml
```

---

## ❌ Problems Without Jenkins

1. Human error
2. Someone forgets tests
3. No history of builds
4. No rollback
5. No standard process
6. 5 developers = chaos
7. Midnight manual deployments



“This is how companies worked before CI/CD.”

---

# 🚀 PART 2 — WITH JENKINS (Automation)

Now:

“Now we are modern DevOps.”

---

## What Jenkins Does

It AUTOMATES these steps:

Checkout
Build
Test
Docker build
Push
Deploy

Jenkins runs commands for you.

---

# 🔥 Jenkinsfile Example

```
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
            }
        }

        stage('Deploy') {
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }
}
```

Now explain each stage clearly.

---

# 🔍 What Each Stage REALLY Means

## 1️⃣ Checkout

What Jenkins does:

* Pulls code from GitHub automatically
* Happens when webhook triggers

Without Jenkins:
You SSH and run git clone

With Jenkins:
Automatic.

---

## 2️⃣ Build

Jenkins runs:

```
npm install
```

Build means:

Prepare dependencies
Compile code
Create artifact

Without Jenkins:
You run it manually.

---

## 3️⃣ Test

Jenkins runs:

```
npm test
```

If tests fail:

Pipeline stops.

Without Jenkins:
You may forget to test.

---

## 4️⃣ Docker Build

Jenkins builds image:

```
docker build -t myapp:15 .
```

Without Jenkins:
You manually type it.

---

## 5️⃣ Deploy

Jenkins runs:

```
kubectl apply -f k8s/
```

Important:

Jenkins does NOT deploy.
Kubernetes deploys.

Jenkins just runs the command.

This is the big confusion.

---

# 🧠 What Jenkins REALLY Is

It is a:

Command automation server.

It executes:

Shell commands
Docker commands
kubectl commands
Terraform commands

That’s it.

---

# 🔥 What  Should Understand

Jenkins does not:

* Manage pods
* Scale applications
* Run containers

Kubernetes does that.

Jenkins just tells Kubernetes what to do.

---

# 🎯 VISUAL COMPARISON 

Without Jenkins:

DevOps typing:

git clone
npm install
npm test
docker build
docker run

With Jenkins:

Push code → Coffee ☕ → Everything automatic.

---

# 🔥 Real DevOps Responsibilities in Jenkins

In real company DevOps:

* Install Jenkins
* Configure agents
* Secure credentials
* Integrate GitHub webhooks
* Write Jenkinsfile templates
* Connect Docker registry
* Connect Kubernetes cluster
* Setup RBAC
* Setup backup
* Monitor disk space

Developers:
Write code.

DevOps:
Build automation system.



# 💥 Final One-Sentence Definition

Before Jenkins:
DevOps manually executes deployment steps.

With Jenkins:
DevOps builds automation so machines execute deployment steps.




















# 🧠 Scenario

Year: 2010
You are DevOps.
There is NO Jenkins.
Developer says: “New version is ready.”

You must deploy manually.

---

# 🏗️ Environment Setup

Use:

* 1 Ubuntu EC2 instance
* Docker installed
* Git installed
* NodeJS installed

Install everything first:

```
sudo apt update
sudo apt install git -y
sudo apt install docker.io -y
sudo apt install nodejs npm -y
```

Start Docker:

```
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

Reconnect SSH.

---

# 📦 Step 1 — Create Simple Application

On your machine or directly on server:

```
mkdir manual-app
cd manual-app
```

Create file:

```
nano app.js
```

Paste:

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.end("Manual Deployment Version 1");
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

Create package.json:

```
npm init -y
```

---

# 🔍 Step 2 — Checkout (Manual Meaning)

Explain:

Checkout = Getting latest code from Git.

Simulate Git process:

Initialize git:

```
git init
git add .
git commit -m "version 1"
```

In real world:

DevOps would do:

```
git clone https://repo-url
```

This is manual checkout.

---

# 🛠 Step 3 — Build (Manual Meaning)

Build = Prepare application to run.

For Node:

```
npm install
```

In Java it would be:

```
mvn package
```

Still manual.

---

# 🧪 Step 4 — Test (Manual Meaning)

There is no automation.

You manually test:

```
node app.js
```

Open browser:

```
http://server-ip:3000
```

You check manually if it works.

If broken?

You inform developer manually.

---

# 🐳 Step 5 — Docker Build (Manual)

Create Dockerfile:

```
nano Dockerfile
```

Paste:

```
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
```

Build image:

```
docker build -t manual-app:v1 .
```

Check:

```
docker images
```

---

# 🚀 Step 6 — Deploy (Manual Deployment)

Run container:

```
docker run -d -p 80:3000 --name manual-app manual-app:v1
```

Open browser:

```
http://server-ip
```

You deployed.

But EVERYTHING was manual.

---

# 🔁 Now Simulate Real Problem

Developer updates code.

Edit app.js:

Change message to:

"Manual Deployment Version 2"

Now what must DevOps do?

Manually:

```
git pull
docker stop manual-app
docker rm manual-app
docker build -t manual-app:v2 .
docker run -d -p 80:3000 --name manual-app manual-app:v2
```

Every time.

Ask students:

What if 10 developers push daily?

What if someone forgets test?
What if someone deploys wrong branch?
What if someone overwrites production?
What if someone forgets to rebuild image?

This is chaos.

---

# ❌ Problems Before Jenkins

No:

* Automated tests
* Build history
* Pipeline logs
* Standard process
* Automatic rollback
* Approval stages
* Parallel builds
* Security scanning

Everything depends on human.

Humans make mistakes.

---

# 🎯 Important Teaching Moment

Ask students:

What exactly did we do?

Answer:

We manually executed:

Checkout
Build
Test
Package
Deploy

Then say:

“Jenkins does exactly these steps — but automatically.”

---

# 🧨 Final Exercise For Students

Tell them:

Now imagine:

5 developers
2 environments
3 servers
Midnight deployment

Would you survive without automation?

Now they understand why Jenkins was born.

---

# 🔥 Key Learning Outcome

Before Jenkins:
DevOps = Manual command executor.

After Jenkins:
DevOps = Automation engineer.









# 🎯 LAB GOAL



1. Create simple Node.js app
2. Build Docker image
3. Run container manually
4. Deploy same app to Kubernetes
5. Update app manually
6. Redeploy manually



Docker ≠ Kubernetes
Kubernetes ≠ Jenkins

---

# 🧰 Requirements (Mac)

You need:

* Docker Desktop installed
* Kubernetes enabled inside Docker Desktop

Enable Kubernetes:

Docker Desktop → Settings → Kubernetes → Enable

Check:

```
kubectl version --client
kubectl get nodes
```

You should see one node.

---

# 🔥 STEP 1 — Create Application

Open Terminal:

```
mkdir k8s-manual-lab
cd k8s-manual-lab
```

Create file:

```
nano app.js
```

Paste:

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.end("Version 1 - Running in Kubernetes");
});

server.listen(3000);
```

Save and exit.

---

# 🔥 STEP 2 — Initialize Project

```
npm init -y
```

Install dependency (none needed, but simulate build):

```
npm install
```

Explain clearly:

Build here means preparing the app to run.

---

# 🔥 STEP 3 — Test Locally (Manual Test)

Run:

```
node app.js
```

Open:

[http://localhost:3000](http://localhost:3000)

You see:

Version 1 - Running in Kubernetes

Stop with Ctrl + C.

---

# 🔥 STEP 4 — Create Dockerfile

```
nano Dockerfile
```

Paste:

```
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
```

Save.

---

# 🔥 STEP 5 — Build Docker Image

```
docker build -t manual-k8s-app:v1 .
```

Check:

```
docker images
```

Explain:

Docker only packages application.

It does NOT manage scaling.
It does NOT restart containers automatically.

---

# 🔥 STEP 6 — Test Docker Manually

Run container:

```
docker run -d -p 8080:3000 --name test-container manual-k8s-app:v1
```

Open:

[http://localhost:8080](http://localhost:8080)

Stop container:

```
docker stop test-container
docker rm test-container
```

Explain:

Docker runs container.
But no high availability.
No scaling.

Now we bring Kubernetes.

---

# ☸ STEP 7 — Create Kubernetes Deployment

Create folder:

```
mkdir k8s
```

Create deployment file:

```
nano k8s/deployment.yaml
```

Paste:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: manual-app
spec:
  replicas: 2
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
        image: manual-k8s-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 3000
```

Important:
imagePullPolicy: Never (because local image)

Save.

---

# 🔥 STEP 8 — Create Service

```
nano k8s/service.yaml
```

Paste:

```
apiVersion: v1
kind: Service
metadata:
  name: manual-service
spec:
  type: NodePort
  selector:
    app: manual-app
  ports:
    - port: 80
      targetPort: 3000
      nodePort: 30007
```

Save.

---

# 🔥 STEP 9 — Deploy to Kubernetes (Manual Deployment)

Apply:

```
kubectl apply -f k8s/
```

Check:

```
kubectl get pods
kubectl get svc
```

Open:

[http://localhost:30007](http://localhost:30007)

You see:

Version 1 - Running in Kubernetes

---

# 🔥 WHAT JUST HAPPENED?

Kubernetes:

* Created 2 pods
* Running 2 containers
* Exposed service
* Managing replicas

Docker:
Built the image.

You:
Deployed manually.

No Jenkins.

---

# 🔥 STEP 10 — Simulate Update

Edit app.js:

Change message to:

"Version 2 - Updated"

---

# 🔥 STEP 11 — Manual Redeployment

Rebuild image:

```
docker build -t manual-k8s-app:v2 .
```

Update deployment.yaml:

Change image:

```
image: manual-k8s-app:v2
```

Apply again:

```
kubectl apply -f k8s/
```

Kubernetes performs rolling update.

Check:

```
kubectl get pods
```

Refresh browser.

Now Version 2 appears.

---





Who built image?
→ Docker

Who created pods?
→ Kubernetes

Who updated version?
→ You (human)

Where is Jenkins?
→ Nowhere.

Everything manual.

---

# 🎯 Clear Separation

Docker:
Packaging

Kubernetes:
Running & scaling

Human:
Automation (manually)

Jenkins:
Would automate the commands we typed.

---



Docker builds container.

Kubernetes runs containers at scale.

Without Jenkins:
Human runs kubectl manually.

With Jenkins:
Jenkins runs kubectl automatically.









# 0) What each tool does 

**Docker** = packages app into an image
**ECR** = stores Docker images (like “Docker Hub” but AWS)
**EKS** = Kubernetes cluster that runs containers (pods)
**Jenkins** = automation server that runs the same commands you would run manually (build/test/push/deploy)


Jenkins does NOT run pods. EKS runs pods. Jenkins only executes `docker` + `kubectl` commands.

---

# 1) Lab architecture

**GitHub → Jenkins (EC2) → build image → push to ECR → kubectl apply to EKS → app runs in EKS**

---

# 2) Prerequisites

## 2.1 Jenkins EC2 requirements

* Ubuntu EC2 with Jenkins installed (you already have)
* Jenkins user must be able to run:

  * `docker`
  * `aws`
  * `kubectl`

## 2.2 IAM role for Jenkins EC2 (VERY IMPORTANT)

Attach an IAM Role to the Jenkins EC2 instance.

### AWS Console clicks

1. **IAM → Roles → Create role**
2. Trusted entity: **AWS service → EC2**
3. Attach policies (minimum for this lab):

   * **AmazonEC2ContainerRegistryPowerUser** (or FullAccess for easiest labs)
   * **AmazonEKSClusterPolicy**
   * **AmazonEKSWorkerNodePolicy**
   * **AmazonEKS_CNI_Policy**
   * **AmazonEKSServicePolicy** (if available in your console; not always needed)
   * **AmazonSSMManagedInstanceCore** (optional but helpful)
4. Role name: `jenkins-eks-ecr-role`
5. **EC2 → Instances → (select Jenkins instance) → Actions → Security → Modify IAM role**
6. Select `jenkins-eks-ecr-role` → Save

---

# 3) Create ECR (us-east-2)

## 3.1 SSH to Jenkins EC2

```bash
ssh -i yourkey.pem ubuntu@EC2_PUBLIC_IP
```

## 3.2 Install tools on Jenkins EC2

```bash
sudo apt update -y
sudo apt install -y awscli git docker.io unzip curl
sudo usermod -aG docker ubuntu
sudo systemctl enable --now docker
```

Reconnect SSH (so docker group applies).

Verify:

```bash
aws --version
docker --version
```

## 3.3 Create ECR repo

Pick a repo name (example: `jtt-demo-app`):

```bash
export AWS_REGION=us-east-2
export ECR_REPO_NAME=jtt-demo-app

aws ecr create-repository \
  --repository-name "$ECR_REPO_NAME" \
  --region "$AWS_REGION"
```

Get your ECR URI:

```bash
aws ecr describe-repositories \
  --repository-names "$ECR_REPO_NAME" \
  --region "$AWS_REGION" \
  --query 'repositories[0].repositoryUri' \
  --output text
```

Save it as a variable:

```bash
export ECR_URI=$(aws ecr describe-repositories \
  --repository-names "$ECR_REPO_NAME" \
  --region "$AWS_REGION" \
  --query 'repositories[0].repositoryUri' \
  --output text)

echo $ECR_URI
```

Example output:
`123456789012.dkr.ecr.us-east-2.amazonaws.com/jtt-demo-app`

---

# 4) Create EKS in us-east-2 (with eksctl)

## 4.1 Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version --client
```

## 4.2 Install eksctl

```bash
curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/eksctl
eksctl version
```

## 4.3 Create the EKS cluster

This creates:

* EKS control plane
* Nodegroup with 2 worker nodes

```bash
export CLUSTER_NAME=jtt-eks-demo

eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --nodegroup-name jtt-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --managed
```

## 4.4 Verify cluster access

```bash
kubectl get nodes
kubectl get pods -A
```

If you see nodes in **Ready** state → EKS is done.

---

# 5) Create a demo app repo (skeleton + code)

You can do this on your laptop then push to GitHub, or create on EC2 and push. Here’s the repo skeleton:

```
jtt-demo-app/
  app.js
  package.json
  Dockerfile
  k8s/
    deployment.yaml
    service.yaml
```

## 5.1 app.js

```js
const http = require("http");

const server = http.createServer((req, res) => {
  res.end("JumpToTech Demo - Version 1 (EKS via Jenkins)");
});

server.listen(3000, () => console.log("Listening on 3000"));
```

## 5.2 package.json

```json
{
  "name": "jtt-demo-app",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "test": "node -c app.js",
    "start": "node app.js"
  }
}
```

## 5.3 Dockerfile

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install --omit=dev
COPY app.js .
EXPOSE 3000
CMD ["node","app.js"]
```

## 5.4 k8s/deployment.yaml  (IMPORTANT: uses ECR image)

Replace `ACCOUNT_ID` with yours (or just use Jenkins to inject).
For now, put a placeholder image; Jenkins will `kubectl set image`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jtt-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: jtt-demo
  template:
    metadata:
      labels:
        app: jtt-demo
    spec:
      containers:
        - name: jtt-demo
          image: ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/jtt-demo-app:latest
          ports:
            - containerPort: 3000
```

## 5.5 k8s/service.yaml (LoadBalancer)

This gives a public URL (AWS creates ELB for you).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: jtt-demo-svc
spec:
  type: LoadBalancer
  selector:
    app: jtt-demo
  ports:
    - port: 80
      targetPort: 3000
```

Push this repo to GitHub.

---

# 6) Jenkins setup (only what you need)

## 6.1 Install Jenkins plugins

Jenkins → **Manage Jenkins → Plugins**:

* **Pipeline**
* **Git**
* (Optional) **Credentials Binding** (usually already)

## 6.2 Ensure Jenkins can run docker + kubectl on EC2

On the EC2 host (not inside Jenkins UI), verify as the `jenkins` user:

```bash
sudo -u jenkins docker ps
sudo -u jenkins kubectl get nodes
sudo -u jenkins aws sts get-caller-identity
```

If `docker` permission fails:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Then re-test.

---

# 7) Jenkins Pipeline (Jenkinsfile)

Create a Jenkins **Pipeline job**:
Jenkins → **New Item → Pipeline → OK**

Pipeline script (copy/paste).
**Edit these values:**

* `GIT_REPO`
* `ECR_REPO_NAME` if different
* region is already `us-east-2`
* cluster name is `jtt-eks-demo`

```groovy
pipeline {
  agent any

  environment {
    AWS_REGION   = 'us-east-2'
    CLUSTER_NAME = 'jtt-eks-demo'
    ECR_REPO_NAME = 'jtt-demo-app'   // must match your ECR repo name
    APP_NAME     = 'jtt-demo'
    K8S_NS       = 'default'
    GIT_REPO     = 'https://github.com/YOUR_USER/YOUR_REPO.git'
  }

  stages {

    stage('Checkout') {
      steps {
        // What it means: pull code from GitHub onto Jenkins workspace
        git url: "${GIT_REPO}"
      }
    }

    stage('Build (app dependencies)') {
      steps {
        // What it means (Node): prepare app to run (install deps)
        sh 'npm install'
      }
    }

    stage('Test') {
      steps {
        // Simple beginner test: check JS syntax
        sh 'npm test'
      }
    }

    stage('Docker Build') {
      steps {
        // Package app into a container image
        sh 'docker build -t ${ECR_REPO_NAME}:${BUILD_NUMBER} .'
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          set -e
          ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
          ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
          aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
          echo "ECR_URI=$ECR_URI" > ecr_env.txt
        '''
      }
    }

    stage('Tag & Push to ECR') {
      steps {
        sh '''
          set -e
          source ecr_env.txt
          docker tag ${ECR_REPO_NAME}:${BUILD_NUMBER} ${ECR_URI}:${BUILD_NUMBER}
          docker tag ${ECR_REPO_NAME}:${BUILD_NUMBER} ${ECR_URI}:latest
          docker push ${ECR_URI}:${BUILD_NUMBER}
          docker push ${ECR_URI}:latest
        '''
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh '''
          set -e
          source ecr_env.txt

          # Connect kubectl to your EKS cluster
          aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

          # Apply manifests (creates/updates deployment + service)
          kubectl apply -f k8s/ -n ${K8S_NS}

          # Ensure the deployment uses the new image tag
          kubectl set image deployment/${APP_NAME} ${APP_NAME}=${ECR_URI}:${BUILD_NUMBER} -n ${K8S_NS}

          # Wait until rollout finishes
          kubectl rollout status deployment/${APP_NAME} -n ${K8S_NS}
        '''
      }
    }

    stage('Show Service URL') {
      steps {
        sh '''
          echo "Waiting for LoadBalancer hostname..."
          kubectl get svc jtt-demo-svc -n default -o wide
        '''
      }
    }
  }
}
```



* **Checkout**: Jenkins downloaded code from GitHub
* **Build**: Jenkins prepared the app (`npm install`)
* **Test**: Jenkins verified code (`npm test`)
* **Docker Build**: Jenkins packaged app into image
* **Push to ECR**: Jenkins stored image in AWS
* **Deploy to EKS**: Jenkins told Kubernetes to update

---

# 8) Verify app is live (EKS)

On Jenkins EC2:

```bash
kubectl get pods
kubectl get svc jtt-demo-svc -o wide
```

You will see an **EXTERNAL-IP / hostname** (may take 1–3 minutes).
Open it in browser.

---

# 9) Update demo (prove automation)

Change `app.js` text to Version 2, push to GitHub, run pipeline again.



* Jenkins rebuilds
* pushes new image
* EKS does rolling update automatically

---

# 10) Cleanup (avoid AWS cost)

Delete EKS cluster:

```bash
eksctl delete cluster --name jtt-eks-demo --region us-east-2
```

Delete ECR repo:

```bash
aws ecr delete-repository --repository-name jtt-demo-app --region us-east-2 --force
```




**Without Jenkins** (human does it):

1. git clone (checkout)
2. npm install (build)
3. npm test (test)
4. docker build (package)
5. docker push (store)
6. kubectl apply (deploy)

**With Jenkins** (automation does it):
Same exact steps — Jenkins executes them automatically.























