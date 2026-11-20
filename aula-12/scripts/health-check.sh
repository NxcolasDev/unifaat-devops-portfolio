#!/usr/bin/env bash
set -euo pipefail

: "${HEALTH_URL:?HEALTH_URL is required}"

MAX_RETRIES="${MAX_RETRIES:-10}"
RETRY_DELAY="${RETRY_DELAY:-6}"

for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
  status="$(curl --silent --show-error --output /dev/null \
    --write-out '%{http_code}' --max-time 5 "$HEALTH_URL" || true)"
  if [[ "$status" == "200" ]]; then
    echo "Health check passed on attempt ${attempt}/${MAX_RETRIES}."
    exit 0
  fi

  echo "Health check attempt ${attempt}/${MAX_RETRIES} returned ${status:-no response}."
  if (( attempt < MAX_RETRIES )); then
    sleep "$RETRY_DELAY"
  fi
done

echo "Health check failed after ${MAX_RETRIES} attempts." >&2
exit 1
