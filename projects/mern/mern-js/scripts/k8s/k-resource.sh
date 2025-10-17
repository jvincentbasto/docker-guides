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