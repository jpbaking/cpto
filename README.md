# CPTO

**Containerized HTTP/SOCKS Proxy Through OpenVPN**


Exposes HTTP and SOCKS proxy ports on your host that forward traffic through an OpenVPN client running in a container. Ideal when you need selective VPN routing — only the traffic you explicitly proxy goes through the VPN; your host machine stays on its normal network.

> **Educational / Experimental project.** This stack exists to explore Docker networking concepts — pod-like namespaces, multi-stage builds, and lightweight proxy tooling. It is not hardened, audited, or supported for production or commercial use. Run it in a controlled environment and treat all credentials as disposable.

---

## Architecture

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
- **tinyproxy** and **srelay** — HTTP and SOCKS4/5 proxy daemons that run *inside* openvpn's network namespace, so all their traffic exits through the VPN
- **haproxy** — the only service with published ports; proxies inbound connections to tinyproxy/srelay via the openvpn service network

Also demonstrates:
- Pod-like container networking with `network_mode: service:` ([docs](https://docs.docker.com/compose/compose-file/compose-file-v2/#network_mode))
- YAML anchors and aliases in `docker-compose.yaml` ([guide](https://medium.com/@kinghuang/docker-compose-anchors-aliases-extensions-a1e4105d70bd))
- Docker multi-stage builds ([docs](https://docs.docker.com/develop/develop-images/multistage-build/))
- Alpine-based images ([alpinelinux.org](https://alpinelinux.org/about/))
- Lightweight open-source proxy tools:
  - **tinyproxy** — HTTP proxy ([site](http://tinyproxy.github.io/) / [github](https://github.com/tinyproxy/tinyproxy))
  - **srelay** — SOCKS4/5 proxy ([site](https://socks-relay.sourceforge.io/))
  - **haproxy** — TCP load balancer / frontend ([site](http://www.haproxy.org/) / [github](https://github.com/haproxy/haproxy))

---

## Usage

### Step 1 — Clone

```bash
git clone git@github.com:jpbaking/cpto.git
cd cpto
```

### Step 2 — Configure

Copy the example env file and edit it to match your OpenVPN setup:

```bash
cp .env.example .env
```

Key variables in `.env`:

| Variable | Default | Description |
|---|---|---|
| `OPENVPN_CONFIG_DIR` | `./.openvpn` | Local directory with your `.ovpn` file and any credential files; mounted read-only into the container |
| `OPENVPN_CMD_ARGS` | *(see example)* | Arguments passed verbatim to `openvpn`; relative paths resolve against `OPENVPN_CONFIG_DIR` |
| `HTTP_PROXY_PORT` | `3128` | Host port for HTTP proxy |
| `SOCKS_PROXY_PORT` | `1080` | Host port for SOCKS4/5 proxy |

Place your `.ovpn` config (and any credential files) in the directory pointed to by `OPENVPN_CONFIG_DIR` before starting.

### Step 3 — Run

Use `compose.sh` — a thin wrapper around `docker-compose` that always sets `--project-name=cpto`:

| Action | Command |
|---|---|
| Start (pre-built images) | `./compose.sh pull && ./compose.sh up --detach --no-build` |
| Start (build locally) | `./compose.sh up --detach --build` |
| Stop | `./compose.sh down` |
| Status | `./compose.sh ps` |
| Logs | `./compose.sh logs -f --tail 100` |
| Rebuild only | `./compose.sh build` |

### Step 4 — Verify (optional)

Run `test.sh` to confirm traffic is routing through the VPN:

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
