#!/usr/bin/env bash
# Delete Pod + PVC, then show the PV is Released (not deleted) and data remains.
set -euo pipefail

kubectl -n storage delete pod writer --ignore-not-found
kubectl -n storage delete pvc data-pvc

echo "--- PV should be 'Released' ---"
kubectl get pv

echo "--- Run this ON THE NODE: data should still exist ---"
echo "find /opt/local-path-provisioner"
