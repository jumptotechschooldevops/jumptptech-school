---
title: "Jenkinsfile – Advanced Level"
description: "1️⃣ What is a Jenkinsfile?   A Jenkinsfile is a pipeline definition written in Groovy.  It..."
published: 2026-02-12
source: "https://dev.to/jumptotech/jenkinsfile-advanced-level-c3e"
tags: []
---

# Jenkinsfile – Advanced Level



# 1️⃣ What is a Jenkinsfile?

A **Jenkinsfile** is a pipeline definition written in Groovy.

It tells **Jenkins**:

* What to build
* How to test
* How to deploy
* Where to run

It lives inside your Git repository.

Example repo structure:

```
my-app/
 ├── Jenkinsfile
 ├── app/
 └── README.md
```

Jenkins reads this file and executes it.

---

# 2️⃣ Two Types of Jenkins Pipelines

Jenkins supports:

1. Declarative Pipeline
2. Scripted Pipeline

Both are written in **Groovy**, but they look different.

---

# 3️⃣ Declarative Pipeline (Modern & Structured)

## What is it?

Declarative is structured and easy to read.

It looks like configuration.

It has strict blocks like:

```
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo Hello'
            }
        }
    }
}
```

---

## Why Declarative Exists

Because Scripted pipelines were:

* Too flexible
* Hard to read
* Hard to maintain
* Hard for beginners

Declarative makes CI/CD safer and cleaner.

---

## Who Writes Declarative?

In most companies:

* DevOps team defines the base pipeline
* Developers add app-specific steps

Declarative is common in production environments.

---

## Full Declarative Example (Real DevOps)

```groovy
pipeline {
    agent any

    environment {
        APP_NAME = "my-app"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/company/my-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'echo Building application'
            }
        }

        stage('Test') {
            steps {
                sh 'echo Running tests'
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo Deploying application'
            }
        }
    }

    post {
        always {
            echo 'Pipeline Finished'
        }
        success {
            echo 'Deployment successful'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
```

---

## Why DevOps Uses Declarative

Because:

* Easier to maintain
* Easy to enforce structure
* Built-in features (post, environment, options)
* Less risky
* Easier for juniors

In real companies → 80% pipelines are Declarative.

---

# 4️⃣ Scripted Pipeline (Advanced & Flexible)

## What is it?

Scripted pipeline gives full programming control.

It looks like pure Groovy.

Example:

```groovy
node {
    stage('Build') {
        sh 'echo Building'
    }

    stage('Test') {
        sh 'echo Testing'
    }
}
```

---

## Why Scripted Exists

Because sometimes you need:

* Complex logic
* Dynamic stage creation
* Loops
* Advanced condition handling
* Custom control flow

Scripted = full control

---

## Who Writes Scripted?

Usually:

* Senior DevOps engineers
* Platform team
* When building shared libraries
* When pipeline needs heavy logic

Developers usually do NOT write full Scripted pipelines.

---

# 5️⃣ Real Scripted Example (Advanced Logic)

```groovy
node {

    def environments = ['dev', 'staging', 'prod']

    for (env in environments) {

        stage("Deploy to ${env}") {

            if (env == 'prod') {
                input "Approve deployment to production?"
            }

            sh "echo Deploying to ${env}"
        }
    }
}
```

---

## What is happening?

* We created a list
* We looped dynamically
* We added manual approval for production
* This is real production behavior

Declarative cannot easily do this cleanly.

This is why Scripted exists.

---

# 6️⃣ When to Use Declarative vs Scripted

## Use Declarative When:

* Simple CI/CD
* Standard build → test → deploy
* Most microservices
* Beginner-friendly pipelines
* Production safety required

## Use Scripted When:

* Dynamic stage generation
* Complex condition logic
* Matrix builds
* Custom logic heavy pipelines
* Shared library development

---

# 7️⃣ How to Mix Both (Very Important)

In real DevOps — we mix both.

Declarative pipeline allows script blocks.

Example:

```groovy
pipeline {
    agent any

    stages {

        stage('Dynamic Logic') {
            steps {
                script {
                    def version = "1.0.${BUILD_NUMBER}"
                    echo "Building version ${version}"
                }
            }
        }
    }
}
```

Here:

* Outer structure = Declarative
* Inside script {} = Scripted Groovy

This is how real companies work.

---

# 8️⃣ Where Do We Write Jenkinsfile?

Inside Git repository root:

```
my-app/
 ├── Jenkinsfile
```

Then in Jenkins:

1. Create New Item
2. Choose "Pipeline"
3. In configuration:

   * Select: Pipeline script from SCM
   * Choose Git
   * Add repo URL
   * Script Path: Jenkinsfile

Click Save → Build Now

---

# 9️⃣ How Jenkins Executes It

Internally:

* Jenkins reads Jenkinsfile
* Creates execution graph
* Runs stages
* Executes on agent
* Logs everything
* Saves build history

This is why Jenkins is stateful.

DevOps must back up:

```
/var/lib/jenkins
```

