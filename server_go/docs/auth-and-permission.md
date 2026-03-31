# 鉴权与权限

## 路由上的三种 `Kind`

[`router.Endpoint.Auth`](../internal/app/router/endpoints.go)：

| `Kind` | 含义 |
|--------|------|
| **`KindPublic`** | 无需 JWT（如登录、验证码、refresh） |
| **`KindAdminJWT`** | 管理端 **access token**（`JWT_SECRET` 场景）；可再叠加 **`MenuPerm`** |
| **`KindAPIJWT`** | App 端 **access token**（`JWT_API_SECRET` 场景） |

[`registerCoreRoutes`](../internal/app/router/engine.go) 组装中间件（在全局链之后）：

- **公开**：仅业务 handler。
- **管理端**：`RequireAdminJWT` →（若 `MenuPerm` 非空）`RequireAdminMenuPerm` → handler。
- **App API**：`RequireAPIJWT` → handler；**不存在**菜单权限中间件，`Endpoint.MenuPerm` 对 **`KindAPIJWT` 无效**（应留空）。若误填，启动注册路由时会 **`slog.Warn`**，且仍不会挂载 `RequireAdminMenuPerm`。

若未配置对应 JWT（`d.JWT` / `d.JWTAPI` 为 nil），相关路由**不会注册**（例如未配 API JWT 则不放需 `KindAPIJWT` 的路由）。

## HTTP 头中的 Token

[`RequireAdminJWT` / `RequireAPIJWT`](../internal/app/middleware/auth_jwt.go) 从请求头读取：

```http
Authorization: Bearer <access_token>
```

缺失、解析失败、或列入黑名单时，返回 **HTTP 200** + 业务 **`code` 401**（`invalid token` / `token revoked` 等），并 **`c.Abort()`**。

JWT 未启用（`jwt not configured` / `jwt api not configured`）时为 **HTTP 200** + `response.Fail(...)`。

## 当前用户 ID

解析成功后，用户 ID 存入 Gin：`c.Set(middleware.CtxUserID, uid)`。

业务中取用户 ID： **`middleware.UserID(c)`**（未登录或公开路由为 `0`）。常量键名：**`middleware.CtxUserID`**（值为 `"jwt_user_id"`）。

## 菜单权限 `MenuPerm`

- `Endpoint.MenuPerm` 必须与**菜单表** **`menu.name`** 一致（与 seeders / **`gen crud`** 生成的菜单 SQL 对齐）。
- **插件**：`menu.name` 应以插件路径推导的前缀开头（**`org/plugin` → `org:plugin`**，大小写与目录一致），否则 **`plugin uninstall`** 无法按前缀删除该插件菜单；规则与示例见 [插件体系 · 菜单 name](plugins.md#plugin-menu-names)。
- [`RequireAdminMenuPerm`](../internal/app/middleware/permission.go)：在已通过管理端 JWT 后，查询当前用户是否具备该 `menu.name`。
- **超级管理员**：角色 `code = SuperAdmin` 时**直接放行**。
- 否则通过 `role_belongs_menu` / `user_belongs_role` 等关联判定。
- 无权限：**HTTP 200** + **`code=403`**（`CodeForbidden`），`message` 为 `forbidden`（可再走 i18n 默认键）。
- 校验通过后：`c.Set(middleware.CtxMenuPerm, menuName)`，供[操作日志](observability.md) 作为 `service_name`。

`MenuPerm` 为空字符串时**不校验菜单**，仅要求已登录（仍走 `RequireAdminJWT`）。

## 黑名单

`ParseAccess` 若返回 **`tools.ErrBlacklisted`**，响应文案为 **`token revoked`**。logout 等场景会向黑名单写入 access token。

## 配置

密钥与环境变量见 [配置](configuration.md)（`JWT_SECRET`、`JWT_API_SECRET`）。登录与 Token 发放在 [`internal/app/http/admin`](../internal/app/http/admin) 等 handler 中实现，路由表见 [`endpoints.go`](../internal/app/router/endpoints.go)。

## 相关文档

- [路由](routing.md)：`Endpoint` 与插件合并
- [API 约定](api-conventions.md)：401 / 403 与响应体
