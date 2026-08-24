#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_desktop_root=$(cd "$_scripts_dir/.." && pwd)

desktop_tauri_build() {
  local platform="${1:-}"
  if [ -z "$platform" ]; then
    echo "usage: pnpm tauri build <macArm|macIntel|win>" >&2
    echo "  macArm   aarch64-apple-darwin  (.app + .dmg)" >&2
    echo "  macIntel x86_64-apple-darwin  (.app + .dmg)" >&2
    echo "  win      x86_64-pc-windows-msvc (NSIS)" >&2
    exit 1
  fi

  # shellcheck source=lib/common.sh
  source "$_scripts_dir/lib/common.sh"

  export DESKTOP_PKG_PLATFORM="$platform"
  desktop_init

  case "$DESKTOP_PKG_PLATFORM" in
    macArm | macIntel)
      desktop_check_rust_target "$DESKTOP_RUST_TARGET" || exit 1
      ;;
    win)
      desktop_check_win_cross_compile || exit 1
      ;;
  esac

  desktop_clean_build_artifacts

  bash "$_scripts_dir/stage.sh" build

  local open_after_build=false
  desktop_open_after_build && open_after_build=true

  # DMG 打包始终走 --skip-jenkins（CI=true），避免 Finder AppleScript 在本地失败。
  # DESKTOP_OPEN_AFTER_BUILD 只控制打包完成后是否 open 安装包，不再 unset CI。
  export CI=true
  unset TAURI_BUNDLER_DMG_IGNORE_CI 2>/dev/null || true

  echo "==> tauri build platform=$DESKTOP_PKG_PLATFORM target=$DESKTOP_RUST_TARGET bundles=$DESKTOP_TAURI_BUNDLES"
  echo "    stage dir: $DESKTOP_BUILD_DIR"
  if $open_after_build; then
    echo "    open after build: on"
  else
    echo "    open after build: off"
  fi

  cd "$DESKTOP_ROOT"
  if $open_after_build; then
    pnpm exec tauri build --target "$DESKTOP_RUST_TARGET" --bundles "$DESKTOP_TAURI_BUNDLES"
  else
    pnpm exec tauri build --target "$DESKTOP_RUST_TARGET" --bundles "$DESKTOP_TAURI_BUNDLES" --ci
  fi

  echo "==> build done"
  echo "    stage:   $DESKTOP_BUILD_DIR"
  echo "    bundle:  $(desktop_bundle_dir)"

  if $open_after_build; then
    desktop_open_bundle_artifact || true
  fi
}

case "${1:-}" in
  build)
    shift
    desktop_tauri_build "${1:-}"
    ;;
  dev)
    bash "$_scripts_dir/stage.sh" dev
    cd "$_desktop_root" && exec pnpm exec tauri dev
    ;;
  *)
    cd "$_desktop_root" && exec pnpm exec tauri "$@"
    ;;
esac
