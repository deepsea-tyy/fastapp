# 日志与审计

## `AccessSlog`

[`access_log.go`](../internal/app/middleware/access_log.go)：请求结束打 **slog Info**（`http`）。**全路径**含 `/admin/*`、`/api/*`、静态、健康检查。

字段：`method`、`path`、`status`（**HTTP 状态**；业务码看 body **`code`**）、`duration_ms`、`request_id`（同 **`X-Request-Id`**）、`user_id`（[`UserID`](../internal/app/middleware/auth_jwt.go)）。

## `RequestHeader`

未带 **`X-Request-Id`** 则生成并写入响应头 + context。**`middleware.RequestID(c)`** 读取。

## `AdminOperationLog`

[`operation_log.go`](../internal/app/middleware/operation_log.go)：**异步**写 **`user_admin_operation_log`**。**路径以 `/api/` 开头 → 整段跳过**（不写库、不 peek body）。

记录条件：`Deps`+`DB` 可用、`UserID≠0`、HTTP **2xx**、路径 **`/admin/*`** 或 **`/attachment/*`** 或 **`/system/*`**、方法 **POST/PUT/PATCH/DELETE**；排除 **`/admin/passport/*`**。

`service_name`：优先 **`CtxMenuPerm`**，否则 `METHOD + path 末段`。`request_params`：Query + JSON body；敏感键 `password`、`token`、`secret` 等脱敏。

列表/删除：**`/admin/user-operation-log/list`**、`DELETE /admin/user-operation-log`（[`endpoints.go`](../internal/app/router/endpoints.go)）。

**相关**：[HTTP · 中间件](http.md#middleware) · [鉴权](auth-and-permission.md)
