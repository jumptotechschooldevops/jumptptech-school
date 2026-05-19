---
title: "what is inside gitlab"
description: "Project header basics     Project (aisalkyn85-project): one repo + issues + pipelines +..."
published: 2026-02-20
source: "https://dev.to/jumptotech/what-is-inside-gitlab-chf"
tags: []
---

# what is inside gitlab


## Project header basics

* **Project (aisalkyn85-project)**: one repo + issues + pipelines + deployments + monitoring, all in one place.
* **Pinned**: shortcuts you choose (for quick access to things you use often).
* **Issues / Merge requests = 0**: means you haven’t started tracking work items (Issues) or code changes (MRs) yet.

---

## Manage

**Goal:** project administration and access.

What you do as DevOps:

1. **Members / Access**: add developers, set roles (Guest/Reporter/Developer/Maintainer/Owner).
2. **Settings**: configure project visibility, default branch protection, merge rules, CI/CD settings.
3. **SSH Keys (usually under your profile, not only project)**: add your public key so you can `git clone`/`push` via SSH securely.

Typical outcomes:

* You lock down `main/master` (protected branch).
* You require MR approvals + pipeline success before merge.

---

## Plan

**Goal:** organize work before coding.

What you do:

1. **Issues**: tasks/bugs/features (like Jira tickets but inside GitLab).
2. **Labels/Milestones**: tag work by “bug”, “devops”, “urgent”, and plan releases/sprints.
3. **Boards**: Kanban board (“To do → Doing → Done”).
4. **Epics (group level)**: big initiatives across multiple projects.

DevOps examples:

* “Create Terraform module for VPC”
* “Implement GitLab CI pipeline for build/test/push”
* “Deploy to EKS using Helm”

---

## Automate

**Goal:** CI/CD pipelines (this is the DevOps heart).

What you do:

1. **Pipelines**: see runs of your `.gitlab-ci.yml` (passed/failed logs).
2. **Jobs**: each step in pipeline (lint, test, build, security scan, deploy).
3. **Schedules**: run pipelines on a schedule (nightly tests, weekly scans).
4. **CI/CD Variables**: store secrets/config safely (tokens, cloud creds) — don’t hardcode in repo.
5. **Runners**: machines/agents that execute your jobs (shared runner or your own EC2/K8s runner).

DevOps outcomes:

* Every push triggers build + test.
* Merge triggers deploy to staging.
* Tag triggers deploy to production.

---

## Code

**Goal:** everything related to the repository and changes.

What you do:

1. **Repository / Files**: browse code, edit files, view history.
2. **Branches**: feature branches workflow (`feature/*`, `hotfix/*`).
3. **Merge Requests (MRs)**: code review + approvals + pipeline gates.
4. **Tags/Releases**: versioning (`v1.2.0`) and release notes.
5. **Web IDE**: edit in browser (useful for quick edits, not heavy work).

DevOps best practice:

* Protect `main`, require MR approvals + “pipeline must pass”.

---

## Build

**Goal:** artifacts and packages produced by pipelines.

What you do:

1. **Artifacts**: pipeline outputs (test reports, compiled binaries).
2. **Package Registry**: store built packages (npm, Maven, PyPI, etc.).
3. **Container Registry**: store Docker images (`registry.gitlab.com/…/image:tag`).

DevOps example flow:

* Pipeline builds Docker image → pushes to Container Registry → deploy job uses that image.

---

## Secure

**Goal:** security scanning integrated into CI/CD (DevSecOps).

What you do:

1. **SAST**: scan code for vulnerabilities.
2. **Dependency scanning**: scan libraries (npm/pip/etc.).
3. **Container scanning**: scan images for CVEs.
4. **Secret detection**: find leaked passwords/keys.
5. **Security Dashboard**: view and track vulnerabilities.

DevOps outcomes:

* Security checks become part of “definition of done”.
* Block merges if critical vulnerabilities exist.

---

## Deploy

**Goal:** environments and deployments.

What you do:

1. **Environments**: define `dev`, `staging`, `prod`.
2. **Deployments**: history of what version went where and when.
3. **Releases**: connect code versions to deployments.
4. **Kubernetes integration (if configured)**: deploy to clusters, view pods/services (depends on setup).

DevOps example:

* MR deploys a review app (temporary environment per MR)
* Merge to main deploys to staging
* Manual approval deploys to production

---

## Operate

**Goal:** run-time operations tooling (ops workflows).

What you do:

* Track operational status, incident-type workflows (varies by GitLab edition/config).
* Connect apps and operational visibility with environments.

DevOps use:

* Keep operational context tied to deployments and incidents.

---

## Monitor

**Goal:** monitoring/observability inside GitLab.

What you do:

* View metrics (often via Prometheus integration), alerts, and environment health (depending on setup).

DevOps use:

* After deploy, confirm health and watch error rates/latency.

---

## Analyze

**Goal:** analytics and insights.

What you do:

* Pipeline analytics, deployment frequency, lead time, DORA-style metrics (depending on plan/features).

DevOps use:

* Measure delivery performance and find bottlenecks (slow pipelines, flaky tests).

---

## Settings (project settings)

This is where you lock the project down and make it “production ready”.

Most important DevOps settings:

1. **Protected branches**: only allow merges/pushes by maintainers.
2. **Merge checks**: require approvals, require pipeline success.
3. **CI/CD variables**: store secrets securely.
4. **Runners**: attach your runner and restrict who can use it.
5. **Integrations/Webhooks**: connect Slack, Jira, AWS, etc.

---

## GitLab Ultimate trial / GitLab Credits / Duo / University

These are “platform features” not your repo code.

* **GitLab Ultimate trial**: unlocks advanced security, compliance, analytics, etc.
* **GitLab Credits**: consumption-based features (often AI/agents/compute depending on GitLab offering).
* **GitLab Duo / Agentic Chat / Flows**: AI helpers to explain code, generate CI snippets, troubleshoot pipelines (useful, but still verify outputs).
* **GitLab University**: learning resources.


