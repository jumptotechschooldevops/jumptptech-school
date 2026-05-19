# kubectl Cheatsheet

## Configuration

```bash
kubectl version --client
kubectl cluster-info
kubectl config view                         # show kubeconfig
kubectl config get-contexts                 # list all contexts
kubectl config use-context my-cluster       # switch context
kubectl config set-context --current --namespace=myns  # default namespace
kubectl config current-context             # show current context
```

## Getting resources

```bash
# Generic: kubectl get <resource> [name] [flags]
kubectl get pods
kubectl get pods -n kube-system            # specific namespace
kubectl get pods -A                        # all namespaces
kubectl get pods -o wide                   # with node and IP
kubectl get pods -w                        # watch for changes
kubectl get pods --show-labels             # show labels
kubectl get pods -l app=myapp              # filter by label
kubectl get pods -l "app in (web, api)"    # set-based selector

kubectl get all                            # pods, svc, deploy, rs
kubectl get deployments
kubectl get services
kubectl get nodes
kubectl get namespaces
kubectl get configmaps
kubectl get secrets
kubectl get ingresses
kubectl get pvc                            # PersistentVolumeClaims
kubectl get pv                             # PersistentVolumes
kubectl get events --sort-by='.lastTimestamp'  # cluster events
```

## Output formats

```bash
kubectl get pods -o yaml                   # YAML format
kubectl get pods -o json                   # JSON format
kubectl get pods -o wide                   # extra columns
kubectl get pods -o name                   # resource type/name only
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\n"}{end}'
```

## Describe (detailed view)

```bash
kubectl describe pod my-pod
kubectl describe deployment myapp
kubectl describe node my-node
kubectl describe svc my-service
kubectl describe ingress my-ingress
```

## Logs

```bash
kubectl logs my-pod                        # pod logs
kubectl logs my-pod -c container-name      # specific container
kubectl logs my-pod -f                     # follow (stream)
kubectl logs my-pod --previous             # previous (crashed) container
kubectl logs my-pod --tail=100             # last 100 lines
kubectl logs my-pod --since=1h             # last 1 hour
kubectl logs -l app=myapp                  # logs from all pods with label
kubectl logs deployment/myapp             # deployment logs
```

## Exec & port-forward

```bash
kubectl exec my-pod -- ls /app            # run command
kubectl exec -it my-pod -- bash           # interactive shell
kubectl exec -it my-pod -c container -- sh  # specific container

kubectl port-forward my-pod 8080:8000     # pod port forward
kubectl port-forward svc/my-service 8080:80  # service port forward
kubectl port-forward deployment/myapp 8080:8000
```

## Apply & delete

```bash
kubectl apply -f manifest.yml             # create or update
kubectl apply -f ./k8s/                  # apply directory
kubectl apply -k ./k8s/overlays/staging  # apply kustomization
kubectl delete -f manifest.yml           # delete from file
kubectl delete pod my-pod                # delete specific resource
kubectl delete pods -l app=myapp         # delete by label
kubectl delete namespace my-ns           # delete namespace and all resources
kubectl delete pod my-pod --force --grace-period=0  # force delete
```

## Create resources quickly

```bash
# Create without a YAML file
kubectl create namespace my-ns
kubectl create configmap my-config --from-literal=key=value
kubectl create configmap my-config --from-file=config.json
kubectl create secret generic my-secret --from-literal=password=secret123
kubectl create secret tls my-tls --cert=cert.pem --key=key.pem
kubectl create deployment myapp --image=nginx:1.25 --replicas=3
kubectl create service clusterip myapp --tcp=80:8000
```

## Deployments

```bash
kubectl scale deployment myapp --replicas=5
kubectl set image deployment/myapp app=myapp:v2      # update image
kubectl rollout status deployment/myapp              # watch rollout
kubectl rollout history deployment/myapp             # revision history
kubectl rollout undo deployment/myapp               # rollback
kubectl rollout undo deployment/myapp --to-revision=2
kubectl rollout pause deployment/myapp              # pause rollout
kubectl rollout resume deployment/myapp             # resume rollout
kubectl annotate deployment myapp kubernetes.io/change-cause="Deploy v2"
```

## Namespaces

```bash
kubectl get namespaces
kubectl create namespace staging
kubectl delete namespace staging

# Run all commands in a namespace
kubectl -n staging get pods
# Or set default namespace:
kubectl config set-context --current --namespace=staging
```

## Labels & annotations

```bash
kubectl label pod my-pod app=myapp version=v2
kubectl label pod my-pod version-                  # remove label
kubectl annotate deployment myapp team=platform

kubectl get pods -l app=myapp
kubectl get pods -l app=myapp,version=v2
kubectl get pods -l 'app in (myapp, otherapp)'
kubectl get pods -l 'version notin (v1)'
```

## Node operations

```bash
kubectl get nodes
kubectl describe node my-node
kubectl top nodes                          # CPU/memory (requires metrics-server)
kubectl top pods
kubectl top pods -A

kubectl cordon my-node                    # mark unschedulable
kubectl uncordon my-node                  # allow scheduling
kubectl drain my-node                     # evict pods + cordon
kubectl drain my-node --ignore-daemonsets --delete-emptydir-data
```

## ConfigMaps & Secrets

```bash
# ConfigMap
kubectl get configmap my-config -o yaml
kubectl create configmap my-config --from-literal=key=value --from-literal=key2=value2
kubectl edit configmap my-config          # open in editor

# Secret
kubectl get secret my-secret -o yaml
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 -d  # decode value
kubectl create secret generic my-secret --from-literal=password=secret
```

## Useful one-liners

```bash
# Get all images running in the cluster
kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u

# Get all non-running pods
kubectl get pods -A --field-selector=status.phase!=Running

# Delete all completed jobs
kubectl delete jobs --field-selector status.conditions[0].type=Complete

# Copy kubeconfig from a running pod
kubectl exec my-pod -- cat /etc/kubernetes/admin.conf > kubeconfig

# Force delete a stuck namespace
kubectl delete namespace my-ns --force --grace-period=0

# Get pods by node
kubectl get pods -o wide --all-namespaces | grep my-node

# Watch all pods across namespaces
kubectl get pods -A -w

# Run a temporary debug pod
kubectl run debug --image=busybox --restart=Never -it --rm -- sh
kubectl run debug --image=curlimages/curl --restart=Never -it --rm -- sh

# Check RBAC permissions
kubectl auth can-i create pods
kubectl auth can-i create pods --as=system:serviceaccount:default:mysa
```

## Kustomize

```bash
kubectl apply -k ./overlays/production    # apply kustomization
kubectl diff -k ./overlays/production     # see what would change
kubectl delete -k ./overlays/production   # delete resources
```

## Context aliases (add to ~/.bashrc)

```bash
alias k=kubectl
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kdp='kubectl describe pod'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias kns='kubectl config set-context --current --namespace'
```
