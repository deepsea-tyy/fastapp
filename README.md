# FastApp 项目说明

FastApp 是一个企业级全栈应用框架，包含 Web 端、后台管理系统、桌面客户端、企业官网和后端服务。

## 项目结构

```
fastapp/
├── server/          # 后端服务（Hyperf 3.1 + Swoole）
├── desktop/         # 桌面客户端（Tauri + SFX）
├── admin/           # 后台管理系统前端（Vue3 + TypeScript + Element Plus）
├── website/         # 企业官网（Nuxt.js 4.2）
├── tools/           # 本地 AI 推理服务（uv + Python）
├── script/          # 通用脚本（桌面构建见 desktop/scripts/）
├── code/            # 代码知识库（见 CODE_WIKI.md）
└── docs/            # 项目文档
```

说明：

- **admin**：目录 `admin/` 为管理后台**前端**；HTTP 前缀 `/admin/*` 为管理端 API。
- **desktop**：桌面端工程，安装包含 SFX `fastapp`、ui、ffmpeg，见 [desktop/README.md](desktop/README.md)。

## 代码知识库

项目全部开发文档已整理到 `code/` 目录，共 20 个主题。**CODE_WIKI.md 是总入口路由页**：

- 👉 **[CODE_WIKI.md](CODE_WIKI.md)** — 所有技术文档的导航路由页

涵盖内容：项目架构、后端/前端分层、Story Studio 核心插件、桌面客户端、数据库设计、依赖与运行、开发规范、WebSocket、代码生成器、插件系统、数据库迁移、监听器与异步、IP 定位、权限系统（RBAC + 数据权限）、企业官网、图标使用、前端开发完整指南。

## 各模块说明

### desktop（桌面客户端）

基于 [Tauri 2](https://tauri.app)，server 为 SFX 整包（plugin 在 phar 内）。

- 工程：[`desktop/`](desktop/)
- 构建与运行时：[`desktop/README.md`](desktop/README.md)

### admin

后台管理系统前端，Vue3 + TypeScript + Element Plus，代码位于 `admin/`。

详细文档：见 [CODE_WIKI.md](CODE_WIKI.md) 中的前端架构与前端开发指南条目。

### server

基于 Hyperf 3.1 + Swoole 的后端：API、WebSocket、权限、代码生成、插件等。

详细文档：见 [CODE_WIKI.md](CODE_WIKI.md) 中的后端架构、后端开发规范、权限系统、插件系统、数据库迁移工具等条目。

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

### website

企业官网（Nuxt.js 4.2）。见 [CODE_WIKI.md](CODE_WIKI.md) 中的企业官网条目。

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
cd desktop && pnpm install && pnpm dev
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

- **[CODE_WIKI.md](CODE_WIKI.md)** — 项目全部技术文档导航路由（code/ 下 20 个主题）
- [桌面客户端（desktop）](desktop/README.md)
- [本地 AI 工具（tools）](tools/README.md)
- [Tauri 官方文档](https://tauri.app/)（框架文档；本仓库应用代码在 `desktop/`）

## 技术支持

- **作者**：deepsea
- **联系方式**：https://t.me/deepsea159
- **框架版本**：Hyperf 3.1

## ☕ 给我一杯咖啡

如果这个项目对你有帮助，欢迎请我喝一杯咖啡！

<div align="center">
  <img src="./wechat_qr.png" alt="微信收款码" width="300" />
</div>
