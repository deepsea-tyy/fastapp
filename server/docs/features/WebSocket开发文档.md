# WebSocket 开发文档

## 概述

FastApp 的 WebSocket 架构基于 Hyperf 框架实现，支持：
- ✅ JWT Token 认证
- ✅ 多设备同时在线
- ✅ 插件化消息处理器
- ✅ 自动注册机制
- ✅ 协程安全的连接管理
- ✅ 统一的响应格式

## 架构设计

**整体流程**：
```
客户端 → WsController → 消息处理器注册表 → 插件消息处理器
```

**核心类关系**：
- `WsController` - 核心控制器，处理连接生命周期和消息路由
- `WsMessageHandlerInterface` - 消息处理器接口
- `WsResponse` - 统一响应格式
- `WsMessageAbstract` - 消息基类（可选）

## 核心组件

| 组件 | 位置 | 说明 |
|------|------|------|
| **WsController** | `app/Websocket/WsController.php` | 核心控制器，处理连接生命周期、消息路由、认证、连接映射 |
| **WsMessageHandlerInterface** | `app/Websocket/WsMessageHandlerInterface.php` | 消息处理器接口，插件需实现 `getActions()` 方法 |
| **WsResponse** | `app/Websocket/WsResponse.php` | 统一响应格式，提供 `success()` 和 `error()` 静态方法 |
| **WsMessageAbstract** | `app/Websocket/WsMessageAbstract.php` | 消息基类（可选），用于推送消息格式化 |

**WsResponse 响应格式**：
```json
{
    "success": true,
    "data": {},
    "message": "",
    "op_id": "",
    "timestamp": 1234567890
}
```

## 消息协议

WebSocket 服务支持两种消息模式：

| 模式 | 特点 | 识别方法 |
|------|------|---------|
| **请求应答模式** | 客户端发起，服务器响应，包含 `success`、`op_id` 字段 | 不包含 `type` 字段或 `type !== "push_message"` |
| **推送消息模式** | 服务器主动推送，包含 `type: "push_message"` | `message.type === "push_message"` |

### 请求消息格式

```json
{
    "action": "action_name",
    "data": {},
    "op_id": "unique_id"
}
```

### 响应消息格式

```json
{
    "success": true,
    "data": {},
    "message": "",
    "op_id": "",
    "timestamp": 1234567890
}
```

### 推送消息格式

```json
{
    "type": "push_message",
    "action": "action_name",
    "timestamp": 1234567890
}
```

**关键区别**：
- 推送消息：包含 `type: "push_message"`，没有 `success`、`op_id` 字段
- 请求响应：不包含 `type` 字段，包含 `success`、`op_id` 字段

## 认证机制

### 连接流程

```
建立连接 → 发送 login action → 验证 JWT Token → 建立 fd ↔ user_id 映射
```

### 认证消息格式

```json
{
    "action": "login",
    "data": {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "device": "device_info"
    },
    "op_id": "login_123"
}
```

**注意**：认证失败后，服务器会在 3 秒后自动关闭连接。

### 认证要求

- ✅ 所有非 `login`、`ping`、`heartbeat` 的 action 都需要先认证
- ✅ **例外**：action 名称中包含 `visitor` 则无需认证（游客操作）
- ✅ Token 验证支持 `default` 和 `api` 两种场景

### 游客操作（无需认证）

**识别规则**：action 名称中包含 `visitor` 字符串

**特点**：
- ✅ 无需认证
- ✅ 处理器方法不需要 `$userId` 参数

**方法签名**：
```php
// 普通操作（需要认证）
protected function methodName(array $data, int $userId): WsResponse

// 游客操作（无需认证）
protected function visitorMethod(array $data): WsResponse
```

## 连接管理

### 连接映射

- `$fdUser`: `fd => user_id` - 通过 fd 查找用户ID
- `$userFds`: `user_id => [fd1, fd2, ...]` - 通过用户ID查找所有连接

### 多设备支持

同一用户可以在多个设备上同时连接，发送消息时系统会自动推送到该用户的所有设备。

