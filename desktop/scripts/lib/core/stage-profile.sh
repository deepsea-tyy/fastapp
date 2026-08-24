# dev/build profile + DESKTOP_FORCE 统一强制重建门控。

desktop_stage_is_dev() {
  case "${DESKTOP_STAGE_PROFILE:-build}" in
    dev) return 0 ;;
    *) return 1 ;;
  esac
}

desktop_force_stage() {
  desktop_env_truthy "${DESKTOP_FORCE:-0}"
}

desktop_should_build() {
  local artifact_path="$1"

  if desktop_force_stage; then
    return 0
  fi
  case "${DESKTOP_STAGE_PROFILE:-build}" in
    build) return 0 ;;
  esac
  if [ ! -f "$artifact_path" ]; then
    return 0
  fi
  return 1
}

desktop_should_sync_ui() {
  local admin_built="${1:-0}"

  if desktop_force_stage; then
    return 0
  fi
  case "${DESKTOP_STAGE_PROFILE:-build}" in
    build) return 0 ;;
  esac
  if [ "$admin_built" -eq 1 ]; then
    return 0
  fi
  if [ ! -f "$DESKTOP_UI_DIR/index.html" ]; then
    return 0
  fi
  return 1
}

desktop_should_rebuild_icons() {
  local logo_abs="$1"
  local icons_dir="$DESKTOP_ROOT/src-tauri/icons"
  local icon_marker="$icons_dir/icon.png"

  if desktop_force_stage; then
    return 0
  fi
  case "${DESKTOP_STAGE_PROFILE:-build}" in
    build) return 0 ;;
  esac
  if ! desktop_icons_complete; then
    return 0
  fi
  if [ "$logo_abs" -nt "$icon_marker" ]; then
    return 0
  fi
  return 1
}

desktop_data_staged() {
  local ffmpeg_name=ffmpeg
  if desktop_stage_is_windows; then
    ffmpeg_name=ffmpeg.exe
  fi
  [ -f "$DESKTOP_STORAGE_STAGE/fastapp.sqlite" ] \
    && [ -f "$DESKTOP_CMD_STAGE/$ffmpeg_name" ]
}

desktop_should_sync_data() {
  if desktop_force_stage; then
    return 0
  fi
  case "${DESKTOP_STAGE_PROFILE:-build}" in
    build) return 0 ;;
  esac
  if desktop_data_staged; then
    return 1
  fi
  return 0
}
