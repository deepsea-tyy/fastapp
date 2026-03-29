# WebSocket系统架构设计

## 架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                         客户端层                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Web App  │  │ Mobile   │  │  Visitor │  │  Admin   │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
└───────┼─────────────┼─────────────┼─────────────┼───────────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                      │
                 WebSocket连接
                      │
┌─────────────────────┼─────────────────────────────────────────────┐
│                     ▼                                               │
│              WsController                                           │
│    ┌──────────────────────────────────┐                           │
│    │  onOpen / onMessage / onClose    │                           │
│    └───┬──────────────┬───────────────┘                           │
│        │              │                                             │
│        ▼              ▼                                             │
│  ┌───────────┐  ┌─────────────┐                                   │
│  │ 认证/登录 │  │ 消息路由器   │                                   │
│  └───────────┘  └──────┬──────┘                                   │
│                        │                                            │
│                        ▼                                            │
│           ┌─────────────────────────┐                             │
│           │   插件处理器动态注册     │                             │
│           │  (扫描plugin目录)        │                             │
│           └────────┬────────────────┘                             │
│                    │                                               │
│          ┌─────────┴──────────┐                                   │
│          ▼                    ▼                                    │
│   ┌─────────────┐      ┌─────────────┐                           │
│   │ 系统处理器  │      │ 插件处理器   │                           │
│   └─────────────┘      └──────┬──────┘                           │
│                                │                                   │
└────────────────────────────────┼───────────────────────────────────┘
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│                        事件总线层                                  │
│                                                                    │
│  ┌────────────────┐        ┌────────────────┐                    │
│  │ 业务事件       │────────▶│ EventDispatcher│                    │
│  │ (各插件定义)    │        └────────┬───────┘                    │
│  └────────────────┘                 │                             │
│                                     │                              │
│                      ┌──────────────┴──────────────┐             │
│                      ▼                              ▼             │
│            ┌──────────────────┐         ┌──────────────────┐    │
│            │  业务逻辑Listener│         │  WsPushListener  │    │
│            │  (各插件实现)     │         │  (推送监听器)    │    │
│            └──────────────────┘         └────────┬─────────┘    │
│                                                   │               │
│                                                   ▼               │
│                                         ┌──────────────────┐    │
│                                         │  WsPushEvent     │    │
│                                         │  (推送事件)      │    │
│                                         └────────┬─────────┘    │
└──────────────────────────────────────────────────┼───────────────┘
                                                    │
                                                    ▼
┌──────────────────────────────────────────────────────────────────┐
│                        连接管理层                                  │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │WsConnectionMgr   │  │  WsRoomManager   │  │ WsController │  │
│  │(连接信息管理)    │  │  (房间管理)      │  │ (fd←→user)   │  │
│  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘  │
│           │                     │                    │           │
│           └─────────────────────┴────────────────────┘           │
│                                 │                                 │
│                                 ▼                                 │
│                         ┌─────────────┐                          │
│                         │    Redis    │                          │
│                         │  分布式存储  │                          │
│                         └─────────────┘                          │
└──────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│                        后台管理层                                  │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │          ConnectionController (Admin)                     │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │   │
│  │  │ 连接列表   │  │ 连接统计   │  │ 推送测试   │         │   │
│  │  └────────────┘  └────────────┘  └────────────┘         │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │   │
│  │  │ 强制断开   │  │ 房间管理   │  │ 广播消息   │         │   │
│  │  └────────────┘  └────────────┘  └────────────┘         │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

## 核心设计原则

### 1. 分层架构

- **客户端层**：各类客户端（Web、Mobile、Visitor、Admin）
- **连接层**：WebSocket连接管理、认证、消息路由
- **事件总线层**：事件驱动的消息分发
- **连接管理层**：连接信息存储、查询、统计
- **后台管理层**：运维管理界面

### 2. 事件驱动

**传统方式（紧耦合）：**
```php
// 订单服务直接调用WebSocket推送
$orderService->createOrder($data);
$wsController->pushToUser($userId, $message);
```

**事件驱动方式（解耦）：**
```php
// 订单服务只负责触发事件
$orderService->createOrder($data);
Tools::eventDispatcher(new OrderCreatedEvent($orderId, $userId));

// WsPushListener监听事件，负责推送
class WsPushListener {
    public function listen() {
        return [OrderCreatedEvent::class];
    }

    public function process($event) {
        Tools::eventDispatcher(
            WsPushEvent::toUser($event->userId, $data)
        );
    }
}
```

**优势：**
- 业务逻辑与推送逻辑解耦
- 同一事件可被多个监听器处理
- 易于扩展和维护

### 3. 插件化架构

