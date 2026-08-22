#!/bin/bash
# CDN 发布：phar zip + manifest.json（非桌面包安装管线）

set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"
desktop_init

_sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

_file_size() {
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

out_dir="${DESKTOP_PUBLISH_OUT:-$REPO_ROOT/dist/desktop-cdn}"
version="${DESKTOP_VERSION:-1.0.0}"
channel="${DESKTOP_CHANNEL:-stable}"
cdn_base="${DESKTOP_CDN_BASE:-https://cdn.example.com/fastapp}"

mkdir -p "$out_dir"

echo "==> build server (phar)"
if [ ! -f "$DESKTOP_PHAR" ]; then
  bash "$_scripts_dir/phar.sh"
fi

server_stage="$out_dir/.stage-server"
rm -rf "$server_stage"
mkdir -p "$server_stage"
cp "$DESKTOP_PHAR" "$server_stage/"

server_zip="$out_dir/server-${version}.zip"
(cd "$server_stage" && zip -rq "$server_zip" .)
server_sha=$(_sha256 "$server_zip")
server_size=$(_file_size "$server_zip")

manifest="$out_dir/manifest.json"
cat > "$manifest" <<EOF
{
  "app_version": "${version}",
  "channel": "${channel}",
  "models_catalog_url": "${cdn_base}/models/catalog.json",
  "components": {
    "server": {
      "url": "${cdn_base}/server-${version}.zip",
      "sha256": "${server_sha}",
      "size": ${server_size},
      "version": "${version}"
    }
  }
}
EOF

rm -rf "$server_stage"
echo "==> manifest: $manifest"
echo "Upload $server_zip and manifest.json to $cdn_base"
