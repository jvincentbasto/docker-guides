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