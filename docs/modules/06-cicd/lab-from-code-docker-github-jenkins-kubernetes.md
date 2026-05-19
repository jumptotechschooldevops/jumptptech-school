---
title: "LAB: From Code Docker GitHub Jenkins Kubernetes"
description: "🔹 Architecture Overview (What Talks to What)           Flow:   Developer pushes code to..."
published: 2026-02-12
source: "https://dev.to/jumptotech/lab-from-code-docker-github-jenkins-kubernetes-45mn"
tags: []
---

# LAB: From Code Docker GitHub Jenkins Kubernetes






# 🔹 Architecture Overview (What Talks to What)

![Image](https://images.openai.com/static-rsc-3/1JssT43dRnj6AmZc9EbXImzBQaSLk1WhEXVOojNss6t_YgTlxYCTq3I6Db7m8irYraKbjg60ChYTiVETgOUyVSEeJcorUjJVvTpLWL4BD6Q?purpose=fullsize\&v=1)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fus675h83ygxu073brdt2.jpg)

![Image](https://miro.medium.com/1%2AuuZ-h5EH76LOtJ614z-qDA.png)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D500%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fdyzwicbhbr3mq76prwwm.png)

Flow:

1. Developer pushes code to GitHub
2. Jenkins pulls (checkout)
3. Jenkins builds Docker image
4. Jenkins tests app
5. Jenkins pushes image
6. Jenkins deploys to Kubernetes
7. Kubernetes runs containers

---

# 🔹 What Each Component Does

## Jenkins = Automation Brain

* Pulls code
* Builds image
* Runs tests
* Deploys

## Docker = Packaging Tool

* Converts app → image
* Image → container

## Kubernetes = Runtime

* Runs containers
* Manages scaling
* Restarts if crash

They are NOT the same.

---

# 🔹 STEP 1 — Create Project Structure

On your laptop (Mac):

```
mkdir devops-beginner-lab
cd devops-beginner-lab
```

Create folders:

```
mkdir app
mkdir k8s
touch Dockerfile
touch Jenkinsfile
```

---

# 🔹 STEP 2 — Write Simple App

Create:

app/app.py

```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from DevOps Lab!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Create requirements.txt

```
Flask
```

---

# 🔹 STEP 3 — Create Dockerfile

Dockerfile:

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app/ app/

EXPOSE 5000

CMD ["python", "app/app.py"]
```

---

# 🔹 STEP 4 — Test Docker Locally

Build:

```
docker build -t devops-lab:v1 .
```

Run:

```
docker run -p 5000:5000 devops-lab:v1
```

Open browser:

```
http://localhost:5000
```

You should see:
Hello from DevOps Lab!

---

# 🔹 STEP 5 — Push to GitHub

```
git init
git add .
git commit -m "initial commit"
```

Create repo in GitHub 

Then:

```
git remote add origin https://github.com/YOURNAME/devops-beginner-lab.git
git branch -M main
git push -u origin main
```

Now code is in GitHub.

---

# 🔹 STEP 6 — Create Kubernetes Files

k8s/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-lab
  template:
    metadata:
      labels:
        app: devops-lab
    spec:
      containers:
      - name: devops-lab
        image: YOUR_DOCKERHUB_USERNAME/devops-lab:v1
        ports:
        - containerPort: 5000
```

k8s/service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-lab-service
spec:
  type: NodePort
  selector:
    app: devops-lab
  ports:
    - port: 80
      targetPort: 5000
      nodePort: 30007
```

---

# 🔹 STEP 7 — What Jenkins Will Do (Pipeline Stages Explained)

Now understand this clearly:

| Stage    | What It Means             |
| -------- | ------------------------- |
| Checkout | Download code from GitHub |
| Build    | Create Docker image       |
| Test     | Run validation            |
| Push     | Push image to registry    |
| Deploy   | Apply Kubernetes YAML     |

This is the real DevOps lifecycle.

---

# 🔹 STEP 8 — Jenkinsfile

Jenkinsfile:

```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "yourdockerhub/devops-lab"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/YOURNAME/devops-beginner-lab.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:v1 .'
            }
        }

        stage('Test') {
            steps {
                sh 'echo "Basic test passed"'
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push $IMAGE_NAME:v1'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }
}
```

---

# 🔹 STEP 9 — Create Jenkins Job

In Jenkins UI:

New Item → Pipeline → Name: devops-lab

In configuration:

* Pipeline from SCM
* Git
* Put repo URL
* Script path: Jenkinsfile

Save → Build Now

---

# 🔹 STEP 10 — What Happens Now

Jenkins:

1. Pulls code (Checkout)
2. Builds Docker image
3. Pushes to DockerHub
4. Deploys to Kubernetes

Kubernetes:

* Creates Pods
* Runs containers
* Keeps 2 replicas
* Restarts if crash

They are completely different jobs.

---

# 🔹 Verify Kubernetes

```
kubectl get pods
kubectl get svc
```

Open:

```
http://NODE_IP:30007
```

You should see app running.

---

# 🔹 FINAL — Who Does What?

| Tool       | Responsibility     |
| ---------- | ------------------ |
| GitHub     | Stores code        |
| Jenkins    | Automates pipeline |
| Docker     | Builds image       |
| Kubernetes | Runs containers    |

---

# 🔥 Real DevOps Understanding

Jenkins = Factory
Docker = Packaging Machine
Kubernetes = Production Floor

Jenkins does NOT run the app.
Kubernetes runs the app.


