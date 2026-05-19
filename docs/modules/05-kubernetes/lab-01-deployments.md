# Lab 1 · Deployments & Rolling Updates

**Duration:** ~75 minutes  
**Goal:** Deploy an application, perform rolling updates, observe the reconciliation loop, and practice rollback.

**Prerequisites:** A working Kubernetes cluster and `kubectl` configured.

---

## Setup

```bash
# Verify your cluster is ready
kubectl cluster-info
kubectl get nodes

# Create a dedicated namespace for this lab
kubectl create namespace lab-deployments
kubectl config set-context --current --namespace=lab-deployments
```

---

## Part 1 — Deploy an application

### 1.1 Write the manifests

```bash
mkdir -p ~/k8s-lab/deployments
cd ~/k8s-lab/deployments
```

```bash
cat > deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: lab-deployments
  labels:
    app: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
        - name: webapp
          image: nginx:1.25-alpine
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "32Mi"
              cpu: "50m"
            limits:
              memory: "64Mi"
              cpu: "100m"
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
EOF
```

```bash
cat > service.yml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: lab-deployments
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
    - port: 80
      targetPort: 80
EOF
```

### 1.2 Apply and observe

```bash
kubectl apply -f deployment.yml
kubectl apply -f service.yml

# Watch pods come up
kubectl get pods -w
```

While watching, you will see pods move through: `Pending → ContainerCreating → Running`

```bash
# Detailed view
kubectl get pods -o wide   # shows node, IP

# Describe the deployment
kubectl describe deployment webapp

# Describe a specific pod
kubectl describe pod $(kubectl get pods -l app=webapp -o name | head -1)
```

### 1.3 Verify the application

```bash
# From inside the cluster — exec into a pod and curl the service
kubectl run -it --rm test-curl \
    --image=curlimages/curl \
    --restart=Never \
    -- curl -s http://webapp-service/
```

You should see the default nginx welcome page HTML.

---

## Part 2 — The reconciliation loop

Watch the reconciliation loop enforce desired state.

### 2.1 Kill a pod manually

```bash
# Note the current pods
kubectl get pods

# Kill one pod
kubectl delete pod $(kubectl get pods -l app=webapp -o name | head -1)

# Immediately watch what happens
kubectl get pods -w
```

The deployment's controller notices the replica count dropped to 2, immediately creates a new pod, and the count returns to 3. This takes a few seconds.

### 2.2 Scale up and down

```bash
# Scale to 5 replicas
kubectl scale deployment webapp --replicas=5
kubectl get pods -w   # watch new pods being created

# Scale back to 3
kubectl scale deployment webapp --replicas=3
kubectl get pods -w   # watch pods being terminated
```

### 2.3 Try to delete a replicaset

```bash
# Find the replicaset
kubectl get replicasets

# Try deleting it
kubectl delete replicaset $(kubectl get rs -l app=webapp -o name)

# Watch what happens
kubectl get replicasets -w
```

The Deployment controller immediately recreates the ReplicaSet. The deployment reconciles.

---

## Part 3 — ConfigMaps in action

### 3.1 Create a custom nginx config

```bash
cat > configmap.yml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: lab-deployments
data:
  nginx.conf: |
    events { worker_connections 1024; }
    http {
      server {
        listen 80;
        location / {
          return 200 '{"service": "webapp", "version": "1.0", "status": "ok"}\n';
          add_header Content-Type application/json;
        }
        location /health {
          return 200 '{"status": "healthy"}\n';
          add_header Content-Type application/json;
        }
      }
    }
  APP_VERSION: "1.0"
  LOG_LEVEL: "info"
EOF

kubectl apply -f configmap.yml
```

### 3.2 Update deployment to use ConfigMap

