# CPTO

*Hands-on Docker experiments: shared network namespaces and multi-stage builds, demonstrated through a VPN-routed proxy stack*

Exposes HTTP and SOCKS proxy ports that forward traffic through an OpenVPN client running in a container. Ideal when you need selective VPN routing — only the traffic you explicitly proxy goes through the VPN; your host machine stays on its normal network.

**CPTO** started as *Containerized HTTP/SOCKS Proxy Through OpenVPN*, later shortened to *Containerized Proxy Through OpenVPN*. The name stuck; the focus shifted from the proxy use case to the Docker patterns underneath it.

> **Educational / Experimental project.** This stack exists to explore Docker networking concepts — pod-like namespaces, multi-stage builds, and lightweight proxy tooling. It is not hardened, audited, or supported for production or commercial use. Run it in a controlled environment and treat all credentials as disposable.

---

## Architecture

### Docker Compose

```
[you / your app]
      │
      │  HTTP  :3128
      │  SOCKS :1080
      ▼
  [ haproxy ]  ◄─── only container with published ports
      │
      ├──► [ tinyproxy :3128 ]  ─┐
      │                           ├─ both share openvpn's network namespace
      └──► [ srelay     :1080 ]  ─┘
                                  │
                              [ openvpn ] ──► VPN / internet
```

- **openvpn** — runs the VPN client; owns the network namespace
- **tinyproxy** and **srelay** — run *inside* openvpn's network namespace via `network_mode: service:openvpn`; all their traffic exits through the VPN
- **haproxy** — the only service with published ports; routes inbound connections to tinyproxy/srelay

### Kubernetes

```
[you / your app]
      │
      │  HTTP  :3128
      │  SOCKS :1080
      ▼
  [ Service ]  ◄─── NodePort, load-balances across pods
      │
      ├──► Pod: [ openvpn | tinyproxy | srelay ] ──► VPN tunnel
      ├──► Pod: [ openvpn | tinyproxy | srelay ] ──► VPN tunnel
      └──► Pod: [ openvpn | tinyproxy | srelay ] ──► VPN tunnel
```

- Each **Pod** is an independent VPN proxy group — all three containers share the Pod's network namespace natively, no `network_mode` trick needed
- The **Service** replaces haproxy; Kubernetes load-balances across all ready Pods
- Scaling replicas spins up more independent tunnel groups

---

Built as a playground for these patterns:
- Shared network namespaces via `network_mode: service:` in Compose ([docs](https://docs.docker.com/reference/compose-file/services/#network_mode)) and natively in Kubernetes Pods
- Service healthchecks and condition-based `depends_on` in Compose ([docs](https://docs.docker.com/reference/compose-file/services/#depends_on))
- Readiness and liveness probes in Kubernetes ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/))
- YAML anchors and aliases in `docker-compose.yaml` ([guide](https://medium.com/@kinghuang/docker-compose-anchors-aliases-extensions-a1e4105d70bd))
- Docker multi-stage builds ([docs](https://docs.docker.com/build/building/multi-stage/))
- Alpine-based images ([alpinelinux.org](https://alpinelinux.org/about/))
- Lightweight open-source proxy tools:
  - **tinyproxy** — HTTP proxy ([site](http://tinyproxy.github.io/) / [github](https://github.com/tinyproxy/tinyproxy))
  - **srelay** — SOCKS4/5 proxy ([site](https://socks-relay.sourceforge.io/))
  - **haproxy** — TCP load balancer / frontend ([site](http://www.haproxy.org/) / [github](https://github.com/haproxy/haproxy))

---

## Usage

### Docker Compose

#### Step 1 — Clone

```bash
git clone git@github.com:jpbaking/cpto.git
cd cpto
```

#### Step 2 — Configure

```bash
cp .env.example .env
```

Key variables in `.env`:

| Variable | Default | Description |
|---|---|---|
| `OPENVPN_CONFIG_DIR` | `./.openvpn` | Directory with your `.ovpn` file and credential files; mounted read-only into the container |
| `OPENVPN_CMD_ARGS` | *(see example)* | Arguments passed verbatim to `openvpn`; relative paths resolve against `OPENVPN_CONFIG_DIR` |
| `HTTP_PROXY_PORT` | `3128` | Host port for HTTP proxy |
| `SOCKS_PROXY_PORT` | `1080` | Host port for SOCKS4/5 proxy |

#### Step 3 — Run

`compose.sh` is a thin wrapper around `docker compose` that always sets `--project-name=cpto`:

| Action | Command |
|---|---|
| Start (pre-built images) | `./compose.sh pull && ./compose.sh up --detach --no-build` |
| Start (build locally) | `./compose.sh up --detach --build` |
| Stop | `./compose.sh down` |
| Status | `./compose.sh ps` |
| Logs | `./compose.sh logs -f --tail 100` |
| Rebuild only | `./compose.sh build` |

---

### Kubernetes

#### Step 1 — Clone

```bash
git clone git@github.com:jpbaking/cpto.git
cd cpto
```

#### Step 2 — Configure

```bash
cp k8s-secret.example.yaml k8s-secret.yaml
```

Edit `k8s-secret.yaml` and paste your `.ovpn` file contents (and credential files if needed). This file is gitignored.

#### Step 3 — Apply

`kube.sh` is a thin wrapper around `kubectl` that always sets `--namespace=cpto`:

```bash
kubectl apply -f k8s-namespace.yaml
kubectl apply -f k8s-configmap.yaml
kubectl apply -f k8s-secret.yaml
./kube.sh apply -f k8s-deployment.yaml
./kube.sh apply -f k8s-service.yaml
```

| Action | Command |
|---|---|
| Status | `./kube.sh get pods` |
| Logs (openvpn) | `./kube.sh logs -l app=cpto -c openvpn -f` |
| Scale | `./kube.sh scale deployment/cpto --replicas=3` |
| Teardown | `./kube.sh delete -f k8s-deployment.yaml -f k8s-service.yaml` |

---

## Verify

Run `test.sh` to confirm traffic is routing through the VPN. For Kubernetes, set `HTTP_PROXY_PORT` and `SOCKS_PROXY_PORT` to the NodePort values assigned by the Service.

```
CMD: curl -s https://checkip.amazonaws.com
Your home WAN IP: 111.111.111.111

CMD: curl -s --proxy http://127.0.0.1:3128 https://checkip.amazonaws.com
IP through HTTP Proxy (port: 3128): 222.222.222.222

CMD: curl -s --proxy socks4://127.0.0.1:1080 https://checkip.amazonaws.com
IP through SOCKS4 Proxy (port: 1080): 222.222.222.222

CMD: curl -s --proxy socks5://127.0.0.1:1080 https://checkip.amazonaws.com
IP through SOCKS5 Proxy (port: 1080): 222.222.222.222
```

The two IPs should differ — your home WAN IP vs. the VPN exit IP.

---

## License

[0BSD](LICENSE) — do whatever you want, no attribution required.
