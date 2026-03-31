# 中间件

HTTP 使用 **Gin**；全局链路与 [`internal/app/router/engine.go`](../internal/app/router/engine.go) 一致。

**管理端**与 **`/api/*`** 共用同一条 Gin **全局前置链**。**`AccessSlog` 对全部路径打点（含 `/api/*`）**；**`AdminOperationLog` 仅 `/api/*` 整段跳过**（不写操作审计）。`RequestHeader`、`Translation`、`CORS` 等全站生效。**菜单权限**只挂在 **`KindAdminJWT`**，App **`KindAPIJWT`** 不使用。

## 全局顺序（`registerCoreRoutes` 之前，所有命中 Gin 的请求）

1. `gin.Recovery`
2. `middleware.AdminOperationLog`（**`/api/*` 整段跳过**；其余管理域路径按规则落库，见 [日志与审计](observability.md)）
3. `middleware.RequestRouteContext`
4. `middleware.RequestHeader`（含 `X-Request-Id`，**全站**）
5. `middleware.Translation`（**全站**）
6. `middleware.ValidatorHook`
7. `middleware.CORS`
8. `middleware.AccessSlog`（**全路径**，含 `/api/*`）

其后注册静态路由；若 `cfg.Deps != nil`，再 **`registerCoreRoutes`**：按 `Kind` 挂载**逐路由**鉴权（见下节）。**`MenuPerm` 仅出现在 `KindAdminJWT`**，见 [鉴权与权限](auth-and-permission.md)。

## Admin 与 App（逐路由，在 `registerCoreRoutes`）

| `Kind` | 中间件链（在全局链之后） |
|--------|--------------------------|
| **`KindPublic`** | 仅 handler。 |
| **`KindAdminJWT`** | `RequireAdminJWT` →（若 `Endpoint.MenuPerm` 非空）`RequireAdminMenuPerm` → handler。 |
| **`KindAPIJWT`** | `RequireAPIJWT` → handler。**无** `MenuPerm`、**无** `RequireAdminMenuPerm`。 |

实现位于 [`internal/app/middleware`](../internal/app/middleware)、[`registerCoreRoutes`](../internal/app/router/engine.go)。

## ValidatorHook

[`middleware.ValidatorHook`](../internal/app/middleware/validator.go) 当前为占位（`c.Next()`）；业务校验勿依赖此项，请在 handler 内使用 [验证器](validators.md)。

**`AccessSlog` / `AdminOperationLog` / `RequestHeader`** 的字段与落库规则见 [日志与审计](observability.md)。
