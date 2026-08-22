#!/bin/bash
set -euo pipefail

PLATFORM="${1:-}"
if [ -z "$PLATFORM" ]; then
  echo "usage: $(basename "$0") <macArm|macIntel|win>" >&2
  exit 1
fi

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"

export DESKTOP_PKG_PLATFORM="$PLATFORM"
desktop_init

case "$DESKTOP_PKG_PLATFORM" in
  macArm | macIntel)
    desktop_check_rust_target "$DESKTOP_RUST_TARGET" || exit 1
    ;;
  win)
    desktop_check_win_cross_compile || exit 1
    ;;
esac

export CI=1

echo "==> tauri build platform=$DESKTOP_PKG_PLATFORM target=$DESKTOP_RUST_TARGET bundles=$DESKTOP_TAURI_BUNDLES"
echo "    stage dir: $DESKTOP_BUILD_DIR"

cd "$DESKTOP_ROOT"
pnpm exec tauri build --target "$DESKTOP_RUST_TARGET" --bundles "$DESKTOP_TAURI_BUNDLES" --ci

BUNDLE_DIR="$DESKTOP_ROOT/src-tauri/target/$DESKTOP_RUST_TARGET/release/bundle"
echo "==> build done"
echo "    stage:   $DESKTOP_BUILD_DIR"
echo "    bundle:  $BUNDLE_DIR"
