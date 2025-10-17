# K8s and MiniKube Guides

## K8s and Minikube Sample CLI Commands

### Init commands

```bash
# verify k8s
kubectl version
minikube version

# start minikube
minikube start

# set configMaps and Secrets
kubectl create cm cm -n <namespace> --from-env-file=sample.txt --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic secret -n <namespace> --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -

# create namespace: 
# - manually, 
kubectl create namespace <name>
# or manifest "kind: Namespace" 

# build and load local images 
minikube image load <image>:<tag>
# only if you reload your local image
kubectl rollout restart deployment <image>

# create cm and secret
kubectl create configmap <image> --from-env-file=.env
kubectl create secret generic <image> --from-env-file=.env

```

### Get commands

```bash
# verify cm and secrets
kubectl get configmaps
kubectl get secrets

# describe cm and secretes
kubectl describe configmap <name>
kubectl describe secret <name>

# apply manifests
kubectl apply -f manifest.yaml
kubectl apply -f k8s/

# get <resource> `-A, deploy, svc, pods, cm, secret, ns`
kubectl get all -A
kubectl describe pod -n <namespace>
kubectl logs <pod-name> --tail=50
```

### Get Ips, Ports commands

```bash
# get ip and port by svc
kubectl get svc -n <namespace>

# minikube ip
minikube ip

# minikube <resource> <resource-name> -n <namespace>
minikube <resource> <name> -n <namespace>
minikube service <name> -n <namespace>
```

### Rename commands

```bash
# kubectl label <resource> `-A, deploy, svc, pods, cm, secret`
kubectl label <resource> <name> <key>=<value>--overwrite

# Immutable names: for almost all Kubernetes resources
# Only rename: "labels, annotations, and selectors"
```

### Apply Changes commands

```bash
kubectl apply -f k8s/
kubectl rollout restart deployment <name> -n <namespace>
```

### Stop commands

```bash
# pause or stop

# by k8s deployment
kubectl rollout pause deployment <name>
kubectl scale deployment <name> --replicas=0

# by minikube
minikube stop
```

### Delete commands

```bash
# delete <resource> `-A, deploy, svc, pods, cm, secret, ns`
kubectl delete <resource> <name>

# by file
kubectl delete -f k8s/prod/

# by ns
kubectl delete all --all -n <namespace>
# Delete everything in the default namespace
kubectl delete all --all

# by entire cluster
minikube delete

```

## Bash scripts

### K8s scripts

```sh
# k-config.sh

#!/usr/bin/env bash
# ↑ This shebang is the most portable — works on Linux, macOS, Git Bash, and WSL

set -e
# -e: exit on error
# -u: treat unset variables as errors
# -o pipefail: fail if any part of a pipe fails

# Default values
MODE="apply"
FILE="k8s/"
NAMESPACE=""
# append
APPEND_ENV=""
APPEND_NAME_ENV=""
APPEND_NAMESPACE_ENV=""
# global
GLOBAL_NAME=""
CONTEXT="."  # optional root path or relative directory

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -- ) continue ;;
    # 
    m=*) MODE="${arg#m=}" ;;
    f=*) FILE="${arg#f=}" ;;
    ns=*) NAMESPACE="${arg#ns=}" ;;
    # append
    ae=*) APPEND_ENV="${arg#ae=}" ;;
    ane=*) APPEND_NAME_ENV="${arg#ane=}" ;;
    anse=*) APPEND_NAMESPACE_ENV="${arg#anse=}" ;;
    # global
    gn=*) GLOBAL_NAME="${arg#gn=}" ;;
    c=*) CONTEXT="${arg#c=}" ;;
    # 
    * ) echo "Unknown argument: $arg" ;;
  esac
done

# Params
cat <<EOF
Params:
  MODE - m = "$MODE"
  FILE - f = "$FILE"
  NAMESPACE - ns = "$NAMESPACE"

  APPEND_ENV - ae = "$APPEND_ENV"
  APPEND_NAME_ENV - ane = "$APPEND_NAME_ENV"
  APPEND_NAMESPACE_ENV - anse = "$APPEND_NAMESPACE_ENV"
  
  GLOBAL_NAME - gn = "$GLOBAL_NAME"
  CONTEXT - c = "$CONTEXT"

Script:
  bash script.sh -- args 
EOF


# Normalize Windows paths (Git Bash/WSL compatibility)
CONTEXT=$(echo "$CONTEXT" | sed 's#\\#/#g')
FILE=$(echo "$FILE" | sed 's#\\#/#g')

# Validate file existence
if [ ! -f "$CONTEXT/$FILE" ] && [ ! -d "$CONTEXT/$FILE" ]; then
  echo -e "\nError - Directory / File not found: $CONTEXT/$FILE \n"
  exit 1
fi

# mutate append
if [ -n "$APPEND_ENV" ]; then
  APPEND_ENV="-$APPEND_ENV"
else 
  APPEND_ENV=""
fi
if [ -n "$APPEND_NAME_ENV" ]; then
  APPEND_NAME_ENV="-$APPEND_NAME_ENV"
else 
  APPEND_NAME_ENV="$APPEND_ENV"
fi
if [ -n "$APPEND_NAMESPACE_ENV" ]; then
  APPEND_NAMESPACE_ENV="-$APPEND_NAMESPACE_ENV"
else 
  APPEND_NAMESPACE_ENV="$APPEND_ENV"
fi

# Run apply
if [ "$MODE" = "apply" ]; then
  echo -e "\nK8s Apply \n"

  # 
  if [ -n "$NAMESPACE" ]; then
    kubectl apply -f "$CONTEXT/$FILE" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
  else
    kubectl apply -f "$CONTEXT/$FILE"
  fi

  echo -e "\nSuccess - apply \n"
fi

# Run delete
if [ "$MODE" = "delete" ]; then
  echo -e "\nK8s Delete \n"

  # 
  if [ -n "$NAMESPACE" ]; then
    kubectl delete -f "$CONTEXT/$FILE" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
  else
    kubectl delete -f "$CONTEXT/$FILE"
  fi

  echo -e "\nSuccess - delete \n"
fi
```

