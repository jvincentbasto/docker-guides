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

