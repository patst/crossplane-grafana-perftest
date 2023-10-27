#!/bin/bash

set -e

cat << EOF >  pgres-values.yaml
auth:
  postgresPassword: admin
EOF

helm install graf-postgresql -n crossplane-system oci://registry-1.docker.io/bitnamicharts/postgresql -f pgres-values.yaml
