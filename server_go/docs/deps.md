# Deps 与 HandlerCtx

## `deps.Deps`

[`deps.go`](../internal/app/common/deps/deps.go) 聚合 HTTP 依赖：

| 字段 | 说明 |
|------|------|
| **`Config`** | `config.Config` |
| **`DB`** | `*gorm.DB`；未配置库或无从连接时，`main` 里通常整体无 `Deps` |
| **`RDB`** | `*redis.Client`，可 nil |
| **`JWT`** / **`JWTAPI`** | 管理端 / App 的 `JWTProvider`，可 nil |
| **`UploadDir`** | 本地附件根，与 Gin `Static("/uploads", …)` 一致 |
| **`WSHub`** | 可选；HTTP 与 WS 同进程时注入，便于业务推送 |

### `DBx(c *gin.Context)`

带**当前请求 context** 的 DB 会话（配合 `RequestRouteContext`）。**`d` 或 `d.DB` 为 nil → 返回 nil**，调用方需判断。

## `HandlerCtx` 与 `deps.Bind`

```go
type HandlerCtx struct { D *Deps; C *gin.Context }
// Bind(d, func(h *HandlerCtx)) → gin.HandlerFunc
```

路由表里常见：`Handler: func(d *deps.Deps) gin.HandlerFunc { return deps.Bind(d, Xxx) }`。  
在 `HandlerCtx` 内：`h.D.DBx(h.C)`、`middleware.UserID(h.C)`、`response.JSON(h.C, …)`。

## `Deps` 何时为 nil

**`DB_DATABASE` 未配置**时 `main` 不构造 `Deps`，**[`router.New`](../internal/app/router/engine.go)** 只挂占位路由，**不执行** `registerCoreRoutes`。  
**`registerCoreRoutes` 内**若 `d == nil || d.DB == nil` 也会跳过核心/插件业务路由（防御性）。

**`AdminOperationLog`**：`Deps` 或 `DB` 为 nil 时跳过落库。

## 相关

[HTTP · MVC](http.md#mvc) · `JWTProvider` 实现在 `internal/app/common`（`tools.Service`）
