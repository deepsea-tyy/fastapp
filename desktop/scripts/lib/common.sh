# 公共加载入口：core 模块（stage/vendor 由 stage.sh 按需加载）。

if [ -n "${DESKTOP_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
DESKTOP_LOADED=1

_lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=core/paths.sh
source "$_lib_dir/core/paths.sh"
# shellcheck source=core/platform.sh
source "$_lib_dir/core/platform.sh"
# shellcheck source=core/gates.sh
source "$_lib_dir/core/gates.sh"
# shellcheck source=core/server-env.sh
source "$_lib_dir/core/server-env.sh"
# shellcheck source=core/clean.sh
source "$_lib_dir/core/clean.sh"
# shellcheck source=core/branding.sh
source "$_lib_dir/core/branding.sh"
