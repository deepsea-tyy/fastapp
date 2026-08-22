#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"
desktop_init

# --- brand sync ---
bash "$_scripts_dir/sync-brand.sh"

# --- prerequisites ---
if [ "${DESKTOP_SKIP_ADMIN:-0}" != "1" ]; then
  echo "==> build admin dist"
  (cd "$REPO_ROOT/admin" && pnpm build)
fi

if [ ! -d "$DESKTOP_ADMIN_DIST" ]; then
  echo "admin/dist 不存在" >&2
  exit 1
fi

desktop_ensure_ffmpeg || exit 1
desktop_resolve_ffmpeg

# --- server binary (phar mirror + SFX) ---
echo "==> build SFX"
bash "$_scripts_dir/sfx.sh"

SFX_TARGET=$(desktop_sfx_target)
if [ ! -f "$SFX_TARGET" ]; then
  echo "SFX 不存在: $SFX_TARGET" >&2
  exit 1
fi

# --- bundle assets (ui + cmd + storage) ---
echo "==> stage bundle -> $DESKTOP_BUILD_DIR"
rm -rf "$DESKTOP_UI_DIR" "$DESKTOP_CMD_STAGE" "$DESKTOP_STORAGE_STAGE"
mkdir -p "$DESKTOP_UI_DIR" "$DESKTOP_CMD_STAGE" "$DESKTOP_STORAGE_STAGE"

rsync -a "$DESKTOP_ADMIN_DIST/" "$DESKTOP_UI_DIR/"

case "$DESKTOP_STAGE_OS" in
  MINGW*|MSYS*|CYGWIN*|Windows*)
    cp "$DESKTOP_FFMPEG_SRC" "$DESKTOP_CMD_STAGE/ffmpeg.exe"
    cp "$DESKTOP_FFPROBE_SRC" "$DESKTOP_CMD_STAGE/ffprobe.exe"
    ;;
  *)
    cp "$DESKTOP_FFMPEG_SRC" "$DESKTOP_CMD_STAGE/ffmpeg"
    cp "$DESKTOP_FFPROBE_SRC" "$DESKTOP_CMD_STAGE/ffprobe"
    chmod +x "$DESKTOP_CMD_STAGE/"*
    ;;
esac

echo "==> stage storage assets"
rsync -a "$DESKTOP_SERVER_SRC/storage/languages/" "$DESKTOP_STORAGE_STAGE/languages/"
if [ ! -d "$DESKTOP_SERVER_SRC/storage/ttc" ]; then
  echo "server/storage/ttc 不存在，请先放置思源黑体字体" >&2
  exit 1
fi
rsync -a "$DESKTOP_SERVER_SRC/storage/ttc/" "$DESKTOP_STORAGE_STAGE/ttc/"

echo "==> bundle ready: $DESKTOP_BUILD_DIR"
echo "    server: $(ls -lh "$SFX_TARGET" | awk '{print $5 " " $9}')"
echo "    ui:     $(find "$DESKTOP_UI_DIR" -type f | wc -l | tr -d ' ') files"
echo "    cmd:    $(ls "$DESKTOP_CMD_STAGE")"
echo "    storage: languages ttc"
