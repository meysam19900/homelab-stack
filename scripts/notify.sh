#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${DOMAIN:-localhost}"
NTFY_URL="${NTFY_URL:-https://ntfy.${DOMAIN}}"
NTFY_TOKEN="${NTFY_TOKEN:-}"

if [ "$#" -ge 3 ] && [ "$#" -le 4 ]; then
  if [ "$#" -eq 4 ]; then
    TOPIC="$1"
    TITLE="$2"
    MESSAGE="$3"
    PRIORITY="${4:-3}"
  elif [ "$#" -eq 3 ] && [[ "$3" =~ ^(min|low|default|high|max|urgent|[1-5])$ ]]; then
    TOPIC="homelab-alerts"
    TITLE="$1"
    MESSAGE="$2"
    PRIORITY="$3"
  else
    TOPIC="$1"
    TITLE="$2"
    MESSAGE="$3"
    PRIORITY="3"
  fi
elif [ "$#" -eq 2 ]; then
  TOPIC="homelab-alerts"
  TITLE="$1"
  MESSAGE="$2"
  PRIORITY="3"
else
  echo "Usage: $0 <topic> <title> <message> [priority]"
  echo "   or: $0 <title> <message> [priority]"
  exit 1
fi

case "${PRIORITY,,}" in
  min|1) PRIO_NUM=1 ;;
  low|2) PRIO_NUM=2 ;;
  default|3) PRIO_NUM=3 ;;
  high|4) PRIO_NUM=4 ;;
  max|urgent|5) PRIO_NUM=5 ;;
  *) PRIO_NUM=3 ;;
esac

AUTH_HEADER=()
if [ -n "$NTFY_TOKEN" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${NTFY_TOKEN}")
fi

TARGET_URL="${NTFY_URL}/${TOPIC}"

curl -fsSL \
  "${AUTH_HEADER[@]}" \
  -H "Title: ${TITLE}" \
  -H "Priority: ${PRIO_NUM}" \
  -d "${MESSAGE}" \
  "${TARGET_URL}"

echo "Notification sent successfully to ${TOPIC}"