**动态发现机制：**
```
启动时扫描 plugin/*/src/WebSocket/*.php
  └─> 提取类名和命名空间
      └─> 检查是否实现 WsMessageHandlerInterface
          └─> 调用 getActions() 获取 action→method 映射
              └─> 注册到 WsController::$actionHandle
```

**插件隔离：**
- 每个插件有独立的命名空间
- 插件通过标准接口与系统交互
- 插件可以独立安装/卸载

### 4. 统一推送接口

**推送目标抽象：**
```
WsPushEvent
  ├─ TARGET_USER      (单个用户)
  ├─ TARGET_USERS     (多个用户)
  ├─ TARGET_ALL       (所有在线用户)
  ├─ TARGET_FD        (单个连接)
  ├─ TARGET_FDS       (多个连接)
  └─ TARGET_ROOM      (房间)
```

**统一的推送方式：**
```php
// 所有推送都通过事件触发
Tools::eventDispatcher(WsPushEvent::toUser(...));
Tools::eventDispatcher(WsPushEvent::toRoom(...));
Tools::eventDispatcher(WsPushEvent::toAll(...));
```

## 数据流转

### 1. 客户端发送消息流程

```
客户端发送消息
  │
  ▼
WsController::onMessage()
  │
  ├─> 心跳消息 ──> 更新心跳时间 ──> 返回
  ├─> 登录消息 ──> JWT验证 ──> addConnection() ──> 返回
  └─> 业务消息
      │
      ├─> visitor消息 ──> 无需登录
      └─> 普通消息 ──> 验证登录状态
          │
          ▼
      查找 $actionHandle[action]
          │
          ▼
      反射调用插件处理器
          │
          ▼
      返回 WsResponse
```

### 2. 服务端推送消息流程

```
业务逻辑触发事件
  │
  ▼
EventDispatcher::dispatch(BusinessEvent)
  │
  ▼
BusinessListener::process()
  │
  ├─> 处理业务逻辑（保存数据、发送通知等）
  └─> 触发推送事件
      │
      ▼
EventDispatcher::dispatch(WsPushEvent)
  │
  ▼
WsPushListener::process()
  │
  ├─> 解析推送目标（user/users/all/fd/fds/room）
  ├─> 查询目标fd列表
  │   ├─> USER: WsController::getUserFds($userId)
  │   ├─> ROOM: WsRoomManager::getRoomFds($roomId)
  │   └─> ALL: WsConnectionManager::getAllConnections()
  ├─> 应用排除规则（excludeUserIds, excludeFds）
  └─> 遍历fd列表
      │
      ▼
  Sender::push($fd, $message)
      │
      ▼
  客户端接收消息
```

### 3. 连接生命周期

```
客户端连接
  │
  ▼
WsController::onOpen()
  │
  └─> 发送欢迎消息

客户端发送login消息
  │
  ▼
WsController::login()
  │
  ├─> 验证JWT Token
  └─> addConnection($fd, $userId)
      │
      ├─> 获取分布式锁
      ├─> 清理旧连接映射
      ├─> 设置 ws:fd:user:{fd} => userId
      ├─> 添加到 ws:user:fds:{userId} => [fds]
      ├─> WsConnectionManager::recordConnection()
      │   └─> 记录详细信息（IP、User-Agent、连接时间等）
      └─> 释放锁

连接断开
  │
  ▼
WsController::onClose()
  │
  ├─> removeConnection($fd)
  │   ├─> 删除 ws:fd:user:{fd}
  │   ├─> 从 ws:user:fds:{userId} 移除fd
  │   └─> 如果用户无其他连接，触发 WsCloseEvent
  ├─> WsConnectionManager::removeConnection($fd)
  │   └─> 删除连接详细信息
  ├─> WsRoomManager::leaveAllRooms($fd)
  │   └─> 离开所有房间
  └─> 清理锁值记录
```

## 数据存储设计

### Redis数据结构

```
# 连接映射（WsController）
ws:fd:user:{fd}           String   → user_id
ws:user:fds:{user_id}     Set      → [fd1, fd2, ...]
ws:lock:fd:{fd}           String   → lock_value (5秒过期)

# 连接详细信息（WsConnectionManager）
ws:connections:info       Hash     → fd => json(详细信息)
ws:user:info:{user_id}    Hash     → fd => json(连接信息)
ws:stats:total            String   → 总连接数

# 房间管理（WsRoomManager）
ws:room:{room_id}:fds     Set      → [fd1, fd2, ...]
ws:room:{room_id}:users   Set      → [user_id1, user_id2, ...]
ws:fd:rooms:{fd}          Set      → [room_id1, room_id2, ...]
```

### 数据一致性保证

1. **分布式锁**：Redis SETNX + Lua脚本保证原子性
2. **锁值验证**：释放锁时验证lockValue，防止误删
3. **降级策略**：锁获取失败时记录日志并放弃操作
4. **自动清理**：连接断开时自动清理所有相关数据

