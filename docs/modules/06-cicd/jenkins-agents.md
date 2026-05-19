---
title: "Jenkins Agents lab"
description: "0) What “create” vs “enable” means     Create agent = define a node in Jenkins UI (name,..."
published: 2026-02-06
source: "https://dev.to/jumptotech/jenkins-agents-1d1g"
tags: []
---

# Jenkins Agents lab



## 0) What “create” vs “enable” means

* **Create agent** = define a node in Jenkins UI (name, labels, workspace).
* **Enable agent** = start the agent process so it connects and becomes **Online**.

---

## A) Create a local agent on your Mac (Controller on localhost)

### Step 1 — Create agent workspace folder (Terminal)

```bash
mkdir -p ~/jenkins-agent
```

### Step 2 — Create the node in Jenkins (UI)

1. Open Jenkins: `http://localhost:9090`
2. **Manage Jenkins → Nodes and Clouds**
3. Click **New Node**
4. Name: `mac-agent`
5. Type: **Permanent Agent**
6. Click **Create**

### Step 3 — Configure the node (UI)

Fill:

* **Number of executors**: `1`
* **Remote root directory**:

  ```
  /Users/aisalkyn/jenkins-agent
  ```
* **Labels**:

  ```
  mac local
  ```
* **Usage**: *Use this node as much as possible*
* **Launch method**: ✅ **Launch agent by connecting it to the controller**
* **Availability**: *Keep this agent online as much as possible*

Click **Save**.

---

## B) Enable (bring Online) the agent — Recommended method (WebSocket)

### Step 4 — Download agent.jar (Terminal)

```bash
cd ~/jenkins-agent
curl -o agent.jar http://localhost:9090/jnlpJars/agent.jar
```

### Step 5 — Start the agent (Terminal)

Run the agent (keep this terminal open):

```bash
java -jar agent.jar \
  -url http://localhost:9090 \
  -secret <PASTE_SECRET_FROM_NODE_PAGE> \
  -name mac-agent \
  -webSocket \
  -workDir "/Users/aisalkyn/jenkins-agent"
```

Where to get `<PASTE_SECRET_FROM_NODE_PAGE>`:

* **Nodes → mac-agent →** Jenkins shows the exact command and secret.

### Step 6 — Confirm it’s Online (UI)

Go to:

* **Manage Jenkins → Nodes and Clouds**
  You should see **mac-agent = green / Online**.

---

## C) Run a job on the agent (proof)

### Step 7 — Pipeline using label `mac`

Use this Jenkinsfile:

```groovy
pipeline {
  agent { label 'mac' }

  stages {
    stage('Proof') {
      steps {
        sh 'hostname'
        sh 'whoami'
        sh 'pwd'
      }
    }
  }
}
```

Expected: workspace path includes:
`/Users/aisalkyn/jenkins-agent/workspace/...`

---

## D) Common problems (fast fixes)

### Agent stays Offline

* You created the node but didn’t start the agent process.
* Fix: run the WebSocket command in terminal (Step 5).

### “Invalid or corrupt jarfile agent.jar”

* You downloaded agent.jar from a tunnel/redirect.
* Fix: re-download from:

  ```bash
  curl -o agent.jar http://localhost:9090/jnlpJars/agent.jar
  ```

### Jenkins won’t start (Java version)

* Jenkins supports Java 17/21.
* Start Jenkins using Java 21 explicitly:

  ```bash
  /opt/homebrew/opt/openjdk@21/bin/java -jar /opt/homebrew/opt/jenkins-lts/libexec/jenkins.war --httpPort=9090 --httpListenAddress=127.0.0.1
  ```

### Pipeline stuck “Still waiting to schedule task”

* Label mismatch or agent offline.
* Fix: ensure node has label `mac` and agent is Online.

---

## E) What to say in interviews (1 sentence)

“I create agents under **Nodes**, assign **labels**, and connect them using **WebSocket** so builds run on workers without opening inbound TCP ports.”















# LAB: Jenkins Agents — Scheduling, Labels, Parallelism, and Scaling

This lab **uses the agent you already created (`mac-agent`)** and teaches:

* how Jenkins schedules work
* why agents matter
* when you need more agents

---

## LAB 1 — Prove the build runs on the agent (baseline)

### Goal

Verify that jobs **do not run on the controller**, but on `mac-agent`.

### Jenkinsfile (Job 1)

