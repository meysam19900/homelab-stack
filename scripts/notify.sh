#!/usr/bin/env bash
set -euo pipefail

# Unified notification script for homelab-stack
# Usage: ./scripts/notify.sh <topic> <title> <message> [priority]

TOPIC="${1:-}"
TITLE="${2:-}"
MESSAGE="${3:-}"
PRIORITY="${4:-default}"

if [[ -z "$TOPIC" || -z "$TITLE" || -z "$MESSAGE" ]]; then
  echo "Usage: $0 <topic> <title> <message> [priority]" >&2
  exit 1
fi

NTFY_URL="${NTFY_URL:-}"
if [[ -z "$NTFY_URL" ]]; then
  if [[ -n "${DOMAIN:-}" ]]; then
    NTFY_URL="https://ntfy.${DOMAIN}"
  else
    NTFY_URL="http://localhost:80"
  fi
fi

TARGET_ENDPOINT="${NTFY_URL%/}/${TOPIC}"

curl -fsS \
  -H "Title: ${TITLE}" \
  -H "Priority: ${PRIORITY}" \
  --data-binary "${MESSAGE}" \
  "${TARGET_ENDPOINT}" >/dev/null

echo "Notification successfully dispatched to: ${TARGET_ENDPOINT}"
