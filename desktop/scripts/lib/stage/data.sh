# cmd / storage → build/<platform>/

desktop_stage_data() {
  if desktop_should_sync_data; then
    mkdir -p "$DESKTOP_CMD_STAGE" "$DESKTOP_STORAGE_STAGE"

    if desktop_stage_is_windows; then
      cp "$DESKTOP_FFMPEG_SRC" "$DESKTOP_CMD_STAGE/ffmpeg.exe"
      cp "$DESKTOP_FFPROBE_SRC" "$DESKTOP_CMD_STAGE/ffprobe.exe"
    else
      cp "$DESKTOP_FFMPEG_SRC" "$DESKTOP_CMD_STAGE/ffmpeg"
      cp "$DESKTOP_FFPROBE_SRC" "$DESKTOP_CMD_STAGE/ffprobe"
      chmod +x "$DESKTOP_CMD_STAGE/"*
    fi

    rsync -a "$DESKTOP_SERVER_SRC/storage/languages/" "$DESKTOP_STORAGE_STAGE/languages/"

    if [ ! -f "$DESKTOP_SERVER_SRC/storage/fastapp.sqlite" ]; then
      echo "server/storage/fastapp.sqlite 不存在，请先初始化数据库" >&2
      return 1
    fi
    cp "$DESKTOP_SERVER_SRC/storage/fastapp.sqlite" "$DESKTOP_STORAGE_STAGE/fastapp.sqlite"
    rm -rf "$DESKTOP_STORAGE_STAGE/uploads"
    mkdir -p "$DESKTOP_STORAGE_STAGE/uploads"
  else
    echo "    skip data sync (profile=dev; artifacts present)"
  fi
}
