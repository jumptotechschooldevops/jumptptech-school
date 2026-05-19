---
title: "JENKINS controller and agent LAB"
description: "Jenkins running on  Mac (controller)   2 agents (mac-agent, node-mac1) GitHub repo + webhook how..."
published: 2026-02-09
source: "https://dev.to/jumptotech/jenkins-controller-and-agent-lab-145l"
tags: []
---

# JENKINS controller and agent LAB



* Jenkins running on  **Mac (controller)**
* **2 agents** (`mac-agent`, `node-mac1`)
* GitHub repo + webhook



* **how controller vs agents work**
* **how CI/CD actually happens in a team**
* **what DevOps pays attention to**
* **what you troubleshoot daily**
* **why companies use Jenkins + GitHub**

No theory fluff — this is **real workday DevOps**.

---

# 

(Controller + 2 Agents + GitHub)

## LAB GOAL

Demonstrate:

* Jenkins **orchestration**
* Job execution on **agents**
* CI on PR / push
* Controlled merge to `main`
* DevOps responsibilities end-to-end

---

## ARCHITECTURE 
![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fnb3vwtkpjh1gdxgybac7.png)

![Image](https://miro.medium.com/0%2AuwMKT_XpzTwOAXxm.png)

![Image](https://www.scaler.com/topics/images/Jenkins-Agent-Architecture.webp)

```
Developer → GitHub → Webhook → Jenkins Controller
                                |
                ---------------------------------
                |                               |
            mac-agent                      node-mac1
```

Controller = brain
Agents = muscle

---

## PART 1 — Prepare the repo (real CI structure)

### Repo structure

```
jenkins-ci-lab/
├── Jenkinsfile
├── app/
│   └── app.sh
├── tests/
│   └── test.sh
└── README.md
```

### app/app.sh

```bash
#!/bin/bash
echo "Application running on $(hostname)"
sleep 3
```

```bash
chmod +x app/app.sh
```

### tests/test.sh

```bash
#!/bin/bash
echo "Running tests on $(hostname)"

if [ -f app/app.sh ]; then
  echo "TEST PASSED"
  exit 0
else
  echo "TEST FAILED"
  exit 1
fi
```

```bash
chmod +x tests/test.sh
```

Why DevOps cares:

* Simple but proves **where code runs**
* Shows **host isolation**
* Easy to break for failure demos

---

## PART 2 — Jenkinsfile (agent-aware, production style)

```groovy
pipeline {
    agent none   // IMPORTANT: controller does NOT run jobs

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            agent any
            steps {
                git branch: 'main',
                    url: 'https://github.com/YOUR_ORG/jenkins-ci-lab.git'
            }
        }

        stage('Build on mac-agent') {
            agent { label 'mac-agent' }
            steps {
                sh '''
                  echo "Build stage"
                  ./app/app.sh
                '''
            }
        }

        stage('Test on node-mac1') {
            agent { label 'node-mac1' }
            steps {
                sh '''
                  echo "Test stage"
                  ./tests/test.sh
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS"
        }
        failure {
            echo "Pipeline FAILED"
        }
        always {
            cleanWs()
        }
    }
}
```

---

## PART 3 — What this pipeline PROVES

### 1. Controller does NOT execute jobs

```groovy
agent none
```

DevOps rule:

* Controller orchestrates
* Agents execute

If agents are offline → pipeline waits.

---

### 2. Different stages run on different agents

* Build → `mac-agent`
* Test → `node-mac1`

You will see in logs:

```
Running on mac-agent in /Users/aisalkyn/jenkins-agent/workspace/...
Running on node-mac1 in /Users/aisalkyn/jenkins-agent/workspace/...
```

This proves:

* Distributed execution
* Load isolation
* Real CI scaling

---

## PART 4 — CI workflow (how teams work)

### Daily team flow (REAL LIFE)

1. Developer creates feature branch
2. Pushes code to GitHub
3. GitHub webhook triggers Jenkins
4. Jenkins:

   * checks out code
   * builds on agent
   * tests on another agent
5. If CI passes → PR approved
6. Merge to `main`

DevOps responsibility:

* CI must be **fast**
* CI must be **reliable**
* CI must **block bad code**

---



### Break the test

Rename:

```
tests/test.sh → tests/test_broken.sh
```

Commit & push.

Result:

* Test stage fails
* Build stage passes
* Pipeline stops

DevOps explanation:

> Jenkins enforces quality gates before merge.

---

## PART 6 — Troubleshooting (end-of-day DevOps reality)

### What DevOps checks DAILY

#### 1. Agent health

```bash
ps aux | grep agent.jar
```

Jenkins UI:

* offline agents
* stuck executors

#### 2. Logs

* Console Output
* Stage failure
* Tool missing
* Permission denied

#### 3. Resource usage

On Mac:

```bash
top
```

In prod:

* CPU spikes
* Memory pressure
* Disk full

---

## PART 7 — Why companies use Jenkins + GitHub

### GitHub

* Source of truth
* Code reviews
* Branch protection
* Audit trail

### Jenkins

* Orchestration
* Custom pipelines
* Complex workflows
* Hybrid environments

Why NOT only GitHub Actions:

* Jenkins handles:

  * legacy systems
  * on-prem
  * complex infra
  * multi-cloud

Interview line:

> “GitHub manages code; Jenkins manages execution.”

---

## PART 8 — CI vs CD (DevOps view)

### CI (what you just built)

* Build
* Test
* Validate
* Block bad merges

### CD (next step in real life)

* Deploy to dev
* Approval gate
* Deploy to prod
* Rollback

Jenkins can do both — or CI only.

---

## PART 9 — What DevOps must pay attention to

| Area       | Why                  |
| ---------- | -------------------- |
| Agents     | CPU / RAM isolation  |
| Controller | Stability            |
| Secrets    | Never in code        |
| Webhooks   | Event-driven         |
| Logs       | First place to debug |
| Cleanup    | Disk pressure        |

---

## PART 10 — Interview-ready explanation (use this)

> “In our setup, Jenkins controller only orchestrates pipelines. Jobs run on dedicated agents to isolate CPU and memory. CI is triggered via GitHub webhooks, validates builds and tests, and blocks bad code before merge to main. This improves reliability, speed, and auditability.”

That is a **strong senior DevOps answer**.













## Big picture (non-marketing truth)

> **GitHub Actions is tightly coupled to GitHub repos.
> Jenkins is a general-purpose automation engine.**

Companies choose based on **complexity, environment, and control** — not hype.

---

## Why companies use **GitHub Actions**

### 1️⃣ Native to GitHub (zero setup)

* No server to manage
* Works immediately with repos
* Easy for dev teams

Why companies like it:

* Low operational overhead
* Fast onboarding
* Fewer moving parts

---

### 2️⃣ Perfect for **repo-centric CI**

Use cases:

* Build & test code
* Run linters
* Simple Docker builds
* PR checks

Example:

```yaml
on: [push, pull_request]
```

DevOps view:

> “GitHub Actions is excellent for straightforward CI.”

---

### 3️⃣ Security & governance

* Secrets managed per repo/org
* Built-in permissions model
* Good audit trail

---

### 4️⃣ Cloud-first teams

* SaaS companies
* GitHub-only workflows
* Minimal infra

---

## Why companies use **Jenkins**

### 1️⃣ Works **everywhere**

Jenkins can run:

* on-prem
* in AWS / Azure / GCP
* hybrid
* air-gapped environments

This is the #1 reason large companies keep Jenkins.

Interview line:

> “Jenkins is environment-agnostic.”

---

### 2️⃣ Complex pipelines & orchestration

Jenkins excels at:

* Multi-stage workflows
* Cross-repo builds
* Infra automation
* Release orchestration

Example:

* Build app
* Scan
* Deploy infra
* Deploy app
* Run smoke tests
* Rollback if needed

---

### 3️⃣ Agent-based scaling

Jenkins:

* Uses dedicated agents
* Controls CPU / memory
* Runs heavy workloads safely

GitHub Actions:

* Limited control over runners
* Shared or self-hosted runners

---

### 4️⃣ Legacy & enterprise reality

Many companies have:

* Old build tools
* Custom scripts
* Long-lived pipelines
* Regulated environments

Replacing Jenkins is **expensive and risky**.

---

## Why companies use **BOTH** (very common)

This is the real-world answer.

### Typical split:

| Task            | Tool           |
| --------------- | -------------- |
| PR checks       | GitHub Actions |
| Heavy CI        | Jenkins        |
| Infra pipelines | Jenkins        |
| On-prem builds  | Jenkins        |
| Simple repos    | GitHub Actions |

DevOps strategy:

> “Use the right tool for the job.”

---

## Real-world example (very realistic)

### GitHub Actions:

* Run unit tests on PR
* Fast feedback to devs

### Jenkins:

* Build release artifacts
* Deploy to environments
* Run long integration tests
* Coordinate releases

---

## Why NOT only GitHub Actions?

Limitations companies hit:

* Vendor lock-in
* Limited runner control
* Harder hybrid setups
* Complex orchestration becomes messy

---

## Why NOT only Jenkins?

Pain points:

* Jenkins infra maintenance
* Plugin management
* UI complexity
* Higher DevOps ownership

---

## Interview-ready answer (strong)

If asked:
**“Why use both Jenkins and GitHub Actions?”**

Answer:

> “GitHub Actions is great for lightweight, repo-centric CI. Jenkins is better for complex, scalable, environment-agnostic pipelines. Many companies use GitHub Actions for fast PR validation and Jenkins for heavy CI/CD and release orchestration.”

This is a **senior-level, realistic answer**.

---

## One-sentence summary (remember this)

> **GitHub Actions simplifies CI close to the code; Jenkins orchestrates CI/CD across systems.**
















# 🔥 HYBRID CI/CD LAB

**GitHub Actions + Jenkins (Real DevOps Workflow)**

---

## 🎯 LAB GOAL (what you demonstrate)

> GitHub Actions does **fast CI checks**
> Jenkins does **heavy CI/CD & orchestration**

This is **not duplicated work** — it’s **separation of responsibilities**.

---

## 🧱 ARCHITECTURE

![Image](https://miro.medium.com/v2/resize%3Afit%3A1015/1%2ArlPRYAfJ_aFOfoj52U7y2A.png)

![Image](https://miro.medium.com/1%2AeHzvAx969hfeWJIwD7RdSQ.png)

![Image](https://ibm-cloud-architecture.github.io/refarch-integration/devops/jenkins-architecture.png)

```
Developer → GitHub PR
        ↓
 GitHub Actions (CI checks)
        ↓
 Merge to main
        ↓
 GitHub Webhook
        ↓
 Jenkins Pipeline (Heavy CI / CD)
        ↓
 Agents (Build / Test / Deploy)
```

---

## PART 1 — Repository structure (single repo)

```
hybrid-ci-cd-lab/
├── .github/
│   └── workflows/
│       └── ci.yml
├── Jenkinsfile
├── app/
│   └── app.sh
├── tests/
│   └── test.sh
└── README.md
```

---

## PART 2 — GitHub Actions (FAST CI)

### `.github/workflows/ci.yml`

```yaml
name: GitHub Actions CI

on:
  pull_request:
    branches: [ main ]

jobs:
  quick-ci:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run quick tests
        run: |
          echo "Running lightweight CI checks"
          test -f app/app.sh
          echo "Quick CI PASSED"
```

### 🔍 What this does

* Runs **on PR**
* Finishes in seconds
* Blocks bad PRs

### DevOps reasoning:

* Fast feedback
* No infra cost
* No Jenkins load

---

## PART 3 — Jenkinsfile (HEAVY WORK)

```groovy
pipeline {
    agent none   // controller does NOT run jobs

    stages {

        stage('Checkout') {
            agent any
            steps {
                git branch: 'main',
                    url: 'https://github.com/YOUR_ORG/hybrid-ci-cd-lab.git'
            }
        }

        stage('Build (mac-agent)') {
            agent { label 'mac-agent' }
            steps {
                sh '''
                  echo "Heavy build running on $(hostname)"
                  ./app/app.sh
                '''
            }
        }

        stage('Test (node-mac1)') {
            agent { label 'node-mac1' }
            steps {
                sh '''
                  echo "Integration tests on $(hostname)"
                  ./tests/test.sh
                '''
            }
        }

        stage('Package') {
            agent any
            steps {
                sh '''
                  mkdir -p artifact
                  tar -czf artifact/app.tar.gz app/
                '''
            }
        }
    }

    post {
        success {
            echo "Jenkins pipeline SUCCESS"
        }
        failure {
            echo "Jenkins pipeline FAILED"
        }
    }
}
```

---

## PART 4 — How the hybrid flow works (step by step)

### 👩‍💻 Developer workflow (daily life)

1. Developer creates feature branch
2. Opens Pull Request
3. **GitHub Actions runs**
4. CI passes → PR approved
5. Merge to `main`

### ⚙️ DevOps workflow

6. GitHub webhook triggers Jenkins
7. Jenkins:

   * builds on agents
   * runs heavy tests
   * packages artifacts
8. (Next step: deploy — optional)

---

## PART 5 — WHY companies split like this

### GitHub Actions handles:

* PR validation
* Fast checks
* Developer feedback

### Jenkins handles:

* CPU-heavy builds
* Multi-agent pipelines
* Legacy scripts
* Complex deployments

DevOps rule:

> “Fast CI close to code, heavy CI/CD close to infrastructure.”

---

## PART 6 — DEMONSTRATE FAILURE (important)

### Break the app

Delete:

```
app/app.sh
```

#### Result:

* ❌ GitHub Actions fails PR
* ❌ Merge blocked
* ❌ Jenkins never runs

This proves:

* **CI gates protect main**
* Jenkins is not wasted on bad code

---

## PART 7 — What DevOps pays attention to DAILY

### 1️⃣ GitHub Actions

* Failed PR checks
* Flaky tests
* Secrets scope
* Runner limits

### 2️⃣ Jenkins

* Agent availability
* CPU / memory pressure
* Offline nodes
* Pipeline failures
* Disk cleanup

### 3️⃣ Integration points

* Webhooks firing
* Auth tokens
* Network access

---

## PART 8 — End of day DevOps checklist

✅ All PRs passing CI
✅ Jenkins agents healthy
✅ No stuck executors
✅ Disk space OK
✅ Secrets rotated
✅ Builds reproducible

---

## PART 9 — Interview-ready explanation (use this)

> “We use GitHub Actions for fast pull-request validation and Jenkins for heavy CI/CD and orchestration. This keeps developer feedback fast while allowing DevOps to control infrastructure-intensive pipelines.”

This answer is **very strong**.

---

## PART 10 — Why companies love this model

✔ Faster feedback
✔ Lower cost
✔ Clear responsibility split
✔ Easier scaling
✔ Safer main branch


