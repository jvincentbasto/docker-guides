# Kubernetes Manifests

## Manifest Types

```yaml
# manifest types are not custom values | refer to docs

# Namespace
apiVersion: v1
kind: Namespace

# ResourceQuota
apiVersion: v1
kind: ResourceQuota

# LimitRange
apiVersion: v1
kind: LimitRange

# Secret
apiVersion: v1
kind: Secret

# Deployment
apiVersion: apps/v1
kind: Deployment

# Service
apiVersion: v1
kind: Service

# NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
```

### Manifest Namespace Parts

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mern-js-backend-local
```

### Manifest ResourceQuota Parts

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js-backend-quota
  namespace: mern-js-backend-local
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

### Manifest LimitRange Parts

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js-backend-limits
  namespace: mern-js-backend-local
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      type: Container
```

### Manifest Secret Parts

```yaml
# Secrets manifest

apiVersion: v1
kind: Secret
metadata:
  name: mern-js-backend-local-secret
  namespace: mern-js-backend-local
type: Opaque
# Secrets
stringData:
  MONGO_URI: "mongodb://localhost:27017/testdb"
  JWT_SECRET: "some-secret-key"
```

### Manifest Deployment Parts

#### Manifest Deployment Spec

```yaml
# Deployment manifest

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-backend
  namespace: mern-js-backend
  labels:
    app: mern-js-backend

# specifications (replica-sets)
spec:
  replicas: 2
  selector:
    # selectors should match the templates
    matchLabels:
      app: mern-js-backend

  # templates (for replicas)
  template:
    metadata:
      labels:
        app: mern-js-backend
    spec:
      containers:
        - name: mern-js-backend
          # remote image
          image: registry/mern-js-backend:latest
          # local image | you should manually load local image first
          image: mern-js-backend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000

          # envs
          envFrom:
            - configMapRef:
                name: mern-config
            - secretRef:
                name: mern-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
```

#### Manifest Deployment Resource

| Resource Type | Unit | Description | Example |
|----------------|-------|--------------|----------|
| **CPU** | `m` | Millicores — 1 CPU = 1000m | `100m` = 0.1 CPU core |
| **CPU** | (none) | Full cores | `1` = 1 CPU core |
| **Memory** | `Ki` | Kibibytes (1024 bytes) | `64Ki` |
| **Memory** | `Mi` | Mebibytes (1024 KiB) | `128Mi` |
| **Memory** | `Gi` | Gibibytes (1024 MiB) | `1Gi` |
| **Memory** | `Ti` | Tebibytes (1024 GiB) | `1Ti` |
| **Ephemeral Storage** | Same as memory units | Temporary disk usage | `500Mi` |
| **GPU / Extended Resource** | Integer | Number of devices | `1` (e.g., `nvidia.com/gpu: 1`) |

```yaml
# resources

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

#### Manifest Deployment Probes

| Environment    | initialDelaySeconds  | periodSeconds  | timeoutSeconds | failureThreshold |
|----------------|----------------------|----------------|----------------|------------------|
| **Local**      | 2–5                  | 3–5            | 1–2            | 1                |
| **Production** | 10–30                | 10–15          | 3–5            | 3                |

```yaml
# probes

readinessProbe:
  httpGet:
    path: /readyz
    port: 9000
  initialDelaySeconds: 5 # delay after container starts
  periodSeconds: 10 # interval
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3

livenessProbe:
  httpGet:
    path: /healthz
    port: 9000
  initialDelaySeconds: 10 # delay after container starts
  periodSeconds: 15 # interval
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

```bash
## K8s and Minikube Sample Process

### Init process

```bash
# verify k8s
kubectl version
minikube version

# start minikube
minikube start

# build and load local images 
minikube image load <image>:<tag>
# only if you reload your local image
kubectl rollout restart deployment <image>

# create cm and secret
kubectl create configmap <image> --from-env-file=.env
kubectl create secret generic <image> --from-env-file=.env

```

### Manifest Service Parts

```yaml
# Service manifest

apiVersion: v1
kind: Service
metadata:
  name: mern-js-backend
  namespace: mern-js-backend
  labels:
    app: mern-js-backend

# Specifications
spec:
  selector:
    app: mern-js-backend

  # ports (multiple)
  ports:
    - protocol: TCP
      port: 9000 # Service port
      targetPort: 9000 # Container port
    - protocol: TCP
      port: 9000 # Service port
      targetPort: 9000 # Container port

  # Types: Client IP (Default), NodePort, LoadBalancer (uses NodePort)
  # change to LoadBalancer if running in cloud
  type: NodePort
```

### Manifest NetworkPolicy Parts

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: mern-js-backend-local
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```
