# Deps 与 HandlerCtx

## `deps.Deps`

[`internal/app/common/deps/deps.go`](../internal/app/common/deps/deps.go) 聚合 HTTP 层依赖：

| 字段 | 说明 |
|------|------|
| **`Config`** | 已加载的 `config.Config`（含 DB/Redis/JWT 等） |
| **`DB`** | `*gorm.DB`；MySQL 未配置或连接失败时可能为 nil |
| **`RDB`** | `*redis.Client`；Redis 失败时可能为 nil |
| **`JWT`** | 管理端 `JWTProvider`（`JWT_SECRET`） |
| **`JWTAPI`** | App 端 `JWTProvider`（`JWT_API_SECRET`） |
| **`UploadDir`** | 本地附件根目录；与 Gin `Static("/uploads", …)` 一致 |
| **`WSHub`** | 可选；HTTP 与 WS 同进程时注入，供业务向连接推送（如 sysKefu） |

### `DBx(c *gin.Context)`

带 **当前请求的 `context`** 的 DB 会话，便于 GORM 与**路由上下文**关联（需配合 `middleware.RequestRouteContext`）。**`d` 或 `d.DB` 为 nil 时返回 nil**，调用方需判断。

## `HandlerCtx`

```go
type HandlerCtx struct {
	D *Deps
	C *gin.Context
}
```

用于**插件或核心**里书写 **`func(h *deps.HandlerCtx)`**，避免每层手动闭包捕获 `d`。

### `deps.Bind`

```go
func Bind(d *deps.Deps, fn func(*HandlerCtx)) gin.HandlerFunc
```

路由表里常见写法：`Handler: func(d *deps.Deps) gin.HandlerFunc { return deps.Bind(d, SomeHandler) }`，其中 `SomeHandler` 为 `func(h *deps.HandlerCtx)`。

在 `HandlerCtx` 内：

- 取 DB：**`h.D.DBx(h.C)`**
- 取用户 ID：**`middleware.UserID(h.C)`**
- 写响应：**`response.JSON(h.C, status, r)`**

## `Deps` 何时为 nil

[`router.New`](../internal/app/router/engine.go) 在 MySQL 未就绪时仍启动 Gin，但 **`cfg.Deps == nil`**：**不执行** `registerCoreRoutes`，仅保留 `/`、`/health`、静态资源等。此时无 JWT 业务路由。

中间件 **`AdminOperationLog`** 在 `Deps` 为 nil 或 `DB` 为 nil 时会跳过落库逻辑。

## 与 MVC 的关系

见 [MVC 与分层](mvc.md)。`JWTProvider` 接口也在 `deps` 包声明，实现位于 `internal/app/common`（`tools.Service`）。
