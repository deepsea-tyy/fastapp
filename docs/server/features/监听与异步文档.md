# Hyperf 监听器与异步操作指南

## 监听器概述

监听器（Listener）是 Hyperf 事件系统的核心组件，用于实现**观察者模式**。

**核心流程**：事件（Event） → 分发（Dispatch） → 监听器（Listener） → 处理（Process）

**优势**：
- ✅ 解耦：事件发布者不需要知道谁在处理事件
- ✅ 扩展性：新增监听器无需修改原有代码
- ✅ 灵活性：一个事件可以有多个监听器
- ✅ 异步支持：可以异步执行，不阻塞主流程

## 监听器开发流程

### 1. 定义事件类

```php
namespace App\Common\Event;

class WsCloseEvent
{
    public function __construct(public int|string $userId) {}
}
```

### 2. 创建监听器

```php
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;

#[Listener]  // 关键：注解让 Hyperf 自动发现并注册
class YourListener implements ListenerInterface
{
    public function listen(): array
    {
        return [WsCloseEvent::class];
    }

    public function process(object $event): void
    {
        if ($event instanceof WsCloseEvent) {
            // 处理逻辑
        }
    }
}
```

### 3. 分发事件

```php
// ✅ 推荐：使用封装的异步方法
Tools::eventDispatcher(new WsCloseEvent($userId));

// ❌ 不推荐：同步执行，会阻塞主流程
$eventDispatcher->dispatch(new WsCloseEvent($userId));
```

### 自动注册流程

```
框架启动 → 扫描 #[Listener] 注解 → 调用 listen() → 建立映射关系 → 注册到事件分发器
```

### 事件分发流程

```
dispatch(event) → 查找监听器 → 按顺序调用 process() → 执行处理逻辑
```

## 监听器开发指南

### 基本结构

```php
#[Listener]
class YourListener implements ListenerInterface
{
    public function listen(): array
    {
        return [YourEvent::class];
    }

    public function process(object $event): void
    {
        if ($event instanceof YourEvent) {
            // 处理逻辑
        }
    }
}
```

### 依赖注入

监听器支持构造函数依赖注入：

```php
public function __construct(
    private readonly YourService $service,
    private readonly LoggerInterface $logger,
) {}
```

### 监听多个事件

```php
public function listen(): array
{
    return [EventA::class, EventB::class, EventC::class];
}

public function process(object $event): void
{
    match (true) {
        $event instanceof EventA => $this->handleA($event),
        $event instanceof EventB => $this->handleB($event),
        $event instanceof EventC => $this->handleC($event),
        default => null,
    };
}
```

### 异常处理

监听器内部应该处理异常，避免影响其他监听器：

```php
public function process(object $event): void
{
    try {
        if ($event instanceof YourEvent) {
            $this->handleEvent($event);
        }
    } catch (\Throwable $e) {
        $this->logger->error('Listener error: ' . $e->getMessage(), [
            'exception' => $e,
            'event' => $event::class,
        ]);
    }
}
```

## 事件分发

### 推荐：使用 Tools::eventDispatcher()

**强烈推荐使用**封装的 `Tools::eventDispatcher()` 方法：

```php
Tools::eventDispatcher(new WsCloseEvent($userId));
```

**优势**：
- ✅ 异步执行：在独立协程中执行，不阻塞主流程
- ✅ 异常隔离：监听器异常不会影响调用者
- ✅ 统一封装：统一的错误处理和日志记录

**实现原理**：在独立协程中执行，自动捕获异常并记录日志

### 不推荐：直接使用 EventDispatcher

```php
// ❌ 同步执行，会阻塞主流程
$eventDispatcher->dispatch(new WsCloseEvent($userId));
```

**问题**：同步执行、异常会影响调用者、需要手动处理异常

## 异步操作指南

### 为什么需要异步操作？

在 Hyperf/Swoole 协程环境中，代码仍然是同步顺序执行的。要实现真正的异步并发，需要手动创建协程。

### 组件异步操作速查表

| 组件 | 是否需要异步 | 推荐方式 |
|------|------------|---------|
| **事件分发** | ✅ 推荐异步 | `Tools::eventDispatcher()` |
| **日志记录** | ✅ 推荐异步 | `Tools::logAsync($message, $level, $name, $group)` |
| **队列分发** | ✅ 推荐异步 | `Tools::redisDispatcher($job, $delay)` |
| **HTTP 请求** | ⚠️ 视情况 | 需要结果时同步，不需要结果时异步 |
| **WebSocket 推送** | ✅ 推荐异步 | `Coroutine::create()` |
| **文件系统** | ⚠️ 大文件异步 | 大文件、批量操作推荐异步 |
| **缓存操作** | ❌ 通常不需要 | 已经是协程安全，操作很快 |
| **Redis 操作** | ❌ 通常不需要 | 已经是协程安全，操作很快 |
| **数据库操作** | ❌ 通常不需要 | 已经是协程安全，需要结果 |
| **模型缓存** | ❌ 通常不需要 | 已经是协程安全，操作很快 |
| **Guzzle 客户端** | ⚠️ 视情况 | 已经是协程安全，不需要结果时可异步 |
| **定时任务** | ❌ 不需要 | 本身在独立进程执行 |
| **异步队列** | ✅ 分发时异步 | `Tools::redisDispatcher()` |

