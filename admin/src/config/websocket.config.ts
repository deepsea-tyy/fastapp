/**
 * WebSocket 全局配置注册中心
 * 支持多模块注册和统一管理
 */

/**
 * 模块配置接口
 */
export interface ModuleConfig {
  /** 模块名称 */
  name: string
  /** WebSocket 动作定义 */
  actions: Record<string, string>
  /** 模块业务常量 */
  constants?: Record<string, any>
  /** WebSocket 连接配置 */
  wsConfig?: {
    url?: string
    maxReconnectAttempts?: number
    reconnectDelay?: number
    heartbeatInterval?: number
  }
}

/**
 * WebSocket 配置注册器
 */
class WebSocketConfigRegistry {
  private modules: Map<string, ModuleConfig> = new Map()
  private globalConfig = {
    maxReconnectAttempts: 5,
    reconnectDelay: 3000,
    heartbeatInterval: 30000,
    defaultWsUrl: 'ws://127.0.0.1:9502/ws',
  }

  /**
   * 注册模块配置
   */
  register(config: ModuleConfig) {
    if (this.modules.has(config.name)) {
      console.warn(`[WebSocket] Module "${config.name}" already registered, overwriting...`)
    }
    this.modules.set(config.name, config)
  }

  /**
   * 获取模块配置
   */
  getModule(name: string): ModuleConfig | undefined {
    return this.modules.get(name)
  }

  /**
   * 获取所有已注册的模块
   */
  getAllModules(): ModuleConfig[] {
    return Array.from(this.modules.values())
  }

  /**
   * 获取所有 WebSocket 动作（合并所有模块）
   */
  getAllActions(): Record<string, string> {
    const actions: Record<string, string> = {}
    this.modules.forEach((module) => {
      Object.assign(actions, module.actions)
    })
    return actions
  }

  /**
   * 获取指定模块的动作
   */
  getModuleActions(moduleName: string): Record<string, string> {
    const module = this.modules.get(moduleName)
    return module?.actions || {}
  }

  /**
   * 获取指定模块的常量
   */
  getModuleConstants(moduleName: string): Record<string, any> {
    const module = this.modules.get(moduleName)
    return module?.constants || {}
  }

  /**
   * 获取全局配置（合并模块配置）
   */
  getGlobalConfig() {
    const config = { ...this.globalConfig }

    // 合并所有模块的 wsConfig
    this.modules.forEach((module) => {
      if (module.wsConfig) {
        Object.assign(config, {
          maxReconnectAttempts: module.wsConfig.maxReconnectAttempts ?? config.maxReconnectAttempts,
          reconnectDelay: module.wsConfig.reconnectDelay ?? config.reconnectDelay,
          heartbeatInterval: module.wsConfig.heartbeatInterval ?? config.heartbeatInterval,
          defaultWsUrl: module.wsConfig.url ?? config.defaultWsUrl,
        })
      }
    })

    return config
  }

  /**
   * 更新全局配置
   */
  updateGlobalConfig(config: Partial<typeof this.globalConfig>) {
    Object.assign(this.globalConfig, config)
  }

  /**
   * 清空所有注册的模块
   */
  clear() {
    this.modules.clear()
  }
}

// 创建全局单例
export const wsRegistry = new WebSocketConfigRegistry()

// ============ 系统级 WebSocket 动作 ============
export const SYSTEM_WS_ACTIONS = {
  LOGIN: 'login',
  LOGOUT: 'logout',
  PING: 'ping',
  PONG: 'pong',
} as const

// 导出类型
export type SystemWSActions = typeof SYSTEM_WS_ACTIONS
