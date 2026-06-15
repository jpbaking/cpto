Push the Docker Hub `full_description` for each CPTO container image using the README.md files in each container's build folder.

Run this bash block exactly as written:

```bash
CREDS=$(cat ~/.docker/config.json | python3 -c "
import sys,json,base64
d=json.load(sys.stdin)
auth = d['auths']['https://index.docker.io/v1/']['auth']
print(base64.b64decode(auth).decode())
")
USER=$(echo "$CREDS" | cut -d: -f1)
PASS=$(echo "$CREDS" | cut -d: -f2-)
JWT=$(curl -s -X POST "https://hub.docker.com/v2/users/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"${USER}\", \"password\": \"${PASS}\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

for REPO in cpto-openvpn cpto-tinyproxy cpto-srelay; do
  DIR=$(echo $REPO | sed 's/cpto-//')
  RESULT=$(python3 -c "
import json
readme = open('${DIR}/README.md').read()
print(json.dumps({'full_description': readme}))
" | curl -s -X PATCH "https://hub.docker.com/v2/repositories/jpbaking/${REPO}/" \
    -H "Authorization: JWT ${JWT}" \
    -H "Content-Type: application/json" \
    -d @-)
  echo "=== jpbaking/${REPO} ==="
  echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print('ok') if 'full_description' in d else print(d)"
done
```

Report each repository's result. If any fail, show the raw response so the error is visible.
