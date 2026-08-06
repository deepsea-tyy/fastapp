# FastApp 项目说明

FastApp 是一个企业级全栈应用框架，包含 Web 端、后台管理系统、桌面客户端、企业官网和后端服务。

## 项目结构

```
fastapp/
├── server/          # 后端服务（Hyperf 3.1 + Swoole）
├── desktop/         # 桌面客户端（Tauri 胖包 + CDN 仅 phar）
├── admin/           # 后台管理系统前端（Vue3 + TypeScript + Element Plus）
├── website/         # 企业官网（Nuxt.js 4.2）
├── tools/           # 本地 AI 推理服务（uv + Python）
├── cdn/             # 桌面端 manifest schema / 示例
├── script/          # 构建脚本（park.sh、desktop-publish.sh 等）
└── docs/            # 项目文档
```

说明：

- **admin**：目录 `admin/` 为管理后台**前端**；HTTP 前缀 `/admin/*` 为管理端 API。
- **desktop**：桌面端**唯一工程**；安装包内含 ui、tools、cmd（7z）；仅 `fastapp.phar` 从 CDN 下载，详见 [desktop/README.md](desktop/README.md)。

## 各模块说明

### desktop（桌面客户端）

基于 [Tauri 2](https://tauri.app) 的胖包：安装包含 ui、tools、cmd（7z 压缩）；**仅 server（phar）** 从 CDN 下载。

- 工程目录：**仅** [`desktop/`](desktop/)
- 架构与分阶段说明：见 [desktop/ARCHITECTURE.md](desktop/ARCHITECTURE.md)
- 打包：`cd admin && pnpm build` → 确认 [`cmd/`](cmd/) 平台二进制 → `cd desktop && pnpm tauri build`
- CDN 发布（仅 phar）：`script/desktop-publish.sh`

### admin

后台管理系统前端，Vue3 + TypeScript + Element Plus，代码位于 `admin/`。

详细文档：[后台管理系统文档](docs/admin/开发指南.md)

### server

基于 Hyperf 3.1 + Swoole 的后端：API、WebSocket、权限、代码生成、插件等。

详细文档：[server 文档](docs/server/getting-started/开发指南.md)

#### server 代码结构

```
server/
├── app/         # Controller、Service、Repository、Model
├── config/
├── plugin/
├── runtime/
└── storage/
```

#### 分层

```
Controller → Service → Repository → Model
```

### server_go

Go 版后端。见 [server_go/README.md](server_go/README.md)、[快速开始](server_go/docs/quick-start.md)。

### website

企业官网（Nuxt.js 4.2）。见 [website 文档](docs/website/企业官网.md)。

### tools

本地 AI 推理与进程管理，与主业务后端解耦。见 [tools/README.md](tools/README.md)。

## 技术栈

| 模块 | 技术 |
|------|------|
| 后端 | Hyperf 3.1 + Swoole + PHP 8.1+ |
| 管理前端 | Vue3 + Element Plus（`admin/`） |
| **桌面客户端** | **Tauri 2 + Rust（`desktop/`，非框架源码）** |
| 官网 | Nuxt.js 4.2 |
| AI 服务 | Python + uv（`tools/`） |

## 快速开始

### 后端

```bash
cd server && composer install && cp .env.example .env && php bin/hyperf.php start
```

### 管理后台（admin）

```bash
cd admin && pnpm install && pnpm dev
```

### 桌面客户端（desktop）

需 [Tauri 系统依赖](https://tauri.app/start/prerequisites/)。

```bash
cd desktop && pnpm install && pnpm tauri dev
```

### 官网

```bash
cd website && pnpm install && pnpm dev
```

### tools（可选）

```bash
cd tools && cp .env.example .env && uv sync
```

## 相关文档

- [桌面客户端（desktop）](desktop/README.md) · [架构说明](desktop/ARCHITECTURE.md)
- [本地 AI 工具（tools）](tools/README.md)
- [后端服务](docs/server/getting-started/开发指南.md)
- [管理后台](docs/admin/开发指南.md)
- [Tauri 官方文档](https://tauri.app/)（框架文档；本仓库应用代码在 `desktop/`）

## 技术支持

- **作者**：deepsea
- **联系方式**：https://t.me/deepsea159
- **框架版本**：Hyperf 3.1

## ☕ 给我一杯咖啡

如果这个项目对你有帮助，欢迎请我喝一杯咖啡！

<div align="center">
  <img src="docs/assets/wechat_qr.png" alt="微信收款码" width="300" />
</div>
