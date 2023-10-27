#!/bin/bash

set -e

echo "Deleting instances"

if [ -z "$CR_INSTANCE_COUNT" ]; then
    echo "CR_INSTANCE_COUNT not set"
    exit 1
fi
i=0
until [[ $i == $CR_INSTANCE_COUNT  ]]
do
  ((i++))
  echo "Deleting folder-${i}"
  kubectl delete --wait=false --ignore-not-found=true folder.oss.grafana.crossplane.io "folder-${i}"
done

echo "Waiting for all folders to be deleted"
while [[ $(kubectl get folder.oss.grafana.crossplane.io --no-headers | wc -l) != 0 ]]
do
  sleep 2
  echo "Existing folders: $(kubectl get folder.oss.grafana.crossplane.io --no-headers  | wc -l) / $CR_INSTANCE_COUNT"
done

echo "All folders are Deleted"
