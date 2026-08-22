# desktop/scripts

入口与交叉编译见 [../README.md](../README.md)；管线见 [../../code/05-桌面打包链路.md](../../code/05-桌面打包链路.md)。CDN 热更新见 [`publish-cdn.sh`](publish-cdn.sh)。

## 脚本

| 脚本 | 职责 |
|------|------|
| [`tauri.sh`](tauri.sh) | 包装 CLI：`build <平台>` → `build-tauri.sh`；其余透传 `tauri` |
| [`build-tauri.sh`](build-tauri.sh) | 平台检测、交叉编译校验、`tauri build --target --bundles --ci` |
| [`sync-brand.sh`](sync-brand.sh) | 读取 `brand.json`，同步名称/logo 到 Tauri/splash/icons |
| [`desktop.sh`](desktop.sh) | 入口：`phar \| sfx \| stage`（调试用，无平台参数） |
| [`stage.sh`](stage.sh) | 编排：sync-brand → admin → ffmpeg → sfx → bundle |
| [`sfx.sh`](sfx.sh) | swoole-cli + `pack-sfx.php` → `build/<platform>/server/fastapp` |
| [`phar.sh`](phar.sh) | 镜像 rsync + 系统 php `phar:build` |
| [`publish-cdn.sh`](publish-cdn.sh) | phar zip + `manifest.json`（非安装包） |

## lib/

| 文件 | 职责 |
|------|------|
| [`paths.sh`](lib/paths.sh) | 路径常量；`DESKTOP_PKG_PLATFORM` → `build/<platform>/` |
| [`platform.sh`](lib/platform.sh) | 平台映射、Rust target、bundles、交叉编译检测 |
| [`ffmpeg.sh`](lib/ffmpeg.sh) | 按目标平台下载/解析 ffmpeg |
| [`swoole-cli.sh`](lib/swoole-cli.sh) | 按目标平台解析 swoole 预编译目录 |
| [`phar-mirror.sh`](lib/phar-mirror.sh) | rsync 镜像 server |
| [`pack-sfx.php`](lib/pack-sfx.php) | phar 拼接进 swoole-cli 单文件 |
