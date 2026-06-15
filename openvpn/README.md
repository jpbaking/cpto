# cpto-openvpn

Part of the [CPTO](https://github.com/jpbaking/cpto) stack — a VPN-routed proxy setup built to explore Docker networking patterns.

This container runs an OpenVPN client on Alpine Linux and **owns the shared network namespace** that `cpto-tinyproxy` and `cpto-srelay` run inside. All proxy traffic exits through this container's VPN tunnel.

## Role in the stack

```
[ haproxy ] → [ tinyproxy :3128 ] ─┐
            → [ srelay    :1080 ] ─┴─ share this container's network namespace
                                   │
                               [ openvpn ] → VPN → internet
```

## What it does

1. Pings `1.1.1.1` in a loop until the host network is ready
2. Starts `openvpn` with the arguments you pass as the container `command`
3. Other containers join its network namespace via `network_mode: service:openvpn`

## Usage (Docker Compose)

See the [CPTO repo](https://github.com/jpbaking/cpto) for the full compose setup. Minimal example:

```yaml
services:
  openvpn:
    image: jpbaking/cpto-openvpn:latest
    command: "--config client.ovpn --auth-user-pass client.pass --auth-nocache"
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    volumes:
      - ./my-ovpn-dir:/.openvpn:ro
    healthcheck:
      test: ["CMD-SHELL", "ip addr show tun0 2>/dev/null | grep -q 'inet '"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
```

## Configuration

| What | How |
|---|---|
| OpenVPN args | Pass as container `command` — forwarded verbatim to `openvpn` |
| Config files | Mount a directory read-only at `/.openvpn` — this is the working directory, so relative paths in your `.ovpn` file resolve there |
| Capabilities | Requires `cap_add: NET_ADMIN` and device `/dev/net/tun` |

## Healthcheck

The compose file ships a healthcheck that passes once `tun0` has an IP address (`ip addr show tun0`). Dependent containers (`tinyproxy`, `srelay`, `haproxy`) wait on this via `depends_on: condition: service_healthy`.

## Source

[github.com/jpbaking/cpto](https://github.com/jpbaking/cpto) — `openvpn/openvpn.Dockerfile`
