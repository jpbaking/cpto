#!/bin/sh
set -e

GW=""
until [ -n "$GW" ]; do
  GW=$(ip route | grep tun | grep 0.0.0.0 | cut -d ' ' -f 5)
  [ -z "$GW" ] && echo "[dante] waiting for tun gateway..." && sleep 1
done

echo "[dante] external gateway: $GW"
sed -i "s/^external: .*/external: $GW/" /etc/sockd.conf

while sleep 5; do
  ip link show tun0 > /dev/null 2>&1 || { echo "[dante] tun0 gone, exiting"; exit 1; }
done &

exec /usr/sbin/sockd -f /etc/sockd.conf
