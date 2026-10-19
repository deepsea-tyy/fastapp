# 打包平台解析（win | macArm | macIntel）。stage 二进制选择用 DESKTOP_STAGE_*。

_DESKTOP_ICON_FILE_NAMES=(
  32x32.png
  128x128.png
  128x128@2x.png
  icon.png
  icon.icns
  icon.ico
)

desktop_validate_pkg_platform() {
  case "${1:-}" in
    macArm | macIntel | win) return 0 ;;
    *)
      echo "未知平台: ${1:-<empty>}（可选: macArm | macIntel | win）" >&2
      return 1
      ;;
  esac
}

desktop_infer_pkg_platform_from_host() {
  case "$DESKTOP_OS" in
    Darwin)
      case "$DESKTOP_ARCH" in
        arm64 | aarch64) echo macArm ;;
        x86_64) echo macIntel ;;
        *)
          echo "不支持的 macOS 架构: $DESKTOP_ARCH" >&2
          return 1
          ;;
      esac
      ;;
    MINGW* | MSYS* | CYGWIN* | Windows*)
      echo win
      ;;
    *)
      echo "不支持的主机系统: $DESKTOP_OS（请设置 DESKTOP_PKG_PLATFORM）" >&2
      return 1
      ;;
  esac
}

desktop_resolve_pkg_platform() {
  if [ -n "${DESKTOP_PKG_PLATFORM:-}" ]; then
    desktop_validate_pkg_platform "$DESKTOP_PKG_PLATFORM"
    return $?
  fi

  local inferred
  inferred=$(desktop_infer_pkg_platform_from_host) || return 1
  DESKTOP_PKG_PLATFORM=$inferred
  export DESKTOP_PKG_PLATFORM
}

desktop_init_stage() {
  desktop_validate_pkg_platform "$DESKTOP_PKG_PLATFORM" || exit 1
  case "$DESKTOP_PKG_PLATFORM" in
    macArm)
      DESKTOP_STAGE_OS=Darwin
      DESKTOP_STAGE_ARCH=arm64
      DESKTOP_RUST_TARGET=aarch64-apple-darwin
      DESKTOP_TAURI_BUNDLES=app,dmg
      ;;
    macIntel)
      DESKTOP_STAGE_OS=Darwin
      DESKTOP_STAGE_ARCH=x86_64
      DESKTOP_RUST_TARGET=x86_64-apple-darwin
      DESKTOP_TAURI_BUNDLES=app,dmg
      ;;
    win)
      DESKTOP_STAGE_OS=Windows
      DESKTOP_STAGE_ARCH=x86_64
      DESKTOP_RUST_TARGET=x86_64-pc-windows-msvc
      DESKTOP_TAURI_BUNDLES=nsis
      ;;
  esac

  local f icon_paths=()
  for f in "${_DESKTOP_ICON_FILE_NAMES[@]}"; do
    icon_paths+=("icons/$f")
  done
  DESKTOP_ICON_PATHS=$(IFS=,; echo "${icon_paths[*]}")
  export DESKTOP_TAURI_BUNDLES DESKTOP_ICON_PATHS
}

desktop_stage_is_windows() {
  case "$DESKTOP_STAGE_OS" in
    MINGW* | MSYS* | CYGWIN* | Windows*) return 0 ;;
    *) return 1 ;;
  esac
}

desktop_resolve_cmd_platform() {
  if desktop_stage_is_windows; then
    echo "$DESKTOP_CMD_SRC/windows"
  else
    echo "$DESKTOP_CMD_SRC/macos"
  fi
}

desktop_sfx_target() {
  if desktop_stage_is_windows; then
    echo "$DESKTOP_BUILD_DIR/fastapp.exe"
  else
    echo "$DESKTOP_BUILD_DIR/fastapp"
  fi
}

desktop_check_rust_target() {
  local target=$1
  if ! command -v rustup >/dev/null 2>&1; then
    echo "未找到 rustup，请手动安装 Rust 工具链" >&2
    return 1
  fi
  if ! rustup target list --installed | grep -q "^${target}\$"; then
    echo "未安装 Rust target: $target" >&2
    echo "请手动执行: rustup target add $target" >&2
    return 1
  fi
  return 0
}

desktop_check_win_cross_compile() {
  local host_os
  host_os=$(uname -s)
  case "$host_os" in
    Darwin)
      ;;
    MINGW* | MSYS* | CYGWIN* | Windows*)
      return 0
      ;;
    *)
      echo "当前主机 ($host_os) 不支持打 Windows 包" >&2
      return 1
      ;;
  esac

  desktop_check_rust_target x86_64-pc-windows-msvc || return 1

  if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
    return 0
  fi
  if command -v cargo-xwin >/dev/null 2>&1; then
    return 0
  fi
  if [ -f "$HOME/.cargo/config.toml" ] && grep -q x86_64-pc-windows-msvc "$HOME/.cargo/config.toml" 2>/dev/null; then
    return 0
  fi

  echo "macOS 交叉编译 Windows 需要以下之一：" >&2
  echo "  - brew install mingw-w64（提供 x86_64-w64-mingw32-gcc）" >&2
  echo "  - cargo install cargo-xwin，并在 .cargo/config.toml 配置 linker" >&2
  return 1
}
