# cpto-srelay

Part of the [CPTO](https://github.com/jpbaking/cpto) stack — a VPN-routed proxy setup built to explore Docker networking patterns.

This container runs [srelay](https://socks-relay.sourceforge.io/) as a SOCKS4/5 proxy on Alpine Linux. It runs **inside `cpto-openvpn`'s network namespace**, so all proxied SOCKS traffic exits through the VPN tunnel.

Built from source via a multi-stage Dockerfile — srelay is not in Alpine's package registry.

## Role in the stack

```
[ haproxy :1080 ] → [ srelay :1080 ] ─┐ shares openvpn's network namespace
                                      │
                                  [ openvpn ] → VPN → internet
```

## Usage (Docker Compose)

See the [CPTO repo](https://github.com/jpbaking/cpto) for the full compose setup. Minimal example:

```yaml
services:
  srelay:
    image: jpbaking/cpto-srelay:latest
    network_mode: service:openvpn
    depends_on:
      openvpn:
        condition: service_healthy
```

## Configuration

The image ships with a minimal `srelay.conf` that accepts connections from any source IP and forwards to any destination:

```
0.0.0.0    any
```

This is intentional — haproxy is the actual public-facing gatekeeper.

To override, mount your own config:

```yaml
volumes:
  - ./srelay.conf:/etc/srelay.conf:ro
```

## Build notes

The image is built in two stages:

1. **Builder** — Alpine with `g++`, `make`, `wget`; downloads srelay 0.4.9 from SourceForge and compiles it with GCC 14+ compatibility flags (`-Wno-incompatible-pointer-types -Wno-int-conversion`)
2. **Runtime** — clean Alpine image with only the compiled `srelay` binary and config

## Source

[github.com/jpbaking/cpto](https://github.com/jpbaking/cpto) — `srelay/srelay.Dockerfile`
