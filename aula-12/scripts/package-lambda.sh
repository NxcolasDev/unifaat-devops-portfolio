#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_dir="$root/lambda-aiops"
temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "$temporary_dir"' EXIT

cp "$package_dir/index.js" "$package_dir/package.json" "$temporary_dir/"
npm --prefix "$temporary_dir" install --omit=dev --no-audit --no-fund
(
  cd "$temporary_dir"
  zip -qr "$package_dir/function.zip" .
)
echo "Created lambda-aiops/function.zip"
