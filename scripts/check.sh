#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:-biscuits.lol}"
NAME="${2:-omg}"
echo "Fetching https://${DOMAIN}/.well-known/nostr.json?name=${NAME}"
curl -s "https://${DOMAIN}/.well-known/nostr.json?name=${NAME}" | jq .
