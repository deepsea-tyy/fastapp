# swoole-cli：使用 desktop/cmd 下预编译 swoole 目录（仅构建期使用）。

desktop_glob_one_dir() {
  local pattern=$1
  local matches=()
  local match

  shopt -s nullglob
  for match in $pattern; do
    if [ -d "$match" ]; then
      matches+=("$match")
    fi
  done
  shopt -u nullglob

  if [ "${#matches[@]}" -eq 0 ]; then
    return 1
  fi

  if [ "${#matches[@]}" -gt 1 ]; then
    echo "警告: 多个 swoole 目录匹配 $pattern，使用 ${matches[0]}" >&2
  fi

  echo "${matches[0]}"
}

desktop_swoole_bundle_glob() {
  local platform
  platform=$(desktop_resolve_cmd_platform)

  if desktop_stage_is_windows; then
    echo "$platform/swoole-*-cygwin-x64"
    return 0
  fi

  case "$DESKTOP_STAGE_ARCH" in
    arm64 | aarch64) echo "$platform/swoole-cli-*-arm64" ;;
    x86_64) echo "$platform/swoole-cli-*-x64" ;;
    *) return 1 ;;
  esac
}

desktop_swoole_bundle_hint() {
  if desktop_stage_is_windows; then
    echo "desktop/cmd/windows/swoole-v5.1.8-cygwin-x64/"
    return 0
  fi

  case "$DESKTOP_STAGE_ARCH" in
    arm64 | aarch64) echo "desktop/cmd/macos/swoole-cli-v5.1.8-arm64/" ;;
    x86_64) echo "desktop/cmd/macos/swoole-cli-v5.1.8-x64/" ;;
    *) echo "desktop/cmd/macos/swoole-cli-v5.1.8-<arch>/" ;;
  esac
}

desktop_resolve_swoole_bundle() {
  local pattern bundle
  pattern=$(desktop_swoole_bundle_glob) || return 1
  bundle=$(desktop_glob_one_dir "$pattern") || return 1
  echo "$bundle"
}

desktop_resolve_swoole_cli() {
  local bundle cli

  bundle=$(desktop_resolve_swoole_bundle) || return 1

  if desktop_stage_is_windows; then
    cli="$bundle/bin/swoole-cli.exe"
  else
    cli="$bundle/swoole-cli"
  fi

  if [ ! -f "$cli" ]; then
    return 1
  fi

  echo "$cli"
}

desktop_resolve_pack_sfx() {
  local bundle pack_sfx

  bundle=$(desktop_resolve_swoole_bundle) || {
    echo "$DESKTOP_PACK_SFX"
    return 0
  }

  if desktop_stage_is_windows; then
    pack_sfx="$bundle/bin/pack-sfx.php"
  else
    pack_sfx="$bundle/pack-sfx.php"
  fi

  if [ -f "$pack_sfx" ]; then
    echo "$pack_sfx"
    return 0
  fi

  echo "$DESKTOP_PACK_SFX"
}

desktop_ensure_swoole_cli() {
  local cli hint

  cli=$(desktop_resolve_swoole_cli) || {
    hint=$(desktop_swoole_bundle_hint)
    echo "未找到 swoole 预编译包，请放置到 $hint" >&2
    return 1
  }

  echo "$cli"
}