Because pipeline history matters in production.

---

# 🔟 In Real Production – Who Owns What?

## Developers:

* Add unit tests
* Define build commands
* Sometimes update pipeline steps

## DevOps Engineers:

* Design pipeline structure
* Configure agents
* Secure secrets
* Handle credentials
* Configure approvals
* Manage environments
* Optimize performance
* Manage shared libraries
* Control production deployment rules

---

# 1️⃣1️⃣ Advanced DevOps Scenario

Example:

DevOps writes:

* Shared library
* Standard pipeline template
* Docker build logic
* Security scanning
* Terraform deploy

Developer only writes:

* App code

This separation is real-world DevOps.

---

# 1️⃣2️⃣ Production Example – Real Structure

Example:

```
company-shared-library/
apps/
   ├── service-a/
   │    ├── Jenkinsfile
   ├── service-b/
```

DevOps writes common logic.
Apps reuse it.

---

# 1️⃣3️⃣ Why DevOps Must Understand Both

Because in interviews they will ask:

* Why declarative?
* When scripted?
* Can you mix?
* What is node block?
* What is agent?
* How Jenkins executes?
* How to secure secrets?
* How to handle production approval?

If you only know declarative → limited.
If you only know scripted → dangerous.

Senior DevOps must know both.

---

# 1️⃣4️⃣ Beginner Summary

| Feature                   | Declarative  | Scripted             |
| ------------------------- | ------------ | -------------------- |
| Easy to read              | Yes          | No                   |
| Flexible                  | Medium       | Very High            |
| Best for beginners        | Yes          | No                   |
| Used in production        | Yes (mostly) | Yes (advanced cases) |
| Supports full programming | Limited      | Full                 |

---


Understand:

* agent
* stages
* steps
* post
* environment

Then learn:

* script {}
* loops
* conditions
* input approval
* shared libraries

Only after that move to full Scripted.










# What is Groovy? 
# 1️⃣ Simple Definition

Groovy = Java + scripting + easier syntax.

It is:

* Object-oriented
* Dynamically typed
* Used for automation
* Used inside Jenkins
* Used for Gradle builds
* Used in DevOps pipelines

---

# 2️⃣ Why DevOps Engineers Care About Groovy

Because:

* Jenkins pipelines are written in Groovy
* Shared libraries use Groovy
* Advanced pipeline logic requires Groovy

If you don’t understand Groovy → you cannot write advanced Jenkins pipelines.

---

# 3️⃣ Where Groovy Is Used in DevOps

Mainly in:

* Jenkinsfile
* Jenkins shared libraries
* Custom pipeline logic
* Complex automation

Example Jenkinsfile:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "Building..."
            }
        }
    }
}
```

That is Groovy syntax.

---

# 4️⃣ How Groovy Is Different from Bash

Bash:

```bash
echo "Hello"
```

Groovy:

```groovy
println "Hello"
```

Groovy is a programming language.
Bash is a shell scripting language.

Groovy supports:

* Variables
* Loops
* Conditions
* Functions
* Objects
* Classes

Bash is more limited.

---

# 5️⃣ Basic Groovy Syntax (Very Important for Jenkins)

## Variables

```groovy
def name = "Aisalkyn"
def number = 5
```

Groovy is dynamically typed.
You don’t need to declare type.

---

## If Condition

```groovy
def env = "prod"

if (env == "prod") {
    println "Production deployment"
}
```

---

## Loop

```groovy
def list = ["dev", "stage", "prod"]

for (e in list) {
    println e
}
```

---

## Function

```groovy
def greet(name) {
    return "Hello ${name}"
}

