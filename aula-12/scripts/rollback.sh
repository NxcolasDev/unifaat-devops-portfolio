#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:?AWS_REGION is required}"

previous_image_file="$HOME/.technova/previous-image"
if [[ ! -s "$previous_image_file" ]]; then
  echo "No previous image was recorded; automatic rollback is unavailable." >&2
  exit 1
fi

previous_image="$(<"$previous_image_file")"
registry="${previous_image%%/*}"

aws ecr get-login-password --region "$AWS_REGION" |
  docker login --username AWS --password-stdin "$registry"
docker pull "$previous_image"

if docker inspect technova-api >/dev/null 2>&1; then
  docker stop technova-api
  docker rm technova-api
fi

docker run --detach \
  --restart unless-stopped \
  --name technova-api \
  --publish 3000:3000 \
  --env PUBLISH_CLOUDWATCH_METRICS=true \
  --env AWS_REGION="$AWS_REGION" \
  "$previous_image"

echo "Restored ${previous_image}."
