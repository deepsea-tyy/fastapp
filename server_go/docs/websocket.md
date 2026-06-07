# WebSocket

**独立端口** `APP_WS_PORT`，路径 **`/ws`**。入口 [`ListenAndServe`](../internal/websocket/server.go)。

## 请求帧（Text JSON）

**`action`**、**`data`**（object）、**`op_id`**（可选）。非法 JSON → `success: false`。

## 响应帧

[`response.go`](../internal/websocket/response.go)：**`success`**、**`op_id`**、**`message`**、**`data`**、**`timestamp`**（非 HTTP 的 `code`/`message`/`data`）。

连接建立后先发成功帧（含 **`bind_key`**）。

## 内建 `action`

| `action` | 说明 |
|----------|------|
| `ping` / `heartbeat` | 刷新 Redis 心跳 |
| `login` | `data.token`；先试 admin JWT 再试 api；失败约 **3s** 后关闭连接 |
| `visitor.bind_fd` | `data.bind_key` 绑定访客 |

其余分发给 **`ActionRegistry`**。未登录且非 `visitor.*` → **`Please login first`**。

## 插件

1. 在 **`src/websocket/`** 实现 **`RegisterWebSocket(reg *websocket.ActionRegistry)`**（例 [`register_ws.go`](../plugin/ds/sysKefu/src/websocket/register_ws.go)）。
2. **[`plugin/plugin.go`](../plugin/plugin.go)** **`init`**：**`RegisterWebSocket(PluginName, ws.RegisterWebSocket)`**（勿在子包 **`init`** 里登记）。插件须 **已安装**（`install.lock`）。

**`ActionFunc`** 签名见 [`registry.go`](../internal/websocket/registry.go)。

**相关**：[redis_contract.md](../internal/websocket/redis_contract.md) · [CLI · ws](cli.md#ws-cli) · [核心功能](core-features.md)