### 连接关闭事件

当用户的所有连接都关闭时，系统会触发 `WsCloseEvent` 事件（异步分发，不阻塞连接清理）。

**监听器示例**：
```php
#[Listener]
class YourListener implements ListenerInterface
{
    public function listen(): array
    {
        return [WsCloseEvent::class];
    }

    public function process(object $event): void
    {
        if ($event instanceof WsCloseEvent) {
            // 处理连接关闭逻辑
        }
    }
}
```

### 实用方法

- `WsController::getUserFds(int $userId): array` - 获取用户的所有连接Fd
- `WsController::isUserOnline(int $userId): bool` - 检查用户是否在线

## 插件开发

### 创建消息处理器

在插件的 `src/WebSocket/` 目录下创建处理器类：

```php
namespace Plugin\YourPlugin\WebSocket;

use App\Websocket\WsMessageHandlerInterface;
use App\Websocket\WsResponse;

class YourMessageHandler implements WsMessageHandlerInterface
{
    public function getActions(): array
    {
        return [
            'your_action_name' => 'yourMethodName',
        ];
    }

    protected function yourMethodName(array $data, int $userId): WsResponse
    {
        if (empty($data['required_field'])) {
            return WsResponse::error('required_field is required');
        }
        
        // 业务逻辑处理
        return WsResponse::success(['result' => 'success'], 'Operation completed');
    }
}
```

### 自动注册机制

系统启动时自动扫描 `plugin/*/src/WebSocket/*.php` 文件，检查是否实现 `WsMessageHandlerInterface`，调用 `getActions()` 注册到映射表。

**要求**：
- 插件目录必须存在 `install.lock` 文件
- 处理器类必须实现 `WsMessageHandlerInterface`
- 处理方法使用 `protected` 访问修饰符（推荐）
- Action 命名：使用小写字母和下划线，如 `module_action`

## 示例代码

### 普通操作示例

```php
class YourMessageHandler implements WsMessageHandlerInterface
{
    public function getActions(): array
    {
        return [
            'your_action' => 'yourMethod',
        ];
    }

    protected function yourMethod(array $data, int $userId): WsResponse
    {
        if (empty($data['required_field'])) {
            return WsResponse::error('required_field is required');
        }
        
        // 业务逻辑处理
        return WsResponse::success(['result' => 'success'], 'Operation completed');
    }
}
```

### 游客操作示例

```php
public function getActions(): array
{
    return [
        'your_action_visitor_send' => 'visitorSend',  // action 包含 visitor
    ];
}

// 游客操作方法不需要 $userId 参数
protected function visitorSend(array $data): WsResponse
{
    if (empty($data['visitor_id'])) {
        return WsResponse::error('visitor_id is required');
    }
    
    // 处理逻辑
    return WsResponse::success(['message_id' => 123]);
}
```

### 服务端推送消息示例

推送消息**不能使用 `WsResponse`**，必须包含 `type: "push_message"` 字段。

**方式一：直接构建推送消息数组（推荐）**

```php
use App\Websocket\WsController;
use Hyperf\WebSocketServer\Sender;

$userFds = WsController::getUserFds($userId);
$sender = make(Sender::class);

$pushData = [
    'type' => 'push_message',  // 必填
    'action' => 'your_action',
    'content' => 'You have a new message',
    'timestamp' => time(),
];

foreach ($userFds as $fd) {
    $sender->push($fd, json_encode($pushData, JSON_UNESCAPED_UNICODE), WEBSOCKET_OPCODE_TEXT);
}
```

**方式二：通过事件监听器推送（推荐）**

```php
#[Listener]
class YourEventListener implements ListenerInterface
{
    #[Inject]
    protected Sender $sender;

    public function process(object $event): void
    {
        if ($event instanceof YourEvent) {
            $this->pushMessage($event->message);
        }
    }

    private function pushMessage($message): void
    {
        $userFds = WsController::getUserFds($message->userId);
        $pushData = [
            'type' => 'push_message',
            'action' => 'your_action',
            'content' => $message->content,
            'timestamp' => time(),
        ];
        
        foreach ($userFds as $fd) {
            $this->sender->push($fd, json_encode($pushData, JSON_UNESCAPED_UNICODE), WEBSOCKET_OPCODE_TEXT);
        }
    }
}
```

