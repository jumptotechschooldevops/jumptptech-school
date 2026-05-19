---
title: "How to create shared library lab"
description: "🧠 LAB GOAL    Create a Shared Library repository Add proper folder structure Configure it in..."
published: 2026-02-12
source: "https://dev.to/jumptotech/how-to-create-shared-library-lab-5bpe"
tags: []
---

# How to create shared library lab


# 🧠 LAB GOAL



1. Create a Shared Library repository
2. Add proper folder structure
3. Configure it in Jenkins
4. Create an application repo
5. Use the library inside Jenkinsfile
6. Run the pipeline

By the end, you will understand:

* Who creates it
* Who uses it
* What DevOps controls
* What happens internally

---

# 🟢 PART 1 — Create Shared Library Repository

## Step 1 — Go to GitHub

Click **New Repository**

Repository name:

```
company-shared-lib
```

Click Create.

---

## Step 2 — Create Required Folder Structure

Inside that repository:

Click **Add file → Create new file**

In the file name field write:

```
vars/buildApp.groovy
```

This automatically creates the `vars` folder.

---

## Step 3 — Write First Shared Function

Inside `vars/buildApp.groovy`, paste:

```groovy
def call() {
    echo "Shared Library: Starting Build Stage"
    sh "echo Running build on $(hostname)"
}
```

Click Commit.

---

## Step 4 — Add Second Function

Click **Add file → Create new file**

Name:

```
vars/deployApp.groovy
```

Paste:

```groovy
def call(String environment) {

    echo "Shared Library: Deploying to ${environment}"

    if (environment == "prod") {
        input "Approve Production Deployment?"
    }

    sh "echo Deployment to ${environment} completed"
}
```

Click Commit.

---

# ✅ Shared Library Repo Is Ready

Your repo should now look like:

```
company-shared-lib/
   └── vars/
        ├── buildApp.groovy
        └── deployApp.groovy
```

Important:

* `vars` folder name must be exact
* File name becomes function name
* `def call()` makes it callable like a function

---

# 🟢 PART 2 — Configure Shared Library in Jenkins

Now go to your Jenkins UI:

```
http://13.59.246.183:8080
```

---

## Step 1 — Go To:

Manage Jenkins
→ Manage System

Scroll down to:

**Global Trusted Pipeline Libraries**

Click **Add**

(We use Trusted because DevOps owns this library.)

---

## Step 2 — Fill Configuration

Name:

```
company-lib
```

Default version:

```
main
```

Retrieval Method:

Modern SCM

SCM:

Git

Repository URL:

Paste your shared library GitHub URL

If private:
Add credentials.

Click Save.

---

# ✅ Shared Library Is Now Connected

Jenkins now knows:

"Whenever someone writes @Library('company-lib'), load this repo."

---

# 🟢 PART 3 — Create Application Repository

Now create second GitHub repository.

Name:

```
sample-app
```

Click Create.

---

## Step 1 — Add Jenkinsfile

Inside sample-app:

Add file:

```
Jenkinsfile
```

Paste:

```groovy
@Library('company-lib') _

pipeline {
    agent { label 'linux' }

    stages {

        stage('Build') {
            steps {
                buildApp()
            }
        }

        stage('Deploy to Dev') {
            steps {
                deployApp("dev")
            }
        }

        stage('Deploy to Prod') {
            steps {
                deployApp("prod")
            }
        }
    }
}
```

Commit.

---

# 🟢 PART 4 — Create Pipeline Job in Jenkins

Go to Jenkins Dashboard.

Click:

New Item

Name:

```
sample-app-pipeline
```

Select:

Pipeline

Click OK.

---

## Step 1 — Configure SCM

Scroll to bottom.

Pipeline section:

Definition:

```
Pipeline script from SCM
```

SCM:

```
Git
```

Repository URL:
Paste sample-app GitHub URL

Branch:

```
main
```

Script Path:

```
Jenkinsfile
```

Click Save.

---

# 🟢 PART 5 — Run The Pipeline

Click:

Build Now

Watch Console Output.

You will see:

* Shared Library loaded
* Build stage executed
* Dev deployment executed
* Production stage waits for approval

Click Approve.

Build completes.

---

# 🧠 What Just Happened?

Step-by-step internally:

1. Jenkins Controller loaded shared library repo
2. It imported functions from `vars`
3. It read Jenkinsfile
4. It sent shell commands to linux agent
5. Agent executed commands
6. Controller saved logs

Controller = Brain
Agent = Worker

---

# 🧑‍💻 Who Creates What in Real Company?

| Component             | Owner                                             |
| --------------------- | ------------------------------------------------- |
| Shared Library Repo   | DevOps / Platform Team                            |
| Jenkins Configuration | DevOps                                            |
| Application Code      | Developers                                        |
| Jenkinsfile in App    | Usually DevOps template, developers minimal edits |

Developers should NOT control deployment logic.

---

# 🔐 What DevOps Must Pay Attention To

Very important production topics:

1. Version control shared library
2. Protect Git branch
3. Use PR approvals
4. Never hardcode credentials
5. Test library changes in dev Jenkins
6. Monitor disk space on agents
7. Pin production pipelines to specific library version

Example version pin:

```groovy
@Library('company-lib@v1.0') _
```

---

# 📦 Final Architecture

EC2 (Controller):

* Orchestrates
* Stores history
* Loads library

GitHub:

* Shared library repo
* App repo

Agents:

* Execute build

---



Shared Library solves:

* Duplicate pipeline logic
* Standardization
* Security control
* Production safety
* Centralized CI/CD



















