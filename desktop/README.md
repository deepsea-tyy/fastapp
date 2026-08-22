# FastApp Desktop

Tauri 桌面客户端：安装包含 admin UI、单文件 `fastapp`（Hyperf 业务）、ffmpeg、storage 静态资源（languages、ttc）。首次启动 seed 到 AppData，运行 `fastapp start`。

工程入口：`desktop/`。支持 **macOS**、**Windows x64**。

## 目录

```
desktop/
├── brand.json       # 应用名 / logo / identifier / dataDir（唯一配置）
├── assets/          # logo 源图（brand.json 的 logo 字段指向此处）
├── cmd/             # 构建输入：ffmpeg、swoole-cli（见 cmd/README.md）
├── scripts/         # stage 编排（见 scripts/README.md）
├── splash/          # 启动页（名称由 sync-brand 同步）
├── build/           # 中间产物（gitignore）
└── src-tauri/
```

## 品牌配置

[`brand.json`](brand.json) 为桌面壳**唯一**配置源：

| 字段 | 说明 |
|------|------|
| `name` | 显示名（窗口标题、安装包名、启动页） |
| `logo` | 源 logo 路径（相对 `desktop/`，正方形 PNG） |
| `identifier` | Tauri bundle id |
| `dataDir` | AppData 子目录名 |

打包前 [`sync-brand.sh`](scripts/sync-brand.sh) 自动同步到 `tauri.conf.json`、图标、`splash`、Rust `APP_DATA_DIR`。单独同步：`bash scripts/sync-brand.sh`。

## 构建环境（手动安装）

| 工具 | 验证 |
|------|------|
| Node.js + pnpm | `node -v`、`pnpm -v` |
| Rust（cargo） | `cargo -V` |
| Xcode CLT（macOS） | `xcode-select -p` |
| PHP 8.1+（打 phar） | `php -v` |

`ffmpeg` 由构建脚本在首次打包时自动下载到 `desktop/cmd/`。`swoole-cli` 使用 `desktop/cmd/` 下对应平台的预编译目录（见 [cmd/README.md](cmd/README.md)）。

打包前需在 `server/storage/ttc/` 放置思源黑体字体（与开发环境相同；约 53MB，不进 git）。

## 构建

```bash
cd desktop && pnpm install
pnpm tauri build macArm     # macOS Apple Silicon → .app + .dmg
pnpm tauri build macIntel   # macOS Intel → .app + .dmg
pnpm tauri build win        # Windows x64 → NSIS（macOS 上需交叉编译工具链）
```

**必须**指定平台参数；打包完成后**不会**自动打开或安装安装包。

中间产物按平台隔离：`desktop/build/<platform>/`（如 `build/macArm/`）。Tauri bundle 在 `src-tauri/target/<rust-triple>/release/bundle/`。

### 交叉编译依赖

| 打包 | `rustup target add` |
|------|---------------------|
| `macArm` | `aarch64-apple-darwin` |
| `macIntel` | `x86_64-apple-darwin` |
| `win` | `x86_64-pc-windows-msvc` |

```bash
rustup target add aarch64-apple-darwin x86_64-apple-darwin x86_64-pc-windows-msvc
```

macOS 打 `win` 另装链接器（二选一）：

```bash
brew install mingw-w64
# 或
cargo install cargo-xwin   # 并配置 ~/.cargo/config.toml linker
```

管线与环境变量见 [code/05-桌面打包链路.md](../code/05-桌面打包链路.md)；脚本索引见 [scripts/README.md](scripts/README.md)。

## 运行时

```
bundled/ui + server/fastapp + cmd + storage(languages,ttc)
  → seed → AppData
  → fastapp migrate（若无 fastapp.sqlite）
  → fastapp start :9501
  → WebView → AppData/ui/index.html
```

AppData `server/storage/`：`languages/`、`ttc/` 由安装包 seed；`fastapp.sqlite` 首次 migrate 生成；`uploads/` 空目录可写。`server/runtime/` 空目录可写（日志、pid 等运行时写入）。

macOS：`~/Library/Application Support/<dataDir>/`；Windows：`%APPDATA%/<dataDir>/`（`<dataDir>` 见 `brand.json`）

`tools/` 不进安装包。

## 开发

```bash
cd desktop && pnpm install && pnpm tauri dev
```

`tauri dev` 启动前同样自动执行 `stage.sh`（含 admin 重建）。
