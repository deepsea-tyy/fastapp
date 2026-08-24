import fs from 'fs';
import path from 'path';

const desktopRoot = process.env.DESKTOP_ROOT;
const buildRoot = process.env.DESKTOP_BUILD_REL;
const platform = process.env.DESKTOP_PKG_PLATFORM;
const appPort = parseInt(process.env.DESKTOP_APP_PORT, 10);
const appWsPort = parseInt(process.env.DESKTOP_APP_WS_PORT, 10);
const bundleTargetsRaw = process.env.DESKTOP_BUNDLE_TARGETS;
const iconPathsRaw = process.env.DESKTOP_ICON_PATHS;

if (!Number.isFinite(appPort) || !Number.isFinite(appWsPort)) {
  console.error('APP_PORT / APP_WS_PORT 无效');
  process.exit(1);
}

let bundleTargets;
try {
  bundleTargets = JSON.parse(bundleTargetsRaw);
} catch {
  console.error('DESKTOP_BUNDLE_TARGETS 无效');
  process.exit(1);
}

const iconPaths = iconPathsRaw ? iconPathsRaw.split(',') : [];
if (iconPaths.length === 0) {
  console.error('DESKTOP_ICON_PATHS 无效');
  process.exit(1);
}

const tauriConfPath = path.join(desktopRoot, 'src-tauri/tauri.conf.json');
const tauriConf = JSON.parse(fs.readFileSync(tauriConfPath, 'utf8'));

const desktop = tauriConf.plugins?.desktop || {};
for (const k of ['dataDir', 'logo']) {
  if (!desktop[k] || typeof desktop[k] !== 'string') {
    console.error('tauri.conf.json plugins.desktop 缺少字段: ' + k);
    process.exit(1);
  }
}

const logoAbs = path.join(desktopRoot, desktop.logo);
if (!fs.existsSync(logoAbs)) {
  console.error('logo 不存在: ' + logoAbs);
  process.exit(1);
}

if (!tauriConf.productName || !tauriConf.identifier) {
  console.error('tauri.conf.json 缺少 productName 或 identifier');
  process.exit(1);
}

tauriConf.plugins = tauriConf.plugins || {};
tauriConf.plugins.desktop = {
  ...desktop,
  appPort,
  appWsPort,
};

const name = tauriConf.productName;
if (tauriConf.app?.windows?.[0]) {
  tauriConf.app.windows[0].title = name;
}

const fastappName = platform === 'win' ? 'fastapp.exe' : 'fastapp';
tauriConf.bundle.resources = {
  [`${buildRoot}${fastappName}`]: `bundled/${fastappName}`,
  [`${buildRoot}ui/`]: 'bundled/ui/',
  [`${buildRoot}cmd/`]: 'bundled/cmd/',
  [`${buildRoot}storage/`]: 'bundled/storage/',
};
tauriConf.bundle.targets = bundleTargets;
tauriConf.bundle.icon = iconPaths;
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

console.error(
  `tauri.conf synced: productName=${name} dataDir=${desktop.dataDir} appPort=${appPort} appWsPort=${appWsPort}`,
);
console.log(desktop.logo);
