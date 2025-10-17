# K8s & Minikube MERN Vite Js

## Backend

### Backend k8s local

```yaml
# local/prod

apiVersion: v1
kind: Namespace
metadata:
  name: mern-js-backend-local

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js-backend-local
  namespace: mern-js-backend-local
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js-backend-local
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

---
# apiVersion: v1
# kind: Secret
# metadata:
#   name: mern-js-backend-local
#   namespace: mern-js-backend-local
# type: Opaque
# stringData:
#   # MONGO_URI: "mongodb://localhost:27017/testdb"
#   # JWT_SECRET: "some-secret-key"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-backend-local
  namespace: mern-js-backend-local
  labels:
    app: mern-js-backend-local

# manifest specs (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-backend-local

  # templates
  template:
    metadata:
      labels:
        app: mern-js-backend-local

    # template specs
    spec:
      containers:
        - name: mern-js-backend-local
          image: mern-js-backend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-backend-local-cm
            - secretRef:
                name: mern-js-backend-local-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

          # resources
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"

          # probes
          readinessProbe:
            httpGet:
              path: /readyz
              port: 9000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: 9000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-backend-local
  namespace: mern-js-backend-local
  labels:
    app: mern-js-backend-local

# manifest specs
spec:
  selector:
    app: mern-js-backend-local

  # ports
  ports:
    - protocol: TCP
      port: 9000 # Service port
      targetPort: 9000 # Container port

  # change to LoadBalancer if running in cloud
  type: NodePort

---
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: deny-all
#   namespace: mern-js-backend-local
# spec:
#   podSelector: {}
#   policyTypes:
#     - Ingress
#     - Egress
```

### Backend k8s remote

```yaml
# remote/prod

apiVersion: v1
kind: Namespace
metadata:
  name: mern-js-backend

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js-backend
  namespace: mern-js-backend
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js-backend
  namespace: mern-js-backend
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      type: Container

---
# apiVersion: v1
# kind: Secret
# metadata:
#   name: mern-js-backend
#   namespace: mern-js-backend
# type: Opaque
# stringData:
#   # MONGO_URI: "mongodb://localhost:27017/testdb"
#   # JWT_SECRET: "some-secret-key"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-backend
  namespace: mern-js-backend
  labels:
    app: mern-js-backend

# manifest specs (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-backend

  # templates
  template:
    metadata:
      labels:
        app: mern-js-backend

    # template specs
    spec:
      containers:
        - name: mern-js-backend
          image: registry/mern-js-backend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-backend-cm
            - secretRef:
                name: mern-js-backend-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

          # resources
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"

          # probes
          readinessProbe:
            httpGet:
              path: /readyz
              port: 9000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: 9000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-backend
  namespace: mern-js-backend
  labels:
    app: mern-js-backend

# manifest specs
spec:
  selector:
    app: mern-js-backend

  # ports
  ports:
    - protocol: TCP
      port: 9000 # Service port
      targetPort: 9000 # Container port

  # change to LoadBalancer if running in cloud
  type: NodePort

---
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: deny-all
#   namespace: mern-js-backend
# spec:
#   podSelector: {}
#   policyTypes:
#     - Ingress
#     - Egress
```

### Backend Scripts

```json
"scripts": {
  "m:start": "minikube start",
  "m:stop": "minikube stop",

  // minikube: load local images 
  "m:load": "minikube image load ${image:-mern-js-backend}",
  // npm run m:load -- image=mern-js-backend-staging
  
  // minikube: service 
  "mloc:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-backend ae=local",
  "m:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-backend",
  // npm run <mloc|m>:svc -- ae=<local-staging|local|staging> n=<...> ns=<...> gn=<...>

  // envs: secret - cm
  "kloc:env": "bash scripts/k8s/k-env.sh -- gn=mern-js-backend ae=local",
  "k:env": "bash scripts/k8s/k-env.sh -- gn=mern-js-backend",
  // npm run <kloc|k>:env -- m=<secret(default)|cm> ae=<local-staging|local|staging> n=<...> ns=<...> gn=<...>
  
  // configs: apply - delete
  "kloc:config": "bash scripts/k8s/k-config.sh -- f=k8s/local/prod",
  "k:config": "bash scripts/k8s/k-config.sh -- f=k8s/remote/prod",
  // npm run <kloc|k>:config -- m=<apply(default)|delete> f=<...> ns=<...> gn=<...>
  
  // configs: pause - restart
  "kloc:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend ae=local",
  "k:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend"
  // npm run <kloc|k>:rollout -- m=<rollout(default)> rt=<status(default)|pause|restart> n=<...> ns=<...> gn=<...>
}
```

## Frontend

### Frontend k8s local

