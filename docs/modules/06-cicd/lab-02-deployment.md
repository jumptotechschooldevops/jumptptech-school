# Lab 2 · Deploy to Kubernetes

**Duration:** ~90 minutes  
**Goal:** Extend the CI pipeline from Lab 1 to automatically deploy to a Kubernetes cluster after a successful build.

**Prerequisites:** Lab 1 complete, a running Kubernetes cluster (minikube or kind).

---

## Architecture

```
GitHub push → CI (lint + test) → Build image → Push to registry
                                                      ↓
                                               Deploy to staging
                                                      ↓
                                           Manual approval (GitHub Environments)
                                                      ↓
                                               Deploy to production
```

---

## Part 1 — Kubernetes manifests

Create the Kubernetes configuration for the application:

```bash
mkdir -p k8s/base k8s/staging k8s/production
```

### Base manifests

```bash
cat > k8s/base/namespace.yml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: ci-lab
EOF

cat > k8s/base/deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-api
  namespace: ci-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: todo-api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: todo-api
    spec:
      containers:
        - name: todo-api
          image: PLACEHOLDER  # replaced by pipeline
          ports:
            - containerPort: 5000
          env:
            - name: APP_VERSION
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: version
          resources:
            requests:
              memory: "64Mi"
              cpu: "50m"
            limits:
              memory: "128Mi"
              cpu: "200m"
          livenessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 5
            periodSeconds: 10
EOF

cat > k8s/base/service.yml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: todo-api-svc
  namespace: ci-lab
spec:
  type: ClusterIP
  selector:
    app: todo-api
  ports:
    - port: 80
      targetPort: 5000
EOF

cat > k8s/base/configmap.yml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: ci-lab
data:
  version: "dev"
  log_level: "info"
EOF
```

### Staging overlay

```bash
cat > k8s/staging/kustomization.yml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ci-lab-staging

resources:
  - ../base

namePrefix: staging-

patches:
  - target:
      kind: Deployment
      name: todo-api
    patch: |
      - op: replace
        path: /spec/replicas
        value: 1
  - target:
      kind: ConfigMap
      name: app-config
    patch: |
      - op: replace
        path: /data/version
        value: staging
EOF
```

### Production overlay

```bash
cat > k8s/production/kustomization.yml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ci-lab-production

resources:
  - ../base

namePrefix: prod-

patches:
  - target:
      kind: Deployment
      name: todo-api
    patch: |
      - op: replace
        path: /spec/replicas
        value: 3
  - target:
      kind: ConfigMap
      name: app-config
    patch: |
      - op: replace
        path: /data/version
        value: production
EOF
```

---

## Part 2 — Local deployment test

Before automating, make sure the manifests work locally:

```bash
# Create the namespaces
kubectl create namespace ci-lab-staging
kubectl create namespace ci-lab-production

# Apply staging manifests (using kustomize)
kubectl apply -k k8s/staging/

# Check what was created
kubectl get all -n ci-lab-staging

# Update the image manually (simulating what the pipeline does)
kubectl set image deployment/staging-todo-api \
    todo-api=YOUR_USERNAME/devops-ci-lab:latest \
    -n ci-lab-staging

kubectl rollout status deployment/staging-todo-api -n ci-lab-staging

# Test it
kubectl port-forward -n ci-lab-staging \
    service/staging-todo-api-svc 5000:80 &
pf_pid=$!
sleep 2

curl http://localhost:5000/health
curl -X POST http://localhost:5000/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "Test from CI"}'
curl http://localhost:5000/todos

kill $pf_pid
```

---

## Part 3 — kubeconfig for GitHub Actions

GitHub Actions needs credentials to talk to your Kubernetes cluster.

### For minikube

```bash
# Export kubeconfig as base64 (for GitHub Secret)
cat ~/.kube/config | base64 | pbcopy   # macOS
cat ~/.kube/config | base64 | xclip    # Linux

# Note: minikube config uses localhost — needs to be your machine's external IP
# Update the server URL first:
MINIKUBE_IP=$(minikube ip)
kubectl config set-cluster minikube --server="https://$MINIKUBE_IP:8443"
cat ~/.kube/config | base64
```

For a cloud cluster (EKS, GKE, AKS), the standard kubeconfig already uses the external endpoint.

### Add to GitHub Secrets

Go to repository Settings → Secrets → Actions, add:

- `KUBE_CONFIG` — the base64-encoded kubeconfig content

---

## Part 4 — Deployment workflow

