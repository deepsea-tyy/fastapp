#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

case "${1:-}" in
  build)
    shift
    if [ $# -lt 1 ]; then
      echo "usage: pnpm tauri build <macArm|macIntel|win>" >&2
      echo "  macArm   aarch64-apple-darwin  (.app + .dmg)" >&2
      echo "  macIntel x86_64-apple-darwin  (.app + .dmg)" >&2
      echo "  win      x86_64-pc-windows-msvc (NSIS)" >&2
      exit 1
    fi
    exec bash "$_scripts_dir/build-tauri.sh" "$@"
    ;;
  *)
    cd "$_scripts_dir/.." && exec pnpm exec tauri "$@"
    ;;
esac
