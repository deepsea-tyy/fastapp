# WebSocket 与 Redis 契约

Go 实现在 `redis_ws.go`、`server.go`、`connection_manager.go`。

## 键名（常量）

| 键模式 | 类型 | 含义 |
|--------|------|------|
| `ws:fd:user:{fd}` | String | fd → user_id（整型字符串）或访客 `bind_key` |
| `ws:user:fds:{user_id}` | Set | 用户/访客标识 → 多个 fd（字符串） |
| `ws:connections:info` | Hash | fd → JSON（user_id、connect_time、ip、user_agent、device_type、last_ping_time） |
| `ws:stats:total` | String | 当前总连接数 |
| `ws:lock:fd:{fd}` | String | fd 级分布式锁（SET NX + Lua 释放） |

## 消息帧 JSON

- 字段：`action`、`data`（对象）、`op_id`（字符串）。
- 内置 `action`：`ping` / `heartbeat`（更新 `last_ping_time`）、`login`、`visitor.bind_fd`。
- 需登录的业务 action：`userID` 须为 Redis 中可解析为正整数的数值字符串（纯数字）；访客绑定键（非纯数字）只能走 `visitor.*`。

## 响应 / 推送 JSON

- 请求响应：`success`、`failure` 形态见 [`response.go`](response.go)（`success`、`op_id`、`message`、`data`、`timestamp`）。
- 推送：`message` 为 `"push"`，`data` 含 `event` 与业务字段（同名字段以业务为准）。

## JWT 黑名单（HTTP）

刷新 token 等场景会把旧 JWT 写入 Redis：`SET {CACHE_PREFIX}{整段 token}`，与 `internal/app/common` 中 `tools.Service` 一致。

## 进程内 Hub

同进程 HTTP 如需推送 WS，使用 `deps.Deps.WSHub`（`*websocket.Hub`），与 `ListenAndServe` 传入的 hub 为同一实例。

## 连接管理与统计

[`connection_manager.go`](connection_manager.go) 提供：

- `GetConnectionsList` / `GetConnectionStats` / `GetConnectionInfo` / `IsConnectionExists`
- `GetBatchUserOnlineStatus`
- `FixConnectionStats`（`ws:stats:total` ← `HLEN(ws:connections:info)`）
- `ClearAllConnections`（扫描删除 `ws:user:fds:*`、`ws:fd:user:*`、`ws:lock:fd:*`、房间相关前缀等）

本地运维 CLI（需 `.env` 中 Redis）：`go run ./cmd/cli ws stats`、`ws fix-stats`、`ws list`、`ws online`、`ws clear --yes`。

## 插件业务 action

- 示例客服：HTTP [`plugin/ds/sysKefu/src/http/`](../../plugin/ds/sysKefu/src/http/)（根目录 `config.go` 与 admin/api handler）；WS [`plugin/ds/sysKefu/src/websocket/register.go`](../../plugin/ds/sysKefu/src/websocket/register.go)。常用 action：`kefu_message_send` / `kefu_message_read` / `kefu_message_end`、`visitor.kefu_message_send`、`visitor.kefu_message_end`。
- [`plugin/plugin.go`](../../plugin/plugin.go) 的 `BindingWS(loaded)` 按已安装插件顺序组装注册表。

## 登录失败

Token 无效时先响应错误，再 **约 3 秒** 关闭 WebSocket（见 [`server.go`](server.go)）。
