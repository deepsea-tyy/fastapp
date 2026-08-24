# phar:build 在镜像目录执行，不修改 server/ 源码。

_PHAR_EXCLUDES=(
  'storage'
  'runtime'
  '.DS_Store'
  'test.json'
  'tests'
)

desktop_phar_mirror() {
  echo "==> mirror server -> $DESKTOP_PHAR_SRC"
  rm -rf "$DESKTOP_PHAR_SRC"
  mkdir -p "$DESKTOP_PHAR_SRC"
  local -a args=(-a)
  local x
  for x in "${_PHAR_EXCLUDES[@]}"; do
    args+=(--exclude "$x")
  done
  rsync "${args[@]}" "$DESKTOP_SERVER_SRC/" "$DESKTOP_PHAR_SRC/"
}

desktop_phar_prune_dirs() {
  echo "==> prune web/docs/database from phar mirror (skip vendor)"
  find "$DESKTOP_PHAR_SRC" -path "$DESKTOP_PHAR_SRC/vendor" -prune -o \
    -type d \( -iname web -o -iname docs -o -iname database \) -prune -print0 \
    | while IFS= read -r -d '' d; do rm -rf "$d"; done
}

desktop_stamp_plugin_install_locks() {
  echo "==> stamp plugin install.lock (baked into phar)"
  find "$DESKTOP_PHAR_SRC/plugin" -name config.json | while read -r config; do
    touch "$(dirname "$config")/install.lock"
  done
}

desktop_build_phar() {
  mkdir -p "$DESKTOP_WORK_DIR"
  rm -f "$DESKTOP_PHAR"

  desktop_phar_mirror
  desktop_phar_prune_dirs
  desktop_stamp_plugin_install_locks

  echo "==> phar:build"
  cd "$DESKTOP_PHAR_SRC"
  php -d phar.readonly=Off bin/hyperf.php phar:build --name="$DESKTOP_PHAR"

  if [ ! -f "$DESKTOP_PHAR" ]; then
    echo "phar 构建失败: $DESKTOP_PHAR" >&2
    return 1
  fi

  rm -rf "$DESKTOP_PHAR_SRC"

  echo "==> phar ready: $DESKTOP_PHAR"
}

desktop_ensure_phar() {
  if [ ! -f "$DESKTOP_PHAR" ]; then
    desktop_build_phar || return 1
  fi

  if [ ! -f "$DESKTOP_PHAR" ]; then
    echo "phar 不存在: $DESKTOP_PHAR" >&2
    return 1
  fi
}
