# Module 08 · Monitoring

Running software is not the end of a DevOps engineer's job — knowing how it is running is. Monitoring, alerting, and observability are what separate teams that find out about problems from their users from teams that find out before their users do.

This module covers the observability stack used by most cloud-native teams: Prometheus for metrics collection, Grafana for visualisation, and the concepts that tie them together.

## What you will cover

**Lecture 1 — Observability Principles**
The three pillars (metrics, logs, traces), the difference between monitoring and observability, SLIs and SLOs, and how to design useful alerts.

**Lecture 2 — Prometheus & Grafana**
The Prometheus data model, scraping, PromQL query language, alert rules, Alertmanager, and building Grafana dashboards.

**Lab 1 — Full Monitoring Stack**
Deploy Prometheus, Grafana, and node-exporter with Docker Compose. Write PromQL queries. Build a dashboard. Set up an alert.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 45 min |
| Lecture 2 | 60 min |
| Lab 1 | 90 min |

## Why observability matters

An application that you cannot observe is one you cannot operate. When something goes wrong at 2am — and it will — the difference between resolving the incident in 15 minutes and 4 hours is having the right metrics, logs, and dashboards ready.

Observability is not added after the fact. It is designed in from the beginning.