## 性能优化

### 1. 异步处理

```php
// 所有事件分发都在协程中异步执行
Coroutine::create(function () use ($event) {
    $this->handlePush($event);
});
```

### 2. 批量推送

```php
// 使用 TARGET_USERS 而不是循环调用 TARGET_USER
WsPushEvent::toUsers([1, 2, 3], $data);  // 一次查询多个用户的fd
```

### 3. 连接池复用

```php
// Redis连接通过容器管理，自动复用
$redis = ApplicationContext::getContainer()->get(Redis::class);
```

### 4. 最小化锁持有时间

```php
try {
    // 快速完成临界区操作
    $redis->set(...);
    $redis->sAdd(...);
} finally {
    $this->releaseLock($fd);  // 立即释放锁
}
```

## 扩展性设计

### 1. 水平扩展

**多进程/多服务器支持：**
- Redis存储连接映射，支持跨进程查询
- 分布式锁保证并发安全
- WebSocket Server可启动多个worker

**负载均衡：**
```
客户端 ──> Nginx ──> WebSocket Server 1
                  ├─> WebSocket Server 2
                  └─> WebSocket Server 3
                           │
                           ▼
                       共享Redis
```

### 2. 功能扩展

**添加新的推送目标类型：**
```php
// 1. 在WsPushEvent中添加常量
public const TARGET_DEPARTMENT = 'department';

// 2. 在WsPushListener中添加解析逻辑
case WsPushEvent::TARGET_DEPARTMENT:
    $fds = $this->getDepartmentFds($event->target);
    break;
```

**添加新的事件类型：**
```php
// 1. 定义事件类
class CustomEvent {
    public function __construct(public int $userId, public array $data) {}
}

// 2. 创建监听器
#[Listener]
class CustomListener implements ListenerInterface {
    public function listen(): array {
        return [CustomEvent::class];
    }

    public function process(object $event): void {
        // 处理逻辑
    }
}
```

## 安全性设计

### 1. 认证机制

- JWT Token验证
- 支持多场景（default、api）
- 登录失败自动断开连接

### 2. 权限控制

- visitor消息（无需登录）：visitor.* 前缀
- 普通消息：验证登录状态
- 方法可见性：只允许调用public方法

### 3. 并发安全

- 分布式锁保护fd映射操作
- Lua脚本保证原子性
- 锁值验证防止误删

### 4. 输入验证

```php
// 验证JSON格式
if (!is_array($params)) {
    return WsResponse::error('Invalid JSON format');
}

// 验证必填参数
if (empty($data['required_field'])) {
    return WsResponse::error('Field is required');
}
```

## 监控与运维

### 1. 日志记录

```php
// WebSocket日志
Tools::logAsync($message, 'info', 'info', 'websocket');

// 推送日志
Tools::logAsync($message, 'info', 'info', 'websocket_push');

// 错误日志
Tools::logAsync($message, 'error', 'error', 'websocket');
```

### 2. 统计指标

```php
$stats = WsConnectionManager::getStats();
// 返回：
// - total_connections: 总连接数
// - unique_users: 唯一用户数
// - visitor_connections: 访客连接数
```

### 3. 后台管理

- 实时查看所有在线连接
- 查看用户连接详情
- 强制断开连接
- 测试消息推送
- 房间管理

### 4. 性能监控

- 连接数趋势
- 推送消息数量
- 平均响应时间
- 错误率统计

## 最佳实践

### 1. 事件命名

```
{namespace}.{action}

示例：
order.created       - 订单创建
payment.success     - 支付成功
chat.message        - 聊天消息
system.maintenance  - 系统维护
```

### 2. 错误处理

```php
try {
    // 业务逻辑
} catch (\Throwable $e) {
    Tools::logAsync("Error: " . $e->getMessage(), 'error', 'error', 'websocket');
    return WsResponse::error('Internal error');
}
```

### 3. 数据结构

```php
// 推送数据应包含
[
    'event' => 'event_name',     // 事件名
    'message' => '用户可读消息',   // 提示信息
    'data' => [],                 // 业务数据
    'timestamp' => time(),        // 时间戳
]
```

### 4. 性能优化

- 批量推送优于循环推送
- 异步处理不阻塞主流程
- 合理使用房间减少查询
- 避免在推送中执行重逻辑

## 总结

这套WebSocket系统设计具有以下特点：

**架构优势：**
- 分层清晰，职责分明
- 事件驱动，松耦合
- 插件化，易扩展
- 统一推送接口

**功能完善：**
- 全局连接管理
- 房间/频道支持
- 后台管理界面
- 完整的监控日志

**性能可靠：**
- 异步处理
- 分布式锁
- 连接池复用
- 水平扩展

**易于使用：**
- 简洁的API
- 丰富的示例
- 完整的文档
- 插件友好