```sh
# k-deploy.sh

#!/usr/bin/env bash
# ↑ This shebang is the most portable — works on Linux, macOS, Git Bash, and WSL

set -e
# -e: exit on error
# -u: treat unset variables as errors
# -o pipefail: fail if any part of a pipe fails

# Default values
MODE="rollout"
ROLLOUT_TYPE="status"
SCALE_NUM="1"
NAME=""
NAMESPACE=""
# append
APPEND_ENV=""
APPEND_NAME_ENV=""
APPEND_NAMESPACE_ENV=""
# global
GLOBAL_NAME=""
CONTEXT="."  # optional root path or relative directory

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -- ) continue ;;
    # 
    m=*) MODE="${arg#m=}" ;;
    rt=*) ROLLOUT_TYPE="${arg#rt=}" ;;
    sn=*) SCALE_NUM="${arg#sn=}" ;;
    n=*) NAME="${arg#n=}" ;;
    ns=*) NAMESPACE="${arg#ns=}" ;;
    # append
    ae=*) APPEND_ENV="${arg#ae=}" ;;
    ane=*) APPEND_NAME_ENV="${arg#ane=}" ;;
    anse=*) APPEND_NAMESPACE_ENV="${arg#anse=}" ;;
    # global
    gn=*) GLOBAL_NAME="${arg#gn=}" ;;
    c=*) CONTEXT="${arg#c=}" ;;
    # 
    * ) echo "Unknown argument: $arg" ;;
  esac
done

# Params
cat <<EOF
Params:
  MODE - m = "$MODE"
  ROLLOUT_TYPE - rt = "$ROLLOUT_TYPE"
  SCALE_NUM - sn = "$SCALE_NUM"
  NAME - n = "$NAME"
  NAMESPACE - ns = "$NAMESPACE"
  
  APPEND_ENV - ae = "$APPEND_ENV"
  APPEND_NAME_ENV - ane = "$APPEND_NAME_ENV"
  APPEND_NAMESPACE_ENV - anse = "$APPEND_NAMESPACE_ENV"

  GLOBAL_NAME - gn = "$GLOBAL_NAME"
  CONTEXT - c = "$CONTEXT"

Script:
  bash script.sh -- args
EOF

# validate name
if [ -z "$NAME" ] && [ -z "$GLOBAL_NAME" ]; then
  echo -e "\nError: name is required | arg n=name \n"
  exit 1
fi

# mutate append
if [ -n "$APPEND_ENV" ]; then
  APPEND_ENV="-$APPEND_ENV"
else 
  APPEND_ENV=""
fi
if [ -n "$APPEND_NAME_ENV" ]; then
  APPEND_NAME_ENV="-$APPEND_NAME_ENV"
else 
  APPEND_NAME_ENV="$APPEND_ENV"
fi
if [ -n "$APPEND_NAMESPACE_ENV" ]; then
  APPEND_NAMESPACE_ENV="-$APPEND_NAMESPACE_ENV"
else 
  APPEND_NAMESPACE_ENV="$APPEND_ENV"
fi

# Run rollout
if [ "$MODE" = "rollout" ]; then
  echo -e "\nK8s rollout \n"
  
  # 
  if [ -n "$NAME" ]; then
    
    # 
    if [ -n "$NAMESPACE" ]; then
      kubectl rollout "$ROLLOUT_TYPE" deployment "$NAME$APPEND_NAME_ENV" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
    else 
      kubectl rollout "$ROLLOUT_TYPE" deployment "$NAME$APPEND_NAME_ENV"
    fi      
  elif [ -n "$GLOBAL_NAME" ]; then
    kubectl rollout "$ROLLOUT_TYPE" deployment "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" 
  else
    echo "Error: Invalid rollout argument \n"
    exit 1
  fi

  echo -e "\nSuccess - rollout \n"
fi

# Run scale
if [ "$MODE" = "scale" ]; then
  echo -e "\nK8s scale \n"
  
  # 
  if [ -n "$NAME" ] && [ -n "$NAMESPACE" ]; then
    if [ -n "$NAMESPACE" ]; then
      kubectl scale deployment "$NAME$APPEND_NAME_ENV" -n "$NAMESPACE$APPEND_NAMESPACE_ENV" --replicas="$SCALE_NUM"
    else 
      kubectl scale deployment "$NAME$APPEND_NAME_ENV" --replicas="$SCALE_NUM"
    fi
  elif [ -z "$NAME" ] && [ -n "$GLOBAL_NAME" ]; then
    kubectl scale deployment "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" --replicas="$SCALE_NUM"
  else
    echo "Error: Invalid scale argument \n"
    exit 1
  fi

  echo -e "\nSuccess - scale \n"
fi
```

