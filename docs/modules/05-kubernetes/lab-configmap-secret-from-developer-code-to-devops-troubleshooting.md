---
title: "LAB: ConfigMap & Secret — From Developer Code to DevOps Troubleshooting"
description: "0) Folder Structure (Create This First)      mkdir -p..."
published: 2026-01-12
source: "https://dev.to/jumptotech/lab-configmap-secret-from-developer-code-to-devops-troubleshooting-11ja"
tags: []
---

# LAB: ConfigMap & Secret — From Developer Code to DevOps Troubleshooting



# 0) Folder Structure (Create This First)

```bash
mkdir -p config-secret-lab/{app,k8s,aws,secrets}
cd config-secret-lab
```

Final structure:

```
config-secret-lab/
├── app/
│   ├── app.py
│   └── Dockerfile
├── k8s/
│   ├── configmap.yaml
│   ├── deployment-env.yaml
│   ├── deployment-file.yaml
│   ├── service.yaml
│   └── secret.yaml          # optional (we will prefer CLI)
├── aws/
│   ├── secrets-manager.md
│   └── iam-policy.json
├── secrets/
│   └── README.md
└── README.md
```

**DevOps attention**

* You may commit `k8s/configmap.yaml`, `deployment*.yaml`, `service.yaml`, docs in `aws/` and `secrets/README.md`.
* **Do not commit real secret values**. Prefer secret managers or CI injection.

---

# 1) Prerequisites (Minikube)

```bash
minikube start
kubectl get nodes
```

Expected output (example):

* One node
* `STATUS` = `Ready`

**DevOps attention**

* If node is `NotReady`, everything else is noise. Fix cluster first.

---

# 2) Developer Part: App Code (Reads Env Vars OR Files)

## 2.1 Create `app/app.py`

```bash
cat > app/app.py <<'PY'
from flask import Flask
import os

app = Flask(__name__)

def read_secret_file(path: str) -> str:
    try:
        with open(path, "r") as f:
            return f.read().strip()
    except Exception:
        return "missing"

@app.route("/")
def index():
    # Config from environment
    env = os.getenv("APP_ENV", "unknown")
    log = os.getenv("LOG_LEVEL", "unknown")
    db_host = os.getenv("DB_HOST", "missing")

    # Secret from environment (Option A)
    db_pass_env = os.getenv("DB_PASSWORD", "missing")

    # Secret from file (Option B)
    db_pass_file = read_secret_file("/secrets/DB_PASSWORD")

    return f"""
    <h3>Config & Secret Demo</h3>
    <b>APP_ENV</b>={env}<br>
    <b>LOG_LEVEL</b>={log}<br>
    <b>DB_HOST</b>={db_host}<br><br>

    <b>DB_PASSWORD (env)</b>={db_pass_env}<br>
    <b>DB_PASSWORD (file)</b>={db_pass_file}<br>
    """

app.run(host="0.0.0.0", port=8080)
PY
```

**DevOps attention**

* Developer code does **not** contain passwords.
* App supports both patterns: env and file. This lets you compare securely.

---

## 2.2 Create `app/Dockerfile`

```bash
cat > app/Dockerfile <<'DOCKER'
FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir flask
COPY app.py .
CMD ["python", "app.py"]
DOCKER
```

---

# 3) Build Image and Load into Minikube

```bash
docker build -t config-secret-demo:1.0 app/
minikube image load config-secret-demo:1.0
```

Expected:

* Docker build succeeds
* Image gets loaded to minikube

**DevOps attention**

* If you forget `minikube image load`, Kubernetes will try to pull from DockerHub and you’ll get `ImagePullBackOff`.

---

# 4) DevOps Part: ConfigMap (Non-Secret)

## 4.1 Create `k8s/configmap.yaml`

```bash
cat > k8s/configmap.yaml <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
  DB_HOST: "mysql.default.svc.cluster.local"
YAML
```

