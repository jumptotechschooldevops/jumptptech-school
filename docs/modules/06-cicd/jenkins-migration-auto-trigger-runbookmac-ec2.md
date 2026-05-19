---
title: "Jenkins Migration & Auto-Trigger Runbook(Mac EC2)"
description: "Goal    Move Jenkins controller from Mac → EC2   Preserve all Jenkins data (jobs, plugins,..."
published: 2026-02-11
source: "https://dev.to/jumptotech/jenkins-migration-auto-trigger-runbookmac-ec2-1mk0"
tags: []
---

# Jenkins Migration & Auto-Trigger Runbook(Mac EC2)



 

## Goal

* Move Jenkins **controller** from Mac → **EC2**
* **Preserve all Jenkins data** (jobs, plugins, credentials)
* Keep **agents on Mac**
* Enable **auto-trigger from GitHub** (no “Build Now”)

---

## Architecture (Final State)

```
GitHub (push)
   |
   v
EC2 Jenkins Controller (8080)
   |
   v
Mac Agents (mac-agent, node-mac1)
```

* Jenkins **state** lives on EC2
* Jenkins **builds** run on Mac
* GitHub triggers Jenkins via webhook

---

# PART 1 — Backup Jenkins from Mac

### 1. Locate Jenkins home on Mac

```bash
ls -ld ~/.jenkins
```

This folder contains:

* jobs
* plugins
* credentials
* build history

---

### 2. Create backup archive

```bash
cd ~
tar -czvf jenkins-backup.tar.gz .jenkins
```

Verify:

```bash
ls -lh jenkins-backup.tar.gz
```

Expected: ~400MB

---

# PART 2 — Create Jenkins Controller on EC2

### 3. EC2 Security Group (CRITICAL)

Inbound rules:

* SSH 22 → your IP
* **Custom TCP 8080 → 0.0.0.0/0**

If 8080 is closed → browser won’t open Jenkins.

---

### 4. Install Java 17

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

Expected:

```
openjdk version "17"
```

---

### 5. Create Jenkins directories

```bash
sudo mkdir -p /opt/jenkins
sudo mkdir -p /var/lib/jenkins
sudo chown -R ubuntu:ubuntu /opt/jenkins /var/lib/jenkins
```

---

### 6. Download Jenkins WAR

```bash
cd /opt/jenkins
curl -LO https://get.jenkins.io/war-stable/latest/jenkins.war
ls -lh jenkins.war
```

Expected: ~92MB

---

# PART 3 — Copy Backup to EC2

### 7. Copy backup from Mac → EC2

Run **from Mac**:

```bash
scp -i ~/Downloads/pem/key.pem \
~/jenkins-backup.tar.gz \
ubuntu@<EC2_PUBLIC_IP>:/home/ubuntu/
```

Verify on EC2:

```bash
ls -lh /home/ubuntu/jenkins-backup.tar.gz
```

---

# PART 4 — Restore Jenkins Data on EC2

### 8. Extract backup

```bash
sudo tar -xzf /home/ubuntu/jenkins-backup.tar.gz -C /var/lib
```

You will now have:

```
/var/lib/.jenkins
```

---

### 9. Move data into correct Jenkins home

```bash
sudo rm -rf /var/lib/jenkins
sudo mv /var/lib/.jenkins /var/lib/jenkins
sudo chown -R ubuntu:ubuntu /var/lib/jenkins
```

Verify:

```bash
ls /var/lib/jenkins | head
```

Expected:

* config.xml
* credentials.xml
* jobs/
* plugins/

---

# PART 5 — Start Jenkins Controller

### 10. Start Jenkins (background)

```bash
cd /opt/jenkins
nohup java -jar jenkins.war \
--httpPort=8080 \
--prefix=/ \
--webroot=/tmp/jenkins \
> jenkins.log 2>&1 &
```

Verify:

```bash
ps aux | grep jenkins.war
```

---

### 11. Open Jenkins in browser

```
http://<EC2_PUBLIC_IP>:8080
```

You should see:

* all old jobs
* no “fresh install” wizard

---

# PART 6 — Reconnect Mac Agents

### 12. Why agents were offline

* Controller URL changed (localhost → EC2 IP)
* Agents must reconnect manually

---

### 13. On Mac, start each agent

From Jenkins UI:

```
Manage Jenkins → Nodes → mac-agent → Launch agent
```

Run the command Jenkins shows (example):

```bash
java -jar agent.jar \
-jnlpUrl http://<EC2_IP>:8080/computer/mac-agent/jenkins-agent.jnlp \
-secret <SECRET> \
-workDir ~/jenkins-agent
```

