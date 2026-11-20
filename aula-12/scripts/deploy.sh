#!/usr/bin/env bash
set -euo pipefail

: "${DEPLOY_IMAGE_URI:?DEPLOY_IMAGE_URI is required}"
: "${AWS_REGION:?AWS_REGION is required}"

state_dir="$HOME/.technova"
previous_image_file="${state_dir}/previous-image"
mkdir -p "$state_dir"

if ! docker inspect technova-api >/dev/null 2>&1; then
  echo "No existing technova-api container is available for automatic rollback." >&2
  exit 1
fi

previous_image="$(docker inspect --format='{{.Config.Image}}' technova-api)"
if [[ -z "$previous_image" ]]; then
  echo "Could not determine the currently deployed image." >&2
  exit 1
fi

temporary_file="${previous_image_file}.tmp"
printf '%s\n' "$previous_image" > "$temporary_file"
mv "$temporary_file" "$previous_image_file"

registry="${DEPLOY_IMAGE_URI%%/*}"
aws ecr get-login-password --region "$AWS_REGION" |
  docker login --username AWS --password-stdin "$registry"
docker pull "$DEPLOY_IMAGE_URI"

docker stop technova-api
docker rm technova-api
docker run --detach \
  --restart unless-stopped \
  --name technova-api \
  --publish 3000:3000 \
  --env PUBLISH_CLOUDWATCH_METRICS=true \
  --env AWS_REGION="$AWS_REGION" \
  "$DEPLOY_IMAGE_URI"