Apply:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl get configmap app-config
kubectl get configmap app-config -o yaml
```

Expected:

* `configmap/app-config created` (or configured)
* YAML shows your keys under `data:`

**DevOps attention**

* ConfigMap is safe for Git **only if it has no credentials**.
* Typical mistake: putting `DB_PASSWORD` in ConfigMap → security incident.

---

# 5) DevOps Part: Secret (Sensitive)

## 5.1 Create Secret via CLI (recommended)

```bash
kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD=supersecret123
```

Verify:

```bash
kubectl get secret app-secret
kubectl describe secret app-secret
```

Expected:

* Secret exists
* `DATA` shows `1`

**DevOps attention**

* It’s **base64 encoded**, not truly protected unless you add encryption at rest + RBAC.
* Anyone with `get secret` permissions can retrieve it.

---

# 6) Deployment Option A: Secret as ENV (Easy, Risky)

## 6.1 Create `k8s/deployment-env.yaml`

```bash
cat > k8s/deployment-env.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: app
        image: config-secret-demo:1.0
        ports:
        - containerPort: 8080
        envFrom:
          - configMapRef:
              name: app-config
          - secretRef:
              name: app-secret
YAML
```

Apply:

```bash
kubectl apply -f k8s/deployment-env.yaml
kubectl get pods -w
```

Expected:

* Pod goes `ContainerCreating` → `Running`
* `READY 1/1`

**DevOps attention**

* If pod shows `CreateContainerConfigError`, it’s often missing secret/configmap name.

Check:

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

---

# 7) Service (Expose App)

## 7.1 Create `k8s/service.yaml`

```bash
cat > k8s/service.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: app-svc
spec:
  type: NodePort
  selector:
    app: demo
  ports:
    - port: 80
      targetPort: 8080
YAML
```

Apply + open:

```bash
kubectl apply -f k8s/service.yaml
minikube service app-svc
```

Expected in browser:

* APP_ENV = production
* LOG_LEVEL = info
* DB_HOST = mysql...
* `DB_PASSWORD (env)` = supersecret123
* `DB_PASSWORD (file)` = missing (because we didn’t mount file yet)

**DevOps attention**

* Seeing `DB_PASSWORD (env)` working proves secret injection.
* Seeing file missing proves there is no secret mount yet.

---

# 8) BREAK & FIX (Production Troubleshooting)

## Case 1: Missing ConfigMap (App still runs but wrong behavior)

```bash
kubectl delete configmap app-config
kubectl delete pod -l app=demo
kubectl get pods -w
```

Expected:

* Pod runs
* Browser shows:

  * `APP_ENV=unknown`
  * `LOG_LEVEL=unknown`
  * `DB_HOST=missing`

**DevOps attention**

* This is a **silent misconfiguration**: app up, behavior wrong.
* Fix:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl rollout restart deployment app
```

---

## Case 2: Missing Secret (Pod fails to start)

```bash
kubectl delete secret app-secret
kubectl delete pod -l app=demo
kubectl get pods
```

Expected:

* Pod becomes `CreateContainerConfigError`

Debug:

```bash
kubectl describe pod <pod-name>
```

Expected message:

* `secret "app-secret" not found`

Fix:

```bash
kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD=supersecret123
kubectl delete pod -l app=demo
```

**DevOps attention**

* Missing secret causes **outage**, not just “wrong behavior”.

---

# 9) Secret Rotation (Senior Skill)

Update secret value:

```bash
kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD=newpassword456 \
  --dry-run=client -o yaml | kubectl apply -f -
```

Now check browser:

* Env may still show old password until restart.

Restart deployment:

```bash
kubectl rollout restart deployment app
```

Expected:

* Browser shows `DB_PASSWORD (env)=newpassword456`

**DevOps attention**

* Env-var secrets require restart.
* Many outages happen because teams rotate secret but forget restart.

---

# 10) Deployment Option B: Secret as FILE (Production-Preferred)

## 10.1 Create `k8s/deployment-file.yaml`

```bash
cat > k8s/deployment-file.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      volumes:
        - name: secret-vol
          secret:
            secretName: app-secret
      containers:
      - name: app
        image: config-secret-demo:1.0
        ports:
        - containerPort: 8080
        envFrom:
          - configMapRef:
              name: app-config
        volumeMounts:
          - name: secret-vol
            mountPath: /secrets
            readOnly: true
YAML
```

