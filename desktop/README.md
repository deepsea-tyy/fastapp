# FastApp Desktop

Tauri **胖包** + CDN 仅下载 phar。安装包内含 ui、tools、cmd（7z 压缩）；首次启动 7z 解压到 AppData，仅 `fastapp.phar` 从 CDN 拉取。

> **唯一入口**：桌面相关代码只在本目录 `desktop/`。不要 clone Tauri 官方源码到仓库；使用 `pnpm tauri` / `@tauri-apps/*` 即可。

## 目录

```
desktop/
├── splash/          # 内置启动页（seed + 下载 server）
├── bundle/          # 构建 staging 产物（gitignore，由 script 生成）
├── src-tauri/       # Rust：manifest、下载、seed、Hyperf/tools 启停、GPU 仲裁
└── ARCHITECTURE.md  # 架构说明
```

平台二进制统一放在仓库根目录 [`cmd/`](../cmd/)。

## 打包桌面安装包

```bash
# 1. 构建 admin UI
cd admin && pnpm build

# 2. 确认 cmd/ 下有所需平台二进制（swoole、uv、ffmpeg、7zz）

# 3. 打 Tauri 安装包（自动执行 desktop-bundle-stage.sh）
cd desktop && pnpm install && pnpm tauri build
```

可选：`DESKTOP_BUILD_ADMIN=1 pnpm tauri build` 会在 staging 前自动 `pnpm build` admin。

## 发布 CDN（仅 phar）

```bash
chmod +x script/desktop-publish.sh
DESKTOP_CDN_BASE=https://your-cdn.example.com/fastapp script/desktop-publish.sh
```

产物在 `dist/desktop-cdn/`：`server-{version}.zip` + `manifest.json`，上传至 CDN。

默认 manifest URL 在 `src-tauri/src/manifest.rs` 的 `DEFAULT_MANIFEST_URL`，上线前请修改。

## 组件来源

| 组件 | 来源 | 说明 |
|------|------|------|
| cmd | 安装包 | php/swoole、uv、ffmpeg → AppData `cmd/` |
| ui | 安装包 | `admin/dist` → AppData `ui/`（扁平，无 dist 子目录） |
| tools | 安装包 | `tools/` 源码；模型按需下载 |
| server | CDN | `fastapp.phar` + `plugin/` |

用户数据：

- macOS：`~/Library/Application Support/FastApp/`
- Windows：`%APPDATA%/FastApp/`

## 硬件检查

启动时 `get_hardware_report` 分层检测 **basic**（编辑器/音频）与 **sdxl**（资产生图），详见 [ARCHITECTURE.md](./ARCHITECTURE.md#硬件检查) 与 [模型选型](../server/plugin/ds/storyStudio/docs/模型选型.md#产品档位)。

## 开发

```bash
# 需先 staging（tauri dev 会自动跑 beforeDevCommand）
cd admin && pnpm build

cd desktop && pnpm install && pnpm tauri dev
```

## 相关

- [架构说明](./ARCHITECTURE.md)
- [manifest schema](../cdn/manifest.schema.json)
- [根目录 README](../README.md)
