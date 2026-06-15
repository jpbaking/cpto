Build all three CPTO images. If any image changed since the last build, tag each with a `YYMMDDHHMM` timestamp and push both `:latest` and the timestamp tag to Docker Hub.

Run this bash block exactly as written:

```bash
cd $(git rev-parse --show-toplevel)

OLD_OPENVPN=$(docker inspect --format='{{.Id}}' jpbaking/cpto-openvpn:latest 2>/dev/null)
OLD_TINYPROXY=$(docker inspect --format='{{.Id}}' jpbaking/cpto-tinyproxy:latest 2>/dev/null)
OLD_SRELAY=$(docker inspect --format='{{.Id}}' jpbaking/cpto-srelay:latest 2>/dev/null)

./compose.sh build

NEW_OPENVPN=$(docker inspect --format='{{.Id}}' jpbaking/cpto-openvpn:latest 2>/dev/null)
NEW_TINYPROXY=$(docker inspect --format='{{.Id}}' jpbaking/cpto-tinyproxy:latest 2>/dev/null)
NEW_SRELAY=$(docker inspect --format='{{.Id}}' jpbaking/cpto-srelay:latest 2>/dev/null)

if [ "$OLD_OPENVPN" = "$NEW_OPENVPN" ] && \
   [ "$OLD_TINYPROXY" = "$NEW_TINYPROXY" ] && \
   [ "$OLD_SRELAY" = "$NEW_SRELAY" ]; then
  echo "No changes — images unchanged, skipping tag and push."
else
  TS=$(date +%y%m%d%H%M)
  for IMG in cpto-openvpn cpto-tinyproxy cpto-srelay; do
    docker tag jpbaking/${IMG}:latest jpbaking/${IMG}:${TS}
  done
  for IMG in cpto-openvpn cpto-tinyproxy cpto-srelay; do
    docker push jpbaking/${IMG}:latest
    docker push jpbaking/${IMG}:${TS}
  done
  echo "Pushed with tag :${TS}"
fi
```

Report the outcome: either "no changes" or which tag was pushed and confirm all six pushes succeeded (three `:latest`, three timestamped).