Repeat for `node-mac1`.

Verify:

```
Manage Jenkins → Nodes
```

Status should be **online**.

---

# PART 7 — Enable GitHub Auto-Trigger (NO “Build Now”)

## 14. Jenkins Job Configuration (Pipeline job)

UI clicks:

```
Job → Configure → Triggers
```

✅ Check:

* **GitHub hook trigger for GITScm polling**

Save.

---

## 15. Jenkinsfile (REQUIRED)

Your Jenkinsfile must be in repo root:

```groovy
pipeline {
  agent any

  triggers {
    githubPush()
  }

  stages {
    stage('Build') {
      steps {
        echo "Build running"
      }
    }
  }
}
```

---

## 16. GitHub Webhook Setup

GitHub UI:

```
Repo → Settings → Webhooks → Add webhook
```

Payload URL:

```
http://<EC2_PUBLIC_IP>:8080/github-webhook/
```

Content type:

```
application/json
```

Events:

* Just the push event

Save.

---

### 17. Verify webhook delivery

GitHub:

```
Webhooks → Recent Deliveries
```

Expected:

* Status **200**
* Jenkins build triggered automatically

---

# PART 8 — Validation (Production Check)

Push code:

```bash
git add Jenkinsfile
git commit -m "enable ci"
git push origin main
```

Expected in Jenkins:

* Build starts automatically
* “Started by GitHub push”
* Runs on Mac agent

---

# PART 9 — Troubleshooting (IF BROKEN → DO THIS)

## ❌ Jenkins UI not opening

* Check security group port 8080
* `ps aux | grep jenkins.war`

---

## ❌ Jenkins asks for new admin password

* Wrong JENKINS_HOME
* Verify:

```bash
ls /var/lib/jenkins/config.xml
```

---

## ❌ Agents offline

* Restart agent command
* Verify controller URL is EC2 IP

---

## ❌ Push does not trigger build

Checklist:

* Jenkins job has GitHub hook trigger checked
* Webhook URL is correct
* Webhook delivery = 200
* Jenkinsfile exists in repo root

---

# WHY THIS IS DEVOPS

You handled:

* Infrastructure (EC2, security groups)
* State migration (Jenkins home)
* CI automation (webhooks)
* Distributed systems (controller + agents)
* Troubleshooting real production failures

This is **real DevOps**, not theory.









# Lab Overview: “Jenkins Operations for DevOps”

You will build a Jenkins controller and practice:

1. Install Jenkins (WAR, package, Docker)
2. Run Jenkins as a service (systemd)
3. Upgrade Jenkins safely
4. Backup & restore
5. Migrate Jenkins to a new server
6. Change Jenkins URL and ports
7. Monitor disk usage in `/var/lib/jenkins`

## Who does this in production?

* **Platform/DevOps/SRE**: installs Jenkins, manages uptime, backups, upgrades, agents, security, plugins.
* **Security/Compliance**: reviews access, secrets, audit requirements.
* **Developers**: write Jenkinsfiles, maintain pipelines (sometimes DevOps helps).

---

# Prereqs 

## AWS / EC2

* 2 EC2 Ubuntu instances (or 1 if you simulate migration with a second directory)

  * **EC2-1**: `jenkins-old` (source)
  * **EC2-2**: `jenkins-new` (destination)
* Security Group inbound:

  * SSH 22 from your IP
  * Jenkins port (we will use **8080**) from your IP (for learning). In real prod, you’d put it behind 443.

## On both instances

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk curl unzip git
java -version
```

Expected: Java 17.

---

# Part 1 — Install Jenkins 3 Ways (WAR, Package, Docker)

In production you typically choose **one** method, but DevOps should know all.

## 1A) Install Jenkins via WAR (portable, works anywhere)

### Why DevOps uses WAR

* Works even when apt repo keys break
* Great for controlled upgrades (you swap one war file)
* Easy to run without package managers

### Steps

```bash
sudo mkdir -p /opt/jenkins
sudo mkdir -p /var/lib/jenkins
sudo chown -R ubuntu:ubuntu /opt/jenkins /var/lib/jenkins

