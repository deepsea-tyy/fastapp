# 鉴权与权限

## 路由 `Kind`

[`Endpoint.Auth`](../internal/app/router/endpoints.go)：

| `Kind` | 含义 |
|--------|------|
| **`KindPublic`** | 无 JWT |
| **`KindAdminJWT`** | 管理端 access（`JWT_SECRET`）；可再叠 **`MenuPerm`** |
| **`KindAPIJWT`** | App access（`JWT_API_SECRET`） |

[`registerCoreRoutes`](../internal/app/router/engine.go) 在全局中间件之后：

- **公开**：仅 handler。
- **Admin**：`RequireAdminJWT` →（`MenuPerm` 非空）`RequireAdminMenuPerm` → handler。
- **App API**：`RequireAPIJWT` → handler；**无**菜单权限。若误设 `MenuPerm`，会 **`slog.Warn`** 且仍不会挂 `RequireAdminMenuPerm`。

**与「是否注册路由」的区别**：

- **`KindAPIJWT`** 且 **`d.JWTAPI == nil`**：该条路由**不注册**（`continue`）。
- **`KindAdminJWT`** 且 **`d.JWT == nil`**：路由**仍会注册**，请求命中时返回 **`jwt not configured`**（HTTP 200 + `response.Fail`）。

## Token 请求头

[`RequireAdminJWT` / `RequireAPIJWT`](../internal/app/middleware/auth_jwt.go)：

```http
Authorization: Bearer <access_token>
```

失败：多为 HTTP **200** + 业务 **`code` 401**（`invalid token` / `token revoked` 等），`c.Abort()`。JWT 未启用：`jwt not configured` / `jwt api not configured`。

## 当前用户

`c.Set(middleware.CtxUserID, uid)`。业务取 **`middleware.UserID(c)`**（未登录 → `0`）。键：**`middleware.CtxUserID`**（`"jwt_user_id"`）。

## `MenuPerm`

- 与表 **`menu.name`** 一致（种子 / `gen crud` SQL 对齐）。
- 插件菜单名需 [`org/plugin` → 前缀 `org:plugin`](plugins.md#plugin-menu-names)，否则 **`plugin uninstall`** 删不全。
- [`RequireAdminMenuPerm`](../internal/app/middleware/permission.go)：JWT 通过后查菜单；**超级管理员**角色直过；否则无权限 → HTTP 200 + **`code=403`**。
- `MenuPerm` 为空：只要求已登录（Admin JWT）。
- 通过后：`c.Set(middleware.CtxMenuPerm, …)`，供 [操作日志](observability.md)。

## 黑名单

`ParseAccess` 返回 **`ErrBlacklisted`** → 文案 **`token revoked`**。

## 配置与实现

密钥见 [配置](configuration.md)。登录与发放在 [`internal/app/http/admin`](../internal/app/http/admin) 等；路由表 [`endpoints.go`](../internal/app/router/endpoints.go)。

**相关**：[用户体系与 App API](user-system.md) · [HTTP 文档 · 路由](http.md#routing) · [HTTP 文档 · API 约定](http.md#api-conventions)
