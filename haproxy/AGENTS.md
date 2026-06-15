# haproxy

## Purpose

TCP frontend for the CPTO stack. The only service with published host ports. Routes inbound HTTP (`:3128`) and SOCKS (`:1080`) connections from the host to tinyproxy and srelay, which are reachable at the `openvpn` hostname because they share its network namespace.

## Ownership

- `haproxy.cfg` — frontend/backend config, timeouts, connection limits; mounted read-only into the `haproxy:alpine` image at `/usr/local/etc/haproxy/haproxy.cfg`

## Local Contracts

- Container listens on `:3128` (HTTP frontend → `openvpn:3128`) and `:1080` (SOCKS frontend → `openvpn:1080`)
- Backend hostnames resolve via docker-compose service name `openvpn`
- Health checks enabled on both backends (`check` keyword); haproxy will not forward until backends respond
- Host port mapping is defined in `docker-compose.yaml`, not here
- `depends_on: [openvpn, tinyproxy, srelay]` is set at compose level

## Work Guidance

- Backend addresses (`openvpn:3128`, `openvpn:1080`) must stay in sync with what tinyproxy/srelay actually bind
- `timeout connect 3s` is intentionally short; `timeout server/client 10m` accommodates long-lived proxy connections
- `maxconn 10240` is set both globally and in defaults; change both if tuning

## Verification

- `./compose.sh up` then `./test.sh` — both proxy ports must return a VPN exit IP different from the home WAN IP
