#!/bin/bash

set -e

echo "Creating YAML"

if [ -z "$CR_INSTANCE_COUNT" ]; then
    echo "CR_INSTANCE_COUNT not set"
    exit 1
fi
i=0
rm folders.yaml || echo "Folders.yaml did not exist; ignoring"
until [[ $i == $CR_INSTANCE_COUNT ]]
do
  ((i++))
   cat << EOF >> folders.yaml
apiVersion: oss.grafana.crossplane.io/v1alpha1
kind: Folder
metadata:
  name: folder-${i}
spec:
  providerConfigRef:
    name: default
  forProvider:
    title: "test-${i}"
    uid: "test-${i}"
---
EOF
done

echo "Applying yaml to cluster"
kubectl apply -f folders.yaml

echo "Waiting for all folders to be healthy"
while [[ $(kubectl get folder.oss.grafana.crossplane.io --no-headers | grep -E '(True)\s*(True)' | wc -l) != $CR_INSTANCE_COUNT ]]
do
  sleep 2
  echo "Ready folders: $(kubectl get folder.oss.grafana.crossplane.io --no-headers | grep -E '(True)\s*(True)' | wc -l) / $CR_INSTANCE_COUNT"
done

echo "All folders are Synced and Ready"
