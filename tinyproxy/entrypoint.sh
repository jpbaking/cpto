#!/bin/sh
set -e

while sleep 5; do
  ip link show tun0 > /dev/null 2>&1 || { echo "[tinyproxy] tun0 gone, exiting"; exit 1; }
done &

exec /usr/bin/tinyproxy -d
