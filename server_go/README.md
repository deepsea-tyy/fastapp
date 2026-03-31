# FastApp 服务端（Go）

**本目录即可作为独立 Git 仓库**；`go.mod` 的 module 为 **`fastapp`**（与应用名一致），import 路径形如 `fastapp/internal/...`（与磁盘文件夹名是否为 `server_go` 无关）。

**FastApp 服务端（Go）**：HTTP + WebSocket、**统一 JSON**（`code` / `message` / `data`）、**插件目录 + `install.lock`**。路由与中间件均为显式 Go 代码（无注解驱动路由、不含 Swagger 生成）。容器化另议。

- 已挂载路由以 [`internal/app/router/endpoints.go`](internal/app/router/endpoints.go) 为准（[`engine.go`](internal/app/router/engine.go) 内 `registerCoreRoutes`）

## 文档导航

| 文档 | 说明 |
|------|------|
| [快速开始](docs/quick-start.md) | 环境、迁移与启动、默认账户、拆仓与 CLI 入口 |
| [配置](docs/configuration.md) | 环境变量、附件存储（sys_storage） |
| [核心功能与架构](docs/core-features.md) | 设计取向、进程依赖、WebSocket 概述、响应与 Redis 约定 |
| [框架结构](docs/framework-structure.md) | 目录树与按层职责 |
| [请求流程与扩展](docs/flows.md) | 路由边界、请求链路、典型扩展步骤 |
| [中间件](docs/middleware.md) | 全局 Gin 中间件顺序、鉴权拼装说明 |
| [路由](docs/routing.md) | `Endpoint`、核心与插件合并、`config.go` |
| [MVC 与分层](docs/mvc.md) | Controller / Service / Model 职责 |
| [验证器使用](docs/validators.md) | `binding` 标签、`BindJSONOr422`、错误文案 |
| [API 约定](docs/api-conventions.md) | 统一 JSON、`code` 常量、`response` 与 snake_case |
| [鉴权与权限](docs/auth-and-permission.md) | JWT（admin/api）、`MenuPerm`、上下文用户 ID |
| [Deps 与 HandlerCtx](docs/deps.md) | `Deps` 字段、`DBx`、`Bind`、nil 行为 |
| [国际化](docs/i18n.md) | `Accept-Language`、`i18n.T`、与 `response` 联动 |
| [WebSocket](docs/websocket.md) | 消息格式、login、插件 `RegisterWS` |
| [日志与审计](docs/observability.md) | `AccessSlog`、`X-Request-Id`、管理端操作日志 |
| [插件](docs/plugins.md) | 目录约定、HTTP/WS、`config.go`、数据库与 seeders 规范 |
| [命令行（CLI）](docs/cli.md) | `plugin` / `migrate` / `gen` / `ws` 全量说明与参数 |
| [代码生成器](docs/code-generator.md) | **`gen crud`**：model、前端、handler、**路由表源码尾部追加** 等见 [说明](docs/code-generator.md#gen-crud-manual-steps)；命令参数见 [CLI](docs/cli.md) |

HTTP 与 WS 协议差异见 [WebSocket](docs/websocket.md)；**Redis 键约定** [internal/websocket/redis_contract.md](internal/websocket/redis_contract.md)。
