# desktop/cmd

桌面打包用的**源二进制**目录（不进 git 的大文件见 `.gitignore`）。

## 目录

| 路径 | 内容 |
|------|------|
| `macos/` | macOS swoole-cli 预编译发行包（`swoole-cli-*-arm64` / `swoole-cli-*-x64`） |
| `windows/` | Windows swoole 预编译发行包（`swoole-*-cygwin-x64`） |
| `macos/ffmpeg`、`windows/ffmpeg.exe` 等 | 首次 stage 由 [`ffmpeg.sh`](../scripts/lib/ffmpeg.sh) 自动下载 |

## 平台选择

由 `DESKTOP_PKG_PLATFORM`（`pnpm tauri build macArm|macIntel|win`）经 [`platform.sh`](../scripts/lib/platform.sh) 派生 `DESKTOP_STAGE_OS` / `DESKTOP_STAGE_ARCH`，再决定取哪套 swoole 与 ffmpeg。

stage 复制到安装包的产物在 `desktop/build/<platform>/cmd/`。