```sh
# k-env.sh

#!/usr/bin/env bash
# ↑ This shebang is the most portable — works on Linux, macOS, Git Bash, and WSL

set -e
# -e: exit on error
# -u: treat unset variables as errors
# -o pipefail: fail if any part of a pipe fails

# Default values
MODE="secret"
SECRET_TYPE="generic"
NAME=""
NAMESPACE=""
FILE=".env"
# append
APPEND_TYPE="secret"
APPEND_ENV=""
APPEND_NAME_ENV=""
APPEND_NAMESPACE_ENV=""
# global
GLOBAL_NAME=""
CONTEXT="."  # optional root path or relative directory

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -- ) continue ;;
    # 
    m=*) MODE="${arg#m=}" ;;
    st=*) SECRET_TYPE="${arg#st=}" ;;
    n=*) NAME="${arg#n=}" ;;
    ns=*) NAMESPACE="${arg#ns=}" ;;
    f=*) FILE="${arg#f=}" ;;    
    # append
    at=*) APPEND_TYPE="${arg#at=}" ;;
    ae=*) APPEND_ENV="${arg#ae=}" ;;
    ane=*) APPEND_NAME_ENV="${arg#ane=}" ;;
    anse=*) APPEND_NAMESPACE_ENV="${arg#anse=}" ;;
    # global
    gn=*) GLOBAL_NAME="${arg#gn=}" ;;
    c=*) CONTEXT="${arg#c=}" ;;
    # 
    * ) echo "Unknown argument: $arg" ;;
  esac
done

# Params
cat <<EOF
Params:
  MODE - m = "$MODE"
  SECRET_TYPE - st = "$SECRET_TYPE"
  NAME - n = "$NAME"
  NAMESPACE - ns = "$NAMESPACE"
  FILE - f = "$FILE"
  
  APPEND_TYPE - at = "$APPEND_TYPE"
  APPEND_ENV - ae = "$APPEND_ENV"
  APPEND_NAME_ENV - ane = "$APPEND_NAME_ENV"
  APPEND_NAMESPACE_ENV - anse = "$APPEND_NAMESPACE_ENV"

  GLOBAL_NAME - gn = "$GLOBAL_NAME"
  CONTEXT - c = "$CONTEXT"

Script:
  bash script.sh -- args 
EOF


# Normalize Windows paths (Git Bash/WSL compatibility)
CONTEXT=$(echo "$CONTEXT" | sed 's#\\#/#g')
FILE=$(echo "$FILE" | sed 's#\\#/#g')

# Validate file existence
if [ ! -f "$CONTEXT/$FILE" ] && [ ! -d "$CONTEXT/$FILE" ]; then
  echo -e "\nError - Directory / File not found: $CONTEXT/$FILE \n"
  exit 1
fi

# mutate append
if [ -n "$APPEND_ENV" ]; then
  APPEND_ENV="-$APPEND_ENV"
else 
  APPEND_ENV=""
fi
if [ -n "$APPEND_NAME_ENV" ]; then
  APPEND_NAME_ENV="-$APPEND_NAME_ENV"
else 
  APPEND_NAME_ENV="$APPEND_ENV"
fi
if [ -n "$APPEND_NAMESPACE_ENV" ]; then
  APPEND_NAMESPACE_ENV="-$APPEND_NAMESPACE_ENV"
else 
  APPEND_NAMESPACE_ENV="$APPEND_ENV"
fi


# Run secret
if [ "$MODE" = "secret" ]; then
  echo -e "\nK8s secret \n"
  
  # 
  if [ -n "$NAME" ]; then
    if [ -n "$NAMESPACE" ]; then
      kubectl create secret $SECRET_TYPE "$NAME$APPEND_NAME_ENV-$APPEND_TYPE" \
        -n "$NAMESPACE$APPEND_NAMESPACE_ENV" \
        --from-env-file="$CONTEXT/$FILE" \
        --dry-run=client -o yaml | kubectl apply -f -
    else 
      kubectl create secret $SECRET_TYPE "$NAME$APPEND_NAME_ENV-$APPEND_TYPE" \
        --from-env-file="$CONTEXT/$FILE" \
        --dry-run=client -o yaml | kubectl apply -f -
    fi
  elif [ -n "$GLOBAL_NAME" ]; then
    kubectl create secret $SECRET_TYPE "$GLOBAL_NAME$APPEND_NAME_ENV-$APPEND_TYPE" \
      -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" \
      --from-env-file="$CONTEXT/$FILE" \
      --dry-run=client -o yaml | kubectl apply -f -
  else
    echo -e "\nError: Invalid secret argument \n"
    exit 1
  fi

  echo -e "\nSuccess - secret \n"
fi

# Run configMap
if [ "$MODE" = "cm" ] || [ "$MODE" = "configMap" ]; then
  echo -e "\nK8s configMap \n"

  # 
  if [ -n "$NAME" ]; then
    if [ -n "$NAMESPACE" ]; then
      kubectl create cm "$NAME$APPEND_NAME_ENV-$APPEND_TYPE" \
        -n "$NAMESPACE$APPEND_NAMESPACE_ENV" \
        --from-env-file="$CONTEXT/$FILE" \
        --dry-run=client -o yaml | kubectl apply -f -
    else 
      kubectl create cm "$NAME$APPEND_NAME_ENV-$APPEND_TYPE" \
        --from-env-file="$CONTEXT/$FILE" \
        --dry-run=client -o yaml | kubectl apply -f -
    fi
  elif [ -n "$GLOBAL_NAME" ]; then
    kubectl create cm "$GLOBAL_NAME$APPEND_NAME_ENV-$APPEND_TYPE" \
      -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" \
      --from-env-file="$CONTEXT/$FILE" \
      --dry-run=client -o yaml | kubectl apply -f -
  else
    echo -e "\nError: Invalid cm argument \n"
    exit 1
  fi

  echo -e "\nSuccess - cm \n"
fi
```

