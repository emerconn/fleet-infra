#!/bin/bash
set -e # exit on first error

CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") # UTC k8s format
echo "current date: $CURRENT_DATE"
CURRENT_SECONDS=$(date -d "$CURRENT_DATE" +%s) # seconds since epoch
echo "current seconds since epoch: $CURRENT_SECONDS"

LABEL="janitor/ttl"
echo "label: $LABEL"
NAMESPACES=$(kubectl get ns -l "$LABEL" -o jsonpath='{.items[*].metadata.name}')
echo "labeled namespaces: $NAMESPACES"

for ns in $NAMESPACES; do
  echo "===================="
  echo "namespace: $ns"

  LABEL_VALUE=$(kubectl get ns "$ns" -o jsonpath="{.metadata.labels.$LABEL}")
  echo "label value: $LABEL_VALUE"
  LABEL_INT=$(echo "$LABEL_VALUE" | sed -nEe 's/([0-9]+).*/\1/p')
  echo "label int: $LABEL_INT"
  LABEL_UNIT=$(echo "$LABEL_VALUE" | sed -nEe 's/[0-9]+(.).*/\1/p')
  echo "label unit: $LABEL_UNIT"

  CREATION_DATE=$(kubectl get ns "$ns" -o jsonpath='{.metadata.creationTimestamp}')
  echo "creation date: $CREATION_DATE"
  CREATION_SECONDS=$(date -d "$CREATION_DATE" +%s) # seconds since epoch
  echo "creation seconds since epoch: $CREATION_SECONDS"

  DIFF_S=$(( CURRENT_SECONDS - CREATION_SECONDS ))
  echo "diff second: $DIFF_S"
  DIFF_M=$(( DIFF_S / 60 ))
  echo "diff minute: $DIFF_M"
  DIFF_H=$(( DIFF_M / 60 ))
  echo "diff hour: $DIFF_H"
  DIFF_D=$(( DIFF_H / 24 ))
  echo "diff day: $DIFF_D"
  DIFF_W=$(( DIFF_D / 7 ))
  echo "diff week: $DIFF_W"

  case "$LABEL_UNIT" in
    "s" | "m" | "h" | "d" | "w")
        echo "case: $LABEL_UNIT"

        eval "DIFF_INT=\$DIFF_${LABEL_UNIT^^}"
        echo "diff int: $DIFF_INT"

        if [[ "$DIFF_INT" -ge "$LABEL_INT" ]]; then
          echo "deleting namespace: ${DIFF_INT}${LABEL_UNIT} >= ${LABEL_INT}${LABEL_UNIT}"
          kubectl delete ns "$ns" --wait=false # namespaces with finalized resources will be left in a perpetual Terminating state
        else 
          echo "keeping namespace: ${DIFF_INT}${LABEL_UNIT} < ${LABEL_INT}${LABEL_UNIT}"
        fi
      ;;
    *)
      echo "invalid unit: $LABEL_UNIT"
      ;;
  esac
done