println greet("DevOps")
```

---

# 6️⃣ Groovy Inside Jenkins

In Jenkins, Groovy runs inside pipeline engine.

Example:

```groovy
pipeline {
    agent any
    stages {
        stage('Version') {
            steps {
                script {
                    def version = "1.0.${BUILD_NUMBER}"
                    echo "Version is ${version}"
                }
            }
        }
    }
}
```

Inside `script {}` → you are writing pure Groovy.

This is how we mix Declarative + Scripted logic.

---

# 7️⃣ Why Jenkins Uses Groovy

Because Groovy:

* Runs on Java
* Easy to extend
* Easy to embed
* Supports DSL (Domain Specific Language)

Jenkins built its pipeline DSL using Groovy.

---

# 8️⃣ What DevOps Engineers Actually Need to Know

You do NOT need to become a full Groovy developer.

You must know:

* def variables
* if conditions
* loops
* string interpolation `${}`
* functions
* basic collections (list, map)

That’s enough for 90% of Jenkins pipelines.

---

# 9️⃣ Real Production Example

Example: dynamic deployment

```groovy
node {
    def environments = ["dev", "stage", "prod"]

    for (env in environments) {
        stage("Deploy ${env}") {

            if (env == "prod") {
                input "Approve production?"
            }

            sh "echo Deploying to ${env}"
        }
    }
}
```

This is Groovy controlling Jenkins stages.

Without Groovy → this logic is impossible.

---

# 🔟 Important Concept: Groovy vs Jenkins DSL

Groovy = language
Jenkins DSL = special commands Jenkins provides

Example:

```
pipeline
stage
steps
sh
echo
input
```

Those are Jenkins DSL keywords written in Groovy style.

---



Groovy is:

* The language Jenkins pipelines use
* Needed for advanced Jenkins logic
* Easy compared to Java
* Powerful for automation



“You don't need to master Groovy.
You need to understand enough to control Jenkins logic.”











# 1️⃣ Why Shared Library Exists

Problem in real companies:

You have:

* 50 microservices
* 50 Jenkinsfiles
* All build Docker images
* All deploy to Kubernetes
* All run security scans

If you copy logic everywhere:

* Hard to maintain
* Hard to update
* Risky
* Messy

Solution:

Write it once → Reuse everywhere.

That is Shared Library.

---

# 2️⃣ Who Writes Shared Library?

In real production:

* DevOps / Platform team writes shared library
* Developers only call library functions

Developers write:

```groovy
@Library('company-lib') _
buildApp()
deployApp()
```

They do NOT write full pipeline logic.

This keeps control in DevOps team.

---

# 3️⃣ How Shared Library Works

Jenkins loads external Git repository that contains reusable Groovy functions.

Structure looks like this:

```
company-shared-library/
 ├── vars/
 │     ├── buildApp.groovy
 │     ├── deployApp.groovy
 ├── src/
 │     └── com/company/utils.groovy
 └── resources/
```

---

# 4️⃣ Important Folders Explained

## vars/

This is most important.

Files inside `vars/` become pipeline functions.

Example:

`vars/buildApp.groovy`

```groovy
def call() {
    sh "echo Building Docker image"
}
```

Now any Jenkinsfile can use:

```groovy
buildApp()
```

Because Jenkins auto-loads it.

---

## src/

Used for complex classes.

Advanced DevOps only.

Example:

```
src/com/company/DeployUtils.groovy
```

Used when logic is large.

---

## resources/

Static files.
YAML templates, JSON files, etc.

---

# 5️⃣ Step-by-Step: How to Create Shared Library

## Step 1 — Create Git Repository

Create new repo:

```
company-shared-library
```

Add structure:

```
vars/buildApp.groovy
vars/deployApp.groovy
```

Example:

`vars/deployApp.groovy`

```groovy
def call(String environment) {
    echo "Deploying to ${environment}"
}
```

Commit and push.

---

## Step 2 — Configure Jenkins

In Jenkins:

Manage Jenkins
→ Manage System
→ Global Pipeline Libraries
→ Add

Fill:

Name: company-lib
Default version: main
Source: Git
Repo URL: your Git repo

Save.

Now Jenkins knows this library.

---

# 6️⃣ How to Use It in Jenkinsfile

In your application repo:

```groovy
@Library('company-lib') _

pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                buildApp()
            }
        }

        stage('Deploy') {
            steps {
                deployApp("dev")
            }
        }
    }
}
```

That’s it.

---

# 7️⃣ Real Production Example

DevOps library might contain:

* Docker build logic
* ECR push logic
* Helm deployment
* Terraform execution
* Security scanning
* Slack notifications
* Production approval logic

Developers only do:

```groovy
buildDocker()
scanImage()
deployK8s("prod")
```

All real logic hidden inside shared library.

---

# 8️⃣ Why DevOps Teams Use Shared Library

Because:

### 1. Standardization

All apps deploy same way.

### 2. Security Control

DevOps controls:

* Credentials usage
* Production approvals
* Deployment rules

Developers cannot break production logic.

### 3. Easy Updates

If you change deploy logic:

Update library once → all apps updated.

---

# 9️⃣ When to Use Shared Library

Use when:

* More than 5 projects
* Microservices architecture
* Kubernetes deployments
* Standard Docker builds
* Security compliance required

If you have only 1 small project → not necessary.

---

# 🔟 Declarative + Shared Library

Example mixing:

```groovy
@Library('company-lib') _

pipeline {
    agent any

    stages {
        stage('CI') {
            steps {
                buildApp()
            }
        }

        stage('CD') {
            steps {
                script {
                    deployApp("staging")
                }
            }
        }
    }
}
```

You can mix declarative structure with library functions.

---

# 1️⃣1️⃣ Advanced DevOps Architecture

Real company:

```
Platform Team
   |
   |--- Shared Library Repo
   |
Developers
   |
   |--- Microservice Repo
         |
         |--- Jenkinsfile (very small)
```

This is real enterprise model.

---

# 1️⃣2️⃣ Interview Questions They Will Ask

Be ready to answer:

* What is Jenkins Shared Library?
* Why do we use it?
* Difference between vars and src?
* How to configure?
* Who owns it?
* How versioning works?
* How to restrict developers from modifying production logic?

---



Shared Library = Reusable Jenkins code stored in Git and used by multiple pipelines.

Written by: DevOps
Used by: Developers
Purpose: Standardization + Security + Maintainability



