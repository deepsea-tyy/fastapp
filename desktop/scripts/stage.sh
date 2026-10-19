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
# shellcheck source=lib/stage/tauri-conf.sh
source "$_scripts_dir/lib/stage/tauri-conf.sh"
desktop_stage_tauri_conf

echo "==> [2/4] ui"
# shellcheck source=lib/stage/fonts.sh
source "$_scripts_dir/lib/stage/fonts.sh"
# shellcheck source=lib/stage/ui.sh
source "$_scripts_dir/lib/stage/ui.sh"
desktop_stage_ui

echo "==> [3/4] runtime"
# shellcheck source=lib/stage/runtime.sh
source "$_scripts_dir/lib/stage/runtime.sh"
desktop_stage_runtime

echo "==> [4/4] data"
# shellcheck source=lib/stage/data.sh
source "$_scripts_dir/lib/stage/data.sh"
desktop_stage_data

echo "==> stage ready: $DESKTOP_BUILD_DIR"
