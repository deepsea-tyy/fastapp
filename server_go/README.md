# FastApp 服务端（Go）

可单独拆仓维护。**Gin** HTTP + WebSocket；JSON 体统一为 **`code` / `message` / `data`**（[`response.Result`](internal/app/common/response/result.go)）。插件目录 `plugin/{组织}/{插件}/`：仅当存在根级 **`config.go`** 与 **`install.lock`**，且在 [`plugin/plugin.go`](plugin/plugin.go) 里完成 **import + `RegisterHTTPEndpoints` / `RegisterWebSocket` 登记** 后，路由才会并入运行实例。

- **模块**：`go.mod` 中为 `module fastapp`，import 路径 `fastapp/...`（与磁盘文件夹是否叫 `server_go` 无关）。
- **Go 版本**：**1.25+**（以 `go.mod` 的 `go` 指令为准）。
- **路由**：以 [`internal/app/router/endpoints.go`](internal/app/router/endpoints.go) 的核心表为准，在 [`engine.go`](internal/app/router/engine.go) 的 `registerCoreRoutes` 中与插件 `Endpoint` 合并。显式 Go 代码挂载，无注解驱动路由、不生成 Swagger。

## 文档

| 分组 | 链接 |
|------|------|
| 入门 | [快速开始](docs/quick-start.md) · [框架结构](docs/framework-structure.md) · [核心功能](docs/core-features.md) |
| HTTP | [路由 · MVC · 中间件 · 流程 · API 约定 · 验证器](docs/http.md) |
| 安全与上下文 | [鉴权与权限](docs/auth-and-permission.md) · [用户体系与 App API](docs/user-system.md) · [Deps](docs/deps.md) |
| 配置与横切 | [配置](docs/configuration.md) · [国际化](docs/i18n.md) · [WebSocket](docs/websocket.md) · [日志与审计](docs/observability.md) |
| 插件与 CLI | [插件](docs/plugins.md) · [CLI](docs/cli.md) · [代码生成器](docs/code-generator.md)（含 `gen crud` 与 [手顺锚点](docs/code-generator.md)） |

WebSocket 协议说明见 [WebSocket](docs/websocket.md)。**Redis 键约定**：[internal/websocket/redis_contract.md](internal/websocket/redis_contract.md)。
