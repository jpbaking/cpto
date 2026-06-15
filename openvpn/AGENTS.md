# openvpn

## Purpose

VPN client container. Owns the network namespace that tinyproxy and srelay run inside (`network_mode: service:openvpn`), so all proxy traffic exits through the VPN tunnel. Waits for internet reachability before starting the openvpn process.

## Ownership

- `openvpn.Dockerfile` — image definition (Alpine + openvpn package)
- `entrypoint.sh` — pings `1.1.1.1` in a loop until reachable, then execs `openvpn $@`
- `README.md` — Docker Hub repository description for `jpbaking/cpto-openvpn`

## Local Contracts

- Requires `cap_add: NET_ADMIN` and device `/dev/net/tun` (set in `docker-compose.yaml`)
- User config directory is volume-mounted read-only at `/.openvpn`; this is also the working directory, so relative paths in `.ovpn` files resolve there
- `OPENVPN_CMD_ARGS` is passed as the container `command` and forwarded to `openvpn` verbatim
- DNS is set to `1.1.1.1` / `1.0.0.1` at compose level to ensure resolution before tunnel is up
- tinyproxy and srelay join this container's network namespace and bind on `:3128` and `:1080` respectively — haproxy reaches them via the `openvpn` hostname

## Work Guidance

- The readiness loop in `entrypoint.sh` uses `ping -W 3 -c 4 1.1.1.1`; adjust wait time there if the host network takes longer to come up
- Do not remove or bypass the readiness check — openvpn fails silently if started before the network interface is ready
- All openvpn configuration is supplied at runtime via `.env`; nothing in this folder is user-specific

## Verification

- `./compose.sh logs -f openvpn` — should show successful tunnel establishment with no auth errors
- `./test.sh` — VPN exit IP must differ from home WAN IP