```sh
# k-resource.sh

#!/usr/bin/env bash
# ↑ This shebang is the most portable — works on Linux, macOS, Git Bash, and WSL

set -e
# -e: exit on error
# -u: treat unset variables as errors
# -o pipefail: fail if any part of a pipe fails

# Default values
MODE="get"
RESOURCE_TYPE="all"
NAME=""
NAMESPACE=""
ALL_NAMESPACE=""
RESOURCE_WATCH=""
RESOURCE_MULTIPLE=""
# append
APPEND_ENV=""
APPEND_NAME_ENV=""
APPEND_NAMESPACE_ENV=""
# global
GLOBAL_NAME=""
CONTEXT="."  # optional root path or relative directory

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -- ) continue ;;
    # 
    m=*) MODE="${arg#m=}" ;;
    rt=*) RESOURCE_TYPE="${arg#rt=}" ;;
    n=*) NAME="${arg#n=}" ;;
    ns=*) NAMESPACE="${arg#ns=}" ;;
    ans=*) ALL_NAMESPACE="${arg#ans=}" ;;
    rw=*) RESOURCE_WATCH="${arg#rw=}" ;;
    rm=*) RESOURCE_MULTIPLE="${arg#rm=}" ;;
    # append
    ae=*) APPEND_ENV="${arg#ae=}" ;;
    ane=*) APPEND_NAME_ENV="${arg#ane=}" ;;
    anse=*) APPEND_NAMESPACE_ENV="${arg#anse=}" ;;
    # global
    gn=*) GLOBAL_NAME="${arg#gn=}" ;;
    c=*) CONTEXT="${arg#c=}" ;;
    # 
    * ) echo "Unknown argument: $arg" ;;
  esac
done

# Params
cat <<EOF
Params:
  MODE - m = "$MODE"
  RESOURCE_TYPE - rt = "$RESOURCE_TYPE"
  NAME - n = "$NAME"
  NAMESPACE - ns = "$NAMESPACE"
  ALL_NAMESPACE - ans = "$ALL_NAMESPACE"
  RESOURCE_WATCH - rw = "$RESOURCE_WATCH"
  RESOURCE_MULTIPLE - rm = "$RESOURCE_MULTIPLE"
  
  APPEND_ENV - ae = "$APPEND_ENV"
  APPEND_NAME_ENV - ane = "$APPEND_NAME_ENV"
  APPEND_NAMESPACE_ENV - anse = "$APPEND_NAMESPACE_ENV"

  GLOBAL_NAME - gn = "$GLOBAL_NAME"
  CONTEXT - c = "$CONTEXT"

Script:
  bash script.sh -- args
EOF

# validate name
# if [ -z "$NAME" ] && [ -z "$GLOBAL_NAME" ]; then
#   echo -e "\nError: name is required | arg n=name \n"
#   exit 1
# fi

# mutate options
to_flag() {
  case "${1,,}" in
    true|t|yes|y) echo "$2" ;;
    *) echo "" ;;
  esac
}

ALL_NAMESPACE=$(to_flag "$ALL_NAMESPACE" "-A")
RESOURCE_WATCH=$(to_flag "$RESOURCE_WATCH" "-w")
RESOURCE_MULTIPLE=$(to_flag "$RESOURCE_MULTIPLE" "true")


# mutate append
if [ -n "$APPEND_ENV" ]; then
  APPEND_ENV="-$APPEND_ENV"
else 
  APPEND_ENV=""
fi
if [ -n "$APPEND_NAME_ENV" ]; then
  APPEND_NAME_ENV="-$APPEND_NAME_ENV"
else 
  APPEND_NAME_ENV="$APPEND_ENV"
fi
if [ -n "$APPEND_NAMESPACE_ENV" ]; then
  APPEND_NAMESPACE_ENV="-$APPEND_NAMESPACE_ENV"
else 
  APPEND_NAMESPACE_ENV="$APPEND_ENV"
fi

# Run get
if [ "$MODE" = "get" ]; then
  echo -e "\nK8s get \n"
  
  # 
  if [ -n "$NAME" ]; then

    # 
    if [ -n "$NAMESPACE" ]; then
      kubectl get "$RESOURCE_TYPE" "$NAME$APPEND_NAME_ENV" -n "$NAMESPACE$APPEND_NAMESPACE_ENV" "$RESOURCE_WATCH"
    elif [ -n "$GLOBAL_NAME" ]; then
      kubectl get "$RESOURCE_TYPE" "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" "$RESOURCE_WATCH"
    else
      kubectl get "$RESOURCE_TYPE" "$NAME$APPEND_NAME_ENV" "$RESOURCE_WATCH"
    fi
  elif [ -n "$NAMESPACE" ]; then
    kubectl get "$RESOURCE_TYPE" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
  elif [ -n "$GLOBAL_NAME" ]; then
    
    # 
    if [ -n "$RESOURCE_WATCH" ]; then
      kubectl get "$RESOURCE_TYPE" "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" "$RESOURCE_WATCH"
    else
      kubectl get "$RESOURCE_TYPE" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
    fi
  elif [ -n "$ALL_NAMESPACE" ]; then
    kubectl get "$RESOURCE_TYPE" "$ALL_NAMESPACE"
  elif [ -z "$NAMESPACE" ] && [ -z "$GLOBAL_NAME" ] && [ -z "$ALL_NAMESPACE" ]; then
    kubectl get "$RESOURCE_TYPE"
  else
    echo "Error: Invalid get argument \n"
    exit 1
  fi

  echo -e "\nSuccess - get \n"
fi

# Run describe
if [ "$MODE" = "describe" ]; then
  echo -e "\nK8s describe \n"
  
  # 
  if [ -n "$NAME" ]; then

    # 
    if [ -n "$NAMESPACE" ]; then
      kubectl describe "$RESOURCE_TYPE" "$NAME$APPEND_NAME_ENV" -n "$NAMESPACE$APPEND_NAMESPACE_ENV" "$RESOURCE_WATCH"
    elif [ -n "$GLOBAL_NAME" ]; then
      kubectl describe "$RESOURCE_TYPE" "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV" "$RESOURCE_WATCH"
    else
      kubectl describe "$RESOURCE_TYPE" "$NAME$APPEND_NAME_ENV" "$RESOURCE_WATCH"
    fi
  elif [ -n "$NAMESPACE" ]; then
    kubectl describe "$RESOURCE_TYPE" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
  elif [ -n "$GLOBAL_NAME" ]; then
    
    # 
    if [ -z "$RESOURCE_MULTIPLE" ]; then
      kubectl describe "$RESOURCE_TYPE" "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
    else
      kubectl describe "$RESOURCE_TYPE" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
    fi
  elif [ -n "$ALL_NAMESPACE" ]; then
    kubectl describe "$RESOURCE_TYPE" "$ALL_NAMESPACE"
  elif [ -z "$NAMESPACE" ] && [ -z "$GLOBAL_NAME" ] && [ -z "$ALL_NAMESPACE" ]; then
    kubectl describe "$RESOURCE_TYPE"
  else
    echo "Error: Invalid describe argument \n"
    exit 1
  fi
  echo -e "\nSuccess - describe \n"
fi


# Run delete
if [ "$MODE" = "delete" ]; then
  echo -e "\nK8s delete \n"
  
  # 
  if [ -n "$NAME" ]; then

    # 
    if [ -n "$NAMESPACE" ]; then
      kubectl delete "$RESOURCE_TYPE" "$NAME$APPEND_NAME_ENV" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
    elif [ -n "$GLOBAL_NAME" ]; then
      kubectl delete "$RESOURCE_TYPE" "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
    else
      kubectl delete "$RESOURCE_TYPE" "$NAME$APPEND_NAME_ENV"
    fi
  elif [ -n "$NAMESPACE" ]; then
    kubectl delete "$RESOURCE_TYPE" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
  elif [ -n "$GLOBAL_NAME" ]; then
    
    # 
    if [ -z "$RESOURCE_MULTIPLE" ]; then
      kubectl delete "$RESOURCE_TYPE" "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
    else
      kubectl delete "$RESOURCE_TYPE" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
    fi
  elif [ -n "$ALL_NAMESPACE" ]; then
    kubectl delete "$RESOURCE_TYPE" "$ALL_NAMESPACE"
  elif [ -z "$NAMESPACE" ] && [ -z "$GLOBAL_NAME" ] && [ -z "$ALL_NAMESPACE" ]; then
    kubectl delete "$RESOURCE_TYPE"
  else
    echo "Error: Invalid delete argument \n"
    exit 1
  fi

  echo -e "\nSuccess - delete \n"
fi
```

