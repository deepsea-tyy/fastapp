# WebSocket 开发说明

WebSocket 在 **独立端口**（`APP_WS_PORT`）上提供服务，路径 **`/ws`**，与 Gin HTTP 分离。入口 [`ListenAndServe`](../internal/websocket/server.go)；Hub、连接读写与 **`login`** 等内建逻辑在同文件。

## 客户端消息格式（Text JSON）

每条消息解析为：

| 字段 | 类型 | 说明 |
|------|------|------|
| **`action`** | string | 动作名；内建含 `ping` / `heartbeat`、`login`、`visitor.bind_fd` |
| **`data`** | object | 载荷；缺省按空对象处理 |
| **`op_id`** | string | 可选；回包原样带上，便于请求-响应关联 |

非法 JSON 会收到错误帧（`success: false`）。

## 服务端响应格式

见 [`internal/websocket/response.go`](../internal/websocket/response.go)：

| 字段 | 说明 |
|------|------|
| **`success`** | 是否成功 |
| **`op_id`** | 与请求一致 |
| **`message`** | 提示文案 |
| **`data`** | 成功时的数据（可无） |
| **`timestamp`** | Unix 秒级 |

**注意**：WS JSON **不是** HTTP 的 `code` / `message` / `data` 三件套，而是 **`success` + `message` + `data`**。

## 连接建立后

升级成功后服务端先发一条 **成功** 消息，`data` 中含 **`bind_key`**（访客绑定用），`message` 如 `connected successfully`。

## 内建 `action`

| `action` | 说明 |
|----------|------|
| **`ping` / `heartbeat`** | 刷新 Redis 侧心跳；无业务响应帧（continue） |
| **`login`** | `data.token` 为 **HTTP 同源**的 access token；先尝试 **admin** `JWT`，失败再试 **API** `JWT`。成功后把连接绑定到用户；失败返回错误并在约 3 秒后关闭连接 |
| **`visitor.bind_fd`** | `data.bind_key` 使用连接建立时下发的 key，将访客身份绑到当前 fd |

其余 **`action`** 由内建 **`ActionRegistry`** 分发给已注册处理器。

## 登录态与访客

- **已登录用户**：`login` 成功后 `userID` 为数字；非 `visitor.*` 的 action 会校验 Redis 中 fd ↔ 用户映射（或内存缓存）。
- **访客**：`action` 以 **`visitor.`** 前缀视为访客通道（[`IsVisitorAction`](../internal/websocket/server.go)），走 **`RegisterVisitor`** 注册的处理器，不强制数字用户 ID。

未登录且非访客处理器：返回 **`Please login first`**。

## 插件如何注册业务 action

1. 在 **`src/websocket/`** 内实现各 action 的处理函数，并在同包提供 **`RegisterWebSocket(reg *websocket.ActionRegistry)`**（如 [`register_ws.go`](../plugin/ds/sysKefu/src/websocket/register_ws.go)）：在同包闭包里调用未导出的 **`handle*`** 即可，不必再导出 **`Action*`**。
2. 在 **[`plugin/plugin.go`](../plugin/plugin.go)** 的 **`init`** 中 **`RegisterWebSocket(插件根.PluginName, ws.RegisterWebSocket)`**（**`PluginName`** 与各插件根常量一致）。**不要**在 `websocket` 子包的 **`init`** 里登记。插件需 **已安装**（**`install.lock`**），**`plugin.BindingWS`** 按安装顺序调用各插件登记函数。

**`ActionFunc` 签名**见 [`registry.go`](../internal/websocket/registry.go)：`func(ctx context.Context, fd int, opID string, data map[string]any, userID any, isVisitor bool, d *deps.Deps, hub *Hub) Response`。

可选 **`AddZeroConnHook`**：当某 Redis 用户键在所有 fd 上无连接时触发，用于清理或推送。

## Redis 与运维

键前缀、fd/user 映射、CLI **`ws` 子命令**见：

- [internal/websocket/redis_contract.md](../internal/websocket/redis_contract.md)
- [命令行 · ws](cli.md#ws--websocket--redis-运维)

## 相关文档

- [核心功能与架构](core-features.md)：进程与端口
- [鉴权与权限](auth-and-permission.md)：Token 与双场景 JWT
