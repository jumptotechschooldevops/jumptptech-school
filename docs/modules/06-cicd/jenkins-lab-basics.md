---
title: "Jenkins lab basics"
description: "🧠 GOAL OF THIS LAB   After this lab, you will clearly understand:   What a Jenkins pipeline..."
published: 2026-02-06
source: "https://dev.to/jumptotech/jenkins-lab-basics-2m25"
tags: []
---

# Jenkins lab basics



# 🧠 GOAL OF THIS LAB

After this lab, you will clearly understand:

* What a Jenkins pipeline is
* How Jenkins executes scripts
* What agent means
* How stages and steps work
* How Jenkins handles success vs failure
* How logs are produced
* How Jenkins decides a build is green or red

This is **foundation knowledge**.



# STEP 1 — CREATE A BASIC PIPELINE JOB

1. Open Jenkins UI
2. Click **New Item**
3. Name:

   ```
   basic-pipeline
   ```
4. Select **Pipeline**
5. Click **OK**

---

# STEP 2 — WRITE THE SIMPLEST POSSIBLE PIPELINE

In **Pipeline → Definition → Pipeline script**, paste:

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello from Jenkins'
            }
        }
    }
}
```

Click **Save** → **Build Now**

---

# STEP 3 — UNDERSTAND WHAT JUST HAPPENED (IMPORTANT)

### What Jenkins did internally

1. Jenkins received a build request
2. Jenkins allocated an **agent**
3. Jenkins created a **workspace**
4. Jenkins executed the steps
5. Jenkins printed logs
6. Jenkins marked build as SUCCESS

---

## Line-by-line explanation

```groovy
pipeline {
```

➡️ Tells Jenkins: *this job is a pipeline*

---

```groovy
agent any
```

➡️ Run on any available Jenkins worker
➡️ Jenkins needs a machine to run commands

---

```groovy
stages {
```

➡️ Pipeline is divided into visible phases

---

```groovy
stage('Hello') {
```

➡️ One logical step in the pipeline

---

```groovy
steps {
```

➡️ Actual commands executed

---

```groovy
echo 'Hello from Jenkins'
```

➡️ Prints to Jenkins console log

---

# STEP 4 — ADD REAL SCRIPT EXECUTION

Now update the pipeline:

```groovy
pipeline {
    agent any

    stages {
        stage('Run Shell Commands') {
            steps {
                sh '''
                echo "Jenkins is running a shell script"
                date
                whoami
                pwd
                '''
            }
        }
    }
}
```

Build again.

---

# STEP 5 — HOW JENKINS RUNS SCRIPTS (KEY CONCEPT)

Jenkins does NOT execute code magically.

It:

* Runs commands **on the agent**
* Uses the OS shell
* Depends on:

  * OS
  * Installed tools
  * User permissions

### What you just saw

* `whoami` → Jenkins user
* `pwd` → workspace directory

📌 **This explains 80% of Jenkins issues in real life**

---

# STEP 6 — UNDERSTAND WORKSPACE

Add this step:

```groovy
sh 'ls -la'
```

Explain:

* Jenkins creates a workspace per job
* Files live only during the build (unless archived)

Workspace path example:

```
/var/jenkins_home/workspace/basic-pipeline
```

---

# STEP 7 — SUCCESS VS FAILURE (CRITICAL)

Modify pipeline:

```groovy
pipeline {
    agent any

    stages {
        stage('Success') {
            steps {
                echo 'This stage will pass'
            }
        }

        stage('Failure') {
            steps {
                sh 'exit 1'
            }
        }

        stage('Never Runs') {
            steps {
                echo 'You will not see this'
            }
        }
    }
}
```

Build.

---

## What happened and WHY

* `exit 1` = non-zero exit code
* Jenkins immediately:

  * stops pipeline
  * marks build as FAILED
  * skips next stages

📌 **This is how Jenkins protects production**

---

# STEP 8 — READ LOGS LIKE A DEVOPS ENGINEER

Click:

* Failed build
* Console Output

Learn to:

* Read from bottom up
* Identify failing command
* Understand exit codes

> Jenkins debugging = log reading skill

---

# STEP 9 — POST ACTIONS (WHAT HAPPENS AFTER BUILD)

Update pipeline:

```groovy
pipeline {
    agent any

    stages {
        stage('Run') {
            steps {
                sh 'exit 1'
            }
        }
    }

    post {
        success {
            echo 'Build succeeded'
        }
        failure {
            echo 'Build failed'
        }
        always {
            echo 'This always runs'
        }
    }
}
```

Build.

---

## Why post section matters

* Cleanup
* Notifications
* Rollbacks
* Reports

---

# STEP 10 — ENVIRONMENT VARIABLES (VERY BASIC)

```groovy
pipeline {
    agent any

    environment {
        MY_ENV = "hello"
    }

    stages {
        stage('Env Demo') {
            steps {
                sh 'echo $MY_ENV'
            }
        }
    }
}
```

Explain:

* Available in all stages
* Used for env-based logic

---

# STEP 11 — HOW JENKINS REALLY WORKS (MENTAL MODEL)

```
Job created
  ↓
Build triggered
  ↓
Agent assigned
  ↓
Workspace created
  ↓
Stages executed in order
  ↓
Shell commands run
  ↓
Logs collected
  ↓
Build result decided
```

---

# 🎤 INTERVIEW FOUNDATION ANSWER

> “A Jenkins pipeline runs on an agent, creates a workspace, executes shell commands step by step, and determines success or failure based on exit codes. Stages give visibility, and logs are used for debugging.”

---

# 🧠 FINAL RULES TO REMEMBER

1. Jenkins runs **scripts**, not magic
2. Exit code controls pipeline flow
3. Logs are your truth
4. Workspace is temporary
5. Pipelines are code, not UI

---

## ✅ You now understand Jenkins fundamentals

Next logical steps (when YOU say):

* Pipeline from GitHub
* Credentials usage
* Docker build
* Kubernetes deploy



















# 🔑 NEXT STEP: Jenkinsfile from GitHub (Pipeline as Code)

## 🎯 What you will learn in THIS step

You will understand:

* How Jenkins pulls code from GitHub
* How Jenkinsfile controls the job
* Why Pipeline-as-Code is mandatory in real teams
* How CI actually starts from a git push

This is the **bridge from “learning Jenkins” → “using Jenkins professionally.”**

---

## 🧠 Mental shift (important)

**Before**

* Pipeline written in Jenkins UI
* Jenkins owns the logic

**Now**

* Pipeline lives in GitHub
* Git owns the logic
* Jenkins only executes

This is how real companies work.

---

## STEP 1 — Create a GitHub Repository

Create a new repo:

```
jenkins-basic-pipeline
```

---

## STEP 2 — Create Repo Structure

Inside the repo:

```
jenkins-basic-pipeline/
├── Jenkinsfile
└── hello.sh
```

---

## STEP 3 — Create a Simple Script (hello.sh)

```bash
#!/bin/bash
echo "Hello from GitHub"
date
whoami
pwd
```

Make it executable:

```bash
chmod +x hello.sh
```

Commit and push.

---

## STEP 4 — Create Jenkinsfile (VERY SIMPLE)

Create `Jenkinsfile`:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Code pulled from GitHub'
                checkout scm
            }
        }

        stage('Run Script') {
            steps {
                sh './hello.sh'
            }
        }
    }
}
```

Commit and push.

---

## STEP 5 — Create Jenkins Pipeline Job (SCM-based)

1. Jenkins → **New Item**
2. Name:

   ```
   github-pipeline
   ```
3. Select **Pipeline**
4. Click **OK**

### Configure:

* **Definition**: Pipeline script from SCM
* **SCM**: Git
* **Repository URL**: your GitHub repo
* **Branch**: `main`
* **Script Path**: `Jenkinsfile`

Save.

---

## STEP 6 — Run the Pipeline

Click **Build Now**

### What Jenkins does internally

1. Jenkins connects to GitHub
2. Pulls repo
3. Finds Jenkinsfile
4. Executes stages
5. Runs shell script
6. Prints logs
7. Marks build success

This is **real CI**.

---

## STEP 7 — PROVE CI AUTOMATION (CRITICAL)

Edit `hello.sh`:

```bash
echo "New change from developer"
```

Commit and push.

### Result:

* GitHub webhook triggers Jenkins
* Jenkins runs pipeline automatically
* No manual click

📌 **This is Continuous Integration**

---

## STEP 8 — BREAK IT ON PURPOSE (LEARN FAILURE)

Edit `hello.sh`:

```bash
exit 1
```

Commit and push.

### Observe:

* Pipeline fails
* Jenkins stops execution
* Console shows error
* Build marked ❌ FAILED

Explain this clearly:

> Jenkins protects the system by blocking bad changes.

---

## STEP 9 — Fix It (RECOVERY)

Remove `exit 1`, commit, push.

Pipeline goes green again.

📌 **This is the real DevOps feedback loop.**

---

## STEP 10 — What You Can Now Explain Confidently

You can now say:

> “I use Jenkinsfile stored in GitHub. Jenkins pulls pipeline definitions from SCM, runs scripts on agents, and automatically triggers builds using webhooks whenever code changes.”

That is **DevOps-level Jenkins knowledge**.



