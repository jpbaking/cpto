# k8s

## Purpose

Kubernetes manifests and the `kube.sh` helper for deploying CPTO. All Kubernetes runtime files live here.

## Ownership

- `namespace.yaml` — creates the `cpto` namespace
- `configmap.yaml` — `tinyproxy.conf` and `srelay.conf` mounted into the Pod
- `secret.example.yaml` — template for `secret.yaml`; copy and fill in OpenVPN credentials
- `deployment.yaml` — 3-replica Deployment; each Pod is an independent openvpn+tinyproxy+srelay group sharing a network namespace
- `service.yaml` — NodePort Service exposing `:3128` (HTTP) and `:1080` (SOCKS) across all ready Pods
- `kube.sh` — thin wrapper: runs `kubectl --namespace=cpto $@` from the repo root

## Local Contracts

- `secret.yaml` is gitignored; it must be created from `secret.example.yaml` before applying
- Apply order: `namespace.yaml` → `configmap.yaml` → `secret.yaml` → `deployment.yaml` → `service.yaml`
- `kube.sh` cds to its own directory on startup; kubectl does not depend on CWD so this is safe
- Port assignments (`:3128` HTTP, `:1080` SOCKS) must match what tinyproxy and srelay bind — see [`tinyproxy/AGENTS.md`](../tinyproxy/AGENTS.md) and [`srelay/AGENTS.md`](../srelay/AGENTS.md)

## Work Guidance

- `configmap.yaml` embeds tinyproxy and srelay config inline; update here if config changes (the component folders own the Compose-side config files)
- NodePort values are assigned by Kubernetes at runtime; pass them to `test.sh` via `HTTP_PROXY_PORT` and `SOCKS_PROXY_PORT`
- Do not add haproxy here — the Service handles load-balancing natively

## Verification

- `kubectl apply -f k8s/namespace.yaml && kubectl apply -f k8s/configmap.yaml && kubectl apply -f k8s/secret.yaml && ./k8s/kube.sh apply -f k8s/deployment.yaml -f k8s/service.yaml`
- `./k8s/kube.sh get pods` — all Pods must reach Running state with all containers ready
- `./test.sh` (with NodePort values set) — VPN exit IP must differ from home WAN IP
