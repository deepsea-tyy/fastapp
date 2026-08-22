#!/bin/bash
# 桌面安装包构建入口：phar | sfx | stage

set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

case "${1:-}" in
  phar) bash "$_scripts_dir/phar.sh" ;;
  sfx) bash "$_scripts_dir/sfx.sh" ;;
  stage) bash "$_scripts_dir/stage.sh" ;;
  *)
    echo "usage: $(basename "$0") phar|sfx|stage" >&2
    echo "  DESKTOP_BUILD_DIR  DESKTOP_FORCE_PHAR  DESKTOP_KEEP_PHAR  DESKTOP_SKIP_ADMIN" >&2
    echo "  DESKTOP_FFMPEG_MIRROR" >&2
    echo "CDN 发布见 publish-cdn.sh" >&2
    exit 1
    ;;
esac