# 🧠 LAB GOAL

We will create:

Shared Library function:

```
buildAndPushECR(imageName, awsRegion)
```

It will:

1. Build Docker image
2. Login to ECR
3. Tag image
4. Push to ECR

---

# ⚙️ PRE-REQUISITES (VERY IMPORTANT)

Before starting, make sure:

On Jenkins Linux Agent:

```bash
docker --version
aws --version
```

If not installed:

```bash
sudo apt update
sudo apt install docker.io -y
sudo apt install awscli -y
sudo usermod -aG docker jenkins
```

Restart agent if needed.

---

# 🔐 IAM PERMISSION (BEST PRACTICE)

On EC2 Jenkins instance:

Attach IAM Role with permissions:

* AmazonEC2ContainerRegistryFullAccess
  OR custom policy allowing:

```
ecr:GetAuthorizationToken
ecr:BatchCheckLayerAvailability
ecr:PutImage
ecr:InitiateLayerUpload
ecr:UploadLayerPart
ecr:CompleteLayerUpload
```

Best practice: use IAM Role (not access keys).

---

# 🟢 PART 1 — Create ECR Repository

Go to AWS Console
→ ECR
→ Create Repository

Name:

```
demo-app
```

Click Create.

Copy:

Repository URI

Example:

```
021399177326.dkr.ecr.us-east-2.amazonaws.com/demo-app
```

Save this.

---

# 🟢 PART 2 — Create Shared Library Repo

Go to GitHub → Create new repo:

```
company-shared-lib
```

---

## Step 1 — Create Folder

Create:

```
vars/buildAndPushECR.groovy
```

---

## Step 2 — Paste This Code

```groovy
def call(String imageName, String region) {

    def accountId = sh(
        script: "aws sts get-caller-identity --query Account --output text",
        returnStdout: true
    ).trim()

    def ecrRepo = "${accountId}.dkr.ecr.${region}.amazonaws.com/${imageName}"
    def tag = "${env.BUILD_NUMBER}"

    echo "Building Docker Image..."
    sh "docker build -t ${imageName}:${tag} ."

    echo "Logging into ECR..."
    sh """
       aws ecr get-login-password --region ${region} | \
       docker login --username AWS --password-stdin ${accountId}.dkr.ecr.${region}.amazonaws.com
    """

    echo "Tagging Image..."
    sh "docker tag ${imageName}:${tag} ${ecrRepo}:${tag}"

    echo "Pushing Image..."
    sh "docker push ${ecrRepo}:${tag}"

    echo "Image pushed successfully: ${ecrRepo}:${tag}"
}
```

Commit.

---

# 🟢 PART 3 — Configure Shared Library in Jenkins

Go to Jenkins:

Manage Jenkins
→ Manage System
→ Global Trusted Pipeline Libraries
→ Add

Fill:

Name:

```
company-lib
```

Default Version:

```
main
```

SCM: Git
Repository URL: your shared library repo

Save.

---

# 🟢 PART 4 — Create Application Repo

Create new GitHub repo:

```
docker-demo-app
```

---

## Step 1 — Add Dockerfile

Create file:

```
Dockerfile
```

Paste:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

---

## Step 2 — Add index.html

```html
<h1>Jenkins Shared Library ECR Demo</h1>
```

---

## Step 3 — Add Jenkinsfile

```groovy
@Library('company-lib') _

pipeline {
    agent { label 'linux' }

    environment {
        AWS_REGION = "us-east-2"
        IMAGE_NAME = "demo-app"
    }

    stages {

        stage('Build and Push to ECR') {
            steps {
                buildAndPushECR(IMAGE_NAME, AWS_REGION)
            }
        }
    }
}
```

Commit.

---

# 🟢 PART 5 — Create Jenkins Pipeline Job

Jenkins → New Item

Name:

```
docker-ecr-pipeline
```

Type:

Pipeline

---

## Configure

Pipeline script from SCM
SCM: Git
Repository URL: docker-demo-app repo
Branch: main
Script Path: Jenkinsfile

Save.

---

# ▶️ RUN BUILD

Click Build Now.

Watch console.

You should see:

* Docker build
* ECR login
* Image tag
* Docker push

---

# 🔎 Verify in AWS

Go to AWS Console → ECR → demo-app

You will see image tag:

```
1
```

If build number = 1

---

# 🧠 What Just Happened?

1. Jenkins loaded shared library
2. It executed Groovy function
3. Agent built Docker image
4. Agent authenticated using IAM role
5. Agent pushed image to ECR
6. Controller saved logs

---

# 🏢 Real Enterprise Architecture

Platform Team:

* Writes shared library
* Controls Docker logic
* Controls tagging standard
* Controls ECR login method
* Controls security

Developers:

Only write:

```groovy
buildAndPushECR("my-service", "us-east-2")
```

They don’t handle login or credentials.

---

# 🔐 What DevOps Must Pay Attention To

Very important:

1. Never store AWS keys in Jenkinsfile
2. Use IAM Role on EC2
3. Protect shared library repo
4. Version library
5. Scan Docker image before push
6. Clean old Docker images to save disk

Cleanup example inside library:

```groovy
sh "docker system prune -f"
```

---

# 🎯 Interview-Level Explanation

If asked:

“How do you standardize Docker builds in Jenkins?”

Answer:

"I create a centralized shared library that handles Docker build and ECR push logic using IAM role authentication. This ensures consistent tagging, secure credential handling, and reuse across multiple microservices."

That is senior DevOps answer.



