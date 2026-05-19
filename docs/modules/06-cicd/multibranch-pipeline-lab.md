---
title: "Multibranch Pipeline Lab"
description: "Why multibranch is important (DevOps reason)   With a normal Jenkins job, you usually build..."
published: 2026-02-09
source: "https://dev.to/jumptotech/multibranch-pipeline-lab-1kca"
tags: []
---

# Multibranch Pipeline Lab





## Why multibranch is important (DevOps reason)

With a normal Jenkins job, you usually build **one branch** and webhooks often don’t map cleanly to “which branch/job”.

**Multibranch Pipeline automatically:**

* discovers branches in GitHub
* builds the right branch automatically
* creates a job per branch (in one place)
* supports PR workflows (real team CI)
* removes “click Build Now”

In production, DevOps wants **CI per branch/PR**, not only on `main`.

---

# What branches do we use in real companies?

Most common production patterns:

### Pattern A (simplest, common)

* `main` = production-ready
* `feature/*` = developer work
* PR → merge to `main`

### Pattern B (with release stability)

* `main` = production
* `develop` = integration/staging
* `feature/*` → PR to `develop`
* release → merge to `main`

For beginners, use **Pattern A**.

---

# Do you have to create more branches?

✅ Yes (at least one feature branch) — because multibranch is meant to build **more than one branch** automatically.

You will create:

* `main`
* `feature/hello-ci`

That’s enough.

---

# PART 1 — Create the GitHub repo (with Jenkinsfile)

## Step 1: Create repo

GitHub → New repository:

* name: `jenkins-multibranch-lab`
* public or private (either works)

Clone it to your Mac.

---

## Step 2: Create files

Inside repo:

**`app.sh`**

```bash
#!/bin/bash
echo "Hello from branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Running on host: $(hostname)"
```

**`test.sh`**

```bash
#!/bin/bash
if [ -f app.sh ]; then
  echo "TEST PASSED"
  exit 0
else
  echo "TEST FAILED"
  exit 1
fi
```

Make them executable:

```bash
chmod +x app.sh test.sh
```

---

## Step 3: Add Jenkinsfile (branch-aware)

Create **`Jenkinsfile`** in repo root:

```groovy
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout Info') {
            steps {
                sh '''
                  echo "Branch: ${BRANCH_NAME}"
                  echo "Commit: $(git rev-parse --short HEAD)"
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                  ./app.sh
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                  ./test.sh
                '''
            }
        }
    }

    post {
        success { echo "CI SUCCESS for ${BRANCH_NAME}" }
        failure { echo "CI FAILED for ${BRANCH_NAME}" }
        always  { cleanWs() }
    }
}
```

Commit and push to `main`:

```bash
git add .
git commit -m "Add multibranch CI lab"
git push origin main
```

---

# PART 2 — Create Multibranch Pipeline in Jenkins (UI steps)

## Step 4: Create job

Jenkins Dashboard → **New Item**

* Name: `multibranch-ci-lab`
* Type: **Multibranch Pipeline**
* OK

---

## Step 5: Configure repo source

Inside job config:

### Branch Sources

* Add source: **GitHub**
* Credentials:

  * If public repo: you can try without credentials
  * If private repo: add GitHub token in Jenkins Credentials first

### Repository HTTPS URL

Paste your repo URL.

---

## Step 6: Build configuration

* Mode: **by Jenkinsfile**
* Script Path: `Jenkinsfile` (default)

---

## Step 7: Branch discovery (important)

Find “Behaviors” or “Discover branches” and enable:

* **Discover branches**
* (Optional later) “Discover pull requests”

Beginner safe option:

* build branches normally

---

## Step 8: Save and scan

Click **Save**.

Jenkins will start:

* **Scan Multibranch Pipeline**
* It finds branches with Jenkinsfile
* It creates jobs automatically

You should see something like:

* `main` branch job created automatically

---

# PART 3 — Webhook (so it triggers automatically)

## Step 9: Configure GitHub webhook (important)

GitHub repo → Settings → Webhooks → Add webhook
Payload URL:

* If Jenkins local only: must use ngrok/public URL
* If Jenkins accessible by internet: use that URL

Content type:

* `application/json`

Events:

* **Just the push event** (beginner)
  (or “Push + Pull Request” later)

Now GitHub push will trigger Jenkins scan/build.

---

# PART 4 — Create feature branch (real production workflow)

## Step 10: Create feature branch

On your Mac:

```bash
git checkout -b feature/hello-ci
```

Edit `app.sh` and change message:

```bash
echo "Hello from FEATURE branch"
```

Commit and push:

```bash
git add app.sh
git commit -m "Update app output on feature branch"
git push -u origin feature/hello-ci
```

### What should happen now

* GitHub sends webhook
* Jenkins multibranch detects new branch
* Jenkins automatically creates:

  * `feature/hello-ci`
* Jenkins automatically runs CI for that branch

No “Build Now” needed.

---

# PART 5 — Merge to main (how real prod is done)

## Step 11: Open PR

GitHub → Pull Requests → New PR

* base: `main`
* compare: `feature/hello-ci`

In real teams:

* PR review happens
* CI must pass before merge (branch protection)

Merge PR.

---

## Step 12: What Jenkins does after merge

After merge:

* webhook triggers Jenkins
* Jenkins runs pipeline for `main`
* `main` is always tested before production deploy

This is why multibranch matters:

> Each branch proves itself before it touches `main`.

---

# What DevOps must pay attention to (daily work)

## 1) Webhook health

* pushes not triggering?

  * webhook delivery logs in GitHub
  * Jenkins logs
  * wrong URL / ngrok expired

## 2) Branch discovery settings

* branch not built?

  * Jenkins didn’t discover it
  * branch doesn’t have Jenkinsfile
  * filters exclude it

## 3) Credentials

* private repo fails checkout:

  * GitHub token missing
  * wrong permissions

## 4) Agents

* if pipeline uses `agent { label 'mac-agent' }`

  * agent must be online
  * correct label exists

## 5) Build stability

* flaky tests
* long build times
* workspace cleanup

---

# Why companies NEED Multibranch (production answer)

Because it enforces:

* CI for every branch (not just main)
* automated branch job creation
* consistent builds across branches
* PR-based workflows
* less manual clicking
* clear traceability: branch → build → commit

Interview answer:

> “Multibranch Pipeline is used to automatically build each branch/PR with pipeline-as-code, which matches real GitHub workflows and prevents manual job management.”