### Minikube scripts

```sh
# m-service.sh

#!/usr/bin/env bash
# ↑ This shebang is the most portable — works on Linux, macOS, Git Bash, and WSL

set -e
# -e: exit on error
# -u: treat unset variables as errors
# -o pipefail: fail if any part of a pipe fails

# Default values
MODE="service"
NAME=""
NAMESPACE=""
# append
APPEND_ENV=""
APPEND_NAME_ENV=""
APPEND_NAMESPACE_ENV=""
# global
GLOBAL_NAME=""
CONTEXT="."  # optional root path or relative directory

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -- ) continue ;;
    # 
    m=*) MODE="${arg#m=}" ;;
    n=*) NAME="${arg#n=}" ;;
    ns=*) NAMESPACE="${arg#ns=}" ;;
    # append
    ae=*) APPEND_ENV="${arg#ae=}" ;;
    ane=*) APPEND_NAME_ENV="${arg#ane=}" ;;
    anse=*) APPEND_NAMESPACE_ENV="${arg#anse=}" ;;
    # global
    gn=*) GLOBAL_NAME="${arg#gn=}" ;;
    c=*) CONTEXT="${arg#c=}" ;;
    # 
    * ) echo "Unknown argument: $arg" ;;
  esac
done

# Params
cat <<EOF
Params:
  MODE - m = "$MODE"
  NAME - n = "$NAME"
  NAMESPACE - ns = "$NAMESPACE"
  
  APPEND_ENV - ae = "$APPEND_ENV"
  APPEND_NAME_ENV - ane = "$APPEND_NAME_ENV"
  APPEND_NAMESPACE_ENV - anse = "$APPEND_NAME_ENV"

  GLOBAL_NAME - gn = "$GLOBAL_NAME"
  CONTEXT - c = "$CONTEXT"

Script:
  bash script.sh -- args
EOF

# validate name
if [ -z "$NAME" ] && [ -z "$GLOBAL_NAME" ]; then
  echo -e "\nError: name is required | arg n=name \n"
  exit 1
fi

# mutate append
if [ -n "$APPEND_ENV" ]; then
  APPEND_ENV="-$APPEND_ENV"
else 
  APPEND_ENV=""
fi
if [ -n "$APPEND_NAME_ENV" ]; then
  APPEND_NAME_ENV="-$APPEND_NAME_ENV"
else 
  APPEND_NAME_ENV="$APPEND_ENV"
fi
if [ -n "$APPEND_NAMESPACE_ENV" ]; then
  APPEND_NAMESPACE_ENV="-$APPEND_NAMESPACE_ENV"
else 
  APPEND_NAMESPACE_ENV="$APPEND_ENV"
fi

# Run rollout
if [ "$MODE" = "service" ]; then
  echo -e "\nMinikube service \n"
  
  # 
  if [ -n "$NAME" ]; then
    if [ -n "$NAMESPACE" ]; then
      minikube service "$NAME$APPEND_NAME_ENV" -n "$NAMESPACE$APPEND_NAMESPACE_ENV"
    else 
      minikube service "$NAME$APPEND_NAME_ENV" 
    fi
  elif [ -z "$NAME" ] && [ -n "$GLOBAL_NAME" ]; then
    minikube service "$GLOBAL_NAME$APPEND_NAME_ENV" -n "$GLOBAL_NAME$APPEND_NAMESPACE_ENV"
  else
    echo -e "\nError: Invalid service argument \n"
    exit 1
  fi

  echo -e "\nSuccess - service \n"
fi
```

