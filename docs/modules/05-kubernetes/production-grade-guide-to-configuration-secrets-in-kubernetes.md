---
title: "production-grade guide to Configuration & Secrets in Kubernetes"
description: "Mental model first (very important)         Kubernetes does NOT magically manage..."
published: 2026-01-09
source: "https://dev.to/jumptotech/production-grade-guide-to-configuration-secrets-in-kubernetes-1ogk"
tags: []
---

# production-grade guide to Configuration & Secrets in Kubernetes


## Mental model first (very important)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AIqSixgSg53qKT4cv.png)

![Image](https://drek4537l1klr.cloudfront.net/luksa/Figures/07fig02.jpg)

![Image](https://doimages.nyc3.cdn.digitaloceanspaces.com/006Community/Learning_Paths/k8s/sealed_secrets_flow.png)

**Kubernetes does NOT magically manage configuration.**
It only **injects data** into containers.
What the app does with it is **your responsibility**.

---

# 1️⃣ What DevOps must understand FIRST

### Configuration problems cause:

* Apps starting but behaving wrong
* Random crashes after deploys
* Downtime during config changes
* Security leaks (very common)

### Core rule

> **Kubernetes delivers config. Applications consume it. Kubernetes does NOT reload it automatically.**

---

# 2️⃣ ConfigMap vs Secret (zero confusion rule)

| Feature            | ConfigMap   | Secret            |
| ------------------ | ----------- | ----------------- |
| Sensitive          | ❌ No        | ✅ Yes             |
| Base64             | ❌ No        | ✅ Yes             |
| Git safe           | ✅ Yes       | ❌ No              |
| Encryption at rest | ❌ No        | ⚠️ Optional       |
| Examples           | URLs, flags | passwords, tokens |

### DevOps rule

* **ConfigMap = behavior**
* **Secret = credentials**

Never mix them.

---

# 3️⃣ How configuration is injected (3 ways)

## Method 1 — Environment variables (MOST COMMON)

### ConfigMap

```bash
kubectl create configmap app-config \
  --from-literal=APP_MODE=prod \
  --from-literal=LOG_LEVEL=info
```

### Secret

```bash
kubectl create secret generic app-secrets \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS=supersecret
```

### Inject into Pod

```yaml
env:
- name: APP_MODE
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_MODE
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: DB_PASS
```

### DevOps attention points

* App restart REQUIRED to apply changes
* Env vars are visible via `kubectl describe pod`
* Never log env vars

---

## Method 2 — EnvFrom (bulk injection)

```yaml
envFrom:
- configMapRef:
    name: app-config
- secretRef:
    name: app-secrets
```

### When DevOps uses this

* Microservices
* Standardized configs
* Fast onboarding

### Danger

* Variable name collisions
* Harder debugging

---

## Method 3 — Mounted files (MOST PROFESSIONAL)

### Why DevOps prefers this

* Supports live reload (if app supports it)
* Cleaner separation
* Works for certificates, configs, JSON, YAML

### ConfigMap as file

```yaml
volumes:
- name: config
  configMap:
    name: app-config

volumeMounts:
- name: config
  mountPath: /etc/config
```

### Result inside container

```bash
/etc/config/APP_MODE
/etc/config/LOG_LEVEL
```

### Secret as file

```yaml
volumes:
- name: secrets
  secret:
    secretName: app-secrets
```

### DevOps reality

* Kubernetes updates files automatically
* App must **watch files or reload**
* Most apps DO NOT reload by default

---

# 4️⃣ The biggest DevOps mistake (very common)

> ❌ “I updated ConfigMap but app didn’t change”

### Why?

* Pods don’t restart
* Env vars are immutable
* App doesn’t reload mounted files

### Correct solutions (DevOps options)

#### Option 1 — Rolling restart

```bash
kubectl rollout restart deployment app
```

#### Option 2 — Hash-based rollout (BEST PRACTICE)

```yaml
metadata:
  annotations:
    config-hash: "{{ .Values.configHash }}"
```

(Change annotation → rollout triggered)

---

# 5️⃣ Secrets: what DevOps MUST secure

![Image](https://4sysops.com/wp-content/uploads/2023/08/Understanding-how-secrets-are-stored-with-and-without-encryption.png)

![Image](https://linuxbuz.com/wp-content/uploads/2024/09/How-to-Decode-a-Kubernetes-Secrets.png)

### Critical truths

* Secrets are **base64**, NOT encrypted
* Anyone with RBAC access can read them
* GitHub leaks happen weekly

### Minimum DevOps requirements

* Enable encryption at rest (cloud KMS)
* Restrict RBAC
* Use namespace isolation
* Rotate secrets

---

# 6️⃣ What NOT to do (interview traps)

❌ Put secrets in YAML
❌ Commit secrets to Git
❌ Share secrets across namespaces
❌ Use same secret in dev & prod
❌ Restart cluster for config changes

---

# 7️⃣ Production patterns DevOps uses

## Pattern 1 — External Secret Managers

* AWS Secrets Manager
* HashiCorp Vault
* Azure Key Vault

Flow:

```
Vault → ExternalSecrets → Kubernetes Secret → Pod
```

### Why DevOps prefers this

* Rotation
* Audit logs
* Central control

---

## Pattern 2 — Immutable config

* New config = new deployment
* No live mutation
* Git controls everything

This prevents:

* Drift
* Mystery changes
* “Works on my cluster”

---

# 8️⃣ Troubleshooting checklist (real-life)

### App not behaving as expected

```bash
kubectl describe pod
kubectl exec pod -- env
kubectl exec pod -- cat /etc/config/*
```

### Secret missing

```bash
kubectl get secret
kubectl describe secret
```

### Config updated but app unchanged

* Check restart
* Check reload capability
* Check correct mount path

---

# 9️⃣ How to explain this in interviews (perfect answer)

> “ConfigMaps control application behavior, Secrets control credentials. Kubernetes injects them but doesn’t manage reload. DevOps must handle rollout, security, and lifecycle correctly.”

---

# 10️⃣ What senior DevOps MUST know (non-negotiable)

You must know:

* All injection methods
* Reload limitations
* Security risks
* Rollout strategies
* External secret managers
* RBAC implications

---

## Final DevOps truth (important)

> **Most production incidents are configuration issues, not code issues.**
> Kubernetes only exposes them faster.

---

### Recommended next topics (logical order)

1. **Resource requests & limits (OOMKilled lab)**
2. **Rolling & Canary deployments using readiness**
3. **Ingress + TLS secrets**
4. **External Secrets + Vault**
5. **GitOps config management**

Tell me **which one you want next**, and I’ll give you a **full production lab with failure demos**.

