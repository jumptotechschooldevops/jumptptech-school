---
title: "AWS EC2 (Ubuntu) --------------------- Jenkins Controller (Orchestrator)"
description: "1️⃣ Your Current Architecture   That machine = Jenkins Controller (Master)  Your Nodes..."
published: 2026-02-12
source: "https://dev.to/jumptotech/aws-ec2-ubuntu-jenkins-46mb"
tags: []
---

# AWS EC2 (Ubuntu) --------------------- Jenkins Controller (Orchestrator)



# 1️⃣ Your Current Architecture


That machine = **Jenkins Controller (Master)**

Your Nodes page:

* Built-In Node (controller itself)
* linux (another Linux agent)
* mac-agent (Mac)
* node-mac1 (Mac)

So architecture is:

```
                 AWS EC2 (Ubuntu)
               ---------------------
               Jenkins Controller
               (Orchestrator)
               ---------------------
                     /     |      \
                    /      |       \
                Linux   Mac-Agent  Mac-Agent
               Agent      (M1)       (M1)
```

---

# 2️⃣ What Is Jenkins Controller?

Controller (formerly Master):

* Stores jobs
* Stores build history
* Stores credentials
* Stores plugins
* Reads Jenkinsfile
* Schedules builds
* Assigns builds to agents

In your case:

Controller = EC2 Ubuntu machine.

Path that matters:

```
/var/lib/jenkins
```

This is critical in production.

If this folder is lost → audit history lost.

DevOps must back this up.

---

# 3️⃣ What Is an Agent (Node)?

Agent:

* Executes builds
* Runs commands
* Builds Docker
* Runs tests
* Deploys apps

Agents DO NOT store pipeline history.

They just execute tasks.

Your mac-agent and node-mac1 are execution machines.

---

# 4️⃣ Where Do We Write What?

Very important.

## On EC2 (Controller)

You:

* Install Jenkins
* Install plugins
* Configure credentials
* Configure Shared Libraries
* Add nodes
* Create jobs
* Control security
* Configure backup

You DO NOT write code directly here.

Pipeline code lives in Git.

---

## On Mac Agents

You:

* Install Java
* Install required tools (Docker, Node, Maven, etc.)
* Configure SSH access
* Register node in Jenkins

Agents must have:

* Same tools needed for build
* Correct permissions
* Enough disk space

---

# 5️⃣ How Node Is Configured (What Each Field Means)

When you click:

Manage Jenkins → Nodes → New Node

You configure:

### Name

Example:

```
mac-agent
```

This is label reference.

---

### Number of Executors

If you set:

```
2
```

That agent can run 2 jobs at same time.

Production advice:

Keep low unless machine is powerful.

---

### Remote Root Directory

Example:

```
/Users/jenkins
```

This is where Jenkins stores workspace on that agent.

---

### Labels

Example:

```
mac
```

Now in Jenkinsfile you can write:

```groovy
pipeline {
    agent { label 'mac' }
}
```

This forces job to run on Mac agent.

---

# 6️⃣ How Jenkins Connects to Mac

Usually via SSH.

On Mac:

Install Java.

On EC2:

Add SSH credentials.

In node config:

* Launch method → Launch agents via SSH
* Host → Mac IP
* Credentials → SSH key

Then Jenkins connects and launches agent.jar automatically.

---

# 7️⃣ What Happens During Build?

When you click Build:

1. Controller reads Jenkinsfile
2. Determines agent label
3. Sends job to selected node
4. Node executes commands
5. Node returns logs
6. Controller stores logs

Controller coordinates.
Agent executes.

---

# 8️⃣ Example Jenkinsfile Using Your Nodes

Run on Linux:

```groovy
pipeline {
    agent { label 'linux' }

    stages {
        stage('Build') {
            steps {
                sh 'echo Running on Linux'
            }
        }
    }
}
```

Run on Mac:

```groovy
pipeline {
    agent { label 'mac-agent' }

    stages {
        stage('Build') {
            steps {
                sh 'echo Running on Mac'
            }
        }
    }
}
```

---

# 9️⃣ Why Use Multiple Nodes?

Real reasons:

* Build iOS app → must use Mac
* Build Docker image → Linux
* Run Windows tests → Windows node
* Parallel builds
* Load distribution
* Isolation

DevOps must design node architecture.

---

# 🔟 What DevOps Must Pay Attention To

This is very important for production.

## 1️⃣ Disk Space

If agent disk is full → build fails.

You saw:

```
Free Disk Space: 3.07 GiB (Linux)
```

3GB is LOW.

Production risk.

---

## 2️⃣ Swap Space

You have:

```
Free Swap Space: 0 B
```

No swap → memory pressure risk.

---

## 3️⃣ Clock Sync

If time difference exists → build issues (certificates, tokens).

---

## 4️⃣ Response Time

If high → network issue.

---

## 5️⃣ Security

Never allow agent to access:

* /var/lib/jenkins
* Controller system files

Agents must be isolated.

---

# 1️⃣1️⃣ Where Shared Library Runs

Important:

Shared library logic executes on:

* Controller for Groovy logic
* Agent for shell steps

Example:

```groovy
script {
   def version = "1.0"
}
sh "docker build ."
```

Groovy part runs in controller memory.
Shell runs on agent.

---

# 1️⃣2️⃣ Production Architecture Best Practice

Real company:

Controller:

* Small
* Secured
* No heavy builds

Agents:

* Scalable
* Ephemeral (Kubernetes)
* Auto-created

Your setup is static agents.

Good for lab.
Enterprise often uses:

* Kubernetes agents
* EC2 auto-scaling agents

---



Jenkins Controller = Brain
Agents = Workers

Brain schedules.
Workers execute.

Never overload the brain.

---

# 1️⃣4️⃣ Important Interview-Level Answer

If interviewer asks:

“How do you design Jenkins node architecture?”

You answer:

"I separate controller and execution nodes. The controller only orchestrates builds and stores state, while agents perform build execution. I assign labels based on workload type (Linux, Mac, Docker, etc.) and ensure disk monitoring, security isolation, and proper executor configuration."

That is senior-level answer.

---



On your EC2:

Check:

```
df -h
free -m
```

On Mac agents:

Check:

* Java installed
* SSH stable
* Enough disk
* Tools installed


