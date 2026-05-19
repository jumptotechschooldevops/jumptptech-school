# JumptpTech DevOps School

Welcome to the JumptpTech DevOps curriculum. This is a hands-on program built for engineers who want to understand how production systems actually work — not just pass a certification exam.

The course runs eight modules, each one building on the last. By the end you will be comfortable taking code from a developer's laptop through a CI/CD pipeline, packaging it in containers, deploying it to Kubernetes, and watching it with Prometheus and Grafana. You will do this for real, with real tools, on real infrastructure.

---

## How this curriculum is organised

Each module contains:

- **Lectures** — concept-first explanations with worked examples. Read these before touching anything.
- **Labs** — step-by-step exercises you run on your own machine or a cloud VM. Every command shown is one you will actually type.

Modules must be done in order. A student who skips Linux basics will struggle with Kubernetes networking. A student who skips networking will struggle with Docker. The dependencies are real.

---

## Modules at a glance

| # | Topic | Key skills |
|---|-------|-----------|
| 01 | [Git](modules/01-git/index.md) | commits, branches, rebasing, merge conflicts, pull requests |
| 02 | [Linux](modules/02-linux/index.md) | filesystem, permissions, processes, systemd, bash scripting |
| 03 | [Networking](modules/03-networking/index.md) | TCP/IP, DNS, HTTP, firewalls, netstat, curl, tcpdump |
| 04 | [Docker](modules/04-docker/index.md) | images, containers, Dockerfiles, registries, Compose |
| 05 | [Kubernetes](modules/05-kubernetes/index.md) | pods, deployments, services, ingress, configmaps, secrets |
| 06 | [CI/CD](modules/06-cicd/index.md) | GitHub Actions, test automation, image builds, deployments |
| 07 | [Terraform](modules/07-terraform/index.md) | HCL, providers, state, modules, workspaces |
| 08 | [Monitoring](modules/08-monitoring/index.md) | Prometheus, Grafana, alerting, dashboards, log aggregation |

---

## Prerequisites

You need:

- A laptop with at least 8 GB RAM and 40 GB free disk space
- A GitHub account (free tier is fine)
- An AWS account with Free Tier access (modules 07–08)
- Basic comfort with the command line — if you have never opened a terminal before, spend one hour with any "Linux for beginners" video first

We do not assume prior knowledge of containers, cloud, or automation. We do assume you can open a terminal, run a command, and read an error message.

---

## Cheatsheets

Quick references are available for the tools you will use most:

- [Git cheatsheet](cheatsheets/git.md)
- [Linux cheatsheet](cheatsheets/linux.md)
- [Docker cheatsheet](cheatsheets/docker.md)
- [kubectl cheatsheet](cheatsheets/kubectl.md)
- [Terraform cheatsheet](cheatsheets/terraform.md)
- [PromQL cheatsheet](cheatsheets/promql.md)

---

## A note on how to learn here

Read the lecture, then close it and try the lab. If you get stuck, re-read the relevant section. If you are stuck for more than 20 minutes on the same thing, that is useful information — write down exactly what you tried and what happened. A senior engineer who looks at "I ran X and got error Y" can help you in 2 minutes. A senior engineer who looks at "it doesn't work" cannot help at all.

Good luck.