```bash
cat > deployment-v2.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: lab-deployments
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: webapp
        version: v2
    spec:
      containers:
        - name: webapp
          image: nginx:1.25-alpine
          ports:
            - containerPort: 80
          env:
            - name: APP_VERSION
              valueFrom:
                configMapKeyRef:
                  name: nginx-config
                  key: APP_VERSION
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: nginx-config
                  key: LOG_LEVEL
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
          resources:
            requests:
              memory: "32Mi"
              cpu: "50m"
            limits:
              memory: "64Mi"
              cpu: "100m"
          readinessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
EOF

kubectl apply -f deployment-v2.yml
kubectl rollout status deployment/webapp
```

Test the new configuration:

```bash
kubectl run -it --rm test-curl \
    --image=curlimages/curl \
    --restart=Never \
    -- curl -s http://webapp-service/
# Should return JSON now, not the default nginx page

kubectl run -it --rm test-curl \
    --image=curlimages/curl \
    --restart=Never \
    -- curl -s http://webapp-service/health
```

---

## Part 4 — Rolling updates

### 4.1 Watch a rolling update in real time

```bash
# Open a watch in one terminal
kubectl get pods -w &
watch_pid=$!

# In another terminal (or after), trigger an update
kubectl set image deployment/webapp webapp=nginx:1.26-alpine

# Watch the output — you should see:
# Old pods terminating, new pods starting, overlap during transition
# (maxUnavailable=0 means no downtime)
```

The update rolls out according to the strategy: one new pod starts (`maxSurge: 1`), and only after it is ready does an old pod terminate (`maxUnavailable: 0`). Service endpoints always have at least 3 healthy pods.

```bash
kill $watch_pid 2>/dev/null || true
```

### 4.2 Check rollout history

```bash
kubectl rollout history deployment/webapp
```

You will see revisions listed. To add descriptions:

```bash
kubectl annotate deployment/webapp kubernetes.io/change-cause="Update to nginx 1.26"
kubectl rollout history deployment/webapp
```

### 4.3 Trigger a bad update

```bash
# Try to deploy a non-existent image version
kubectl set image deployment/webapp webapp=nginx:99.99.99-nonexistent

# Watch what happens
kubectl rollout status deployment/webapp
# After ~30s you will see it is stuck

kubectl get pods   # some old pods running, new ones stuck in ImagePullBackOff
```

### 4.4 Roll back

```bash
# Immediately roll back to the previous version
kubectl rollout undo deployment/webapp

# Watch the recovery
kubectl rollout status deployment/webapp
kubectl get pods

# Verify rollback succeeded
kubectl run -it --rm test-curl \
    --image=curlimages/curl \
    --restart=Never \
    -- curl -s http://webapp-service/health
```

Roll back to a specific revision:

```bash
kubectl rollout history deployment/webapp
kubectl rollout undo deployment/webapp --to-revision=1
```

---

## Part 5 — Requests, limits, and QoS

### 5.1 Check QoS class

```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

The current pods should show `Burstable` (requests < limits).

### 5.2 Create a Guaranteed QoS pod

```bash
cat > guaranteed-pod.yml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: guaranteed-app
  namespace: lab-deployments
spec:
  containers:
    - name: app
      image: nginx:1.25-alpine
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "64Mi"
          cpu: "100m"
EOF

kubectl apply -f guaranteed-pod.yml
kubectl get pod guaranteed-app -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

---

## Cleanup

```bash
cd ~/k8s-lab/deployments
kubectl delete -f deployment.yml -f service.yml -f configmap.yml
kubectl delete pod guaranteed-app --ignore-not-found
kubectl delete namespace lab-deployments
kubectl config set-context --current --namespace=default
```

---

## Review questions

1. What happened when you deleted a pod from the deployment? Why?
2. Why did we set `maxUnavailable: 0` in the rolling update strategy?
3. What is the difference between a liveness probe and a readiness probe? When does each trigger?
4. Why did the deployment get "stuck" when we tried to deploy a non-existent image?
5. What QoS class does a pod get if it has no resource requests or limits set?
