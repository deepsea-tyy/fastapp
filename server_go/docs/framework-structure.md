# 框架结构

工程根 = 含 `go.mod` 的目录，或 **`SERVER_GO_ROOT`** 指向该目录。

## 目录树

```
./
├── cmd/server/main.go       # HTTP + WS；import fastapp/plugin
├── cmd/cli/main.go          # fastapp-cli
├── internal/app/
│   ├── http/               # apphttp（user.go）、admin/*、api/user/*
│   ├── common/             # tools、jwt、deps、response、i18n
│   ├── middleware/
│   ├── router/             # engine.go、endpoints.go
│   └── service/
├── internal/cli/           # Cobra；gen/templates
├── internal/config/
├── internal/model/
├── internal/store/         # database/migrations、seeders
├── internal/websocket/
├── plugin/
│   ├── plugin.go / registry.go
│   └── ds/<org>/<插件>/    # config.go、install.lock、src/http、src/websocket、database/…
├── storage/locales/        # 核心 i18n JSON
└── docs/
```

## 按层

| 路径 | 职责 |
|------|------|
| `cmd/server` | 根目录、`LoadDotEnvForServerRoot`、`i18n.Init`、`LoadInstalled`、`router.New`、HTTP/WS。详见 [插件 · 加载](plugins.md#plugin-load-runtime)。 |
| `cmd/cli` | 注册子命令，不启动 HTTP。 |
| `internal/app/router` | **`engine.go`**：`New`、`registerCoreRoutes`；**`endpoints.go`**：`Kind`、`Endpoint`、`Endpoints()`。 |
| `internal/app/http` | Handler 工厂；**实际路径**以 [`endpoints.go`](../internal/app/router/endpoints.go) 为准。 |
| `internal/app/middleware` | CORS、JWT、菜单权限、`AccessSlog`、`AdminOperationLog`、`Translation` 等。 |
| `internal/app/common/deps` | `Deps`、`HandlerCtx`、`Bind`。 |
| `internal/app/service` | 无 Gin；菜单树、验证码等。 |
| `plugin/` | **`LoadInstalled`**、**`HTTPEndpoints`**、**`BindingWS`**、**`LoadPluginI18n`**；**禁止**插件 import `fastapp/plugin`。 |
| `internal/websocket` | 独立端口 WS；协议见 `redis_contract.md`。 |

**相关**：[HTTP · MVC](http.md#mvc) · [HTTP · 路由](http.md#routing) · [插件](plugins.md)
