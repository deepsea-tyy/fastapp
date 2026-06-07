# FastApp 项目说明

FastApp 是一个企业级全栈应用框架，包含移动端、Web端、后台管理系统、企业官网和后端服务。

## 项目结构

```
fastapp/
├── server/          # 后端服务（Hyperf 3.1 + Swoole）
├── server_go/       # 后端服务（Go + Gin）
├── admin/           # 后台管理系统前端（Vue3 + TypeScript + Element Plus）
├── app/             # 客户端应用（Tauri：[tauri-apps/tauri](https://github.com/tauri-apps/tauri)）
├── website/         # 企业官网（Nuxt.js 4.2）
├── tools/           # 本地工具：HF 模型下载、Python 服务进程管理（main.py）
└── docs/            # 项目文档
```

说明：**admin** 在本仓库指「后台管理系统」——目录 `admin/` 为其前端工程；Go/PHP 服务端对应的 HTTP 前缀一般为 `/admin/*`（管理端接口）。

## 各模块说明

### app
基于 [Tauri](https://github.com/tauri-apps/tauri) 的客户端：Web 技术栈构建界面，Rust 编写原生壳与系统能力，体积与资源占用相对可控。开发与构建以工程内 `app/` 目录为准。

更多信息（文档、入门）：[tauri.app](https://tauri.app/)

### admin
后台管理系统的前端应用，基于 Vue3 + TypeScript + Element Plus 构建，代码位于 `admin/`。

详细文档：[后台管理系统文档](docs/admin/开发指南.md)

### server
后端服务目录

基于 Hyperf 3.1 + Swoole 构建的高性能后端服务，提供 API 接口、WebSocket 服务、权限管理、代码生成等功能。

详细文档请查看：[server 文档](docs/server/getting-started/开发指南.md)

### server_go
Go 版后端（HTTP / WebSocket、插件、统一 JSON）。**文档索引与导航**见：[server_go/README.md](server_go/README.md)；入门可直接看 [快速开始](server_go/docs/quick-start.md)。

#### 项目结构

```
fastapp/
├── server/          # 后端服务
│   ├── app/         # 应用代码（Controller、Service、Repository、Model）
│   ├── config/      # 配置文件
│   ├── databases/   # 数据库迁移和种子文件
│   ├── plugin/      # 插件目录
│   ├── runtime/     # 运行时文件（日志、缓存）
│   └── storage/     # 存储目录（上传文件、多语言、Swagger）
├── admin/           # 后台管理系统前端
├── app/             # Tauri 客户端应用
└── website/         # 企业官网
```

#### 代码架构

采用分层架构设计：

```
Controller → Service → Repository → Model
   HTTP      业务逻辑    数据操作   数据模型
```

**命名规范**：
- 文件：`UserController.php`、`UserService.php`、`UserRepository.php`
- 目录：使用 PascalCase，按业务模块划分

### website
企业官网，基于 Nuxt.js 4.2 构建，支持 SSR/SSG、SEO 优化、国际化等功能。

详细文档：[website 文档](docs/website/企业官网.md)

### tools
本地辅助脚本，与主业务后端解耦：

- **`main.py`**：服务启停 `start`/`stop`/`restart`/`status`、清理运行日志 `clear`、按服务名下载模型 `download`（依赖见 `tools/README.md` 的 `uv sync`）。

说明见 **[tools/README.md](tools/README.md)**。

## 技术栈

- **后端**: Hyperf 3.1 + Swoole + PHP 8.1+
- **后台管理系统前端**: Vue3 + TypeScript + Element Plus + Pinia（`admin/`）
- **客户端（app）**: [Tauri](https://github.com/tauri-apps/tauri)（Web 前端 + Rust；系统 WebView 渲染）
- **官网**: Nuxt.js 4.2 + Vue3 + TypeScript
- **数据库**: MySQL + Redis
- **本地工具（tools）**: Python（HF 下载、venv）；见 [tools/README.md](tools/README.md)

## 快速开始

### 后端服务
```bash
cd server && composer install && cp .env.example .env && php bin/hyperf.php start
```

### 后台管理系统（admin）
```bash
cd admin && pnpm install && pnpm dev
```

### 客户端应用（Tauri）
```bash
cd app && pnpm install && pnpm tauri dev
```

（若项目使用 npm / yarn，将 `pnpm` 换成对应命令；需已安装 [Tauri 系统依赖](https://tauri.app/start/prerequisites/)。）

### 企业官网
```bash
cd website && pnpm install && pnpm dev
```

### 本地 tools（可选）
详见 [tools/README.md](tools/README.md)。

```bash
cd tools && cp .env.example .env   # 填写 HF_TOKEN 等
uv sync
```

## 项目特点

- 🚀 **高性能**: 基于 Swoole 协程，支持高并发
- 🔐 **权限管理**: 完整的 RBAC 权限系统
- 🤖 **AI 辅助**: AI 模板开发，智能代码生成
- 📱 **跨平台客户端**: Tauri 支持桌面（及移动路线）打包分发
- 🎨 **现代化 UI**: Vue3 + Element Plus 构建美观的管理界面
- 🔌 **插件系统**: 灵活的插件扩展机制

## 相关文档

- [本地 AI 与运维工具（tools）](tools/README.md)
- [Go 服务端（server_go）](server_go/README.md) · [快速开始](server_go/docs/quick-start.md)
- [后端服务文档](docs/server/getting-started/开发指南.md)
- [后台管理系统文档](docs/admin/开发指南.md)
- [Tauri 仓库](https://github.com/tauri-apps/tauri) · [Tauri 官方文档](https://tauri.app/)
- [企业官网文档](docs/website/企业官网.md)

## 技术支持

- **作者**：deepsea
- **联系方式**：https://t.me/deepsea159
- **框架版本**：Hyperf 3.1

## ☕ 给我一杯咖啡

如果这个项目对你有帮助，欢迎请我喝一杯咖啡！

<div align="center">
  <img src="docs/assets/wechat_qr.png" alt="微信收款码" width="300" />
</div>

