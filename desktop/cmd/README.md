# desktop/cmd

桌面打包用的**源二进制**（大文件见 `.gitignore`）。

| 路径 | 内容 |
|------|------|
| `macos/` | macOS swoole-cli 预编译包 |
| `windows/` | Windows swoole 预编译包 |
| `*/ffmpeg*` | 首次 stage 由 [`ffmpeg.sh`](../scripts/lib/ffmpeg.sh) 自动下载 |

stage 复制到安装包的产物在 `build/<platform>/cmd/`。平台选择见 [../README.md](../README.md)。
