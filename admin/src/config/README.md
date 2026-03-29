# WebSocket 模块化配置系统

## 概述

此配置系统提供了一个统一的 WebSocket 管理方式，支持多模块注册和灵活配置。

## 架构设计

```
web/src/
├── config/
│   └── websocket.config.ts          # 全局配置注册中心
├── store/modules/
│   └── useWebSocketStore.ts         # WebSocket Store (使用注册配置)
└── plugins/ds/sysKefu/
    └── config/
        └── module.config.ts         # 客服模块配置
```

## 核心组件

### 1. 全局配置注册中心 (`websocket.config.ts`)

提供模块注册和配置管理功能：

```typescript
import { wsRegistry } from '@/config/websocket.config'

// 注册模块
wsRegistry.register({
  name: 'your-module',
  actions: { ... },
  constants: { ... },
  wsConfig: { ... }
})

// 获取配置
const actions = wsRegistry.getAllActions()
const config = wsRegistry.getGlobalConfig()
```

### 2. 模块配置 (`module.config.ts`)

每个模块定义自己的配置并自动注册：

```typescript
export const yourModuleConfig: ModuleConfig = {
  name: 'your-module',
  actions: {
    SEND_MESSAGE: 'your_module_send',
    // ...
  },
  constants: {
    PAGE_SIZE: 20,
    // ...
  },
  wsConfig: {
    url: 'ws://your-server/ws',
    heartbeatInterval: 30000,
  }
}

// 自动注册
wsRegistry.register(yourModuleConfig)
```

### 3. WebSocket Store (`useWebSocketStore.ts`)

自动整合所有模块的配置：

- 合并所有模块的 WebSocket 动作
- 使用统一的配置进行连接管理
- 支持多模块消息分发

## 使用指南

### 添加新模块

1. **创建模块配置文件**

```typescript
// web/src/plugins/your-module/config/module.config.ts

import { wsRegistry, type ModuleConfig } from '@/config/websocket.config'

export const YOUR_MODULE_WS_ACTIONS = {
  SEND: 'your_module_send',
  RECEIVE: 'your_module_receive',
} as const

export const YOUR_MODULE_CONSTANTS = {
  PAGE_SIZE: 15,
  // ...
} as const

export const yourModuleConfig: ModuleConfig = {
  name: 'your-module',
  actions: YOUR_MODULE_WS_ACTIONS,
  constants: YOUR_MODULE_CONSTANTS,
  wsConfig: {
    heartbeatInterval: 25000,
  }
}

// 自动注册
wsRegistry.register(yourModuleConfig)
```

2. **在 WebSocketStore 中导入模块配置**

```typescript
// web/src/store/modules/useWebSocketStore.ts

// 导入模块配置（确保被注册）
import '@/plugins/ds/sysKefu/config/module.config'
import '@/plugins/your-module/config/module.config'  // 添加新模块
```

3. **使用模块配置**

```typescript
import { WS_ACTION } from '@/store/modules/useWebSocketStore'
import { YOUR_MODULE_CONSTANTS } from '@/plugins/your-module/config/module.config'

// 发送消息
wsStore.sendWebSocketMessage(
  WS_ACTION.SEND,  // 自动可用
  { ... }
)
```

### 客服模块使用示例

```typescript
import { CHAT_CONSTANTS } from '$/ds/sysKefu/config/module.config'
import { WS_ACTION } from '@/store/modules/useWebSocketStore'

// 使用常量
const pageSize = CHAT_CONSTANTS.PAGE_SIZE
const senderType = CHAT_CONSTANTS.SENDER_TYPE.KEFU

// 使用 WebSocket 动作
wsStore.sendWebSocketMessage(
  WS_ACTION.USER_SEND,
  { content: 'Hello' }
)
```

## 配置优先级

1. 模块特定配置优先
2. 全局默认配置兜底

## 向后兼容

旧的 `constants.ts` 文件已更新为从新配置导入，保持向后兼容：

```typescript
// 旧代码仍然可用
import { CHAT_CONSTANTS } from '../constants'

// 但建议使用新的导入方式
import { CHAT_CONSTANTS } from '$/ds/sysKefu/config/module.config'
```

## 配置项说明

### ModuleConfig

```typescript
interface ModuleConfig {
  name: string                    // 模块名称（唯一标识）
  actions: Record<string, string> // WebSocket 动作映射
  constants?: Record<string, any> // 业务常量
  wsConfig?: {
    url?: string                  // WebSocket 服务地址
    maxReconnectAttempts?: number // 最大重连次数
    reconnectDelay?: number       // 重连延迟（毫秒）
    heartbeatInterval?: number    // 心跳间隔（毫秒）
    messageTimeout?: number       // 消息超时（毫秒）
  }
}
```

## API 参考

### wsRegistry

- `register(config: ModuleConfig)` - 注册模块
- `getModule(name: string)` - 获取模块配置
- `getAllModules()` - 获取所有模块
- `getAllActions()` - 获取所有 WebSocket 动作
- `getModuleActions(name: string)` - 获取指定模块动作
- `getModuleConstants(name: string)` - 获取指定模块常量
- `getGlobalConfig()` - 获取全局配置
- `updateGlobalConfig(config)` - 更新全局配置
- `clear()` - 清空所有注册

## 最佳实践

1. ✅ 每个模块维护独立的配置文件
2. ✅ 在配置文件末尾自动注册
3. ✅ 导出常量和动作供外部使用
4. ✅ 使用 TypeScript 类型提供智能提示
5. ❌ 不要在多处重复定义相同配置
6. ❌ 不要直接修改全局注册中心的内部状态

## 迁移指南

### 从旧配置迁移

**之前：**
```typescript
import { CHAT_CONSTANTS } from '../constants'
const action = CHAT_CONSTANTS.WS_ACTION.USER_SEND
```

**之后：**
```typescript
import { CHAT_CONSTANTS } from '$/ds/sysKefu/config/module.config'
import { WS_ACTION } from '@/store/modules/useWebSocketStore'

const action = WS_ACTION.USER_SEND
// 或
const action = CHAT_CONSTANTS.WS_ACTION.USER_SEND
```

## 未来扩展

系统设计支持：
- 多个 WebSocket 连接
- 动态模块加载/卸载
- 运行时配置更新
- 模块间消息路由
