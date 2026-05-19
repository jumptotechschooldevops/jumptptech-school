---
title: "GitLab – Full DevOps Lecture"
description: "1️⃣ What Is GitLab?   GitLab is a complete DevOps platform built around Git.  It..."
published: 2026-02-19
source: "https://dev.to/jumptotech/gitlab-full-devops-lecture-3h8p"
tags: []
---

# GitLab – Full DevOps Lecture



![Image](https://images.icon-icons.com/2699/PNG/512/gitlab_logo_icon_169112.png)

![Image](https://docs.gitlab.com/ci/pipelines/img/pipeline_dependency_view_v17_9.png)

![Image](https://docs.gitlab.com/user/project/merge_requests/img/post_merge_pipeline_v16_0.png)

![Image](https://about.gitlab.com/images/7_13/approvers_mr.png)

---

# 1️⃣ What Is GitLab?

**GitLab** is a **complete DevOps platform built around Git**.

It allows teams to:

* Store source code (Git repositories)
* Review code (Merge Requests)
* Run CI/CD pipelines
* Scan for security issues
* Deploy applications
* Manage infrastructure
* Track issues and sprints

Unlike older setups (GitHub + Jenkins + Jira + SonarQube), GitLab combines everything into **one platform**.

---

# 2️⃣ Why Do We Need GitLab in DevOps?

Before DevOps tools:

* Developers wrote code
* Ops deployed manually
* Testing was manual
* Releases were slow
* Many human errors

GitLab solves these problems:

| Problem            | GitLab Solution            |
| ------------------ | -------------------------- |
| Manual deployments | CI/CD pipelines            |
| No version control | Git repositories           |
| Code conflicts     | Branching & merge requests |
| No automation      | Pipeline automation        |
| Security risks     | Built-in scanning          |
| No visibility      | Pipeline dashboard         |

---

# 3️⃣ What Problems Does GitLab Solve for DevOps?

As a DevOps engineer, you need:

* Automation
* Repeatability
* Traceability
* Faster releases
* Infrastructure as Code
* Security integration

GitLab provides:

* Automated build/test/deploy
* Version-controlled infrastructure (Terraform)
* Secure pipelines
* Artifact storage
* Container registry
* Kubernetes integration

---

# 4️⃣ What Components Does GitLab Include?

GitLab is not just Git.

It includes:

### ✅ 1. Git Repository

Code storage with:

* Branching
* Tagging
* Commit history

---

### ✅ 2. Merge Requests (Code Review)

Like Pull Requests.

* Developers create feature branches
* Submit Merge Request
* Team reviews
* Approves
* Merges to main

---

### ✅ 3. CI/CD Pipelines

Defined inside:

```
.gitlab-ci.yml
```

Example:

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - docker build -t app .
```

Every push triggers pipeline automatically.

---

### ✅ 4. GitLab Runner

Very important.

GitLab itself does NOT execute jobs.
GitLab Runner executes pipeline jobs.

You install runner on:

* EC2
* VM
* Kubernetes
* Docker

---

### ✅ 5. Container Registry

Stores Docker images:

```
registry.gitlab.com/project/app:latest
```

---

### ✅ 6. Security Scanning

Built-in:

* SAST
* DAST
* Dependency scanning
* Secret detection

---

### ✅ 7. Infrastructure as Code Support

You can run:

* Terraform
* Ansible
* Helm
* kubectl

Inside pipeline.

---

# 5️⃣ Who Sets Up GitLab in a DevOps Team?

Depends on company size.

### Small Company:

DevOps Engineer sets it up.

### Medium Company:

Platform Engineer or DevOps Engineer.

### Large Enterprise:

Platform Team / DevOps Platform Team.

---

# 6️⃣ How GitLab Is Installed

Two main options:

## Option 1 – GitLab SaaS (Cloud)

Use:
👉 gitlab.com

No installation needed.

---

## Option 2 – Self-Managed GitLab

Installed on:

* EC2
* VM
* On-prem server
* Kubernetes

DevOps engineer installs:

```bash
sudo apt install gitlab-ee
```

Then configures:

* SSL
* Backup
* Runners
* Storage

---

# 7️⃣ How DevOps Uses GitLab – Real Flow

Let’s simulate your DevOps bootcamp example.

### Step 1 – Developer Pushes Code

```bash
git push origin feature-login
```

---

### Step 2 – GitLab Triggers Pipeline

Pipeline stages:

1. Build Docker image
2. Run tests
3. Scan vulnerabilities
4. Push image to registry
5. Deploy to Kubernetes

---

### Step 3 – GitLab Runner Executes Jobs

Runner:

* Runs docker build
* Pushes image
* Runs kubectl apply

---

### Step 4 – App Is Deployed to EKS

Automatic deployment.

No manual SSH.
No manual copying files.

---

# 8️⃣ Where GitLab Fits in DevOps Lifecycle

DevOps lifecycle:

Plan → Code → Build → Test → Release → Deploy → Monitor

GitLab covers ALL stages.

That’s why it’s called:

"Single Application for the Entire DevOps Lifecycle"

---

# 9️⃣ Why DevOps Engineers Prefer GitLab

### ✅ Built-in CI/CD

No need Jenkins.

### ✅ Everything in One Tool

Less integration complexity.

### ✅ Strong Kubernetes Integration

Perfect for EKS labs (like yours).

### ✅ Secure Pipelines

Shift-left security.

### ✅ Version Controlled Pipelines

Pipeline defined as code.

---

# 🔟 GitLab vs Jenkins (Important for Interview)

| Feature              | GitLab  | Jenkins   |
| -------------------- | ------- | --------- |
| Built-in CI          | Yes     | No        |
| Plugin dependency    | Minimal | Heavy     |
| Maintenance          | Low     | High      |
| UI modern            | Yes     | Old style |
| Full DevOps platform | Yes     | No        |

Jenkins = CI tool
GitLab = DevOps platform

---

# 1️⃣1️⃣ Who Uses GitLab in DevOps Team?

| Role              | How They Use GitLab       |
| ----------------- | ------------------------- |
| Developer         | Push code, create MR      |
| QA                | Check pipelines           |
| DevOps Engineer   | Create pipelines, runners |
| Security Engineer | Review scans              |
| Platform Engineer | Maintain GitLab           |
| Project Manager   | Track issues              |

---

# 1️⃣2️⃣ GitLab Architecture (Simplified)

GitLab Server
↓
GitLab Runner
↓
Docker / Kubernetes / Cloud

---

# 1️⃣3️⃣ When Should a Company Choose GitLab?

Choose GitLab when:

* Want full DevOps platform
* Need CI/CD + security
* Want less tool integration
* Want self-hosted option
* Need strong Kubernetes integration

---

# 1️⃣4️⃣ Real DevOps Use Case 

Imagine your students build:

* NodeJS app
* Dockerfile
* Helm chart

GitLab pipeline:

1. Build Docker image
2. Push to registry
3. Deploy to EKS
4. Notify Slack

All automatic.

That’s real DevOps.

---

# 1️⃣5️⃣ Interview Answer (Professional)

> GitLab is a complete DevOps platform that provides source code management, CI/CD automation, security scanning, container registry, and deployment capabilities in a single application. As a DevOps engineer, I use GitLab to automate build and deployment pipelines, manage infrastructure as code, integrate security scanning, and deploy applications to Kubernetes environments.

---

# Final Summary

GitLab is:

* Git repository manager
* CI/CD engine
* Security platform
* Container registry
* DevOps lifecycle tool

DevOps engineers use it to:

* Automate everything
* Reduce manual work
* Deploy faster
* Increase reliability
* Improve security




 The Big Picture: What GitLab CI/CD Actually Is

### What GitLab CI/CD does

* You push code → GitLab creates a **pipeline**
* Pipeline contains **stages**
* Each stage contains **jobs**
* Jobs run on **GitLab Runners**
* Jobs execute scripts and can produce:

  * **artifacts** (files stored by GitLab)
  * **reports** (test reports, security reports)
  * **docker images** (if you build/push)
  * **deployments** (to servers/Kubernetes)

### Key terms 
* **Pipeline**: whole workflow for a commit/branch/MR
* **Stage**: high-level step (build, test, deploy)
* **Job**: unit of execution inside a stage
* **Runner**: machine that executes jobs
* **Executor**: how runner runs jobs (shell, docker, kubernetes)
* **Artifact**: saved output from a job (zip, binary, report)
* **Cache**: speeds up pipelines by reusing dependencies

---

 GitLab CI Architecture (Server vs Runner)

### GitLab server responsibilities

* stores repos, UI, pipeline definitions
* schedules jobs
* stores artifacts, logs, variables
* controls permissions

### Runner responsibilities

* polls GitLab for jobs
* executes jobs in an environment (executor)
* uploads logs/artifacts back to GitLab

### Runner types

* **Shared runner** (company-wide)
* **Group runner** (for a group)
* **Project runner** (for one project)

### Executor choices (what DevOps decides)

* **Shell**: runs directly on VM (fast, but riskier)
* **Docker**: isolated containers per job (common)
* **Kubernetes**: each job runs as a pod (best for scale)
* **Docker+Machine / autoscaling**: dynamic build fleet

---

##  Core Syntax: `.gitlab-ci.yml` From Zero to Real Pipeline

### Pipeline skeleton

```yaml
stages:
  - build
  - test
  - package
  - deploy
```

### A minimal job

```yaml
hello:
  stage: test
  script:
    - echo "Hello from GitLab CI"
```

### A realistic Node.js example (build + test)

```yaml
stages: [build, test]

default:
  image: node:20
  before_script:
    - node -v
    - npm -v

build:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    when: always
    expire_in: 7 days
    paths:
      - dist/

test:
  stage: test
  script:
    - npm ci
    - npm test
```

Key points :

* `image:` means the job runs inside that container (Docker executor)
* `before_script:` runs before each job (unless overridden)
* `artifacts.paths` persists build output for later jobs/download

### Why artifacts matter

Without artifacts, each job is isolated. If you build in one job and want to deploy in another, you need artifacts (or you rebuild).

---

##  Runners Deep Dive: Setup, Tags, and Execution Flow

### How job gets matched to a runner

Jobs can specify:

* tags (runner must have same tag)
* protected/unprotected
* runner type (shared vs project)

Example:

```yaml
build:
  stage: build
  tags: ["docker-runner"]
  script:
    - echo "Runs only on runners tagged docker-runner"
```

### Common real-world runner setups

1. **EC2 VM + Docker executor** (most common for learning)
2. **Kubernetes runner** (best for production scale)
3. **Shell runner** (quick but risky; avoid for multi-tenant)

### Runner security basics 

* Runner is like “hands” executing your code.
* If someone can push code that runs in a pipeline, they can execute commands on the runner environment.
* Use:

  * protected branches
  * protected variables
  * least privileges for cloud credentials
  * separate runners for prod deploys

---

## Pipeline Efficiency: Cache vs Artifacts (Critical)

### Cache (speed): reuse dependencies between pipelines

* Example: Node modules cache

```yaml
default:
  image: node:20
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .npm/

build:
  stage: build
  script:
    - npm ci --cache .npm --prefer-offline
    - npm run build
```

**Explain clearly:**

* Cache is “best effort” speed optimization.
* Artifacts are “guaranteed” outputs stored by GitLab.

### Artifacts (correctness): pass outputs between jobs

```yaml
build:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  script:
    - ls -la dist
```

### Typical mistake

 confuse cache with artifacts and wonder why files don’t exist in next job. Repeat:

* cache = dependency speed
* artifacts = build outputs you need later

---

##  Real Control: `rules`, `only/except`, `needs`, `when`, `allow_failure`

This is where pipelines become professional.

### `rules` (modern way)

Run job only on merge requests:

```yaml
test:
  stage: test
  script: npm test
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

Run deploy only on main branch:

```yaml
deploy:
  stage: deploy
  script: ./deploy.sh
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

Manual job for production:

```yaml
deploy_prod:
  stage: deploy
  script: ./deploy_prod.sh
  when: manual
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

### `needs` (pipeline speed)

By default, stages are sequential. `needs` allows faster pipelines by enabling jobs to start once dependencies are done.

```yaml
build:
  stage: build
  script: npm run build
  artifacts:
    paths: [dist/]

unit_test:
  stage: test
  script: npm test

deploy:
  stage: deploy
  needs: ["build"]
  script: ./deploy.sh
```

Explain:

* `deploy` does not need to wait for all test jobs unless you require it.

### `allow_failure`

Useful for optional scans or flaky tests in learning:

```yaml
lint:
  stage: test
  script: npm run lint
  allow_failure: true
```

---

## Secrets and Variables: Correct DevOps Practice

### Variable types

* **Project variables**
* **Group variables**
* **Instance variables**
* **Protected variables** (only on protected branches/tags)
* **Masked variables** (hidden in logs)

### Use variables in job

```yaml
deploy:
  stage: deploy
  script:
    - echo "Deploying to $ENV_NAME"
    - ./deploy.sh "$ENV_NAME"
```

### Protect production credentials

Best practice:

* `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` stored as **protected + masked**
* production deploy job runs only on protected branch (main) + manual

### Common mistake 

Never hardcode secrets in `.gitlab-ci.yml` or repo.
Use variables or better: cloud-native auth (OIDC/IAM role) if available.

---

## Docker Build & Push in GitLab (Real DevOps Flow)

### Option A: Docker-in-Docker (DinD) (common but needs caution)

```yaml
build_image:
  stage: build
  image: docker:27
  services:
    - docker:27-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    - docker build -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA" .
    - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"
  rules:
    - if: '$CI_COMMIT_BRANCH'
```

Explain:

* `CI_REGISTRY_*` variables exist if you use GitLab Container Registry.
* For DockerHub, store credentials as variables.

### Option B: Kaniko (more secure in Kubernetes)

 advanced: mention Kaniko builds images without privileged DinD.

---

##  Deployments: Environments, Kubernetes, Rollback

### Environments in GitLab

You can track deploy history.

```yaml
deploy_staging:
  stage: deploy
  script: ./deploy_staging.sh
  environment:
    name: staging
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'
```

Production manual:

```yaml
deploy_prod:
  stage: deploy
  script: ./deploy_prod.sh
  environment:
    name: production
  when: manual
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

### Kubernetes deploy (conceptual + example)

Typical approach:

* pipeline updates Helm chart values or runs `helm upgrade`
* needs kubeconfig or cluster auth

Example (simplified):

```yaml
deploy_eks:
  stage: deploy
  image: alpine/helm:3.15.0
  script:
    - helm upgrade --install manual-app ./chart -n app --create-namespace
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

 what DevOps must solve:

* How runner authenticates to cluster
* Where kubeconfig lives (variable or mounted secret)
* Least privilege RBAC

### Rollback concept

* Tag-based releases
* Keep previous image tags
* `helm rollback` or redeploy previous version

---

##  Templates, Reuse, Monorepos, Child Pipelines (Advanced)

### YAML reuse with `extends`

```yaml
.base_node:
  image: node:20
  before_script:
    - npm ci

test:
  extends: .base_node
  stage: test
  script: npm test
```

### `include` (shared pipelines)

```yaml
include:
  - project: "platform/ci-templates"
    file: "/node/default.yml"
```

### Child pipelines

Use when:

* monorepo with many services
* split responsibilities
* reduce complexity

---

##  GitLab “CI/CD as Policy”: Approvals, Protected Branches, MR Pipelines



### What DevOps sets up

* Branch protection:

  * main branch protected
  * only maintainers can push
* Merge request approvals:

  * 1–2 reviewers required
* Pipeline required to pass before merge:

  * no green pipeline → no merge
* Separate runners:

  * staging runner
  * production runner (restricted)

This is where GitLab becomes a **release control system**, not just automation.

---

##  Troubleshooting: How DevOps Debugs GitLab Pipelines

consistent debug checklist:

### A) Pipeline didn’t run

* check `.gitlab-ci.yml` exists on that branch
* check `rules` conditions (most common)
* check pipeline source type (push vs MR vs schedule)

### B) Job stuck “pending”

* no runner available
* tags don’t match any runner
* runner is offline
* runner is protected but job is not (or vice versa)

### C) Job fails immediately

* image not found
* script syntax errors
* missing tools (curl, helm, aws cli)

### D) Permission problems

* registry auth (wrong login)
* cloud credentials not available
* protected variables not exposed to branch

### E) Slow pipeline

* add cache for dependencies
* use `needs` for parallelism
* reduce repeated installs (use base images, prebuilt images)

### F) Debug commands 

Add temporary debug:

```yaml
script:
  - set -euxo pipefail
  - env | sort
  - ls -la
  - whoami
```

---

## Final Wrap-Up: 

1. GitLab = scheduler + UI; **Runner executes**
2. `.gitlab-ci.yml` = pipeline as code
3. **Artifacts** pass outputs; **cache** speeds installs
4. `rules` controls when jobs run
5. DevOps sets up:

   * runners
   * permissions
   * secrets
   * deployments
   * policies (branch protection, approvals)


