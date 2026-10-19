# swoole-cli + phar → 单文件 fastapp（build 根目录）

_runtime_lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../vendor/ffmpeg.sh
source "$_runtime_lib_dir/../vendor/ffmpeg.sh"
# shellcheck source=../vendor/swoole-cli.sh
source "$_runtime_lib_dir/../vendor/swoole-cli.sh"
# shellcheck source=phar.sh
source "$_runtime_lib_dir/phar.sh"

desktop_build_sfx() {
  local bundle swoole_cli pack_sfx sfx_target

  echo "==> build phar"
  if desktop_force_stage; then
    desktop_build_phar || return 1
  else
    desktop_ensure_phar || return 1
  fi

  desktop_ensure_swoole_cli || return 1
  swoole_cli=$DESKTOP_SWOOLE_CLI
  bundle=$DESKTOP_SWOOLE_BUNDLE

  pack_sfx=$(desktop_pack_sfx_for_bundle "$bundle")
  if [ ! -f "$pack_sfx" ]; then
    echo "pack-sfx.php 不存在: $pack_sfx" >&2
    return 1
  fi

  sfx_target=$(desktop_sfx_target)
  rm -f "$sfx_target"

  echo "==> pack SFX ($swoole_cli)"
  "$swoole_cli" "$pack_sfx" "$DESKTOP_PHAR" "$sfx_target"

  if desktop_stage_is_windows; then
    local runtime_dir="$bundle/bin"
    if [ -d "$runtime_dir" ]; then
      echo "==> copy Windows runtime libs"
      local f base
      for f in "$runtime_dir"/*; do
        base=$(basename "$f")
        if [ "$base" = "swoole-cli.exe" ]; then
          continue
        fi
        cp -a "$f" "$DESKTOP_BUILD_DIR/"
      done
    fi
  fi

  if ! desktop_env_truthy "${DESKTOP_KEEP_PHAR:-0}"; then
    rm -f "$DESKTOP_PHAR"
  fi

  echo "==> SFX ready: $sfx_target"
}

desktop_stage_runtime() {
  desktop_ensure_ffmpeg || return 1

  if desktop_should_build "$(desktop_sfx_target)"; then
    echo "    build SFX (phar + fastapp)"
    desktop_build_sfx
  else
    echo "    skip SFX (profile=$DESKTOP_STAGE_PROFILE; DESKTOP_FORCE=1 to rebuild)"
  fi

  local sfx_target
  sfx_target=$(desktop_sfx_target)
  if [ ! -f "$sfx_target" ]; then
    echo "fastapp 不存在: $sfx_target" >&2
    return 1
  fi
}
