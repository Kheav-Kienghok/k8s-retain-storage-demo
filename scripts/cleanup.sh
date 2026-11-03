#!/usr/bin/env bash
# Full cleanup. Retain means the PV and node data are NOT removed automatically.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl delete -f manifests/ --ignore-not-found

# Remove leftover Released PVs that used this StorageClass
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="retain-storage")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete pv "$pv"
done

echo "Now delete the data dir ON THE NODE (path from 'find /opt/local-path-provisioner'):"
echo "  sudo rm -rf /opt/local-path-provisioner/pvc-*_storage_data-pvc"
