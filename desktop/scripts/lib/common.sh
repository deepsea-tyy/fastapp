# 公共加载入口：路径 + 平台 + 工具。

if [ -n "${DESKTOP_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
DESKTOP_LOADED=1

_lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# core
# shellcheck source=core/paths.sh
source "$_lib_dir/core/paths.sh"
# shellcheck source=core/platform.sh
source "$_lib_dir/core/platform.sh"
# shellcheck source=core/stage-profile.sh
source "$_lib_dir/core/stage-profile.sh"
# shellcheck source=core/server-env.sh
source "$_lib_dir/core/server-env.sh"

# vendor (构建依赖)
# shellcheck source=vendor/ffmpeg.sh
source "$_lib_dir/vendor/ffmpeg.sh"
# shellcheck source=vendor/swoole-cli.sh
source "$_lib_dir/vendor/swoole-cli.sh"

# stage
# shellcheck source=stage/phar.sh
source "$_lib_dir/stage/phar.sh"
# shellcheck source=stage/runtime.sh
source "$_lib_dir/stage/runtime.sh"
# shellcheck source=stage/tauri-conf.sh
source "$_lib_dir/stage/tauri-conf.sh"
# shellcheck source=stage/fonts.sh
source "$_lib_dir/stage/fonts.sh"
# shellcheck source=stage/ui.sh
source "$_lib_dir/stage/ui.sh"
# shellcheck source=stage/data.sh
source "$_lib_dir/stage/data.sh"
