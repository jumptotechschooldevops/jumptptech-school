---
title: "What problem do Config & Secret solve?"
description: "They solve configuration separation.  Golden rule (very important):   Application code should NOT..."
published: 2026-01-12
source: "https://dev.to/jumptotech/what-problem-do-config-secret-solve-9j1"
tags: []
---

# What problem do Config & Secret solve?



## 

They solve **configuration separation**.

**Golden rule (very important):**

> **Application code should NOT change when configuration changes.**

Kubernetes gives us **ConfigMaps** and **Secrets** to externalize configuration.

---

## ConfigMap — “Non-Sensitive Configuration”

![Image](https://cdn.prod.website-files.com/626a25d633b1b99aa0e1afa7/6809ddcf993ea5ce2613819f_image2.jpg)

![Image](https://wangwei1237.github.io/Kubernetes-in-Action-Second-Edition/images/9.3.png)

![Image](https://miro.medium.com/1%2AgmXKfs48YOxoyQYiqGdglw.png)

### What is a ConfigMap?

A **ConfigMap** stores **non-secret configuration data**, such as:

* Environment variables
* App settings
* Feature flags
* URLs
* Port numbers
* Log levels

### Examples of ConfigMap data

```text
APP_ENV=prod
LOG_LEVEL=debug
DB_HOST=mysql-service
DB_PORT=3306
```

### Why DevOps uses ConfigMaps

* Change config **without rebuilding images**
* Same image → different environments (dev / stage / prod)
* Safe to store in Git

### How ConfigMaps are used

1. As **environment variables**
2. As **mounted files**

---

## Secret — “Sensitive Configuration”

![Image](https://d2908q01vomqb2.cloudfront.net/ca3512f4dfa95a03169c5a670a4c91a19b3077b4/2020/04/09/Screen-Shot-2020-04-09-at-6.54.55-PM.png)

![Image](https://a.storyblok.com/f/153547/2946x3250/39e7a0726d/types_of_k8s_secret-03-03.png)

![Image](https://dz2cdn1.dzone.com/storage/temp/15417658-secret-volume-page-4.png)

### What is a Secret?

A **Secret** stores **sensitive data**, such as:

* Passwords
* API keys
* Tokens
* Certificates
* Private keys

### Examples of Secret data

```text
DB_PASSWORD
AWS_SECRET_ACCESS_KEY
JWT_SECRET
TLS_CERT
```

### Important truth (many beginners miss this)

> Kubernetes Secrets are **Base64 encoded**, NOT encrypted by default.

Encoding ≠ encryption.

### Why DevOps uses Secrets

* Avoid hard-coding credentials
* Control access via RBAC
* Rotate secrets without code changes

---

## ConfigMap vs Secret (Side-by-Side)

| Feature        | ConfigMap            | Secret            |
| -------------- | -------------------- | ----------------- |
| Purpose        | Non-sensitive config | Sensitive data    |
| Stored as      | Plain text           | Base64 encoded    |
| Safe for Git   | Yes                  | No (usually)      |
| RBAC protected | Basic                | Strongly required |
| Examples       | URLs, flags          | Passwords, tokens |

---

## How Pods consume Config & Secret

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AeRnMRGh_zu_GHq07)

![Image](https://phoenixnap.com/kb/wp-content/uploads/2021/04/use-configmap-with-envform.png)

![Image](https://miro.medium.com/1%2A2T2dFm4rt5B-R3hqUqmbZw.png)

### 1️⃣ As Environment Variables

```yaml
envFrom:
  - configMapRef:
      name: app-config
  - secretRef:
      name: app-secret
```

### 2️⃣ As Files (Volumes)

```yaml
volumes:
  - name: secret-vol
    secret:
      secretName: app-secret
```

This is commonly used for:

* TLS certs
* SSH keys
* JSON credentials

---

## DevOps Real-World Use Cases

### Production patterns

* **ConfigMap**

  * Feature toggles
  * App behavior tuning
  * Logging configuration
* **Secret**

  * Database credentials
  * Cloud provider keys
  * OAuth tokens

### What breaks if misused

* Secrets in ConfigMap → **security incident**
* Hardcoded secrets → **credential leak**
* One config for all envs → **deployment failure**

---

## What DevOps Engineers MUST know

✔ Never store secrets in Git
✔ Rotate secrets without redeploying code
✔ Restrict access using RBAC
✔ Prefer **external secret managers** in production:

* AWS Secrets Manager
* HashiCorp Vault
* External Secrets Operator

---

## One-line mental model (remember this)

> **ConfigMap = how the app behaves**
> **Secret = how the app authenticates**


