#!/usr/bin/env bash
# Deploy, write a file, then show where it lives on the node.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl apply -f manifests/
kubectl -n storage wait --for=condition=Ready pod/writer --timeout=120s

kubectl -n storage exec writer -- sh -c "echo hello > /data/test.txt"
kubectl -n storage exec writer -- cat /data/test.txt

echo "--- PV / PVC ---"
kubectl get pv,pvc -n storage

echo "--- Run this ON THE NODE running the pod (path may need sudo) ---"
echo "find /opt/local-path-provisioner"
