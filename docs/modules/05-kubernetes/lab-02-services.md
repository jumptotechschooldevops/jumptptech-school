# Lab 2 · Services & Ingress

**Duration:** ~75 minutes  
**Goal:** Expose applications using different service types, configure Ingress with path-based routing.

---

## Setup

```bash
kubectl create namespace lab-services
kubectl config set-context --current --namespace=lab-services

mkdir -p ~/k8s-lab/services
cd ~/k8s-lab/services
```

If using minikube, enable the ingress addon:

```bash
minikube addons enable ingress
```

If using kind or Docker Desktop, install the nginx ingress controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
```

---

## Part 1 — Deploy two applications

You will expose both through Ingress at different paths.

### Frontend app

```bash
cat > frontend.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: lab-services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: nginx:1.25-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: content
              mountPath: /usr/share/nginx/html
      initContainers:
        - name: setup
          image: busybox:1.36
          command:
            - sh
            - -c
            - |
              echo '<!DOCTYPE html>
              <html><head><title>Frontend</title></head>
              <body><h1>Frontend Service</h1>
              <p>Served by: '$(hostname)'</p>
              <p>Time: '$(date)'</p>
              </body></html>' > /html/index.html
          volumeMounts:
            - name: content
              mountPath: /html
      volumes:
        - name: content
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: lab-services
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl apply -f frontend.yml
```

### API app

```bash
cat > api.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: lab-services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: nginx:1.25-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: content
              mountPath: /usr/share/nginx/html
      initContainers:
        - name: setup
          image: busybox:1.36
          command:
            - sh
            - -c
            - |
              mkdir -p /html/api/v1
              echo '{"service":"api","version":"v1","pod":"'$(hostname)'"}' \
                > /html/api/v1/index.html
              echo '{"service":"api","health":"ok"}' \
                > /html/health.json
              mv /html/health.json /html/health
          volumeMounts:
            - name: content
              mountPath: /html
      volumes:
        - name: content
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: api-svc
  namespace: lab-services
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl apply -f api.yml
```

Wait for both deployments:

```bash
kubectl rollout status deployment/frontend
kubectl rollout status deployment/api

kubectl get pods
kubectl get services
```

---

## Part 2 — Service types in depth

### 2.1 ClusterIP — internal access only

```bash
# Get the ClusterIP of both services
kubectl get svc

# Access from inside the cluster
kubectl run -it --rm client \
    --image=curlimages/curl \
    --restart=Never \
    -- sh

# Inside the container:
curl http://frontend-svc/
curl http://api-svc/api/v1/
curl http://api-svc/health
exit
```

From outside the cluster, ClusterIP services are unreachable. Confirm this:

```bash
frontend_ip=$(kubectl get svc frontend-svc -o jsonpath='{.spec.clusterIP}')
echo "Frontend ClusterIP: $frontend_ip"
curl --connect-timeout 3 http://$frontend_ip/ 2>&1 || echo "Cannot reach from outside — expected"
```

### 2.2 NodePort — direct node access

```bash
cat > nodeport.yml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
  namespace: lab-services
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
EOF

kubectl apply -f nodeport.yml
kubectl get svc frontend-nodeport
```

```bash
# minikube — get the URL
minikube service frontend-nodeport -n lab-services --url

# kind — find the node IP
kubectl get nodes -o wide
# Then: curl http://<node-ip>:30080

# Docker Desktop — localhost works
curl http://localhost:30080
```

### 2.3 Service DNS

Services have DNS names. Inside the cluster:

```bash
kubectl run -it --rm dns-test \
    --image=curlimages/curl \
    --restart=Never \
    -- sh

# Inside:
# Same namespace — just service name
curl http://frontend-svc/

# Cross-namespace — full DNS name
# format: <service>.<namespace>.svc.cluster.local
curl http://frontend-svc.lab-services.svc.cluster.local/

# Inspect DNS
cat /etc/resolv.conf
nslookup frontend-svc   # if nslookup is available

exit
```

---

## Part 3 — Ingress

### 3.1 Create the Ingress resource

```bash
cat > ingress.yml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: lab-services
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /()(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: frontend-svc
                port:
                  number: 80
          - path: /api(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: api-svc
                port:
                  number: 80
EOF

kubectl apply -f ingress.yml
kubectl get ingress myapp-ingress
kubectl describe ingress myapp-ingress
```

### 3.2 Find the ingress IP

```bash
# minikube
minikube ip

# kind / Docker Desktop
kubectl get svc -n ingress-nginx ingress-nginx-controller
# Use the EXTERNAL-IP

INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Ingress IP: $INGRESS_IP"
```

### 3.3 Test routing

```bash
# Test frontend route
curl http://$INGRESS_IP/

# Test API route
curl http://$INGRESS_IP/api/v1/
curl http://$INGRESS_IP/api/health

# Test with a hostname (adding to /etc/hosts for local testing)
echo "$INGRESS_IP  myapp.local api.myapp.local" | sudo tee -a /etc/hosts
```

Update the Ingress to use hostname-based routing:

```bash
cat > ingress-host.yml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress-host
  namespace: lab-services
spec:
  ingressClassName: nginx
  rules:
    - host: myapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-svc
                port:
                  number: 80
    - host: api.myapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-svc
                port:
                  number: 80
EOF

kubectl apply -f ingress-host.yml

# Test with Host header
curl -H "Host: myapp.local" http://$INGRESS_IP/
curl -H "Host: api.myapp.local" http://$INGRESS_IP/api/v1/
```

---

## Part 4 — Service endpoints

Understanding how Services actually route traffic:

```bash
# See the endpoints (IP:port pairs of all ready pods)
kubectl get endpoints frontend-svc

# Watch endpoints change as pods are scaled
kubectl scale deployment frontend --replicas=4
kubectl get endpoints frontend-svc

kubectl scale deployment frontend --replicas=1
kubectl get endpoints frontend-svc

# If you delete and redeploy, endpoints update automatically
kubectl delete pod $(kubectl get pods -l app=frontend -o name | head -1)
kubectl get endpoints frontend-svc -w   # watch the change
```

What happens when a pod fails its readiness probe:
- It is removed from the service endpoints
- Traffic stops going to that pod
- After it recovers, it is re-added

```bash
# Observe: a pod that is not ready is not in endpoints
kubectl get pods -l app=frontend
kubectl describe svc frontend-svc | grep Endpoints
```

---

## Part 5 — Basic load balancing observation

```bash
# Make 10 requests to the service — which pod responds each time?
for i in $(seq 1 10); do
    kubectl run -it --rm request-$i \
        --image=curlimages/curl \
        --restart=Never \
        -- curl -s http://frontend-svc/ 2>/dev/null | grep "Served by"
done
```

You should see requests distributed across the pods (the hostname changes).

---

## Cleanup

```bash
# Remove /etc/hosts entries if added
sudo sed -i '/myapp.local/d' /etc/hosts

cd ~/k8s-lab/services
kubectl delete -f frontend.yml -f api.yml -f nodeport.yml \
    -f ingress.yml -f ingress-host.yml

kubectl delete namespace lab-services
kubectl config set-context --current --namespace=default
```

---

## Summary

You have configured:

- **ClusterIP** — internal service accessible by name within the cluster
- **NodePort** — external access via node IP and port
- **Ingress** — HTTP routing based on path and hostname, one load balancer for all services
- **Endpoints** — observed how Kubernetes tracks which pods are ready to receive traffic

The pattern for production: ClusterIP for all internal services, one Ingress controller with a LoadBalancer for all external HTTP traffic.
