#!/bin/bash
set -euo pipefail

_scripts_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$_scripts_dir/lib/common.sh"
desktop_init

BRAND_FILE="$DESKTOP_ROOT/brand.json"
if [ ! -f "$BRAND_FILE" ]; then
  echo "brand.json 不存在: $BRAND_FILE" >&2
  exit 1
fi

echo "==> sync brand from $BRAND_FILE"

LOGO_REL=$(node -e "
const b = require('$BRAND_FILE');
for (const k of ['name','logo','identifier','dataDir']) {
  if (!b[k] || typeof b[k] !== 'string') {
    console.error('brand.json 缺少字段: ' + k);
    process.exit(1);
  }
}
console.log(b.logo);
")

LOGO_ABS="$DESKTOP_ROOT/$LOGO_REL"
if [ ! -f "$LOGO_ABS" ]; then
  echo "logo 不存在: $LOGO_ABS" >&2
  exit 1
fi

mkdir -p "$DESKTOP_BUILD_DIR"
cp "$BRAND_FILE" "$DESKTOP_BUILD_DIR/brand.json"

export DESKTOP_ROOT
node <<'NODE'
const fs = require('fs');
const path = require('path');

const desktopRoot = process.env.DESKTOP_ROOT;
const brand = JSON.parse(fs.readFileSync(path.join(desktopRoot, 'brand.json'), 'utf8'));
const { name, identifier } = brand;

const tauriConfPath = path.join(desktopRoot, 'src-tauri/tauri.conf.json');
const tauriConf = JSON.parse(fs.readFileSync(tauriConfPath, 'utf8'));
tauriConf.productName = name;
tauriConf.identifier = identifier;
if (tauriConf.app?.windows?.[0]) {
  tauriConf.app.windows[0].title = name;
}
fs.writeFileSync(tauriConfPath, JSON.stringify(tauriConf, null, 2) + '\n');

const capsPath = path.join(desktopRoot, 'src-tauri/capabilities/default.json');
const caps = JSON.parse(fs.readFileSync(capsPath, 'utf8'));
caps.description = `${name} desktop capabilities`;
fs.writeFileSync(capsPath, JSON.stringify(caps, null, 2) + '\n');

const splashPath = path.join(desktopRoot, 'splash/index.html');
let splash = fs.readFileSync(splashPath, 'utf8');
splash = splash.replace(/<title>[^<]*<\/title>/, `<title>${name}</title>`);
splash = splash.replace(/<h1>[^<]*<\/h1>/, `<h1>${name}</h1>`);
fs.writeFileSync(splashPath, splash);

console.log(`brand synced: name=${name} identifier=${identifier} dataDir=${brand.dataDir}`);
NODE

echo "==> generate icons from $LOGO_ABS"
(cd "$DESKTOP_ROOT" && pnpm tauri icon "$LOGO_ABS")

echo "==> brand sync done"
