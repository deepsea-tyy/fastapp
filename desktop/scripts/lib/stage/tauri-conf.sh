# tauri.conf.json：桌面壳唯一配置；stage 从 server/.env 同步端口

desktop_icons_complete() {
  local icons_dir="$DESKTOP_ROOT/src-tauri/icons"
  local f
  for f in "${_DESKTOP_ICON_FILE_NAMES[@]}"; do
    if [ ! -f "$icons_dir/$f" ]; then
      return 1
    fi
  done
  return 0
}

desktop_sync_tauri_conf() {
  local stage_lib_dir

  desktop_read_server_env_port || return 1

  echo "==> sync tauri.conf.json (ports from server/.env)" >&2

  stage_lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  export DESKTOP_ROOT DESKTOP_PKG_PLATFORM DESKTOP_BUILD_REL \
    DESKTOP_APP_PORT DESKTOP_APP_WS_PORT DESKTOP_TAURI_BUNDLES DESKTOP_ICON_PATHS
  node "$stage_lib_dir/sync-tauri-conf.mjs"
}

desktop_sync_icons() {
  local logo_rel="$1"
  local logo_abs="$DESKTOP_ROOT/$logo_rel"

  if ! desktop_should_rebuild_icons "$logo_abs"; then
    echo "==> skip icons (profile=dev; unchanged)"
    return 0
  fi

  local icons_dir="$DESKTOP_ROOT/src-tauri/icons"

  echo "==> generate icons from $logo_abs"
  rm -rf "$icons_dir"
  (cd "$DESKTOP_ROOT" && pnpm exec tauri icon "$logo_abs")

  rm -rf "$icons_dir/android" "$icons_dir/ios"
  rm -f "$icons_dir/64x64.png" "$icons_dir/StoreLogo.png"
  rm -f "$icons_dir"/Square*.png
}

desktop_stage_tauri_conf() {
  local logo_rel

  logo_rel=$(desktop_sync_tauri_conf) || return 1
  desktop_sync_icons "$logo_rel"

  echo "==> tauri.conf sync done"
}
