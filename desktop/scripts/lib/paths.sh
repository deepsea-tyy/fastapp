# 桌面打包路径常量（唯一定义点）。由 desktop_init 填充。

desktop_init() {
  local lib_dir
  lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  DESKTOP_ROOT="$(cd "$lib_dir/../.." && pwd)"
  REPO_ROOT="$(cd "$DESKTOP_ROOT/.." && pwd)"

  DESKTOP_CMD_SRC="$DESKTOP_ROOT/cmd"
  DESKTOP_ADMIN_DIST="$REPO_ROOT/admin/dist"
  DESKTOP_SERVER_SRC="$REPO_ROOT/server"
  DESKTOP_PACK_SFX="$lib_dir/pack-sfx.php"

  DESKTOP_OS=$(uname -s)
  DESKTOP_ARCH=$(uname -m)

  desktop_init_stage

  DESKTOP_BUILD_DIR="${DESKTOP_BUILD_DIR:-$DESKTOP_ROOT/build}"
  DESKTOP_WORK_DIR="$DESKTOP_BUILD_DIR/.work"
  DESKTOP_PHAR="$DESKTOP_WORK_DIR/fastapp.phar"
  DESKTOP_PHAR_SRC="$DESKTOP_WORK_DIR/server-phar-src"
  DESKTOP_SERVER_DIR="$DESKTOP_BUILD_DIR/server"
  DESKTOP_UI_DIR="$DESKTOP_BUILD_DIR/ui"
  DESKTOP_CMD_STAGE="$DESKTOP_BUILD_DIR/cmd"
  DESKTOP_STORAGE_STAGE="$DESKTOP_BUILD_DIR/storage"
}
