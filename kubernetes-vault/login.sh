#!/bin/sh
set -eu

VAULT_ADDR="http://vault.vault.svc:8200"


JWT="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
printf '{"role":"%s","jwt":"%s"}\n' otus-role "$JWT" > /tmp/login.json

echo "[login] POST $VAULT_ADDR/v1/auth/kubernetes/login"
RESP="$(curl -sS -X POST -H 'Content-Type: application/json' \
              --data @/tmp/login.json \
              "$VAULT_ADDR/v1/auth/kubernetes/login")" || {
  echo "Login request failed"
  exit 1
}
echo "$RESP"


CT="$(echo "$RESP" | sed -n 's/.*"client_token":"\([^"]*\)".*/\1/p')"
if [ -z "$CT" ]; then
  echo "Failed to parse client_token from login response"
  exit 1
fi
echo "[login] client_token acquired"


echo "[read] GET $VAULT_ADDR/v1/otus/data/cred"
curl -sS -H "X-Vault-Token: $CT" "$VAULT_ADDR/v1/otus/data/cred" || {
  echo "Read request failed"
  exit 1
}