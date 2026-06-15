# cpto-tinyproxy

Part of the [CPTO](https://github.com/jpbaking/cpto) stack — a VPN-routed proxy setup built to explore Docker networking patterns.

This container runs [tinyproxy](http://tinyproxy.github.io/) on Alpine Linux as an HTTP proxy. It runs **inside `cpto-openvpn`'s network namespace**, so all proxied HTTP traffic exits through the VPN tunnel.

## Role in the stack

```
[ haproxy :3128 ] → [ tinyproxy :3128 ] ─┐ shares openvpn's network namespace
                                         │
                                     [ openvpn ] → VPN → internet
```

## Usage (Docker Compose)

See the [CPTO repo](https://github.com/jpbaking/cpto) for the full compose setup. Minimal example:

```yaml
services:
  tinyproxy:
    image: jpbaking/cpto-tinyproxy:latest
    network_mode: service:openvpn
    depends_on:
      openvpn:
        condition: service_healthy
```

## Configuration

The image ships with a `tinyproxy.conf` that:

- Listens on `:3128`
- Accepts connections from any source IP — haproxy is the actual public-facing gatekeeper
- `MaxClients 1024`, `StartServers 64`, `Timeout 600`
- Logs at `Connect` level to stdout

To override, mount your own config:

```yaml
volumes:
  - ./tinyproxy.conf:/etc/tinyproxy/tinyproxy.conf:ro
```

## Notes

- Changing the listen port requires matching updates in `haproxy.cfg` and `docker-compose.yaml`
- This container has no independent network interface in the CPTO stack — it sees only the openvpn tunnel and communicates through it

## Source

[github.com/jpbaking/cpto](https://github.com/jpbaking/cpto) — `tinyproxy/tinyproxy.Dockerfile`
