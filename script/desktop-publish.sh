#!/bin/bash
set -euo pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT_DIR="${DESKTOP_PUBLISH_OUT:-$BASE_DIR/dist/desktop-cdn}"
VERSION="${DESKTOP_VERSION:-1.0.0}"
CHANNEL="${DESKTOP_CHANNEL:-stable}"
CDN_BASE="${DESKTOP_CDN_BASE:-https://cdn.example.com/fastapp}"

mkdir -p "$OUT_DIR"

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

file_size() {
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

zip_dir() {
  local name="$1"
  local src="$2"
  local dest="$OUT_DIR/${name}.zip"
  (cd "$src" && zip -rq "$dest" .)
  echo "$dest"
}

echo "==> build server (phar + plugin)"
if [ ! -f "$BASE_DIR/server/fastapp.phar" ]; then
  bash "$BASE_DIR/script/park.sh"
fi
SERVER_STAGE="$OUT_DIR/.stage-server"
rm -rf "$SERVER_STAGE"
mkdir -p "$SERVER_STAGE"
cp "$BASE_DIR/server/fastapp.phar" "$SERVER_STAGE/"
cp -R "$BASE_DIR/server/plugin" "$SERVER_STAGE/"
SERVER_ZIP=$(zip_dir "server-${VERSION}" "$SERVER_STAGE")
SERVER_SHA=$(sha256_file "$SERVER_ZIP")
SERVER_SIZE=$(file_size "$SERVER_ZIP")

MANIFEST="$OUT_DIR/manifest.json"
cat > "$MANIFEST" <<EOF
{
  "app_version": "${VERSION}",
  "channel": "${CHANNEL}",
  "models_catalog_url": "${CDN_BASE}/models/catalog.json",
  "components": {
    "server": {
      "url": "${CDN_BASE}/server-${VERSION}.zip",
      "sha256": "${SERVER_SHA}",
      "size": ${SERVER_SIZE},
      "version": "${VERSION}"
    }
  }
}
EOF

rm -rf "$SERVER_STAGE"
echo "==> manifest: $MANIFEST"
echo "Upload $OUT_DIR/server-${VERSION}.zip and manifest.json to $CDN_BASE"
