# Module 06 · CI/CD

CI/CD is the practice that connects code changes to running software. Without it, you have an assembly line where a single human hands things from station to station. With it, code goes from a developer's laptop to production automatically, through automated gates that catch problems early.

**Continuous Integration (CI):** Every commit is automatically built and tested. If a test fails, the developer is notified within minutes, while the context is still fresh.

**Continuous Delivery (CD):** Every commit that passes CI is automatically deployable. A human still presses the button. 

**Continuous Deployment:** Every commit that passes CI is automatically deployed to production. No human button.

Most teams practice CI and either Delivery or Deployment, depending on their risk tolerance and release cadence.

## What you will cover

**Lecture 1 — CI/CD Concepts & Pipelines**
The why and how of CI/CD, pipeline stages, artifact management, deployment strategies (blue-green, canary, rolling).

**Lecture 2 — GitHub Actions in Depth**
Workflows, triggers, jobs, steps, contexts, secrets, caching, matrix builds, and reusable workflows.

**Lab 1 — Build & Test Pipeline**
Write a GitHub Actions workflow that lints, tests, builds a Docker image, and pushes to a registry.

**Lab 2 — Deploy to Kubernetes**
Extend the pipeline to deploy to a Kubernetes cluster, including environment-based deployment and rollback.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 45 min |
| Lecture 2 | 60 min |
| Lab 1 | 90 min |
| Lab 2 | 90 min |

## Prerequisites

- GitHub account
- Docker Hub account (for image registry)
- A Kubernetes cluster (minikube or kind, from Module 05)