cd /opt/jenkins
curl -LO https://get.jenkins.io/war-stable/latest/jenkins.war
ls -lh jenkins.war
```

Run once (foreground test):

```bash
export JENKINS_HOME=/var/lib/jenkins
java -jar /opt/jenkins/jenkins.war --httpPort=8080
```

Open browser:

```
http://<EC2_PUBLIC_IP>:8080
```

Stop it with Ctrl+C.

---

## 1B) Install Jenkins via Ubuntu package (classic production style)

### Why DevOps uses packages

* systemd service is created automatically
* standard OS patching tools
* simpler for many enterprises

### Note

You already hit repo GPG issues before. If repo works in your environment, follow Jenkins official repo steps; if it fails, WAR is the fallback.

---

## 1C) Install Jenkins via Docker (common in platform teams)

### Why DevOps uses Docker

* Consistent runtime
* Easy to move between servers
* Simple upgrades (new image)

### Steps

```bash
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
newgrp docker
docker --version
```

Run Jenkins container with persistent volume:

```bash
docker volume create jenkins_home

docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

Open:

```
http://<EC2_PUBLIC_IP>:8080
```

In production, Docker install is often replaced by Kubernetes, but the concept is the same: **persist Jenkins home**.

---

# Part 2 — Run Jenkins as a systemd Service (production requirement)

## Why DevOps does this

* Jenkins must survive reboot
* Must start automatically after instance restart
* Standard operations: start/stop/restart/status/logs

We’ll do systemd for **WAR method** (most educational).

## 2A) Create a dedicated Jenkins user (best practice)

```bash
sudo useradd -r -m -d /var/lib/jenkins -s /bin/bash jenkins || true
sudo chown -R jenkins:jenkins /var/lib/jenkins /opt/jenkins
```

## 2B) Create systemd service

```bash
sudo tee /etc/systemd/system/jenkins.service > /dev/null <<'EOF'
[Unit]
Description=Jenkins Controller (WAR)
After=network.target

[Service]
User=jenkins
Group=jenkins
Environment="JENKINS_HOME=/var/lib/jenkins"
WorkingDirectory=/opt/jenkins
ExecStart=/usr/bin/java -jar /opt/jenkins/jenkins.war --httpPort=8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

Enable + start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager
```

Logs:

```bash
sudo journalctl -u jenkins -n 100 --no-pager
```

**DevOps checkpoint:** reboot test

```bash
sudo reboot
```

After reconnect:

```bash
sudo systemctl status jenkins --no-pager
```

---

# Part 3 — Change Jenkins URL and Ports (real ops)

## Why DevOps does this

* Move from localhost → public DNS / Elastic IP
* Put Jenkins behind Nginx/ALB
* Meet company standards (443 TLS)

## 3A) Change Jenkins port (WAR)

Edit systemd service:

```bash
sudo sed -i 's/--httpPort=8080/--httpPort=9090/g' /etc/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

Open:

```
http://<EC2_PUBLIC_IP>:9090
```

Security Group must allow the new port (9090) or you won’t reach it.

## 3B) Set Jenkins URL in UI (important for webhooks and agents)

UI:

* Manage Jenkins → System → **Jenkins Location**
* Jenkins URL:

  * `http://<EC2_PUBLIC_IP>:8080/` (or your DNS)

**Why it matters:** GitHub webhooks and agent JNLP links depend on correct Jenkins URL.

---

# Part 4 — Backup & Restore (most important ops skill)

## Why DevOps does this

* Jenkins is stateful
* Loss of Jenkins home = loss of:

  * pipelines config
  * credentials
  * build history / audit logs
  * plugin configuration

## 4A) What to back up

Backup **JENKINS_HOME**:

* `/var/lib/jenkins` (WAR/systemd install)
* or `/var/jenkins_home` (Docker)
  This is the “source of truth”.

## 4B) Create a backup (tar)

Stop Jenkins to get a consistent backup:

```bash
sudo systemctl stop jenkins
```

Create archive:

```bash
sudo tar -czvf /home/ubuntu/jenkins-backup-$(date +%F).tar.gz -C /var/lib jenkins
ls -lh /home/ubuntu/jenkins-backup-*.tar.gz
```

Start Jenkins:

```bash
sudo systemctl start jenkins
```

## 4C) Restore (same server)

Stop Jenkins:

```bash
sudo systemctl stop jenkins
```

Restore into a clean directory:

```bash
sudo rm -rf /var/lib/jenkins
sudo tar -xzvf /home/ubuntu/jenkins-backup-YYYY-MM-DD.tar.gz -C /var/lib
sudo chown -R jenkins:jenkins /var/lib/jenkins
```

Start Jenkins:

```bash
sudo systemctl start jenkins
```

**Success indicator:** Jenkins opens and your jobs/credentials are back.

---

# Part 5 — Migrate Jenkins to a New Server (real production scenario)

This is exactly what you already did with Mac → EC2. Here’s the production version EC2-1 → EC2-2.

## 5A) On EC2-1 (source): backup

