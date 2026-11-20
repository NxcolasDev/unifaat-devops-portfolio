#!/usr/bin/env bash
set -Eeuo pipefail

: "${LISTENER_ARN:?LISTENER_ARN is required}"
: "${TG_STABLE_ARN:?TG_STABLE_ARN is required}"
: "${TG_CANARY_ARN:?TG_CANARY_ARN is required}"
: "${ALB_DNS:?ALB_DNS is required}"

ERROR_THRESHOLD="${ERROR_THRESHOLD:-5}"
HEALTH_PATH="${HEALTH_PATH:-/health}"
SAMPLE_COUNT="${SAMPLE_COUNT:-40}"
WAIT_SECONDS="${WAIT_SECONDS:-60}"

rollback() {
  echo "Rollback: routing all new requests to the stable target group."
  aws elbv2 modify-listener \
    --listener-arn "$LISTENER_ARN" \
    --default-actions "$(jq -cn \
      --arg stable "$TG_STABLE_ARN" \
      --arg canary "$TG_CANARY_ARN" \
      '[{
        Type:"forward",
        ForwardConfig:{
          TargetGroups:[
            {TargetGroupArn:$stable,Weight:100},
            {TargetGroupArn:$canary,Weight:0}
          ],
          TargetGroupStickinessConfig:{Enabled:true,DurationSeconds:300}
        }
      }]')"
}

fail_and_rollback() {
  echo "ERROR: $1" >&2
  rollback
  exit 1
}

set_weights() {
  local canary_weight="$1"
  local stable_weight=$((100 - canary_weight))

  aws elbv2 modify-listener \
    --listener-arn "$LISTENER_ARN" \
    --default-actions "$(jq -cn \
      --arg stable "$TG_STABLE_ARN" \
      --arg canary "$TG_CANARY_ARN" \
      --argjson stable_weight "$stable_weight" \
      --argjson canary_weight "$canary_weight" \
      '[{
        Type:"forward",
        ForwardConfig:{
          TargetGroups:[
            {TargetGroupArn:$stable,Weight:$stable_weight},
            {TargetGroupArn:$canary,Weight:$canary_weight}
          ],
          TargetGroupStickinessConfig:{Enabled:true,DurationSeconds:300}
        }
      }]')" >/dev/null
}

canary_is_healthy() {
  local healthy_count
  healthy_count="$(aws elbv2 describe-target-health \
    --target-group-arn "$TG_CANARY_ARN" \
    --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' \
    --output text)"
  [[ "$healthy_count" =~ ^[0-9]+$ ]] && (( healthy_count > 0 ))
}

measure_error_rate() {
  local errors=0
  local status

  for ((request = 1; request <= SAMPLE_COUNT; request++)); do
    status="$(curl --silent --show-error --output /dev/null \
      --write-out '%{http_code}' \
      --max-time 5 \
      "http://${ALB_DNS}${HEALTH_PATH}" 2>/dev/null || true)"
    if [[ ! "$status" =~ ^[0-9]{3}$ ]] || (( 10#$status >= 500 )); then
      errors=$((errors + 1))
    fi
  done

  awk -v errors="$errors" -v samples="$SAMPLE_COUNT" \
    'BEGIN { if (samples < 1) exit 2; printf "%.2f", (errors / samples) * 100 }'
}

stages=(5 25 50 100)

for index in "${!stages[@]}"; do
  stage_number=$((index + 1))
  canary_weight="${stages[$index]}"
  stable_weight=$((100 - canary_weight))

  echo "Stage ${stage_number}/4: stable=${stable_weight}% canary=${canary_weight}%"
  canary_is_healthy || fail_and_rollback "Canary target group has no healthy targets."
  set_weights "$canary_weight"
  sleep "$WAIT_SECONDS"

  canary_is_healthy || fail_and_rollback "Canary target became unhealthy."

  error_rate="$(measure_error_rate)"
  echo "Observed HTTP 5xx/error rate: ${error_rate}% (threshold ${ERROR_THRESHOLD}%)."
  awk -v rate="$error_rate" -v threshold="$ERROR_THRESHOLD" \
    'BEGIN { if (rate > threshold) exit 1 }' \
    || fail_and_rollback "Observed error rate exceeded the configured threshold."
done

echo "Canary rollout completed; the canary target group now receives 100% of requests."