## 测试工具

### WebSocket 测试页面

项目提供了测试页面: `app/Websocket/ws_test.html`

**功能**：连接/断开、发送认证、发送自定义 JSON 消息、格式化 JSON

**使用方法**：
1. 在浏览器中打开 `ws_test.html`
2. 配置 WebSocket 地址（默认: `ws://127.0.0.1:9502/ws`）
3. 输入 JWT Token 并连接
4. 发送认证消息进行登录
5. 使用示例按钮或自定义 JSON 发送消息

### 客户端连接示例

```javascript
const ws = new WebSocket('ws://127.0.0.1:9502/ws');

ws.onopen = () => {
    // 发送认证
    ws.send(JSON.stringify({
        action: 'login',
        data: { token: 'your-jwt-token' },
        op_id: 'login_' + Date.now()
    }));
};

ws.onmessage = (event) => {
    const message = JSON.parse(event.data);
    
    // 判断消息类型
    if (message.type === 'push_message') {
        // 推送消息
        handlePushMessage(message);
    } else {
        // 请求响应
        handleRequestResponse(message);
    }
};

// 发送消息
function sendMessage(action, data) {
    ws.send(JSON.stringify({
        action: action,
        data: data,
        op_id: 'msg_' + Date.now()
    }));
}
```

## 服务器配置

### WebSocket 服务器配置

在 `config/autoload/server.php` 中配置：

```php
[
    'name' => 'ws',
    'type' => Server::SERVER_WEBSOCKET,
    'host' => '0.0.0.0',
    'port' => (int)env('WS_PORT', 9502),
    'sock_type' => \SWOOLE_SOCK_TCP,
    'callbacks' => [
        Event::ON_HAND_SHAKE => [Hyperf\WebSocketServer\Server::class, 'onHandShake'],
        Event::ON_MESSAGE => [Hyperf\WebSocketServer\Server::class, 'onMessage'],
        Event::ON_CLOSE => [Hyperf\WebSocketServer\Server::class, 'onClose'],
    ],
    'settings' => [
        Constant::OPTION_HEARTBEAT_IDLE_TIME => 60,
        Constant::OPTION_HEARTBEAT_CHECK_INTERVAL => 30,
    ],
]
```

### 路由配置

在 `config/routes.php` 中配置：

```php
Router::addServer('ws', function () {
    Router::get('/ws', \App\Websocket\WsController::class);
});
```

## 常见问题

| 问题 | 答案 |
|------|------|
| **如何处理消息推送？** | 使用 `WsController::getUserFds()` 获取连接，构建包含 `type: "push_message"` 的消息，使用 `Sender::push()` 发送。推荐通过事件监听器处理推送。 |
| **Action 冲突怎么办？** | 系统会记录警告日志，后注册的 action 会覆盖先注册的。建议使用插件前缀命名 action。 |
| **如何调试消息处理器？** | 核心框架错误通过 `Tools::logAsync()` 记录，插件错误使用 `LoggerFactory` 记录到 `runtime/logs/websocket.log` |
| **连接断开后数据会保留吗？** | 不会，连接断开后映射会被清除，下次连接需要重新认证 |
| **支持二进制消息吗？** | 目前只支持文本消息（JSON 格式），PING/PONG 帧会被自动忽略 |
| **如何实现游客操作？** | Action 名称包含 `visitor`，处理器方法不需要 `$userId` 参数 |

## 最佳实践

1. ✅ 错误处理：所有处理方法都应该使用 try-catch 捕获异常
2. ✅ 参数验证：在处理业务逻辑前先验证必要参数
3. ✅ 日志记录：记录关键操作和错误信息
4. ✅ 响应格式：统一使用 `WsResponse` 返回响应
5. ✅ Action 命名：使用模块前缀避免冲突

更多文档请查看 [文档导航](../README.md)