```bash
sudo systemctl stop jenkins
sudo tar -czvf /home/ubuntu/jenkins-migrate.tar.gz -C /var/lib jenkins
sudo systemctl start jenkins
```

Copy to EC2-2 (run from EC2-1 or your laptop):

```bash
scp -i <key.pem> /home/ubuntu/jenkins-migrate.tar.gz ubuntu@<EC2-2_PUBLIC_IP>:/home/ubuntu/
```

## 5B) On EC2-2 (destination): install Jenkins WAR + systemd (Part 1 + Part 2)

Make sure Jenkins service exists but is stopped before restore:

```bash
sudo systemctl stop jenkins || true
```

Restore:

```bash
sudo rm -rf /var/lib/jenkins
sudo tar -xzvf /home/ubuntu/jenkins-migrate.tar.gz -C /var/lib
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo systemctl start jenkins
```

Open Jenkins UI on EC2-2 and confirm old jobs exist.

## 5C) Update integrations after migration

DevOps must update:

* Jenkins URL (Manage Jenkins → System)
* GitHub webhook payload URL to new host
* Agents must reconnect to new controller host
* Any DNS/Elastic IP mapping

---

# Part 6 — Leave Agents on Mac (hybrid model)

## Why DevOps does this

* Mac builds require Mac (iOS/Xcode)
* Cheap to reuse existing machines
* Common in hybrid teams

## How it works (important)

Agents connect **outbound**:

* Mac agent → EC2 controller
  So your Mac being “local” is fine as long as it has internet.

## Steps to reconnect Mac agents (what you did)

UI:

* Manage Jenkins → Nodes → `<agent>` → Launch agent

Run on Mac:

```bash
cd ~/jenkins-agent
java -jar agent.jar \
  -jnlpUrl http://<EC2_IP>:8080/computer/<AGENT_NAME>/jenkins-agent.jnlp \
  -secret <SECRET> \
  -workDir ~/jenkins-agent
```

**DevOps checkpoints**

* Node shows “online”
* Labels match Jenkinsfile (very common failure)

---

# Part 7 — Auto-trigger on Git Push (no “Build Now”)

## Why DevOps does this

* CI must run automatically on every change
* Manual “Build Now” is not production CI

## 7A) Jenkins job settings (Pipeline-from-SCM job)

UI:

* Job → Configure → Triggers
  Enable:
* **GitHub hook trigger for GITScm polling**

Save.

## 7B) Jenkinsfile trigger

In Jenkinsfile:

```groovy
triggers { githubPush() }
```

## 7C) GitHub Webhook

GitHub repo → Settings → Webhooks → Add webhook:

* Payload URL:

  * `http://<EC2_IP>:8080/github-webhook/`
* Content type: `application/json`
* Events: Push

Then verify:

* Webhook → Recent deliveries → **200 OK**

**DevOps troubleshooting truth:** If GitHub deliveries are not 200, Jenkins will never trigger.

---

# Part 8 — Monitor disk usage (/var/lib/jenkins)

## Why DevOps cares

Jenkins fills disk fast due to:

* build logs
* workspaces
* artifacts
* plugin caches

If disk fills, Jenkins crashes or behaves badly.

## Commands

Check disk:

```bash
df -h
```

Check Jenkins home size:

```bash
sudo du -sh /var/lib/jenkins
sudo du -sh /var/lib/jenkins/jobs/* 2>/dev/null | sort -h | tail
```

Set build discard policy (UI):

* Job → Configure → Discard old builds
  Or global strategy in pipeline.

---

# Troubleshooting Guide (what we actually troubleshot)

## 1) “Jenkins UI not opening”

* Security group missing port 8080
* Jenkins not running
  Commands:

```bash
ps aux | grep jenkins.war
sudo systemctl status jenkins --no-pager
curl http://localhost:8080
```

## 2) “Jenkins looks like fresh install”

* Wrong JENKINS_HOME
* Restore extracted into wrong folder level (`.jenkins` vs `jenkins`)
  Check:

```bash
ls /var/lib/jenkins/config.xml
```

## 3) “Agents offline”

* Controller moved → agent still pointing to old URL
  Fix: relaunch agent using new EC2 URL.

## 4) “Push doesn’t trigger build”

Must have ALL:

* Job checkbox: GitHub hook trigger enabled
* Jenkinsfile triggers block
* GitHub webhook configured and returning 200

---



* Jenkins is stateful: **JENKINS_HOME is everything**
* Production needs:

  * systemd service
  * backups
  * upgrades plan
  * security (ports, creds)
  * webhooks for automation
  * reliable agents