```yaml
# local/prod

apiVersion: v1
kind: Namespace
metadata:
  name: mern-js-frontend-local

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js-frontend-local
  namespace: mern-js-frontend-local
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js-frontend-local
  namespace: mern-js-frontend-local
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      type: Container

---
# apiVersion: v1
# kind: Secret
# metadata:
#   name: mern-js-frontend-local
#   namespace: mern-js-frontend-local
# type: Opaque
# stringData:
#   # MONGO_URI: "mongodb://localhost:27017/testdb"
#   # JWT_SECRET: "some-secret-key"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-frontend-local
  namespace: mern-js-frontend-local
  labels:
    app: mern-js-frontend-local

# manifest specs (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-frontend-local

  # templates
  template:
    metadata:
      labels:
        app: mern-js-frontend-local

    # template specs
    spec:
      containers:
        - name: mern-js-frontend-local
          image: mern-js-frontend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 4000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-frontend-local-cm
            - secretRef:
                name: mern-js-frontend-local-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

          # resources
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"

          # probes
          livenessProbe:
            httpGet:
              path: /healthz
              port: 4000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-frontend-local
  namespace: mern-js-frontend-local
  labels:
    app: mern-js-frontend-local

# manifest specs
spec:
  selector:
    app: mern-js-frontend-local

  # ports
  ports:
    - protocol: TCP
      port: 4000 # Service port
      targetPort: 4000 # Container port

  # change to LoadBalancer if running in cloud
  type: NodePort

---
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: deny-all
#   namespace: mern-js-frontend-local
# spec:
#   podSelector: {}
#   policyTypes:
#     - Ingress
#     - Egress
```

### Frontend k8s remote

```yaml
# remote/prod

apiVersion: v1
kind: Namespace
metadata:
  name: mern-js-frontend

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js-frontend
  namespace: mern-js-frontend
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js-frontend
  namespace: mern-js-frontend
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      type: Container

---
# apiVersion: v1
# kind: Secret
# metadata:
#   name: mern-js-frontend
#   namespace: mern-js-frontend
# type: Opaque
# stringData:
#   # MONGO_URI: "mongodb://localhost:27017/testdb"
#   # JWT_SECRET: "some-secret-key"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-frontend
  namespace: mern-js-frontend
  labels:
    app: mern-js-frontend

# manifest specs (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-frontend

  # templates
  template:
    metadata:
      labels:
        app: mern-js-frontend

    # template specs
    spec:
      containers:
        - name: mern-js-frontend
          image: registry/mern-js-frontend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 4000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-frontend-cm
            - secretRef:
                name: mern-js-frontend-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

          # resources
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"

          # probes
          livenessProbe:
            httpGet:
              path: /
              port: 4000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-frontend
  namespace: mern-js-frontend
  labels:
    app: mern-js-frontend

# manifest specs
spec:
  selector:
    app: mern-js-frontend

  # ports
  ports:
    - protocol: TCP
      port: 4000 # Service port
      targetPort: 4000 # Container port

  # change to LoadBalancer if running in cloud
  type: NodePort

---
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: deny-all
#   namespace: mern-js-frontend
# spec:
#   podSelector: {}
#   policyTypes:
#     - Ingress
#     - Egress

```

### Frontend Scripts

```json
"scripts": {
  "m:start": "minikube start",
  "m:stop": "minikube stop",
  "m:load": "minikube image load mern-js-frontend",

  // minikube: load local images 
  "m:load": "minikube image load ${image:-mern-js-frontend}",
  // npm run m:load -- image=mern-js-frontend-staging
  
  // minikube: service 
  "mloc:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-frontend ae=local",
  "m:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-frontend",
  // npm run <mloc|m>:svc -- ae=<local-staging|local|staging> n=<...> ns=<...> gn=<...>

  // envs: secret - cm
  "kloc:env": "bash scripts/k8s/k-env.sh -- gn=mern-js-frontend ae=local",
  "k:env": "bash scripts/k8s/k-env.sh -- gn=mern-js-frontend",
  // npm run <kloc|k>:env -- m=<secret(default)|cm> ae=<local-staging|local|staging> n=<...> ns=<...> gn=<...>
  
  // configs: apply - delete
  "kloc:config": "bash scripts/k8s/k-config.sh -- f=k8s/local/prod",
  "k:config": "bash scripts/k8s/k-config.sh -- f=k8s/remote/prod",
  // npm run <kloc|k>:config -- m=<apply(default)|delete> f=<...> ns=<...> gn=<...>
  
  // configs: pause - restart
  "kloc:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-frontend ae=local",
  "k:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-frontend"
  // npm run <kloc|k>:rollout -- m=<rollout(default)> rt=<status(default)|pause|restart> n=<...> ns=<...> gn=<...>
}
```

## App

### App k8s local

```yaml
# local/prod/init/namespace.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: mern-js-local

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js-local
  namespace: mern-js-local
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js-local
  namespace: mern-js-local
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

```yaml
# local/prod/app/api.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-api-local
  namespace: mern-js-local
  labels:
    app: mern-js-api-local

# manifest spec (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-api-local

  # templates
  template:
    metadata:
      labels:
        app: mern-js-api-local

    # template spec
    spec:
      containers:
        - name: mern-js-api-local
          image: mern-js-api:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-api-local-cm
            - secretRef:
                name: mern-js-api-local-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "9000"

          # probes
          readinessProbe:
            httpGet:
              path: /readyz
              port: 9000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: 9000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-api-local
  namespace: mern-js-local
