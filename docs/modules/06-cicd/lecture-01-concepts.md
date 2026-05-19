# Lecture 1 · CI/CD Concepts & Pipelines

## The problem CI/CD solves

Without automation, deploying software looks like:

1. Developer finishes feature, manually runs some tests
2. Emails a zip file or merge request to a "build person"
3. Build person compiles and tests on their machine
4. Hands off to QA team
5. QA runs manual tests over several days
6. After QA signoff, an ops person deploys manually, usually at night
7. Something breaks in production at 11pm because the ops person's deployment differed from QA's environment

Each handoff introduces delay, errors, and mismatches. The feedback loop from "write code" to "know if it works" is days long.

With CI/CD, the feedback loop collapses to minutes. A developer pushes code and within 5-10 minutes knows if their change broke any tests, failed to build, or caused a security issue. If it passes all gates, deployment is automatic.

---

## Pipeline stages

A typical CI/CD pipeline:

```
Code push
    │
    ▼
┌─────────┐
│  Lint   │  Code style, static analysis, type checking
└────┬────┘
     │ pass
     ▼
┌─────────┐
│  Test   │  Unit tests, integration tests
└────┬────┘
     │ pass
     ▼
┌─────────┐
│  Build  │  Compile code, build Docker image
└────┬────┘
     │ pass
     ▼
┌─────────────┐
│  Security   │  Container scanning, dependency audit, SAST
└──────┬──────┘
       │ pass
       ▼
┌─────────────┐
│  Publish    │  Push image to registry with immutable tag
└──────┬──────┘
       │ pass
       ▼
┌─────────────┐
│  Deploy     │  Deploy to staging, run smoke tests
│  (Staging)  │
└──────┬──────┘
       │ pass
       ▼
┌─────────────┐
│  Deploy     │  Deploy to production (manual approval or automatic)
│  (Prod)     │
└─────────────┘
```

Any stage can fail the pipeline. Failures stop the pipeline at that point — nothing gets deployed if tests fail.

---

## Artifact management

### The immutable artifact principle

Build the artifact once. Deploy that same artifact through every environment — staging, QA, production. If staging passes with image `myapp:sha-a3f8c91`, production gets exactly that image. Not "the same code rebuilt" — the exact same image.

This is important because: rebuilding code between environments can produce different results (different OS packages available, different compiler, different transient dependencies). "Works in staging" followed by "broken in production" is often caused by environment differences. Immutable artifacts eliminate this class of problem.

### Image tagging strategy

```bash
# BAD — "latest" is mutable and ambiguous
docker tag myapp:latest myrepo/myapp:latest

# GOOD — immutable tags
# Git commit SHA
docker tag myapp myrepo/myapp:sha-$(git rev-parse --short HEAD)

# Git tag (for releases)
docker tag myapp myrepo/myapp:v1.2.3

# Both — allows finding the running version
docker tag myapp myrepo/myapp:sha-a3f8c91
docker tag myapp myrepo/myapp:latest  # convenience, points to same image
```

In Kubernetes manifests, always use the SHA tag, not `latest`:

```yaml
image: myrepo/myapp:sha-a3f8c91   # always know what is running
```

---

## Deployment strategies

### Rolling update

Replace pods one (or a few) at a time. New and old versions run simultaneously during the transition. Zero downtime if the new version is backwards-compatible.

```
Before: [v1] [v1] [v1] [v1]
Step 1: [v1] [v1] [v1] [v2]
Step 2: [v1] [v1] [v2] [v2]
Step 3: [v1] [v2] [v2] [v2]
Step 4: [v2] [v2] [v2] [v2]
```

Kubernetes Deployments use rolling update by default.

**Limitation:** Both versions are live simultaneously. Database migrations must be backwards-compatible. API changes must be backwards-compatible.

### Blue-Green

Run two identical environments. Production (blue) serves all traffic. When ready to deploy, update green to the new version. Switch traffic all at once. If problems occur, switch back to blue.

```
Blue  (v1): ← production traffic
Green (v2): running, not receiving traffic

→ switch →

Blue  (v1): standby (rollback target)
Green (v2): ← production traffic
```

**Advantage:** Instant rollback by switching traffic back.  
**Cost:** Double the infrastructure cost during deployment.

### Canary

Send a small percentage of traffic to the new version, monitor for errors, gradually increase.

```
v1: 100%
→ deploy v2
v1: 95%, v2: 5%   — monitor
v1: 80%, v2: 20%  — monitor
v1: 50%, v2: 50%  — monitor
v1: 0%,  v2: 100% — done
```

**Advantage:** Real user traffic tests the new version at low risk.  
**Complexity:** Requires traffic splitting (Ingress, service mesh, or load balancer support).

### Feature flags

Deploy code with new features disabled. Enable features in production without a new deployment. Allows separating deployment from release.

```python
if feature_flags.is_enabled("new-checkout-flow", user=current_user):
    return new_checkout()
else:
    return old_checkout()
```

---

## What makes a good pipeline

**Speed.** A 45-minute pipeline means developers get feedback 45 minutes after pushing. They have moved on, lost context, and will be interrupted. Under 10 minutes is the target for the CI phase.

**Reliability.** Flaky tests that fail sometimes but pass on retry are worse than no tests. Every false failure reduces trust in the pipeline. Developers start clicking "retry" without reading the error.

**Clear failures.** When the pipeline fails, the developer should know immediately why. Not "see the logs" — the failure message should say exactly what broke.

**Separation of concerns.** Test failures should not trigger deployments. Lint failures should not block deployment to staging in an emergency. Make the dependencies explicit and controllable.

---

## Summary

- CI = automatic build and test on every commit. Fast feedback loop.
- CD = automatic deployment of every passing commit. No manual handoffs.
- Build once, deploy everywhere. Use immutable image tags (SHA).
- Rolling update for zero-downtime. Blue-green for instant rollback. Canary for gradual rollout.
- Good pipelines are fast (under 10 min CI), reliable, and report clear failures.
