# srelay

## Purpose

SOCKS4/5 proxy daemon running inside the openvpn network namespace, so all proxied traffic exits through the VPN. Built from source via a multi-stage Dockerfile because srelay is not packaged in Alpine's apk.

## Ownership

- `srelay.Dockerfile` — two-stage build: Alpine builder compiles srelay 0.4.8p3 from SourceForge tarball; runtime stage copies the binary
- `srelay.conf` — minimal accept-all config (`0.0.0.0 any`)

## Local Contracts

- Binds on `:1080` (SOCKS4/5) inside the openvpn network namespace
- `network_mode: service:openvpn` is set at compose level — srelay sees no independent network interface
- Config mounted at `/etc/srelay.conf`
- haproxy reaches srelay at `openvpn:1080`

## Work Guidance

- The tarball URL in `srelay.Dockerfile` points to a specific SourceForge mirror (`udomain.dl`); if the download fails during build, try a different mirror or host the tarball elsewhere
- `srelay.conf` line `0.0.0.0    any` means srelay accepts connections from any source IP and forwards to any destination — appropriate here because haproxy is the actual public-facing gatekeeper
- Do not add a `WORKDIR` or user-specific config here; all runtime concerns belong in `.env`

## Verification

- `./compose.sh build srelay` — build must succeed (source download + compile)
- `./test.sh` — SOCKS4 and SOCKS5 entries must both return the VPN exit IP
