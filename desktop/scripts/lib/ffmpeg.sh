# ffmpeg/ffprobe：缺失时自动下载到 desktop/cmd（仅构建期使用）。

desktop_resolve_ffmpeg() {
  local platform
  platform=$(desktop_resolve_cmd_platform)
  if [ -z "$platform" ]; then
    return 1
  fi
  case "$DESKTOP_STAGE_OS" in
    MINGW* | MSYS* | CYGWIN* | Windows*)
      DESKTOP_FFMPEG_SRC="$platform/ffmpeg.exe"
      DESKTOP_FFPROBE_SRC="$platform/ffprobe.exe"
      ;;
    *)
      DESKTOP_FFMPEG_SRC="$platform/ffmpeg"
      DESKTOP_FFPROBE_SRC="$platform/ffprobe"
      ;;
  esac
}

desktop_ffmpeg_release_tag() {
  echo "${DESKTOP_FFMPEG_VERSION:-latest}"
}

desktop_ffmpeg_archive_name() {
  case "$DESKTOP_STAGE_OS" in
    Darwin)
      case "$DESKTOP_STAGE_ARCH" in
        arm64 | aarch64) echo "ffmpeg-master-latest-macosarm64-gpl.zip" ;;
        x86_64) echo "ffmpeg-master-latest-macos64-gpl.zip" ;;
        *) return 1 ;;
      esac
      ;;
    MINGW* | MSYS* | CYGWIN* | Windows*)
      echo "ffmpeg-master-latest-win64-gpl.zip"
      ;;
    *)
      return 1
      ;;
  esac
}

desktop_ffmpeg_download_url() {
  local mirror=${1:-${DESKTOP_FFMPEG_MIRROR:-github}}
  local tag archive

  tag=$(desktop_ffmpeg_release_tag) || return 1
  archive=$(desktop_ffmpeg_archive_name) || return 1

  if [ "$mirror" = china ]; then
    echo "https://ghfast.top/https://github.com/BtbN/FFmpeg-Builds/releases/download/${tag}/${archive}"
  else
    echo "https://github.com/BtbN/FFmpeg-Builds/releases/download/${tag}/${archive}"
  fi
}

desktop_ffmpeg_fetch_file() {
  local dest=$1
  local mirror url

  for mirror in $(if [ "${DESKTOP_FFMPEG_MIRROR:-}" = china ]; then echo china github; else echo github china; fi); do
    url=$(desktop_ffmpeg_download_url "$mirror") || continue
    echo "    download ($mirror): $url" >&2
    if curl -fSL --http1.1 --retry 3 --retry-delay 2 --connect-timeout 30 -o "$dest" "$url"; then
      return 0
    fi
    rm -f "$dest"
  done

  echo "ffmpeg 下载失败，可设置 DESKTOP_FFMPEG_MIRROR=china 后重试" >&2
  return 1
}

desktop_install_ffmpeg() {
  local platform ffmpeg_src ffprobe_src archive work_dir extracted
  local ffmpeg_bin ffprobe_bin

  platform=$(desktop_resolve_cmd_platform) || return 1
  desktop_resolve_ffmpeg || return 1
  ffmpeg_src="$DESKTOP_FFMPEG_SRC"
  ffprobe_src="$DESKTOP_FFPROBE_SRC"

  work_dir="$DESKTOP_WORK_DIR/ffmpeg-fetch"
  archive="$work_dir/archive.zip"
  extracted="$work_dir/extracted"

  rm -rf "$work_dir"
  mkdir -p "$work_dir" "$platform"

  desktop_ffmpeg_fetch_file "$archive" || return 1
  mkdir -p "$extracted"
  unzip -qo "$archive" -d "$extracted"

  case "$DESKTOP_STAGE_OS" in
    MINGW* | MSYS* | CYGWIN* | Windows*)
      ffmpeg_bin=$(find "$extracted" -name ffmpeg.exe -type f | head -1)
      ffprobe_bin=$(find "$extracted" -name ffprobe.exe -type f | head -1)
      ;;
    *)
      ffmpeg_bin=$(find "$extracted" -name ffmpeg -type f ! -name '*.exe' | head -1)
      ffprobe_bin=$(find "$extracted" -name ffprobe -type f ! -name '*.exe' | head -1)
      ;;
  esac

  if [ -z "$ffmpeg_bin" ] || [ -z "$ffprobe_bin" ]; then
    echo "ffmpeg 解压结果异常: $extracted" >&2
    return 1
  fi

  cp -f "$ffmpeg_bin" "$ffmpeg_src"
  cp -f "$ffprobe_bin" "$ffprobe_src"
  chmod +x "$ffmpeg_src" "$ffprobe_src"
  if [ "$DESKTOP_OS" = Darwin ]; then
    xattr -d com.apple.quarantine "$ffmpeg_src" 2>/dev/null || true
    xattr -d com.apple.quarantine "$ffprobe_src" 2>/dev/null || true
  fi
}

desktop_ensure_ffmpeg() {
  desktop_resolve_ffmpeg || {
    echo "不支持的构建平台: $DESKTOP_STAGE_OS $DESKTOP_STAGE_ARCH" >&2
    return 1
  }

  if [ -f "$DESKTOP_FFMPEG_SRC" ] && [ -f "$DESKTOP_FFPROBE_SRC" ]; then
    return 0
  fi

  echo "==> fetch ffmpeg -> $DESKTOP_FFMPEG_SRC" >&2
  desktop_install_ffmpeg || return 1

  if [ ! -f "$DESKTOP_FFMPEG_SRC" ] || [ ! -f "$DESKTOP_FFPROBE_SRC" ]; then
    echo "ffmpeg 安装失败" >&2
    return 1
  fi
}
