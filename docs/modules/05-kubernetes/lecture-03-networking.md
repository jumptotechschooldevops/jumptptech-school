# Lecture 3 · Networking & Storage

## Kubernetes networking model

Kubernetes imposes a flat networking model:

- Every pod gets its own IP address
- Every pod can reach every other pod's IP directly, without NAT
- Nodes can reach every pod, and vice versa

This is enforced by CNI (Container Network Interface) plugins: Calico, Flannel, Cilium, Weave. The plugin implements the actual networking — the cluster spec just defines the rules.

Pod IPs are ephemeral. Pods come and go, get new IPs, get rescheduled to different nodes. You should never connect to a pod IP directly. You use Services.

---

## Services

A Service is a stable network endpoint for a set of pods. It has a stable IP (ClusterIP) and DNS name that do not change even as pods are replaced.

Services find their pods using label selectors. Any pod with matching labels is automatically added to the service's endpoint list.

### ClusterIP (default)

Accessible only within the cluster. The most common type.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  type: ClusterIP
  selector:
    app: myapi
  ports:
    - port: 80           # port the service listens on
      targetPort: 8000   # port the pods listen on
```

Inside the cluster, other pods reach this service at `api-service:80` (within the same namespace) or `api-service.mynamespace.svc.cluster.local:80` (full DNS name).

### NodePort

Exposes the service on a static port on every node's IP address. Traffic to `<any-node-IP>:<nodePort>` is forwarded to the service.

```yaml
spec:
  type: NodePort
  selector:
    app: myapi
  ports:
    - port: 80
      targetPort: 8000
      nodePort: 30080     # 30000-32767 range
```

Not suitable for production — it exposes services on every node's IP, requires knowing a node's IP, and uses non-standard ports. Use it for quick testing in local clusters.

### LoadBalancer

Creates an external load balancer in the cloud provider. The cloud provider provisions a load balancer and assigns a public IP.

```yaml
spec:
  type: LoadBalancer
  selector:
    app: myapi
  ports:
    - port: 80
      targetPort: 8000
```

Cloud providers charge for each load balancer. If you have 20 services, you pay for 20 load balancers. This is where Ingress comes in.

### Headless Service

A Service with `clusterIP: None` does not load balance. DNS queries return the IPs of all matching pods. Used with StatefulSets for peer-to-peer discovery.

```yaml
spec:
  clusterIP: None
  selector:
    app: postgres
```

DNS for `postgres-headless.default.svc.cluster.local` returns all pod IPs. DNS for `postgres-0.postgres-headless.default.svc.cluster.local` returns pod 0's IP specifically.

---

## Ingress

An Ingress routes external HTTP/HTTPS traffic to Services based on hostnames and paths. One LoadBalancer (the Ingress controller) handles all your services.

```
Internet → LoadBalancer IP → Ingress Controller → Services
```

You need an Ingress controller first (nginx-ingress, Traefik, Contour):

```bash
# Install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Or with Helm
helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace
```

Then define an Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - myapp.example.com
        - api.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
    - host: api.example.com
      http:
        paths:
          - path: /v1
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
          - path: /v2
            pathType: Prefix
            backend:
              service:
                name: api-v2-service
                port:
                  number: 80
```

### DNS for Ingress

After creating an Ingress, get the external IP of the Ingress controller:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
# Shows: EXTERNAL-IP = 1.2.3.4
```

Create DNS A records pointing `myapp.example.com` and `api.example.com` to that IP.

---

## Network Policies

By default, all pods can reach all other pods. Network Policies restrict which pods can communicate:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nginx    # only nginx pods can reach the api
      ports:
        - protocol: TCP
          port: 8000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
    - to:
        - podSelector:
            matchLabels:
              app: redis
      ports:
        - protocol: TCP
          port: 6379
```

Network Policies require a CNI plugin that supports them (Calico, Cilium, Weave). Flannel does not support Network Policies.

---

## Persistent storage

### The problem

Pods are ephemeral. When a pod is deleted, its storage is deleted too. For stateful applications (databases, file uploads), you need storage that survives pod restarts and reschedules.

### PersistentVolume (PV)

A PersistentVolume is a piece of storage in the cluster — an NFS share, an EBS volume, a GCP disk. It is a cluster-level resource, not namespaced.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce    # mounted as read-write by one node
  persistentVolumeReclaimPolicy: Retain
  storageClassName: fast-ssd
  awsElasticBlockStore:
    volumeID: vol-0123456789abcdef
    fsType: ext4
```

Access modes:
- `ReadWriteOnce` (RWO) — one node at a time (most block storage)
- `ReadOnlyMany` (ROX) — multiple nodes, read only
- `ReadWriteMany` (RWX) — multiple nodes, read-write (NFS, EFS)

### PersistentVolumeClaim (PVC)

A PVC is a request for storage by a pod. Kubernetes matches PVCs to PVs based on requested size and access mode.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

Use the PVC in a pod:

```yaml
spec:
  containers:
    - name: postgres
      image: postgres:16
      volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: postgres-pvc
```

### StorageClass

StorageClasses enable dynamic provisioning — PVs are created automatically when a PVC is created, without pre-provisioning.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
reclaimPolicy: Delete    # or Retain
volumeBindingMode: WaitForFirstConsumer
```

On AWS, GCP, and Azure, default StorageClasses are pre-installed that provision EBS, GCE PD, and Azure Disk respectively.

---

## Summary

- Every pod has its own IP. Services provide stable network endpoints in front of pods.
- ClusterIP for internal traffic. LoadBalancer for external. Ingress for HTTP routing.
- Ingress lets one LoadBalancer route traffic to many services based on hostname and path.
- Network Policies control which pods can communicate.
- PVCs request storage. StorageClasses provision PVs automatically.
- StatefulSets use `volumeClaimTemplates` to give each pod its own PVC.
