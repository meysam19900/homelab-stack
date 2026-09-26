#!/usr/bin/env bash
set -euo pipefail

# ====================================================================
# Homelab Notification Dispatcher
# Unified alerting script for ntfy and Gotify
#====================================================================

TITLE="${1:-Homelab Alert}"
MESSAGE="${2:-No details provided.}"
PRIORITY="${3:-default}"
TAGS="${4:-bell}"

# Target URLs and authentication loaded from environment
NTFY_URL="${NTFY_URL:-http://localhost:8080/homelab-alerts}"
NTFY_TOKEN="${NTFY_TOKEN:-}"
GOTIFY_URL="${GOTIFY_URL:-http://localhost:8081/message}"
GOTIFY_TOKEN="${GOTIFY_TOKEN:-}"

# Priority mapping (ntfy / Gotify)
case "${PRIORITY,,}" in
  min|low|1)
    NTFY_PRIORITY="1"
    GOTIFY_PRIORITY="1"
    ;;
  high|urgent|critical|4|5)
    NTFY_PRIORITY="4"
    GOTIFY_PRIORITY="8"
    ;;
  *)
    NTFY_PRIORITY="3"
    GOTIFY_PRIORITY="5"
    ;;
esac

# 1. Dispatch to ntfy
if [[ -n "${NTFY_URL}" ]]; then
  AUTH_HEADER=()
  if [[ -n "${NTFY_TOKEN}" ]]; then
    AUTH_HEADER=(-H "Authorization: Bearer ${NTFY_TOKEN}")
  fi

  curl -fsS -X POST "${NTFY_URL}" \
    -H "Title: ${TITLE}" \
    -H "Priority: ${NTFY_PRIORITY}" \
    -H "Tags: ${TAGS}" \
    "${AUTH_HEADER[@]}" \
    -d "${MESSAGE}" >/dev/null || echo "[WARN] Failed to deliver alert to ntfy" >&2
fi

# 2. Dispatch to Gotify (if app token is configured)
if [[ -n "${GOTIFY_URL}" && -n "${GOTIFY_TOKEN}" ]]; then
  curl -fsS -X POST "${GOTIFY_URL}" \
    -H "X-Gotify-Key: ${GOTIFY_TOKEN}" \
    -F "title=${TITLE}" \
    -F "message=${MESSAGE}" \
    -F "priority=${GOTIFY_PRIORITY}" >/dev/null || echo "[WARN] Failed to deliver alert to Gotify" >&2
fi
