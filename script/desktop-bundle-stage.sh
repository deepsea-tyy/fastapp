#!/bin/bash
set -euo pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BUNDLE_DIR="$BASE_DIR/desktop/bundle"
STAGE_DIR="$BASE_DIR/desktop/.bundle-stage"
ADMIN_DIST="$BASE_DIR/admin/dist"
CMD_DIR="$BASE_DIR/cmd"
TOOLS_SRC="$BASE_DIR/tools"

OS=$(uname -s)
ARCH=$(uname -m)

if [ "${DESKTOP_BUILD_ADMIN:-0}" = "1" ]; then
  echo "==> build admin dist"
  (cd "$BASE_DIR/admin" && pnpm build)
fi

if [ ! -d "$ADMIN_DIST" ]; then
  echo "admin/dist 不存在，请先 cd admin && pnpm build" >&2
  exit 1
fi

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64) CMD_PLATFORM="$CMD_DIR/macos/arm" ;;
      *) CMD_PLATFORM="$CMD_DIR/macos/x86" ;;
    esac
    PHP_SRC="$CMD_PLATFORM/swoole"
    if [ ! -f "$PHP_SRC" ]; then
      PHP_SRC="$CMD_PLATFORM/swoole-cli"
    fi
    FFMPEG_SRC="$CMD_DIR/macos/ffmpeg"
    FFPROBE_SRC="$CMD_DIR/macos/ffprobe"
    UV_SRC="$CMD_PLATFORM/uv"
    UVX_SRC="$CMD_PLATFORM/uvx"
    ARCHIVER="$CMD_DIR/7zz"
    ;;
  MINGW*|MSYS*|CYGWIN*|Windows*)
    CMD_PLATFORM="$CMD_DIR/windows/win64"
    PHP_SRC="$CMD_PLATFORM/swoole/swoole-cli.exe"
    FFMPEG_SRC="$CMD_PLATFORM/ffmpeg.exe"
    FFPROBE_SRC="$CMD_PLATFORM/ffprobe.exe"
    UV_SRC="$CMD_PLATFORM/uv.exe"
    UVX_SRC="$CMD_PLATFORM/uvx.exe"
    case "$ARCH" in
      ARM64|aarch64) ARCHIVER="$CMD_DIR/7z2602-arm64.exe" ;;
      *) ARCHIVER="$CMD_DIR/7z2602-x64.exe" ;;
    esac
    ;;
  *)
    echo "unsupported OS: $OS" >&2
    exit 1
    ;;
esac

if [ ! -f "$PHP_SRC" ]; then
  echo "PHP 二进制不存在: $PHP_SRC" >&2
  exit 1
fi
if [ ! -f "$UV_SRC" ]; then
  echo "uv 二进制不存在: $UV_SRC" >&2
  exit 1
fi
if [ ! -f "$ARCHIVER" ]; then
  echo "7z 解压器不存在: $ARCHIVER" >&2
  exit 1
fi

echo "==> stage bundle -> $BUNDLE_DIR"
rm -rf "$BUNDLE_DIR" "$STAGE_DIR"
mkdir -p "$STAGE_DIR/ui" "$STAGE_DIR/tools" "$STAGE_DIR/cmd" "$BUNDLE_DIR"

rsync -a "$ADMIN_DIST/" "$STAGE_DIR/ui/"

rsync -a \
  --exclude '.venv' \
  --exclude 'models' \
  --exclude 'runtime' \
  --exclude '__pycache__' \
  --exclude '.git' \
  "$TOOLS_SRC/" "$STAGE_DIR/tools/"

case "$OS" in
  MINGW*|MSYS*|CYGWIN*|Windows*)
    cp "$PHP_SRC" "$STAGE_DIR/cmd/php.exe"
    rsync -a "$CMD_PLATFORM/swoole/" "$STAGE_DIR/cmd/swoole/"
    cp "$UV_SRC" "$STAGE_DIR/cmd/uv.exe"
    cp "$UVX_SRC" "$STAGE_DIR/cmd/uvx.exe"
    cp "$FFMPEG_SRC" "$STAGE_DIR/cmd/ffmpeg.exe"
    cp "$FFPROBE_SRC" "$STAGE_DIR/cmd/ffprobe.exe"
    cp "$ARCHIVER" "$BUNDLE_DIR/"
    ;;
  *)
    cp "$PHP_SRC" "$STAGE_DIR/cmd/php"
    cp "$UV_SRC" "$STAGE_DIR/cmd/uv"
    cp "$UVX_SRC" "$STAGE_DIR/cmd/uvx"
    cp "$FFMPEG_SRC" "$STAGE_DIR/cmd/ffmpeg"
    cp "$FFPROBE_SRC" "$STAGE_DIR/cmd/ffprobe"
    chmod +x "$STAGE_DIR/cmd/"*
    cp "$ARCHIVER" "$BUNDLE_DIR/7zz"
    chmod +x "$BUNDLE_DIR/7zz"
    ;;
esac

pack_7z() {
  local name="$1"
  local src="$2"
  local out="$BUNDLE_DIR/${name}.7z"
  (cd "$src" && "$ARCHIVER" a -t7z -mx=9 "$out" .)
}

pack_7z ui "$STAGE_DIR/ui"
pack_7z tools "$STAGE_DIR/tools"
pack_7z cmd "$STAGE_DIR/cmd"

rm -rf "$STAGE_DIR"

echo "==> bundle ready"
echo "    ui.7z: $(ls -lh "$BUNDLE_DIR/ui.7z" | awk '{print $5}')"
echo "    tools.7z: $(ls -lh "$BUNDLE_DIR/tools.7z" | awk '{print $5}')"
echo "    cmd.7z: $(ls -lh "$BUNDLE_DIR/cmd.7z" | awk '{print $5}')"
