/**
 * WebSocket 全局连接管理 Store
 * 负责 WebSocket 连接的建立、心跳、重连和消息收发
 * 支持多模块注册和统一管理
 */

import type { WebSocketMessage, WebSocketResponse, PendingOperation } from '$/ds/sysKefu/views/chat/types'
import { generateOperationId } from '$/ds/sysKefu/views/chat/helpers'
import useUserStore from '@/store/modules/useUserStore'
import { wsRegistry, SYSTEM_WS_ACTIONS } from '@/config/websocket.config'

/**
 * 扫描并加载 `src/plugins/ds/<插件名>/config/module.config.ts`（存在则加载）。
 * 各插件应在该文件中调用 wsRegistry.register；无需在本文件再手写 import。
 */
export function loadPluginWebSocketModuleConfigs(): Record<string, unknown> {
  return import.meta.glob('@/plugins/ds/*/config/module.config.ts', { eager: true })
}

loadPluginWebSocketModuleConfigs()

/**
 * 获取 WebSocket 配置
 */
function getWsConfig() {
  const config = wsRegistry.getGlobalConfig()
  return {
    MAX_RECONNECT_ATTEMPTS: config.maxReconnectAttempts,
    RECONNECT_DELAY: config.reconnectDelay,
    HEARTBEAT_INTERVAL: config.heartbeatInterval,
    DEFAULT_WS_URL: config.defaultWsUrl,
  }
}

/**
 * 获取所有 WebSocket 动作（合并系统动作和所有模块动作）
 */
function getWsActions() {
  return {
    ...SYSTEM_WS_ACTIONS,
    ...wsRegistry.getAllActions(),
  }
}

// 导出配置和动作（为了向后兼容）
export const WS_CONFIG = getWsConfig()
export const WS_ACTION = getWsActions()

/**
 * 消息处理器类型
 */
type MessageHandler = (message: any) => void | Promise<void>

/**
 * 客服 WebSocket Store
 */
