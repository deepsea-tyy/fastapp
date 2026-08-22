# 公共加载入口：路径 + 平台 + 工具。

if [ -n "${DESKTOP_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
DESKTOP_LOADED=1

_lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=paths.sh
source "$_lib_dir/paths.sh"
# shellcheck source=platform.sh
source "$_lib_dir/platform.sh"
# shellcheck source=ffmpeg.sh
source "$_lib_dir/ffmpeg.sh"
# shellcheck source=swoole-cli.sh
source "$_lib_dir/swoole-cli.sh"
# shellcheck source=phar-mirror.sh
source "$_lib_dir/phar-mirror.sh"
