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