## Npm Scripts

```json
// set npm to use shell by default (for windows)

"scripts": {
  "win:set-sh": "npm config set script-shell 'C:\\Program Files\\Git\\bin\\bash.exe' && npm config get script-shell",
}
```

```json
// npm scripts v1
// local (staging,prod) | remote (staging,prod)

"scripts": {
  "m:start": "minikube start",
  "m:stop": "minikube stop",

  // minikube: load local images
  "m:load-staging": "minikube image load mern-js-backend-staging",
  "m:load": "minikube image load mern-js-backend",

  // minikube: service
  "mloc:svc-staging": "minikube service mern-js-backend-local-staging -n mern-js-backend-local-staging",
  "mloc:svc": "minikube service mern-js-backend-local -n mern-js-backend-local",
  "m:svc-staging": "minikube service mern-js-backend-staging -n mern-js-backend-staging",
  "m:svc": "minikube service mern-js-backend -n mern-js-backend",

  // configMap (cm)
  "kloc:cm-staging": "kubectl create cm mern-js-backend-local-staging-cm -n mern-js-backend-local-staging --from-env-file=.env.staging --dry-run=client -o yaml | kubectl apply -f -",
  "kloc:cm": "kubectl create cm mern-js-backend-local-cm -n mern-js-backend-local --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -",
  "k:cm-staging": "kubectl create cm mern-js-backend-staging-cm -n mern-js-backend-staging --from-env-file=.env.staging --dry-run=client -o yaml | kubectl apply -f -",
  "k:cm": "kubectl create cm mern-js-backend-cm -n mern-js-backend --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -",
  
  // secrets
  "kloc:secret-staging": "kubectl create secret generic mern-js-backend-local-staging-secret -n mern-js-backend-local-staging --from-env-file=.env.staging --dry-run=client -o yaml | kubectl apply -f -",
  "kloc:secret": "kubectl create secret generic mern-js-backend-local-secret -n mern-js-backend-local --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -",
  "k:secret-staging": "kubectl create secret generic mern-js-backend-staging-secret -n mern-js-backend-staging --from-env-file=.env.staging --dry-run=client -o yaml | kubectl apply -f -",
  "k:secret": "kubectl create secret generic mern-js-backend-secret -n mern-js-backend --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -",

  // apply - delete | local
  "kloc:apply-staging": "kubectl apply -f k8s/local/staging -n mern-js-backend-local-staging",
  "kloc:apply": "kubectl apply -f k8s/local/prod -n mern-js-backend-local",
  "kloc:delete-staging": "kubectl delete -f k8s/local/staging -n mern-js-backend-local-staging",
  "kloc:delete": "kubectl delete -f k8s/local/prod -n mern-js-backend-local",
  // apply - delete | remote
  "k:apply-staging": "kubectl apply -f k8s/remote/staging -n mern-js-backend-staging",
  "k:apply": "kubectl apply -f k8s/remote/prod -n mern-js-backend",
  "k:delete-staging": "kubectl delete -f k8s/remote/staging -n mern-js-backend-staging",
  "k:delete": "kubectl delete -f k8s/remote/prod -n mern-js-backend",
  
  // deploy: pause - restart | local
  "kloc:pause-staging": "kubectl rollout pause deployment mern-js-backend-local-staging -n mern-js-backend-local-staging",
  "kloc:pause": "kubectl rollout pause deployment mern-js-backend-local -n mern-js-backend-local",
  "kloc:restart-staging": "kubectl rollout restart deployment mern-js-backend-local-staging -n mern-js-backend-local-staging",
  "kloc:restart": "kubectl rollout restart deployment mern-js-backend-local -n mern-js-backend-local",
  // deploy: pause - restart | remote
  "k:pause-staging": "kubectl rollout pause deployment mern-js-backend-staging",
  "k:pause": "kubectl rollout pause deployment mern-js-backend -n mern-js-backend",
  "k:restart-staging": "kubectl rollout restart deployment mern-js-backend-staging",
  "k:restart": "kubectl rollout restart deployment mern-js-backend -n mern-js-backend",

  // deploy: scale | local
  "kloc:scale-staging": "kubectl scale deployment mern-js-backend-local-staging -n mern-js-backend-local-staging --replicas=2",
  "kloc:scale": "kubectl scale deployment mern-js-backend-local -n mern-js-backend-local --replicas=2",
  // deploy: scale | remote
  "k:scale-staging": "kubectl scale deployment mern-js-backend-staging -n mern-js-backend-staging --replicas=2",
  "k:scale": "kubectl scale deployment mern-js-backend -n mern-js-backend --replicas=2",
  
  // resource: get - describe | local
  "kloc:get-staging": "kubectl get mern-js-backend-local-staging -n mern-js-backend-local-staging -A -w",
  "kloc:get": "kubectl get mern-js-backend-local -n mern-js-backend-local -A -w",
  "kloc:describe-staging": "kubectl describe mern-js-backend-local-staging -n mern-js-backend-local-staging -A -w",
  "kloc:describe": "kubectl describe mern-js-backend-local -n mern-js-backend-local -A -w",
  // resource: get - describe | remote
  "k:get-staging": "kubectl get mern-js-backend-staging -n mern-js-backend-staging -A -w",
  "k:get": "kubectl get mern-js-backend -n mern-js-backend -A -w",
  "k:describe-staging": "kubectl describe mern-js-backend-staging -n mern-js-backend-staging -A -w",
  "k:describe": "kubectl describe mern-js-backend -n mern-js-backend -A -w",
}
```

