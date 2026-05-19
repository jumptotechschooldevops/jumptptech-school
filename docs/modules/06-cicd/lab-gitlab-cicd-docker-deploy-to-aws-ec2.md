---
title: "LAB: GitLab CI/CD Docker Deploy to AWS EC2"
description: "🎯 Lab Objective   Build a full CI/CD pipeline that:   Connects GitLab to Mac terminal Builds..."
published: 2026-02-21
source: "https://dev.to/jumptotech/lab-gitlab-cicd-docker-deploy-to-aws-ec2-2k4o"
tags: []
---

# LAB: GitLab CI/CD Docker Deploy to AWS EC2




# 🎯 Lab Objective

Build a full CI/CD pipeline that:

1. Connects GitLab to Mac terminal
2. Builds Docker image
3. Pushes image to GitLab Registry
4. SSH into EC2
5. Deploys container
6. Handles real-world production errors

---

# 🏗️ Architecture

```
Mac Terminal
     ↓
GitLab Repo
     ↓
GitLab CI/CD Pipeline
     ↓
Docker Image Build
     ↓
Push to GitLab Container Registry
     ↓
SSH to AWS EC2
     ↓
Docker Pull & Run
     ↓
Application Live on Port 80
```



# 🔹 STEP 1 — GitLab Pages Basic Pipeline

We had:

`.gitlab-ci.yml`

```yaml
image: busybox

pages:
  stage: deploy
  script:
    - echo "The site will be deployed"
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

Trigger pipeline:

```bash
git commit --allow-empty -m "Trigger pipeline"
git push origin master
```

---

# 🔹 STEP 2 — Add Docker Build Stage

Create Dockerfile (ROOT of project):

```Dockerfile
FROM nginx:alpine
COPY public /usr/share/nginx/html
EXPOSE 80
```

---

Update `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - push
  - deploy

variables:
  IMAGE_NAME: registry.gitlab.com/$CI_PROJECT_PATH:latest

build_image:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $IMAGE_NAME .
```

---

# 🔹 STEP 5 — Push to GitLab Container Registry

Add:

```yaml
push_image:
  stage: push
  image: docker:24
  services:
    - docker:24-dind
  script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
    - docker push $IMAGE_NAME
```

---

# 🔴 ERROR #1 — Image Not Found

Error:

```
An image does not exist locally with the tag
```

Fix:
Make sure build and push stages use SAME $IMAGE_NAME.

---

# 🔹 STEP 6 — Deploy to AWS EC2

Deploy stage:

```yaml
deploy_ec2:
  stage: deploy
  image: alpine
  before_script:
    - apk add --no-cache openssh
  script:
    - echo "$EC2_KEY" > key.pem
    - chmod 600 key.pem
    - ssh -o StrictHostKeyChecking=no -i key.pem ubuntu@$EC2_HOST "
        docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY &&
        docker pull $IMAGE_NAME &&
        docker stop web || true &&
        docker rm web || true &&
        docker run -d -p 80:80 --name web $IMAGE_NAME
      "
```

---

# 🔴 ERROR #2 — SSH Hostname Not Resolved

Cause:
CI/CD variables not set.

Fix:

Go to:

Settings → CI/CD → Variables

Add:

### Variable 1

Key: `EC2_HOST`
Value: EC2 Public IP

### Variable 2

Key: `EC2_KEY`
Value: FULL .pem file content

Important:

* NOT protected
* Visible
* Separate variables

---

# 🔴 ERROR #3 — Port 80 Already in Use

Pipeline error:

```
failed to bind host port 80
address already in use
```

SSH into EC2:

```bash
sudo lsof -i :80
```

Found:

```
nginx running
```

Fix:

```bash
sudo systemctl stop nginx
sudo systemctl disable nginx
```

Re-run pipeline → SUCCESS.

---

# 🔹 Final Result

App accessible at:

```
http://EC2_PUBLIC_IP
```

---

# 🧠 Real DevOps Troubleshooting Lessons

You debugged:

| Issue                     | Tool Used              |
| ------------------------- | ---------------------- |
| SSH denied                | ssh-add                |
| Pipeline variable missing | GitLab CI/CD variables |
| Docker tag mismatch       | Inspect IMAGE_NAME     |
| SSH hostname error        | Check variables        |
| Port conflict             | lsof -i :80            |
| Nginx conflict            | systemctl stop         |

This is REAL production debugging.

---

# 🎓 Interview Explanation Version

If interviewer asks:

"How would you deploy using GitLab CI/CD to EC2?"

You answer:

1. Create Dockerfile
2. Configure multi-stage pipeline
3. Build image
4. Push to registry
5. Store SSH key & host as CI variables
6. Use SSH in deploy stage
7. Handle container replacement safely
8. Troubleshoot port conflicts
9. Ensure idempotent deployment

That is senior-level answer.