```bash
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy

on:
  workflow_run:
    workflows: [CI]
    types: [completed]
    branches: [main]

jobs:
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}

    environment:
      name: staging
      url: http://staging.internal/

    steps:
      - uses: actions/checkout@v4

      - name: Set up kubectl
        uses: azure/setup-kubectl@v3

      - name: Configure kubectl
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config
          kubectl version --client

      - name: Determine image tag
        id: image
        run: |
          SHA="${{ github.event.workflow_run.head_sha }}"
          SHORT_SHA="${SHA::7}"
          echo "tag=sha-$SHORT_SHA" >> $GITHUB_OUTPUT
          echo "full_image=${{ secrets.DOCKERHUB_USERNAME }}/devops-ci-lab:sha-$SHORT_SHA" >> $GITHUB_OUTPUT

      - name: Apply base manifests
        run: |
          kubectl apply -k k8s/staging/

      - name: Update image
        run: |
          kubectl set image deployment/staging-todo-api \
            todo-api=${{ steps.image.outputs.full_image }} \
            -n ci-lab-staging

      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/staging-todo-api \
            -n ci-lab-staging \
            --timeout=120s

      - name: Smoke tests
        run: |
          # Port forward and run quick smoke tests
          kubectl port-forward -n ci-lab-staging \
            service/staging-todo-api-svc 5001:80 &
          PF_PID=$!
          sleep 5

          # Health check
          STATUS=$(curl -sf http://localhost:5001/health | python3 -c "import sys,json; print(json.load(sys.stdin)['status'])" 2>/dev/null)
          if [ "$STATUS" != "ok" ]; then
            echo "Health check failed: $STATUS"
            kill $PF_PID
            exit 1
          fi

          # Create a todo
          TODO_RESP=$(curl -sf -X POST http://localhost:5001/todos \
            -H "Content-Type: application/json" \
            -d '{"title": "Smoke test todo"}')
          TODO_ID=$(echo "$TODO_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

          # Verify it was created
          curl -sf http://localhost:5001/todos | \
            python3 -c "import sys,json; todos=json.load(sys.stdin)['todos']; assert any(t['id']==$TODO_ID for t in todos)"

          echo "Smoke tests passed"
          kill $PF_PID

      - name: Annotate deployment
        if: success()
        run: |
          kubectl annotate deployment/staging-todo-api \
            -n ci-lab-staging \
            kubernetes.io/change-cause="Deploy ${{ steps.image.outputs.tag }} from CI run ${{ github.run_id }}" \
            --overwrite

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging

    environment:
      name: production
      url: http://api.jumptptech.school/

    steps:
      - uses: actions/checkout@v4

      - name: Set up kubectl
        uses: azure/setup-kubectl@v3

      - name: Configure kubectl
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config

      - name: Determine image tag
        id: image
        run: |
          SHA="${{ github.event.workflow_run.head_sha }}"
          SHORT_SHA="${SHA::7}"
          echo "tag=sha-$SHORT_SHA" >> $GITHUB_OUTPUT
          echo "full_image=${{ secrets.DOCKERHUB_USERNAME }}/devops-ci-lab:sha-$SHORT_SHA" >> $GITHUB_OUTPUT

      - name: Apply production manifests
        run: kubectl apply -k k8s/production/

      - name: Update image
        run: |
          kubectl set image deployment/prod-todo-api \
            todo-api=${{ steps.image.outputs.full_image }} \
            -n ci-lab-production

      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/prod-todo-api \
            -n ci-lab-production \
            --timeout=180s

      - name: Record deployment
        if: always()
        run: |
          if kubectl rollout status deployment/prod-todo-api -n ci-lab-production --timeout=5s 2>/dev/null; then
            echo "DEPLOYMENT_STATUS=success"
          else
            echo "DEPLOYMENT_STATUS=failed"
          fi

      - name: Rollback on failure
        if: failure()
        run: |
          echo "Deployment failed — rolling back"
          kubectl rollout undo deployment/prod-todo-api -n ci-lab-production
          kubectl rollout status deployment/prod-todo-api -n ci-lab-production --timeout=60s
EOF
```

---

## Part 5 — Set up GitHub Environments

1. Go to repository Settings → Environments
2. Create environment **staging** (no protection rules — auto-deploy)
3. Create environment **production** with:
   - Required reviewers: add yourself
   - Wait timer: 0 minutes (optional, add 5+ for safety)

Now when the deploy workflow reaches `deploy-production`, it will pause and wait for your approval.

---

## Part 6 — Test the full pipeline

### Trigger a deployment

```bash
# Make a small change
echo "# pipeline test" >> README.md
git add README.md
git commit -m "Trigger deployment pipeline"
git push origin main
```

Watch on GitHub:

1. CI workflow runs (lint → test → build → push)
2. Deploy workflow triggers (staging → approve → production)

### Test rollback

Deploy a broken image:

```bash
git checkout -b feature/broken-deploy

# Break the health endpoint to make readinessProbe fail
cat >> src/app.py << 'EOF'

# This breaks health
import time
@app.before_request
def slow_down():
    if request.path == '/health':
        time.sleep(60)  # 60 second delay causes readiness probe to fail
EOF

git add src/app.py
git commit -m "Break health endpoint to test rollback"
git push -u origin feature/broken-deploy
```

Merge to main (create a PR and merge it). Watch:

1. CI builds and pushes the broken image
2. Deploy to staging — rollout gets stuck (pods never become ready)
3. Deployment fails, rollback step fires automatically

---

## Checkpoint

End state:

- [x] GitHub Actions CI pipeline: lint → test → build → push
- [x] GitHub Actions deploy pipeline: staging → smoke tests → approve → production
- [x] Rollback fires automatically if the rollout fails
- [x] Production deploys only after manual approval
- [x] Every deployment is annotated with the image SHA and CI run ID

```bash
# Verify what is running
kubectl get deployments -A | grep -E "(staging|prod)-todo-api"
kubectl rollout history deployment/staging-todo-api -n ci-lab-staging
kubectl rollout history deployment/prod-todo-api -n ci-lab-production
```
