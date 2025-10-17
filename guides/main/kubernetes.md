# Kubernetes Guides

## 🧭 Kubernetes Commands

### 🧭 Basics

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl cluster-info` | View cluster info | Shows master & service endpoints |
| `kubectl version` | Check client & server version | Use `--short` for concise output |
| `kubectl config current-context` | Show current context |  |
| `kubectl config get-contexts` | List contexts | `-o name` to show names only |
| `kubectl config use-context <context-name>` | Switch context |  |
| `kubectl get all -A` | View all resources in all namespaces | `-A` = all namespaces |

---

### 📜 Config & Resources

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl apply -f <file.yaml>` | Apply YAML config | Creates or updates |
| `kubectl apply -f <file.yaml> -n <name>` | Apply YAML config and assign a namespace | |
| `kubectl apply -f <file.yaml> --dry-run=client` | Dry run (no apply) | Useful for validation |
| `kubectl delete -f <file.yaml>` | Delete resource from YAML |  |
| `kubectl get all` | Get all resources | `-A` = all namespaces |
| `kubectl get <resource>` | Get specific type | Examples:   `ns`, `deploy`, `svc`, `pods`, `cm`, `secret` |
| `kubectl get <resource> -o yaml` | View resource definition | `-o json` = JSON format |

---

### 📁 Namespaces

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl get namespaces` | List namespaces | Alias: `ns` |
| `kubectl create namespace <name>` | Create namespace |  |
| `kubectl delete namespace <name>` | Delete namespace |  |
| `kubectl get pods -n <namespace>` | Use specific namespace | `-n` = specify namespace |

---

### 🧩 ConfigMaps & Secrets

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl create configmap <name> --from-literal=KEY=VALUE` | Create ConfigMap from literal |  |
| `kubectl create configmap <name> --from-file=<path>` | Create ConfigMap from file |  |
| `kubectl create configmap <name> --from-env-file=.env` | Create ConfigMap from `.env` file | Common for non-sensitive vars |
| `kubectl get configmaps` | List all ConfigMaps | `-o yaml` for full config |
| `kubectl describe configmap <name>` | View details |  |
| `kubectl delete configmap <name>` | Delete ConfigMap |  |
| `kubectl create secret generic <name> --from-literal=KEY=VALUE` | Create Secret from literal |  |
| `kubectl create secret generic <name> --from-env-file=.env` | Create Secret from `.env` file | Common for sensitive vars |
| `kubectl get secrets` | List all Secrets | `-o yaml` = view base64 values |
| `kubectl describe secret <name>` | View Secret details | Use `base64 --decode` to read |
| `kubectl delete secret <name>` | Delete Secret |  |

---

### ⚙️ Deployments

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl get deployments` | List deployments | `deploy` = shortcut, `-o wide` = more info |
| `kubectl create deployment <name> --image=<image>` | Create deployment | Quick test deploy |
| `kubectl describe deployment <name>` | Describe deployment |  |
| `kubectl scale deployment <name> --replicas=<num>` | Scale deployment |  |
| `kubectl edit deployment <name>` | Edit deployment | Opens default editor |
| `kubectl delete deployment <name>` | Delete deployment |  |
| `kubectl rollout status deployment/<name>` | Rollout status |  |
| `kubectl rollout pause deployment/<name>` | Rollout pause |  |
| `kubectl rollout restart deployment/<name>` | Rollout restart |  |
| `kubectl rollout undo deployment/<name>` | Rollback last update |  |
| `kubectl get rs` | List ReplicaSets | Shortcut: `rs` = ReplicaSet |

---

### 🌐 Services

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl get svc` | List services | `svc` = shortcut for Service |
| `kubectl describe svc <name>` | Describe service |  |
| `kubectl delete svc <name>` | Delete service |  |
| `kubectl expose deployment <name> --type=LoadBalancer --port=80 --target-port=8080` | Expose deployment |  |

---

### 📦 Pods

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl get pods` | List pods | `-A` = all namespaces, `-o wide` = more info |
| `kubectl get pods -w` | Watch pods | `-w` = watch live changes |
| `kubectl delete pod <pod-name>` | Delete a pod | `--force --grace-period=0` = force delete |
| `kubectl describe pod <pod-name>` | Get detailed info |  |
| `kubectl logs <pod-name>` | View logs | `-f` = follow, `--tail=100` = last 100 lines |
| `kubectl exec -it <pod-name> -- /bin/bash` | Execute into pod | Use `/bin/sh` if no bash |

---

### 🔍 Debugging & Monitoring

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl get events --sort-by=.metadata.creationTimestamp` | Check events | `--watch` = follow events |
| `kubectl describe <type> <name>` | Describe any resource | Works with all resource types |
| `kubectl top pod` / `kubectl top node` | Get resource usage | Needs metrics server |
| `kubectl port-forward <pod-name> 8080:80` | Port forward | `-n <namespace>` for specific namespace |
| `kubectl logs -l app=<label> --tail=20` | View logs from multiple pods | Combine with `-f` to follow |

---

### 🧱 Nodes

| Command | Purpose | Notes |
|----------|----------|-------|
| `kubectl get nodes` | List nodes | `-o wide` = show internal IPs |
| `kubectl describe node <node-name>` | Describe node |  |
| `kubectl top nodes` | Get node metrics |  |

---

### ⚡ Quick Tips

- `-A` → all namespaces  
- `-n <namespace>` → specify namespace  
- `-o wide` → show more details  
- `-o yaml` / `-o json` → show full definition  
- `-f` → follow logs or streams  
- `--watch` / `-w` → live updates  
- Label resources: `kubectl label pod <pod> env=prod`  
- Annotate: `kubectl annotate pod <pod> description='web server'`
