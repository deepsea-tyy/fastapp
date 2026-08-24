#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"

DESKTOP_STAGE_PROFILE="${1:-${DESKTOP_STAGE_PROFILE:-build}}"
export DESKTOP_STAGE_PROFILE

desktop_init

echo "==> stage profile: $DESKTOP_STAGE_PROFILE"

echo "==> [1/4] tauri-conf"
desktop_stage_tauri_conf

echo "==> [2/4] ui"
desktop_stage_ui

echo "==> [3/4] runtime"
desktop_stage_runtime

echo "==> [4/4] data"
desktop_stage_data

echo "==> stage ready: $DESKTOP_BUILD_DIR"