```json
// npm scripts v2 | specific bash scripts
// local (staging,prod) | remote (staging,prod)
// names are constants across scripts

"scripts": {
  "m:start": "minikube start",
  "m:stop": "minikube stop",
  
  // minikube: load local images
  "m:load-staging": "minikube image load ${image:-mern-js-backend-staging}",
  "m:load": "minikube image load ${image:-mern-js-backend}",

  // minikube: service
  "mloc:svc-staging": "bash scripts/minikube/m-service.sh -- gn=mern-js-backend ae=local-staging",
  "mloc:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-backend ae=local",
  "m:svc-staging": "bash scripts/minikube/m-service.sh -- gn=mern-js-backend ae=staging",
  "m:svc": "bash scripts/minikube/m-service.sh -- gn=mern-js-backend",
  
  // configMaps
  "kloc:cm-staging": "bash scripts/k8s/k-env.sh -- m=cm gn=mern-js-backend ae=local-staging",
  "kloc:cm": "bash scripts/k8s/k-env.sh -- m=cm gn=mern-js-backend ae=local",
  "k:cm-staging": "bash scripts/k8s/k-env.sh -- m=cm gn=mern-js-backend ae=staging",
  "k:cm": "bash scripts/k8s/k-env.sh -- m=cm gn=mern-js-backend",
  
  // secrets
  "kloc:secret-staging": "bash scripts/k8s/k-env.sh -- gn=mern-js-backend ae=local-staging",
  "kloc:secret": "bash scripts/k8s/k-env.sh -- gn=mern-js-backend ae=local",
  "k:secret-staging": "bash scripts/k8s/k-env.sh -- gn=mern-js-backend ae=staging",
  "k:secret": "bash scripts/k8s/k-env.sh -- gn=mern-js-backend",

  // apply - delete | local
  "kloc:apply-staging": "bash scripts/k8s/k-config.sh -- f=k8s/local/staging",
  "kloc:apply": "bash scripts/k8s/k-config.sh -- f=k8s/local/prod",
  "kloc:delete-staging": "bash scripts/k8s/k-config.sh -- m=delete f=k8s/local/staging",
  "kloc:delete": "bash scripts/k8s/k-config.sh -- m=delete f=k8s/local/prod",
  // apply - delete | remote
  "k:apply-staging": "bash scripts/k8s/k-config.sh -- f=k8s/remote/staging",
  "k:apply": "bash scripts/k8s/k-config.sh -- f=k8s/remote/prod",
  "k:delete-staging": "bash scripts/k8s/k-config.sh -- m=delete f=k8s/remote/staging",
  "k:delete": "bash scripts/k8s/k-config.sh -- m=delete f=k8s/remote/prod",
  
  // deploy: pause - restart | local
  "kloc:pause-staging": "bash scripts/k8s/k-deploy.sh -- rt=pause gn=mern-js-backend ae=local-staging",
  "kloc:pause": "bash scripts/k8s/k-deploy.sh -- rt=pause gn=mern-js-backend ae=local",
  "kloc:restart-staging": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend-staging ae=local-staging",
  "kloc:restart": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend ae=local",
  // deploy: pause - restart | remote
  "k:pause-staging": "bash scripts/k8s/k-deploy.sh -- rt=pause gn=mern-js-backend-staging ae=staging",
  "k:pause": "bash scripts/k8s/k-deploy.sh -- rt=pause gn=mern-js-backend",
  "k:restart-staging": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend ae=staging",
  "k:restart": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend",

  // deploy: scale | local
  "kloc:scale-staging": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-backend sn=2 ae=local-staging",
  "kloc:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-backend sn=2 ae=local",
  // deploy: scale | remote
  "k:scale-staging": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-backend-staging sn=2 ae=staging",
  "k:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-backend sn=2",

  // resource: get - describe | local
  "kloc:get-staging": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=local-staging",
  "kloc:get": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=local",
  "kloc:describe-staging": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=local-staging",
  "kloc:describe": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=local",
  // resource: get - describe | remote
  "k:get-staging": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=staging",
  "k:get": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend",
  "k:describe-staging": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=staging",
  "k:describe": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend",
}
```

```json
// npm scripts v3 | smaller bash scripts
// local (staging,prod) | remote (staging,prod)
// names are constants across scripts

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
  "k:rollout": "bash scripts/k8s/k-deploy.sh -- rt=restart gn=mern-js-backend",
  // npm run <kloc|k>:rollout -- m=<rollout(default)> rt=<status(default)|pause|restart> n=<...> ns=<...> gn=<...>

  // deploy: scale | local
  "kloc:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-backend sn=2 ae=local",
  "k:scale": "bash scripts/k8s/k-deploy.sh -- gn=mern-js-backend sn=2",
  // npm run <kloc|k>:scale -- m=<rollout(default)> sn=<...> n=<...> ns=<...> gn=<...>

  // resource: get - describe
  "kloc:res": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend ae=local",
  "k:res": "bash scripts/k8s/k-resource.sh -- gn=mern-js-backend",
  // npm run <kloc|k>:scale -- m=<rollout(default)> rt=<all(default)|ns,deploy,svc,pods,...> n=<...> ns=<...> ans=<...> rw=<...> gn=<...>
}
```
