#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"
desktop_init

stamp_plugin_install_locks() {
  echo "==> stamp plugin install.lock (baked into phar)"
  find "$DESKTOP_PHAR_SRC/plugin" -name config.json | while read -r config; do
    touch "$(dirname "$config")/install.lock"
  done
}

mkdir -p "$DESKTOP_WORK_DIR"
rm -f "$DESKTOP_PHAR"

desktop_phar_mirror
stamp_plugin_install_locks

echo "==> phar:build"
cd "$DESKTOP_PHAR_SRC"
php -d phar.readonly=Off bin/hyperf.php phar:build --name="$DESKTOP_PHAR"

if [ ! -f "$DESKTOP_PHAR" ]; then
  echo "phar 构建失败: $DESKTOP_PHAR" >&2
  exit 1
fi

echo "==> phar ready: $DESKTOP_PHAR"
