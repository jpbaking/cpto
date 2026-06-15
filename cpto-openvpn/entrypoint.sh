#!/bin/sh

ready() {
  echo 'Checking if internet is available...' 1>&2
  ping -W 3 -c 4 1.1.1.1 1>&2 && echo '0' || echo '1'
}

while [ "$(ready)" != '0' ]; do
  echo 'Internet still not ready...'
  sleep 1
done

echo 'Connecting OpenVPN client now!'
/usr/sbin/openvpn $@