const useWebSocketStore = defineStore('useWebSocketStore', () => {
  // WebSocket 相关状态
  const ws = ref<WebSocket | null>(null)
  const wsConnected = ref(false)
  const wsReconnectTimer = ref<number | null>(null)
  const reconnectAttempts = ref(0)
  const heartbeatTimer = ref<number | null>(null)
  const initialized = ref(false) // 是否已初始化

  // WebSocket 操作ID跟踪
  const pendingOperations = ref<Map<string, PendingOperation>>(new Map())

  // 消息处理器注册表
  const messageHandlers = new Map<string, MessageHandler>()

  // 标记 watch 是否已设置
  let watchSetup = false

  /**
   * 设置 token 监听（延迟执行以避免循环依赖）
   */
  function setupTokenWatch() {
    if (watchSetup) {
      return
    }
    watchSetup = true

    // 延迟到下一个 tick，确保 userStore 已经完全初始化
    nextTick(() => {
      const userStore = useUserStore()

      // 使用 watch 监听 token 变化，immediate: true 确保初始化时也会执行
      watch(() => userStore.token, (newToken, oldToken) => {
        if (newToken && !initialized.value) {
          // 有 token 且未初始化，则初始化 WebSocket
          initialize()
        } else if (!newToken && oldToken) {
          // token 被清除（用户退出），关闭 WebSocket
          closeWebSocket()
        }
      }, { immediate: true })
    })
  }

  /**
   * 判断是否超过最大重连数
   */
  const isMaxReconnectReached = computed(() => {
    return !wsConnected.value && reconnectAttempts.value >= WS_CONFIG.MAX_RECONNECT_ATTEMPTS
  })

  /**
   * 获取 WebSocket 地址
   */
  function getWebSocketUrl(): string {
    const env = import.meta.env
    return (env.VITE_APP_WS_URL as string) || WS_CONFIG.DEFAULT_WS_URL
  }

  /**
   * 发送 WebSocket 认证消息
   */
  function sendWebSocketAuth() {
    const userStore = useUserStore()
    const token = userStore.token

    if (!ws.value || !token) {
      return
    }

    const authData = {
      action: WS_ACTION.LOGIN,
      data: { token },
    }

    ws.value.send(JSON.stringify(authData))
  }

  /**
   * 发送退出登录消息
   */
  function sendWebSocketLogout() {
    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      return
    }

    try {
      ws.value.send(JSON.stringify({
        action: WS_ACTION.LOGOUT,
        data: {},
      }))
    } catch (error) {
      // 忽略错误
    }
  }

  /**
   * 拒绝并清空所有待响应的 op_id 请求（断线、重连、主动关闭时调用）
   */
  function rejectAllPendingOperations(reason: string) {
    pendingOperations.value.forEach((operation) => {
      operation.reject(new Error(reason))
    })
    pendingOperations.value.clear()
  }

  function cancelPendingOperation(opId: string, reason = 'Operation cancelled'): boolean {
    const operation = pendingOperations.value.get(opId)
    if (!operation)
      return false
    pendingOperations.value.delete(opId)
    operation.reject(new Error(reason))
    return true
  }

  /**
   * 处理 WebSocket 响应消息（带 op_id）
   *
   * @param message - WebSocket 消息
   * @returns 是否处理成功
   */
  function handleWebSocketResponse(message: any): boolean {
    if (message.op_id && pendingOperations.value.has(message.op_id)) {
      const operation = pendingOperations.value.get(message.op_id)!
      pendingOperations.value.delete(message.op_id)

      if (message.success) {
        operation.resolve(message)
      } else {
        operation.reject(new Error(message.message || 'Operation failed'))
      }
      return true
    }
    return false
  }

  /**
   * 处理 WebSocket 消息类型
   *
   * @param message - WebSocket 消息
   * @returns 是否处理成功
   */
  function handleWebSocketMessageType(message: any): boolean {
    // 优先处理带 op_id 的响应消息
    if (handleWebSocketResponse(message)) {
      return true
    }

    // 连接成功消息
    if (message.type === 'connected' || (message.success === true && message.message === 'connected successfully')) {
      return true
    }

    // 认证成功响应
    if (message.success === true && (message.message === 'Authentication successful' || message.message === 'Auth successfully')) {
      return true
    }

    // 心跳响应（PONG）
    if (message.type === 'pong' || message.type === 'heartbeat' || message.action === WS_ACTION.PONG) {
      return true
    }

    // 用户发送的消息
    if (message.action === WS_ACTION.PUSH_USER_MESSAGE || message.data?.action === WS_ACTION.PUSH_USER_MESSAGE) {
      const handler = messageHandlers.get(WS_ACTION.PUSH_USER_MESSAGE)
      if (handler) {
        handler(message.data || message as WebSocketMessage)
      }
      return true
    }

    // 游客消息推送
    if ((message.type === 'push_message' || message.data?.type === 'push_message') &&
        (message.action === WS_ACTION.PUSH_VISITOR_MESSAGE || message.data?.action === WS_ACTION.PUSH_VISITOR_MESSAGE)) {
      const handler = messageHandlers.get(WS_ACTION.PUSH_VISITOR_MESSAGE)
      if (handler) {
        const data = message.data || message
        handler(data)
      }
      return true
    }

    // 游客会话结束推送
    if ((message.type === 'push_message' || message.data?.type === 'push_message') &&
        (message.action === WS_ACTION.PUSH_VISITOR_END || message.data?.action === WS_ACTION.PUSH_VISITOR_END)) {
      const handler = messageHandlers.get(WS_ACTION.PUSH_VISITOR_END)
      if (handler) {
        handler(message.data || message)
      }
      return true
    }

    return false
  }

  /**
   * 发送心跳（PING）
   *
   * @returns 是否发送成功
   */
  function sendHeartbeat(): boolean {
    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      return false
    }

    try {
      ws.value!.send(JSON.stringify({
        action: WS_ACTION.PING,
        timestamp: Date.now(),
      }))
      return true
    } catch (error) {
      return false
    }
  }

  /**
   * 启动心跳
   */
  function startHeartbeat() {
    stopHeartbeat()

    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      return
    }

    heartbeatTimer.value = window.setInterval(() => {
      if (ws.value && ws.value.readyState === WebSocket.OPEN) {
        const success = sendHeartbeat()
        if (!success) {
          stopHeartbeat()
          wsConnected.value = false
          scheduleReconnect()
        }
      } else {
        stopHeartbeat()
      }
    }, WS_CONFIG.HEARTBEAT_INTERVAL)
  }

  /**
   * 停止心跳
   */
  function stopHeartbeat() {
    if (heartbeatTimer.value) {
      clearInterval(heartbeatTimer.value)
      heartbeatTimer.value = null
    }
  }

  /**
   * 计划重连
   */
  function scheduleReconnect() {
    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
    }

    if (reconnectAttempts.value >= WS_CONFIG.MAX_RECONNECT_ATTEMPTS) {
      return
    }

    reconnectAttempts.value++
    wsReconnectTimer.value = window.setTimeout(() => {
      connectWebSocket()
    }, WS_CONFIG.RECONNECT_DELAY)
  }

  /**
   * 手动重新连接
   */
  function manualReconnect() {
    stopHeartbeat()
    reconnectAttempts.value = 0
    initialized.value = false
    wsConnected.value = false

    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
      wsReconnectTimer.value = null
    }

    rejectAllPendingOperations('WebSocket reconnecting')

    if (ws.value) {
      ws.value.onclose = null
      ws.value.onerror = null
      ws.value.close()
      ws.value = null
    }

    connectWebSocket()
  }

  /**
   * 连接 WebSocket
   */
  function connectWebSocket() {
    if (ws.value?.readyState === WebSocket.OPEN) {
      return
    }

    const userStore = useUserStore()
    const token = userStore.token

    if (!token) {
      return
    }

    try {
      const wsUrl = getWebSocketUrl()
      ws.value = new WebSocket(wsUrl)

      ws.value.onopen = () => {
        wsConnected.value = true
        reconnectAttempts.value = 0
        initialized.value = true
        sendWebSocketAuth()
        startHeartbeat()
      }

      ws.value.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data)
          handleWebSocketMessageType(message)
        } catch (error) {
          // 消息解析错误，忽略
        }
      }

      ws.value.onerror = () => {
        wsConnected.value = false
        stopHeartbeat()
        rejectAllPendingOperations('WebSocket connection lost')
        scheduleReconnect()
      }

      ws.value.onclose = () => {
        wsConnected.value = false
        stopHeartbeat()
        rejectAllPendingOperations('WebSocket connection closed')
        scheduleReconnect()
      }
    } catch (error) {
      wsConnected.value = false
      scheduleReconnect()
    }
  }

  /**
   * 初始化 WebSocket（自动检查并连接）
   */
  function initialize() {
    if (initialized.value) {
      return
    }

    const userStore = useUserStore()

    if (userStore.token) {
      connectWebSocket()
    }
  }

  /**
   * 关闭 WebSocket 连接
   */
  function closeWebSocket() {
    stopHeartbeat()

    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
      wsReconnectTimer.value = null
    }

    rejectAllPendingOperations('WebSocket connection closed')

    if (ws.value) {
      ws.value.onclose = null
      ws.value.close()
      ws.value = null
    }
    wsConnected.value = false
    reconnectAttempts.value = 0
    initialized.value = false
  }

  /**
   * 断线时触发重连（已在连接中则跳过，避免重复建连）
   */
  function ensureWebSocketReconnect() {
    if (ws.value?.readyState === WebSocket.OPEN || ws.value?.readyState === WebSocket.CONNECTING) {
      return
    }

    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
      wsReconnectTimer.value = null
    }

    reconnectAttempts.value = 0
    connectWebSocket()
  }

  /**
   * 发送 WebSocket 消息并等待响应
   *
   * @param action - WebSocket 操作类型
   * @param data - 消息数据
   * @param opId - 操作ID（可选）
   * @returns Promise<响应数据>（直至收到带 op_id 的响应，或连接关闭/重连时 reject）
   */
  async function sendWebSocketMessage(
    action: string,
    data: Record<string, any>,
    opId?: string,
  ): Promise<WebSocketResponse> {
    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      ensureWebSocketReconnect()
      throw new Error('WebSocket is not connected')
    }

    const operationId = opId || generateOperationId('op')

    return new Promise<WebSocketResponse>((resolve, reject) => {
      pendingOperations.value.set(operationId, {
        type: 'send',
        resolve,
        reject,
      })

      try {
        ws.value!.send(JSON.stringify({
          action,
          data,
          op_id: operationId,
        }))
      } catch (error) {
        pendingOperations.value.delete(operationId)
        ensureWebSocketReconnect()
        reject(error)
      }
    })
  }

  /**
   * 注册消息处理器
   *
   * @param action - 消息类型
   * @param handler - 处理函数
   */
  function registerMessageHandler(action: string, handler: MessageHandler) {
    messageHandlers.set(action, handler)
  }

  /**
   * 取消注册消息处理器
   *
   * @param action - 消息类型
   */
  function unregisterMessageHandler(action: string) {
    messageHandlers.delete(action)
  }

  /**
   * 清除所有消息处理器
   */
  function clearMessageHandlers() {
    messageHandlers.clear()
  }

  return {
    // 状态
    ws,
    wsConnected,
    isMaxReconnectReached,
    initialized,

    // 方法
    initialize,
    connectWebSocket,
    closeWebSocket,
    manualReconnect,
    sendWebSocketMessage,
    sendWebSocketLogout,
    cancelPendingOperation,
    registerMessageHandler,
    unregisterMessageHandler,
    clearMessageHandlers,
    setupTokenWatch, // 导出以便手动调用
  }
})

export default useWebSocketStore
