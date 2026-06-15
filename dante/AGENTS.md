# dante

## Purpose

SOCKS4/5 proxy daemon running inside the openvpn network namespace, so all proxied traffic exits through the VPN. Installed directly from Alpine's apk (`dante-server`).

## Ownership

- `dante.Dockerfile` — single-stage build: installs `dante-server` from Alpine apk
- `entrypoint.sh` — detects the first non-loopback NIC via `/proc/net/dev` at startup and patches `external:` in `/etc/sockd.conf` before exec-ing `sockd`
- `danted.conf` — permissive accept-all config; binds on `0.0.0.0:1080`; `external: eth0` is a placeholder replaced at runtime

## Local Contracts

- Binds on `:1080` (SOCKS4/5) inside the openvpn network namespace
- `network_mode: service:openvpn` is set at compose level — dante sees no independent network interface
- Config mounted at `/etc/danted.conf`
- haproxy reaches dante at `openvpn:1080`

## Work Guidance

- `external: eth0` in `danted.conf` is a placeholder; `entrypoint.sh` replaces it with the actual NIC name at container startup via `/proc/net/dev`
- All routing through the VPN tunnel is handled by openvpn's routing table in the shared namespace, not by dante
- `socksmethod: none` and `clientmethod: none` allow unauthenticated connections — appropriate because haproxy is the actual public-facing gatekeeper
- If `danted` refuses to start due to privilege issues, ensure `user.privileged: root` and `user.notprivileged: nobody` are both present in `danted.conf`

## Verification

- `./compose.sh build dante` — build must succeed
- `./test.sh` — SOCKS4 and SOCKS5 entries must both return the VPN exit IP