Apply:

```bash
kubectl apply -f k8s/deployment-file.yaml
kubectl rollout status deployment app
```

Expected in browser:

* `DB_PASSWORD (env)` might be `missing` (we removed secretRef)
* `DB_PASSWORD (file)` = current secret value (e.g., newpassword456)

**DevOps attention**

* This is the **preferred pattern** in many regulated orgs.
* Secrets are not visible via `env`.

Test:

```bash
kubectl exec -it deploy/app -- env | grep DB_PASSWORD || echo "DB_PASSWORD not in env"
```

Expected:

* “DB_PASSWORD not in env”

---

# 11) Why Some Teams BAN Env-Var Secrets (Practical Reasons)

Teams ban env secrets because:

* `kubectl exec env` can leak secrets into tickets/Slack
* Debug endpoints can accidentally expose env
* Core dumps may include env
* Harder to audit and control

**Senior mental model**

* Env = convenience
* Files = safer boundary

---

# 12) How to Detect Leaked Secrets (What to Use)

## 12.1 Git scanning locally (example: gitleaks)

If you use gitleaks in CI, you catch leaks early:

```bash
gitleaks detect --source .
```

## 12.2 GitHub secret scanning

* Catches common tokens
* Alerts security quickly
* Still not enough → you need prevention + rotation playbook

## 12.3 Cluster signals to watch

* Pods failing after secret change
* Unexpected rollouts
* Frequent `CreateContainerConfigError`

---

# 13) AWS Secrets Manager (Production Integration)

## 13.1 What production does (best practice)

Flow:

```
AWS Secrets Manager → External Secrets Operator → K8s Secret → Mounted as files → App
```

Why:

* Encryption at rest
* IAM access control
* Rotation support
* CloudTrail auditing
* No secrets in Git

## 13.2 Document it (you don’t store values here)

Create `aws/secrets-manager.md`:

```bash
cat > aws/secrets-manager.md <<'MD'
# AWS Secrets Manager → Kubernetes (Production Pattern)

Preferred flow:
AWS Secrets Manager
  -> External Secrets Operator (ESO)
  -> Kubernetes Secret
  -> mount as files (/secrets)
  -> application reads file

Why:
- encryption + auditing
- IAM-based least privilege
- rotation support
- no secrets in Git

Operational rule:
After rotation, ensure workloads reload secrets:
- restart pods OR
- use file-mounted secrets + app reload logic
MD
```

---

# 14) Security Audit Checklist (Senior-Level)

## Git / Repo

* [ ] No secret values committed (including history)
* [ ] Secret scanning enabled
* [ ] `.env` ignored
* [ ] CI injects secrets

## Kubernetes

* [ ] No credentials in ConfigMaps
* [ ] RBAC restricts secrets (`get/list/watch`)
* [ ] Namespace isolation (dev/stage/prod)
* [ ] Prefer file-mounted secrets for prod
* [ ] No debug endpoints printing env/config
* [ ] Logs don’t print secrets

## AWS

* [ ] Use IAM roles (not long-lived access keys)
* [ ] Secrets stored in Secrets Manager
* [ ] Rotation enabled where possible
* [ ] CloudTrail enabled for audit

---

# 15) Production Outage Stories (Quick List to Remember)

* Secret deleted → pods fail (`CreateContainerConfigError`) → outage
* Secret rotated but pods not restarted → app fails auth/DB → outage
* Secret committed to git → key compromised → financial + security incident
* Same secret across envs → dev mistake hits prod → disaster

---

# What you should do now (exact sequence)

1. Run the lab with **deployment-env.yaml** and confirm env secret works
2. Break/fix missing ConfigMap and missing Secret
3. Rotate secret and observe restart requirement
4. Switch to **deployment-file.yaml** and confirm file-based secret works
5. Practice “leak risk” by running `kubectl exec env` and seeing why env secrets are dangerous


