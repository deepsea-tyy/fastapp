# 框架结构

仓库根为 **含 `go.mod` 的目录**（或通过 `SERVER_GO_ROOT` 指向该目录）。以下为目录职责与主要文件说明。

## 总览树

```
./
├── cmd/
│   ├── server/main.go          # HTTP（Gin）+ WebSocket；仅 import fastapp/plugin
│   └── cli/main.go             # fastapp-cli 入口（gen / plugin 子命令）
├── internal/
│   ├── app/                    # Web 应用骨架
│   │   ├── http/              # 核心 HTTP 处理器（gin.HandlerFunc 工厂）；根包名 apphttp（避免与 net/http 混淆）
│   │   │   ├── user.go # App 注册/登录/短信/刷新令牌/重置密码/baseInfo 等（公开路由）
│   │   │   ├── admin/         # 管理端 Passport、permission、menu、attachment…
│   │   │   └── api/
│   │   │       └── user/      # App 用户（auth.go / file.go / search.go）
│   │   ├── common/            # tools、jwt、deps、response/；i18n/（embed locales）
│   │   ├── middleware/        # CORS、请求头、JWT、校验、多语言、菜单权限等
│   │   ├── router/            # engine.go（Config、New、registerCoreRoutes）；endpoints.go（Kind/Endpoint + 路由表）
│   │   └── service/           # 菜单树、验证码、数据范围、captcha 等（无 HTTP）
│   ├── cli/                    # Cobra：migrate、gen、plugin…
│   │   ├── gen/columns.go
│   │   └── templates/
│   ├── config/                 # 配置结构体与 .env 加载
│   ├── model/                  # GORM 模型（user、menu、role、配置、通知等）
│   ├── store/                  # MySQL、Redis；database/migrations|seeders（.sql）
│   └── websocket/              # WS 服务、消息注册、sysKefu stub；redis_contract.md
├── plugin/                     # plugin.go + registry.go：LoadInstalled、HTTPEndpoints、BindingWS、i18n；init 内 Register* 挂接各 ds 实现（依赖方向 plugin → ds）
│   ├── plugin.go
│   ├── registry.go             # 编译期 HTTP/WS 工厂表
│   └── ds/                     # plugin/{组织}/{插件}/：根级 config.go、install.lock；src/http、src/model、src/websocket、web、database/migrations、seeders…
│       ├── sysConfig/
│       ├── sysCms/
│       ├── sysKefu/            # 例：根 config.go + src/http、src/websocket
│       └── sysNotify/
├── bin/                        # 构建产物（server、fastapp-cli），通常不入库
├── go.mod / go.sum
├── .env / .env.example
├── README.md
└── docs/                       # 框架说明（本分目录）
```

## 按层说明

| 路径 | 职责 |
|------|------|
| `cmd/server` | 解析工程根、`LoadDotEnv`；**仅 `import fastapp/plugin`**；**[`plugin.go`](../plugin/plugin.go)** 加载时 **`init`** 已将各插件 **HTTP/WS** 登记进 **`registry`**；再 `plugin.LoadInstalled`、`LoadPluginI18n`、MySQL/Redis、`router.New`、`plugin.HTTPEndpoints`、`plugin.BindingWS`、HTTP 与 WS。详见 [插件](plugins.md#plugin-load-runtime)。 |
| `cmd/cli` | 调用 `internal/cli` 注册子命令，不启动 HTTP。 |
| `internal/app/i18n` | `T` / `Merge` / `FromGin`；词条 JSON 在工程根 `storage/locales/*.json`，启动时 `i18n.Init`（见 `cmd/server/main.go`）。 |
| `internal/app/common/response` | 统一 JSON：`Result`、`JSON`、`Stub`；业务码与 [`snake`](../internal/app/common/response/snake.go) 键名转换。 |
| `internal/app/router` | **`engine.go`**：`Config`（`Deps`、`PluginEndpoints`）、`New`、`registerCoreRoutes`（合并核心 + 插件 `Endpoint` 后挂载）。**`endpoints.go`**：`Kind`、`Endpoint` 与 `Endpoints()` 核心路由表。 |
| `internal/app/middleware` | 横切：`AdminOperationLog`、`RequestRouteContext`、[`request.go`](../internal/app/middleware/request.go)（`RequestHeader` / `RequestID`）、`Translation`、`ValidatorHook`、`CORS`、`AccessSlog`；`RequireAdminJWT` / `RequireAPIJWT`（`CtxUserID`）；[`permission.go`](../internal/app/middleware/permission.go)（`RequireAdminMenuPerm`、`UserHasMenuByName` 等）。 |
| `internal/app/common/deps`（`package deps`） | `Deps` 聚合 `config.Config`、`*gorm.DB`、`*redis.Client`、admin/api 两套 [`JWTProvider`](../internal/app/common/deps/deps.go)（实现为 `common` 的 `tools.Service`）。 |
| `internal/app/common`（`package tools`） | **`tools.go`**（`BindJSONOr422`、TOTP `Validate`/`GenerateSecret`/`ProvisioningURI`、密码与设备号、`IssueAPIToken` 等）、**`jwt.go`**（`Service` → `deps.JWTProvider`）；`verifycode` 包内单独维护 `isProd()`，避免 `tools`↔`verifycode` 循环依赖。 |
| `internal/app/http` | **`user.go`**（`package apphttp`，App 注册/登录/短信等公开路由）；另含 `admin/*`、`api/user/*` 等 `gin.HandlerFunc` 工厂，由 **`router.Endpoints`** 引用（`endpoints.go` 内 **`import apphttp "fastapp/internal/app/http"`**）；**已实现路径** 以 [`router/endpoints.go`](../internal/app/router/endpoints.go) 为准。 |
| `internal/store` | MySQL（GORM）、Redis 客户端初始化。 |
| `internal/app/service` | **服务层**：无 HTTP，可单测；跨核心 HTTP / 插件复用（菜单树、验证码、数据范围等）。详见 [MVC 与分层](mvc.md)。 |
| `internal/app/model` | GORM 模型与表前缀（`model.P` ← `DB_PREFIX`）。 |
| `plugin/` | [`plugin.go`](../plugin/plugin.go) + [`registry.go`](../plugin/registry.go)：`LoadInstalled`、**`HTTPEndpoints` / `BindingWS`**（读包内登记表）、**`init`** 中对各 **`ds/*`** 的 **`RegisterHTTPEndpoints` / `RegisterWebSocket`**、`LoadPluginI18n`。依赖方向 **`fastapp/plugin` → 插件树**，插件**禁止** import **`fastapp/plugin`**。 |
| `plugin/ds/*` | 根级 **`config.go`**（**仅常量**）/ **`install.lock`** / 可选 `readme.md`、`publish.json`；**HTTP** **`src/http/routes.go`**；**WS** **`src/websocket/`**；须在 [`plugin.go`](../plugin/plugin.go) 中 **import + `init` 登记**才会挂路由。见 [插件体系](plugins.md)。 |
| `internal/websocket` | 独立端口 WS；`registry` 注册 action；协议与 Redis 见 `redis_contract.md`。 |
| `internal/cli` | Cobra 子命令；[`internal/cli/gen`](../internal/cli/gen/columns.go) 供 `gen model` 等查表结构；[`internal/cli/templates`](../internal/cli/templates/) 为生成器模板根目录。 |
