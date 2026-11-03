# retain-storage-demo

Small Kubernetes demo showing a **`Retain` reclaim policy** with the Rancher
**local-path** provisioner: delete the PVC and the PV + data stay on the node.

## Layout

```
retain-storage-demo/
├── manifests/
│   ├── 00-namespace.yaml      # namespace: storage
│   ├── 01-storageclass.yaml   # retain-storage (Retain, WaitForFirstConsumer)
│   ├── 02-pvc.yaml            # data-pvc, 1Gi, RWO
│   └── 03-pod.yaml            # writer (nginx:alpine, mounts /data)
└── scripts/
    ├── test.sh                # deploy + write test file
    ├── prove-retain.sh        # delete Pod/PVC, show PV is Released
    └── cleanup.sh             # full cleanup (PV + reminder for node data)
```

## Requirements

- A Kubernetes cluster (e.g. RKE2) with `kubectl` access
- [rancher/local-path-provisioner](https://github.com/rancher/local-path-provisioner) installed
  (default node path: `/opt/local-path-provisioner`)

## Usage

```bash
# 1. Deploy and write data
./scripts/test.sh

# Manual equivalent:
kubectl apply -f manifests/
kubectl -n storage exec writer -- sh -c "echo hello > /data/test.txt"

# 2. On the node running the pod, confirm the data
find /opt/local-path-provisioner

# 3. Prove Retain works
./scripts/prove-retain.sh
```

## Expected results

| Step | Result |
|------|--------|
| After `apply` | PVC `Pending` until the Pod is scheduled (`WaitForFirstConsumer`) |
| After Pod starts | PVC `Bound`, PV created automatically |
| After deleting PVC | PV status becomes `Released`, **not** deleted |
| On the node | `test.txt` still exists under `/opt/local-path-provisioner/pvc-...` |

## Notes

- A `Released` PV cannot be bound by a new PVC until its `claimRef` is cleared:
  `kubectl patch pv <name> -p '{"spec":{"claimRef":null}}'`
- local-path volumes are node-local; the Pod must run on the node that holds the data.
- `Retain` means cleanup is manual: run `./scripts/cleanup.sh`, then remove the
  directory on the node.
