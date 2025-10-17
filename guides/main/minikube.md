# Minikube Guides

## 🚀 Minikube Commands

Minikube is a tool that lets you **run Kubernetes locally**.  
These are the most common and practical commands you'll use when developing or testing locally.

---

### 🧭 Cluster Management

| Command | Purpose | Notes |
|----------|----------|-------|
| `minikube start` | Start a local Kubernetes cluster | Automatically downloads and runs a VM or container runtime |
| `minikube status` | Check cluster status | Shows if the cluster, kubelet, and apiserver are running |
| `minikube stop` | Stop the running cluster | Saves state for later restart |
| `minikube delete` | Delete the cluster | Removes all cluster data and configuration |
| `minikube pause` | Pause cluster | Useful to free system resources temporarily |
| `minikube unpause` | Resume cluster | Starts paused components again |
| `minikube dashboard` | Launch Kubernetes dashboard | Opens web dashboard in browser |
| `minikube addons list` | List available add-ons | Shows add-ons like metrics-server, ingress, etc. |
| `minikube addons enable <addon>` | Enable an add-on | Example: `minikube addons enable ingress` |
| `minikube addons disable <addon>` | Disable an add-on |  |

---

### 🧱 Node & Image Management

| Command | Purpose | Notes |
|----------|----------|-------|
| `minikube node list` | List cluster nodes | Typically 1 node unless configured otherwise |
| `minikube node add` | Add a new node to the cluster | Useful for testing multi-node clusters |
| `minikube node delete <node-name>` | Delete a node | Removes from the cluster |
| `minikube image build -t <image-name> .` | Build a Docker image inside Minikube | Works without pushing to external registry |
| `minikube image load <image>` | Load a local image into Minikube | Faster testing cycle |
| `minikube image ls` | List images inside Minikube |  |
| `minikube image rm <image>` | Remove image from Minikube |  |

---

### ⚙️ Configuration & Info

| Command | Purpose | Notes |
|----------|----------|-------|
| `minikube config view` | View current configuration | Shows key/value settings |
| `minikube config set <key> <value>` | Set configuration value | Example: `minikube config set memory 4096` |
| `minikube config unset <key>` | Remove a configuration value |  |
| `minikube profile list` | List profiles (clusters) | Supports multiple named clusters |
| `minikube profile <name>` | Switch to a different profile |  |
| `minikube update-check` | Check for updates | Verifies if a new version of Minikube is available |

---

### 🌐 Networking

| Command | Purpose | Notes |
|----------|----------|-------|
| `minikube ip` | Show cluster IP address | Useful for accessing NodePort or LoadBalancer services |
| `minikube service <service-name>` | Access a service in your browser | Automatically opens service endpoint |
| `minikube tunnel` | Create a network tunnel for LoadBalancer services | Required for `type=LoadBalancer` to work locally |
| `minikube ssh` | SSH into the Minikube node | For debugging inside the VM or container |
| `minikube mount <local-path>:<vm-path>` | Mount local directory into Minikube | Example: `minikube mount ./data:/data` |

---

### 🔍 Troubleshooting

| Command | Purpose | Notes |
|----------|----------|-------|
| `minikube logs` | View Minikube logs | Helps debug startup or runtime issues |
| `minikube ssh "docker ps"` | Check running containers inside Minikube |  |
| `minikube kubectl -- get pods -A` | Run `kubectl` directly via Minikube | Useful if kubectl not installed globally |
| `minikube delete --all` | Delete all Minikube clusters | Cleans up disk space completely |

---

### ⚡ Quick Tips

- Use `minikube start --driver=docker` for lightweight setup (no VM) or open docker desktop and run `minikube start`
- Set default resources:

```bash
minikube config set memory 4096
minikube config set cpus 2
```