### Tools 方法说明

**Tools::logAsync($message, $level, $name, $group)**：
- `$message`: 日志消息
- `$level`: 日志级别（默认 'info'）
- `$name`: 日志名称/channel（默认 'app'）
- `$group`: 日志分组（默认 'error'）

### 判断标准

**需要异步的情况**：
- ✅ 操作耗时较长（>100ms）
- ✅ 不需要立即结果
- ✅ 可能阻塞主流程
- ✅ 批量操作

**不需要异步的情况**：
- ❌ 需要结果的操作
- ❌ 操作很快（<10ms）
- ❌ 已经是协程安全的组件
- ❌ 关键业务逻辑

### 异步操作实现方式

**方式一：使用 Tools 封装方法（最推荐）**

```php
Tools::eventDispatcher(new YourEvent($data));
Tools::logAsync('Message', 'info', 'app', 'error');
Tools::redisDispatcher($job, $delay);
```

**方式二：使用 Coroutine::create()**

```php
Coroutine::create(function () use ($data) {
    try {
        $this->doSomething($data);
    } catch (\Throwable $e) {
        Tools::logAsync('Error: ' . $e->getMessage(), 'error', 'app', 'error');
    }
});
```

### 异步操作注意事项

1. **变量捕获**：使用 `use` 关键字捕获外部变量
2. **异常处理**：异步操作中的异常不会自动传播，需要手动处理
3. **上下文传递**：协程上下文会自动传递
4. **不要异步需要结果的操作**：异步操作的结果无法返回给调用者

## 最佳实践

### 监听器设计原则

```php
#[Listener]
class GoodListener implements ListenerInterface
{
    public function __construct(
        private readonly LoggerInterface $logger,
    ) {}

    public function process(object $event): void
    {
        // ✅ 类型检查
        if (!$event instanceof YourEvent) {
            return;
        }

        // ✅ 异常处理
        try {
            $this->handleEvent($event);
        } catch (\Throwable $e) {
            $this->logger->error('Listener error', [
                'exception' => $e,
                'event' => $event::class,
            ]);
        }
    }
}
```

### 事件分发最佳实践

```php
// ✅ 推荐：使用封装的异步方法
Tools::eventDispatcher(new YourEvent($data));

// ✅ 推荐：在 finally 块中分发（确保执行）
try {
    // 业务逻辑
} finally {
    Tools::eventDispatcher(new YourEvent($data));
}
```

### 异步操作最佳实践

```php
// ✅ 推荐：使用 Tools 封装
Tools::eventDispatcher($event);
Tools::logAsync($message, 'info', 'app', 'error');
Tools::redisDispatcher($job);

// ✅ 推荐：需要自定义时使用 Coroutine::create()
Coroutine::create(function () use ($data) {
    try {
        $this->doSomething($data);
    } catch (\Throwable $e) {
        Tools::logAsync('Error: ' . $e->getMessage(), 'error', 'app', 'error');
    }
});
```

### 监听器性能优化

耗时操作应在监听器内部异步执行：

```php
public function process(object $event): void
{
    if (!$event instanceof YourEvent) {
        return;
    }

    // ✅ 异步执行耗时操作
    Coroutine::create(function () use ($event) {
        $this->slowOperation($event);
    });
}
```

## 常见问题

| 问题 | 答案 |
|------|------|
| **监听器没有被调用？** | 检查：是否有 `#[Listener]` 注解、是否实现 `ListenerInterface`、`listen()` 方法是否正确、事件是否被分发、框架是否已重启 |
| **监听器执行顺序？** | 按注册顺序执行，可以使用优先级（Hyperf 3.x 支持） |
| **监听器异常会影响其他监听器吗？** | 同步分发：会影响后续监听器；异步分发：不会影响，异常被隔离 |
| **什么时候使用异步操作？** | 事件分发、日志记录、队列分发、HTTP 请求（不需要结果时）、WebSocket 推送 |
| **如何调试监听器？** | 添加日志：`Tools::logAsync('Event received: ' . $event::class, 'info', 'app', 'error')` |
| **监听器可以监听框架事件吗？** | 可以，如 `QueryExecuted::class`（数据库查询事件）、`AfterHandle::class`（队列处理完成事件） |

## 总结

1. **监听器流程**：定义事件 → 创建监听器 → 自动注册 → 分发事件 → 执行处理
2. **推荐使用**：`Tools::eventDispatcher()` 进行异步事件分发
3. **异步操作**：事件分发、日志记录、队列分发、大文件操作等场景推荐异步
4. **最佳实践**：异常处理、类型检查、性能优化
