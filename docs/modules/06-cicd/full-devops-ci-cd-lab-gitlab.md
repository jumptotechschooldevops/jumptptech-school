---
title: "FULL DEVOPS CI CD LAB gitlab"
description: "🏗️ FINAL ARCHITECTURE      Developer (Mac)       ↓ GitLab CI Runner       ↓ GitLab Container..."
published: 2026-02-21
source: "https://dev.to/jumptotech/full-devops-ci-cd-lab-gitlab-2li7"
tags: []
---

# FULL DEVOPS CI CD LAB gitlab

 


# 🏗️ FINAL ARCHITECTURE

```
Developer (Mac)
      ↓
GitLab CI Runner
      ↓
GitLab Container Registry
      ↓
EC2 (Production Server)
      ↓
nginx (Port 80)
      ↓
Docker Container (Port 8081)
```

Jenkins runs separately on 8080.

---

# 🧱 STEP 1 — EC2 PREPARATION

### Install Docker

```bash
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
```

Log out and back in.

---

### Install nginx

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

---

# 🧠 TROUBLESHOOTING #1 — Port 80 Conflict

### Problem:

```
bind() to 0.0.0.0:80 failed (98: Address already in use)
```

### Cause:

Docker container was running on 80.

### Fix:

```bash
docker ps
docker stop web
docker rm web
sudo lsof -i :80
```

Then start nginx:

```bash
sudo systemctl start nginx
```

---

# 🧱 STEP 2 — Configure nginx Reverse Proxy

Edit:

```bash
sudo nano /etc/nginx/sites-available/default
```

Replace server block with:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Test:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

# 🧠 TROUBLESHOOTING #2 — Port 8080 Conflict

### Problem:

```
failed to bind host port 8080: address already in use
```

### Cause:

Jenkins running on 8080.

Check:

```bash
sudo lsof -i :8080
```

Result:

```
java jenkins 8080
```

### Fix:

Use port 8081 for Docker container.

---

# 🧱 STEP 3 — Dockerfile

Create `Dockerfile` in project root:

```dockerfile
FROM nginx:alpine
COPY public /usr/share/nginx/html
EXPOSE 80
```

---

# 🧱 STEP 4 — FINAL `.gitlab-ci.yml`

```yaml
stages:
  - build
  - deploy

variables:
  IMAGE_NAME: registry.gitlab.com/$CI_PROJECT_PATH:latest

build_and_push:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $IMAGE_NAME .
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
    - docker push $IMAGE_NAME
  only:
    - master

deploy_ec2:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh
  script:
    - echo "$EC2_KEY" > key.pem
    - chmod 600 key.pem
    - |
      ssh -o StrictHostKeyChecking=no -i key.pem ubuntu@$EC2_HOST "
        docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY &&
        docker pull $IMAGE_NAME &&
        docker stop web || true &&
        docker rm web || true &&
        docker run -d -p 8081:80 --name web --restart always $IMAGE_NAME
      "
  only:
    - master
```

---

# 🧠 TROUBLESHOOTING #3 — Image Not Found

### Error:

```
An image does not exist locally with the tag
```

### Cause:

Build and push were in separate jobs.

### Fix:

Combine build + push in same job (done above).

---

# 🧠 TROUBLESHOOTING #4 — Port 8081 Already Used

If this happens:

```bash
sudo lsof -i :8081
```

Clean:

```bash
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

---

# 🧠 TROUBLESHOOTING #5 — SSH Host Not Resolved

Error:

```
Could not resolve hostname
```

Cause:
EC2_HOST variable missing.

Fix:
Add in GitLab → Settings → CI/CD → Variables:

```
EC2_HOST = 3.131.97.47
EC2_KEY  = (full private key content)
```

Visible, not masked.

---

# 🧠 TROUBLESHOOTING #6 — Public Key Error

Error:

```
Permission denied (publickey)
```

Fix:

On EC2:

```bash
nano ~/.ssh/authorized_keys
```

Add your public key.

---

# 🧠 TROUBLESHOOTING #7 — CI Jobs Isolation

Problem:
Image built but not available in push stage.

Reason:
Each GitLab job runs in separate container.

Fix:
Combine stages.

---

# 🔥 FINAL WORKING DEPLOYMENT

After successful pipeline:

On EC2:

```bash
docker ps
```

You must see:

```
0.0.0.0:8081->80/tcp
```

Test:

```
http://3.131.97.47
```

---

# 🧠 WHAT YOU BUILT

You now have:

✔ CI/CD automation
✔ Docker image build
✔ GitLab registry integration
✔ SSH deployment
✔ nginx reverse proxy
✔ Port conflict resolution
✔ Jenkins coexistence
✔ Idempotent deployment
✔ Production-style architecture

---

# 🎓 THIS IS REAL DEVOPS

You debugged:

* Port conflicts
* CI isolation
* Reverse proxy
* SSH variables
* Docker container lifecycle
* Registry authentication
* Production deployment flow

This is senior-level debugging.


