# 桌面打包路径常量（唯一定义点）。由 desktop_init 填充。

desktop_init() {
  local lib_dir
  lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  DESKTOP_ROOT="$(cd "$lib_dir/../../.." && pwd)"
  REPO_ROOT="$(cd "$DESKTOP_ROOT/.." && pwd)"

  DESKTOP_CMD_SRC="$DESKTOP_ROOT/cmd"
  DESKTOP_ADMIN_DIST="$REPO_ROOT/admin/dist"
  DESKTOP_SERVER_SRC="$REPO_ROOT/server"
  DESKTOP_PACK_SFX="$lib_dir/../vendor/pack-sfx.php"

  DESKTOP_OS=$(uname -s)
  DESKTOP_ARCH=$(uname -m)

  desktop_resolve_pkg_platform || exit 1
  desktop_init_stage

  DESKTOP_BUILD_DIR="${DESKTOP_BUILD_DIR:-$DESKTOP_ROOT/build/$DESKTOP_PKG_PLATFORM}"
  DESKTOP_BUILD_REL="../build/$DESKTOP_PKG_PLATFORM/"

  DESKTOP_WORK_DIR="$DESKTOP_BUILD_DIR/.work"
  # 跨 stage clean 持久；与 build/<platform>/.work/（phar 等临时产物）分离
  DESKTOP_BRANDING_ENV="$DESKTOP_ROOT/.work/branding.env"
  DESKTOP_PHAR="$DESKTOP_WORK_DIR/fastapp.phar"
  DESKTOP_PHAR_SRC="$DESKTOP_WORK_DIR/server-phar-src"
  DESKTOP_UI_DIR="$DESKTOP_BUILD_DIR/ui"
  DESKTOP_CMD_STAGE="$DESKTOP_BUILD_DIR/cmd"
  DESKTOP_STORAGE_STAGE="$DESKTOP_BUILD_DIR/storage"
}

desktop_tauri_output_dir() {
  echo "$DESKTOP_ROOT/src-tauri/target/$DESKTOP_RUST_TARGET/release/bundle"
}

desktop_env_truthy() {
  case "${1:-}" in
    1 | true | TRUE | yes | YES | on | ON) return 0 ;;
    *) return 1 ;;
  esac
}

desktop_open_after_build() {
  desktop_env_truthy "${DESKTOP_OPEN_AFTER_BUILD:-0}"
}

desktop_open_bundle_artifact() {
  local bundle_dir artifact

  bundle_dir=$(desktop_tauri_output_dir)
  case "$DESKTOP_PKG_PLATFORM" in
    macArm | macIntel)
      shopt -s nullglob
      for artifact in "$bundle_dir/dmg"/*.dmg; do
        echo "==> open $artifact"
        open "$artifact"
        return 0
      done
      shopt -u nullglob
      echo "未找到 DMG: $bundle_dir/dmg/*.dmg" >&2
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}
