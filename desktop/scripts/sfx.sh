#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"
desktop_init

echo "==> build phar"
if [ ! -f "$DESKTOP_PHAR" ] || [ "${DESKTOP_FORCE_PHAR:-0}" = "1" ]; then
  bash "$_scripts_dir/phar.sh"
fi
if [ ! -f "$DESKTOP_PHAR" ]; then
  echo "phar 不存在: $DESKTOP_PHAR" >&2
  exit 1
fi

SWOOLE_CLI=$(desktop_ensure_swoole_cli)
PACK_SFX=$(desktop_resolve_pack_sfx)
if [ ! -f "$PACK_SFX" ]; then
  echo "pack-sfx.php 不存在: $PACK_SFX" >&2
  exit 1
fi

SFX_TARGET=$(desktop_sfx_target)
mkdir -p "$DESKTOP_SERVER_DIR"
rm -f "$SFX_TARGET"

echo "==> pack SFX ($SWOOLE_CLI)"
"$SWOOLE_CLI" "$PACK_SFX" "$DESKTOP_PHAR" "$SFX_TARGET"
chmod +x "$SFX_TARGET"

case "$DESKTOP_STAGE_OS" in
  MINGW*|MSYS*|CYGWIN*|Windows*)
    RUNTIME_DIR="$(desktop_resolve_swoole_bundle)/bin"
    if [ -d "$RUNTIME_DIR" ]; then
      echo "==> copy Windows runtime libs"
      for f in "$RUNTIME_DIR"/*; do
        base=$(basename "$f")
        if [ "$base" = "swoole-cli.exe" ]; then
          continue
        fi
        cp -a "$f" "$DESKTOP_SERVER_DIR/"
      done
    fi
    ;;
esac

if [ "${DESKTOP_KEEP_PHAR:-0}" != "1" ]; then
  rm -f "$DESKTOP_PHAR"
fi

echo "==> SFX ready: $SFX_TARGET"
ls -lh "$SFX_TARGET"
