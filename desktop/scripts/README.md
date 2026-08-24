# desktop/scripts

用户向说明见 [../README.md](../README.md)。

## 调用关系

```text
pnpm dev / pnpm build <平台>
        └── tauri.sh
              ├── dev   → stage.sh dev → tauri dev
              └── build → clean → stage.sh build → tauri build

stage.sh
  [1] tauri-conf → stage/tauri-conf.sh
  [2] ui         → stage/ui.sh
  [3] runtime    → stage/runtime.sh (desktop_stage_runtime)
  [4] data       → stage/data.sh
```

## 入口

| 脚本 | 职责 |
|------|------|
| [`tauri.sh`](tauri.sh) | `dev` / `build <macArm\|macIntel\|win>` / 透传 `tauri` |
| [`stage.sh`](stage.sh) | bundle 编排；profile `dev` \| `build` |

## lib

| 目录 / 文件 | 职责 |
|-------------|------|
| [`common.sh`](lib/common.sh) | 统一 `source` 入口 |
| **core/** | 路径、平台、bundle 常量、门控、server/.env |
| [`core/paths.sh`](lib/core/paths.sh) | `desktop_init`、路径、clean、open-after-build |
| [`core/platform.sh`](lib/core/platform.sh) | 平台解析、Rust target、`DESKTOP_TAURI_BUNDLES` / `DESKTOP_BUNDLE_TARGETS` / `DESKTOP_ICON_PATHS` |
| [`core/stage-profile.sh`](lib/core/stage-profile.sh) | dev/build 门控（见下表） |
| [`core/server-env.sh`](lib/core/server-env.sh) | 从 `server/.env` 读 `APP_PORT` / `APP_WS_PORT` |
| **stage/** | stage 四步实现 |
| [`stage/tauri-conf.sh`](lib/stage/tauri-conf.sh) + [`sync-tauri-conf.mjs`](lib/stage/sync-tauri-conf.mjs) | `tauri.conf.json`：端口、bundle.resources、splash、icons |
| [`stage/fonts.sh`](lib/stage/fonts.sh) | 校验 `admin/public/font/alibaba-pu-hui-ti-3/`（见目录 README）；MSDF → `scripts/font/gen-bitmap-font.mjs` |
| [`stage/ui.sh`](lib/stage/ui.sh) | admin build + rsync → `ui/` |
| [`stage/runtime.sh`](lib/stage/runtime.sh) | phar → fastapp SFX |
| [`stage/phar.sh`](lib/stage/phar.sh) | phar 镜像（含 `server/.env`；排除 storage/runtime）→ prune `web`/`docs`/`database` |
| [`stage/data.sh`](lib/stage/data.sh) | cmd / storage（sqlite、languages、空 uploads） |
| **vendor/** | 构建依赖 |
| [`vendor/ffmpeg.sh`](lib/vendor/ffmpeg.sh) / [`vendor/swoole-cli.sh`](lib/vendor/swoole-cli.sh) | ffmpeg / swoole 预编译包 |
| [`vendor/pack-sfx.php`](lib/vendor/pack-sfx.php) | swoole 包内无 `pack-sfx.php` 时的 fallback |

## 门控（`core/stage-profile.sh`）

| 步骤 | 函数 | dev 跳过条件 |
|------|------|-------------|
| tauri-conf | — | 永不跳过 |
| icons | `desktop_should_rebuild_icons` | 齐全且 logo 未变 |
| admin | `desktop_should_build` | `admin/dist/index.html` 存在 |
| ui rsync | `desktop_should_sync_ui` | admin 未重建且 `ui/index.html` 存在 |
| fastapp SFX | `desktop_should_build` | `fastapp` 存在 |
| data | `desktop_should_sync_data` | staged 目录已有 sqlite + ffmpeg |

`build` profile 对上述可跳过步骤一律重建。`DESKTOP_FORCE=1` 在 dev 下等同强制重建（tauri-conf 不受 profile 影响，本就每次执行）。