spec:
  selector:
    app: mern-js-api-local
  ports:
    - port: 9000
      targetPort: 9000
  type: ClusterIP
```

```yaml
# local/prod/web.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-web-local
  namespace: mern-js-local
  labels:
    app: mern-js-web-local

# manifest specs (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-web-local

  # templates
  template:
    metadata:
      labels:
        app: mern-js-web-local

    # template specs
    spec:
      containers:
        - name: mern-js-web-local
          image: mern-js-web:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 4000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-web-local-cm
            - secretRef:
                name: mern-js-web-local-secret
          env:
            - name: NODE_ENV
              value: "production"
            # - name: API_BASE_URL
            #   value: "http://mern-js-backend-local.mern-js-local.svc.cluster.local:9000"

          # probes
          livenessProbe:
            httpGet:
              path: /healthz
              port: 4000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-web-local
  namespace: mern-js-local
spec:
  selector:
    app: mern-js-web-local
  ports:
    - port: 4000
      targetPort: 4000
  type: NodePort
```

### App k8s remote

```yaml
# local/prod/init/namespace.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: mern-js

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mern-js
  namespace: mern-js
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mern-js
  namespace: mern-js
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

```yaml
# local/prod/app/api.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-api
  namespace: mern-js
  labels:
    app: mern-js-api

# manifest spec (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-api

  # templates
  template:
    metadata:
      labels:
        app: mern-js-api

    # template spec
    spec:
      containers:
        - name: mern-js-api
          image: mern-js-api:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-api-cm
            - secretRef:
                name: mern-js-api-secret
          env:
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "9000"

          # probes
          readinessProbe:
            httpGet:
              path: /readyz
              port: 9000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: 9000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-api
  namespace: mern-js
spec:
  selector:
    app: mern-js-api
  ports:
    - port: 9000
      targetPort: 9000
  type: ClusterIP
```

```yaml
# local/prod/web.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-js-web
  namespace: mern-js
  labels:
    app: mern-js-web

# manifest specs (replicas)
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-js-web

  # templates
  template:
    metadata:
      labels:
        app: mern-js-web

    # template specs
    spec:
      containers:
        - name: mern-js-web
          image: mern-js-web:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 4000

          # envs
          envFrom:
            #   - configMapRef:
            #       name: mern-js-web-cm
            - secretRef:
                name: mern-js-web-secret
          env:
            - name: NODE_ENV
              value: "production"

          # probes
          livenessProbe:
            httpGet:
              path: /healthz
              port: 4000
            initialDelaySeconds: 10
            periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: mern-js-web
  namespace: mern-js
spec:
  selector:
    app: mern-js-web
  ports:
    - port: 4000
      targetPort: 4000
  type: NodePort
```

### App Scripts

```json
"scripts": {
  "m:start": "minikube start",
  "m:stop": "minikube stop",

  "m-api:load": "minikube image load ${image:-mern-js-api}",
  "m-web:load": "minikube image load ${image:-mern-js-web}",

  // local
  "mloc-api:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-api ae=local",
  "mloc-web:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-web ae=local",
  // 
  "kloc-api:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-api sn=2 ae=local",
  "kloc-web:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-web sn=2 ae=local",
  // 
  "kloc-api:env": "bash scripts/k8s/k-env.sh -- gn=mern-js-api c=./backend ae=local",
  "kloc-web:env": "bash scripts/k8s/k-env.sh -- gn=mern-js-web c=./frontend ae=local",  
  // 
  "kloc-init:config": "bash scripts/k8s/k-config.sh -- f=k8s/local/prod/init",
  "kloc:config": "npm run kloc-init:config && bash scripts/k8s/k-config.sh -- f=k8s/local/prod/app",
  // 
  "kloc-api:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-api ae=local",
  "kloc-web:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-web ae=local",
  // 
  "kloc-api:res": "bash scripts/k8s/k-resource.sh -- gn=mern-js-api ae=local",
  "kloc-web:res": "bash scripts/k8s/k-resource.sh -- gn=mern-js-web ae=local",

  // remote
  "m-api:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-api",
  "m-web:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-api",
  // 
  "k-api:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-api sn=2",
  "k-web:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-web sn=2",
  // 
  "k:env-api": "bash scripts/k8s/k-env.sh -- gn=mern-js-api c=./backend",
  "k:env-web": "bash scripts/k8s/k-env.sh -- gn=mern-js-web c=./frontend",
  // 
  "k-init:config": "bash scripts/k8s/k-config.sh -- f=k8s/remote/prod/init",
  "k:config": "npm run k-init:config && bash scripts/k8s/k-config.sh -- f=k8s/remote/prod/app",
  // 
  "k-api:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-api",
  "k-web:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-web",
  // 
  "k-api:res": "bash scripts/k8s/k-resource.sh -- gn=mern-js-api",
  "k-web:res": "bash scripts/k8s/k-resource.sh -- gn=mern-js-web",
}
```

<!-- http://<minikube-ip>:<nodePort> -->
<!-- http://mern-js-backend-local.mern-js-local.svc.cluster.local:9000 -->