```groovy
pipeline {
  agent { label 'mac' }

  stages {
    stage('Where am I running?') {
      steps {
        sh 'echo "Node name: $NODE_NAME"'
        sh 'hostname'
        sh 'whoami'
        sh 'pwd'
      }
    }
  }
}
```

### Expected result

* `NODE_NAME = mac-agent`
* Workspace path:

  ```
  /Users/aisalkyn/jenkins-agent/workspace/...
  ```

### DevOps takeaway

> Agent labels decide **where** code runs.

---

## LAB 2 — What happens if the agent is offline?

### Goal

Understand *why* jobs get stuck.

### Steps

1. Stop the agent process (Ctrl+C in terminal)
2. Click **Build Now**

### Result

* Job stuck in **Build Queue**
* Message:

  ```
  Still waiting to schedule task
  mac-agent is offline
  ```

### DevOps takeaway

> Jenkins does not “start” agents.
> Agents must be alive for jobs to run.

---

## LAB 3 — Controller vs Agent (anti-pattern demo)

### Goal

Show why running on controller is bad practice.

### Jenkinsfile (Job 2)

```groovy
pipeline {
  agent any

  stages {
    stage('Controller test') {
      steps {
        sh 'echo "Running on $NODE_NAME"'
      }
    }
  }
}
```

### Result

* Runs on **Built-In Node**

### Explain to students

* Controller should **not**:

  * build Docker images
  * run Terraform
  * run heavy tests

### DevOps rule

> `agent any` is dangerous in production.

---

## LAB 4 — Labels control scheduling (important)

### Goal

Show how labels select agents.

### Step

Change label in Jenkinsfile to something invalid:

```groovy
agent { label 'linux' }
```

### Result

* Job stuck in queue

### Fix

Change back:

```groovy
agent { label 'mac' }
```

### DevOps takeaway

> Label mismatch = no execution.

---

## LAB 5 — Parallel builds with a single agent

### Goal

Show executor limitation.

### Jenkinsfile (Job 3)

```groovy
pipeline {
  agent { label 'mac' }

  stages {
    stage('Parallel test') {
      parallel {
        stage('Task A') {
          steps {
            sh 'sleep 20'
          }
        }
        stage('Task B') {
          steps {
            sh 'sleep 20'
          }
        }
      }
    }
  }
}
```

### Result

* One stage runs
* Other waits

### Why?

* `mac-agent` has **1 executor**

---

## LAB 6 — Increase executors vs add agents

### Option A — Increase executors

In **mac-agent config**:

* Executors: `2`

Re-run job → both stages run.

### Option B — Add another agent

Create `mac-agent-2` with 1 executor.

### DevOps rule

| Method         | When to use                |
| -------------- | -------------------------- |
| More executors | Light workloads            |
| More agents    | Heavy / isolated workloads |

---

## LAB 7 — Simulate real DevOps workloads

### Jenkinsfile

```groovy
pipeline {
  agent { label 'mac' }

  stages {
    stage('Build') {
      steps {
        sh 'echo "Building..."'
        sh 'sleep 10'
      }
    }

    stage('Test') {
      steps {
        sh 'echo "Testing..."'
        sh 'sleep 10'
      }
    }

    stage('Package') {
      steps {
        sh 'echo "Packaging..."'
        sh 'sleep 10'
      }
    }
  }
}
```

### Explain

* In real CI:

  * build → test → scan → package
* All executed by agents, not controller

---

# Do you NEED more agents?

## Short answer

**Right now: NO**
**In real DevOps: YES**

---

## When ONE agent is enough

* Learning Jenkins
* Demos
* Small team
* Sequential pipelines

You are here now ✅

---

## When you MUST add more agents

### 1️⃣ Parallel pipelines

* Multiple devs pushing code
* CI jobs pile up

### 2️⃣ Different tools

* One agent for Docker
* One for Terraform
* One for security scans

### 3️⃣ Different OS

* Linux agent
* Windows agent
* macOS agent

### 4️⃣ Security isolation

* Prod deploy agent ≠ build agent

---

## Real-world DevOps setup (typical)

| Agent type         | Purpose           |
| ------------------ | ----------------- |
| Linux Docker agent | CI builds         |
| Terraform agent    | Infra             |
| Security agent     | Scans             |
| Kubernetes agents  | Scaled CI         |
| Mac agent          | iOS / local demos |

---

## Interview-ready conclusion (memorize)

> “I start with one agent for learning, but in real DevOps we use multiple, often ephemeral agents to handle parallel builds, isolation, security, and different environments.”


