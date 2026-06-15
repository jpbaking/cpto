# cpto-tinyproxy

## Purpose

HTTP proxy daemon running inside the openvpn network namespace, so all proxied traffic exits through the VPN.

## Ownership

- `tinyproxy.Dockerfile` — image definition (Alpine + tinyproxy package)
- `tinyproxy.conf` — full tinyproxy configuration

## Local Contracts

- Binds on `:3128` (HTTP proxy) inside the openvpn network namespace
- `network_mode: service:openvpn` is set at compose level — tinyproxy sees no independent network interface
- Config mounted at `/etc/tinyproxy/tinyproxy.conf`
- haproxy reaches tinyproxy at `openvpn:3128`

## Work Guidance

- `tinyproxy.conf` is the canonical tinyproxy config format; refer to tinyproxy docs for option reference
- The `Allow` directive in `tinyproxy.conf` controls which source IPs tinyproxy accepts — since haproxy is the actual public gatekeeper, this can remain permissive within the container network
- Do not change the listen port without updating `haproxy.cfg` backend and `docker-compose.yaml` accordingly

## Verification

- `./test.sh` — the HTTP proxy entry must return the VPN exit IP
