# 日志与审计

## 1. `AccessSlog`（访问日志）

[`middleware.AccessSlog`](../internal/app/middleware/access_log.go) 在请求结束后打一条 **结构化日志**（标准库 **`log/slog`**，级别 **Info**，消息 **`http`**）。**`/admin/*`、`/api/*`、静态、健康检查等全部路径**都会打点（与 **`AdminOperationLog`** 不同，后者不写 `/api/*`）。

每条日志含：

| 字段 | 含义 |
|------|------|
| `method` | HTTP 方法 |
| `path` | 请求路径 |
| `status` | **写入的 HTTP 状态码**（注意：多数业务 JSON 仍 200，以 body 内 `code` 为准） |
| `duration_ms` | 耗时（毫秒） |
| `request_id` | 与 **`X-Request-Id`** 一致（见下） |
| `user_id` | [`middleware.UserID(c)`](../internal/app/middleware/auth_jwt.go)；未鉴权为 0 |

用于排障与粗粒度 QPS/延迟观察；不包含请求体。

## 2. `RequestHeader` / `X-Request-Id`

[`middleware.RequestHeader`](../internal/app/middleware/request.go)：若客户端未传 **`X-Request-Id`**，则生成随机 ID 并 **回写响应头** 与 **`c.Set(CtxRequestID, …)`**。读取：**`middleware.RequestID(c)`**。

## 3. `AdminOperationLog`（管理端操作审计）

[`middleware.AdminOperationLog`](../internal/app/middleware/operation_log.go)：**异步**写入表 **`user_admin_operation_log`**。**`Path` 以 `/api/` 开头时整段中间件直接 `Next()`**，与 App 端隔离（不写库、不读 body）。

### 何时记录

- **`d == nil` 或 `d.DB == nil`**：直接跳过。
- **`UserID(c) == 0`**：跳过（未登录）。
- **HTTP 状态**：**非 2xx** 不写入。
- **路径与方法**：仅 **`/admin/*`**、**`/attachment/*`**、**`/system/*`**，且方法为 **POST / PUT / PATCH / DELETE**。
- **排除**：**`/admin/passport/*`**（登录等不落库）；`/admin/passport` 的 JSON body 也不会被 peek。

### 记录内容

- **用户**：根据 `UserID` 查 **`user.username`**。
- **路由**：`c.FullPath()`，空则用真实 path。
- **`service_name`**：优先 **`CtxMenuPerm`**（与路由 **`MenuPerm`** 一致）；否则启发式为 **`METHOD + 路径最后一段`**。
- **`request_params`**：Query + 解析到的 JSON body 合并；敏感键 **`password`、`token`、`secret` 等** 会被替换为 **`***`**。

实现细节见 **`peekJSONBody` / `mergeOpParams` / `sanitizeOpParams`**。

### 查询与清理

管理端列表与删除接口路由见 [`endpoints.go`](../internal/app/router/endpoints.go)：`/admin/user-operation-log/list`、`DELETE /admin/user-operation-log`（需对应菜单权限）。

## 相关文档

- [鉴权与权限](auth-and-permission.md)：`CtxUserID`、`MenuPerm`
- [中间件](middleware.md)：全局中间件顺序
- [deps](deps.md)：`DBx` 与 `Deps` 为空行为
