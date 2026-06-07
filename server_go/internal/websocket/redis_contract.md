# WebSocket 与 Redis

实现：`redis_ws.go`、`server.go`、`connection_manager.go`。

## 键

| 模式 | 含义 |
|------|------|
| `ws:fd:user:{fd}` | fd → user_id 或访客 `bind_key` |
| `ws:user:fds:{id}` | 用户/访客标识 → fd 集合 |
| `ws:connections:info` | fd → 连接元数据 JSON |
| `ws:stats:total` | 总连接数 |
| `ws:lock:fd:{fd}` | fd 分布式锁 |

## 消息

上行：`action`、`data`、`op_id`。内置 `ping`/`heartbeat`、`login`、`visitor.bind_fd`。非访客业务：`userID` 须为 Redis 中可解析的正整数；访客走 `visitor.*`。

## 响应 / 推送

见 [`response.go`](response.go)。推送常 `message: "push"`，`data.event` 等。

## HTTP JWT 黑名单

`SET {CACHE_PREFIX}{token}`，与 `tools.Service` 一致。

## Hub

同进程 HTTP 推送 → **`deps.Deps.WSHub`**（与 `ListenAndServe` 共用实例）。

## 运维 CLI

需 Redis：**`ws stats|fix-stats|list|online|clear --yes`**（[`cmd/cli`](../../cmd/cli)）。

## 示例插件

sysKefu：HTTP [`plugin/ds/sysKefu/src/http/`](../../plugin/ds/sysKefu/src/http/)，WS [`register_ws.go`](../../plugin/ds/sysKefu/src/websocket/register_ws.go)。**`plugin.go`** 里 `BindingWS(loaded)` 按已装插件顺序注册。
