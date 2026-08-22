# phar:build 在镜像目录执行，不修改 server/ 源码。依赖 desktop_init 后的 DESKTOP_SERVER_SRC、DESKTOP_PHAR_SRC。

_PHAR_EXCLUDES=(
  'storage'
  'runtime'
  'plugin/*/Database'
  'plugin/*/docs'
  'plugin/*/web'
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
