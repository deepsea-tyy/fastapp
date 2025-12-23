/**
 * WebSocket 连接管理模块
 * 负责 WebSocket 连接的建立、心跳、重连和消息收发
 */

import type { WebSocketMessage, WebSocketResponse, PendingOperation } from '../types'
import { CHAT_CONSTANTS } from '../constants'
import { generateOperationId } from '../helpers'

/**
 * 消息处理器类型
 */
type MessageHandler = (message: any) => void | Promise<void>

/**
 * useWebSocket 返回类型
 */
export interface UseWebSocketReturn {
  // 状态
  ws: Ref<WebSocket | null>
  wsConnected: Ref<boolean>
  isMaxReconnectReached: ComputedRef<boolean>

  // 方法
  connectWebSocket: () => void
  closeWebSocket: () => void
  manualReconnect: () => void
  sendWebSocketMessage: (action: string, data: Record<string, any>, opId?: string, timeout?: number) => Promise<WebSocketResponse>
  registerMessageHandler: (action: string, handler: MessageHandler) => void
}

/**
 * WebSocket 连接管理 Hook
 *
 * @param token - 用户认证令牌
 * @returns WebSocket 管理接口
 */
export function useWebSocket(token: string): UseWebSocketReturn {
  // WebSocket 相关状态
  const ws = ref<WebSocket | null>(null)
  const wsConnected = ref(false)
  const wsReconnectTimer = ref<number | null>(null)
  const reconnectAttempts = ref(0)
  const heartbeatTimer = ref<number | null>(null)

  // WebSocket 操作ID跟踪
  const pendingOperations = ref<Map<string, PendingOperation>>(new Map())

  // 消息处理器注册表
  const messageHandlers = new Map<string, MessageHandler>()

  /**
   * 获取 WebSocket 地址
   */
  function getWebSocketUrl(): string {
    const env = import.meta.env
    return (env.VITE_APP_WS_URL as string) || CHAT_CONSTANTS.DEFAULT_WS_URL
  }

  /**
   * 发送 WebSocket 认证消息
   */
  function sendWebSocketAuth() {
    if (ws.value && token) {
      const authData = {
        action: CHAT_CONSTANTS.WS_ACTION.LOGIN,
        data: { token },
      }
      ws.value.send(JSON.stringify(authData))
    }
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
      clearTimeout(operation.timeout)
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
    if (message.type === 'connected') {
      return true
    }

    // 认证成功响应
    if (message.success === true && message.message === 'Authentication successful') {
      return true
    }

    // 心跳响应（PONG）
    if (message.type === 'pong' || message.type === 'heartbeat' || message.action === CHAT_CONSTANTS.WS_ACTION.PONG) {
      return true
    }

    // 用户发送的消息
    if (message.action === CHAT_CONSTANTS.WS_ACTION.PUSH_USER_MESSAGE || message.data?.action === CHAT_CONSTANTS.WS_ACTION.PUSH_USER_MESSAGE) {
      const handler = messageHandlers.get(CHAT_CONSTANTS.WS_ACTION.PUSH_USER_MESSAGE)
      if (handler) {
        handler(message.data || message as WebSocketMessage)
      }
      return true
    }

    // 游客消息推送
    if ((message.type === 'push_message' || message.data?.type === 'push_message') &&
        (message.action === CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_MESSAGE || message.data?.action === CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_MESSAGE)) {
      const handler = messageHandlers.get(CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_MESSAGE)
      if (handler) {
        const data = message.data || message
        handler(data)
      }
      return true
    }

    // 游客会话结束推送
    if ((message.type === 'push_message' || message.data?.type === 'push_message') &&
        (message.action === CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_END || message.data?.action === CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_END)) {
      const handler = messageHandlers.get(CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_END)
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
      ws.value.send(JSON.stringify({
        action: CHAT_CONSTANTS.WS_ACTION.PING,
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
    }, CHAT_CONSTANTS.HEARTBEAT_INTERVAL)
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

    if (reconnectAttempts.value >= CHAT_CONSTANTS.MAX_RECONNECT_ATTEMPTS) {
      return
    }

    reconnectAttempts.value++
    wsReconnectTimer.value = window.setTimeout(() => {
      connectWebSocket()
    }, CHAT_CONSTANTS.RECONNECT_DELAY)
  }

  /**
   * 判断是否超过最大重连数
   */
  const isMaxReconnectReached = computed(() => {
    return !wsConnected.value && reconnectAttempts.value >= CHAT_CONSTANTS.MAX_RECONNECT_ATTEMPTS
  })

  /**
   * 手动重新连接
   */
  function manualReconnect() {
    stopHeartbeat()
    reconnectAttempts.value = 0

    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
      wsReconnectTimer.value = null
    }

    if (ws.value) {
      ws.value.onclose = null
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

    if (!token) {
      return
    }

    try {
      const wsUrl = getWebSocketUrl()
      ws.value = new WebSocket(wsUrl)

      ws.value.onopen = () => {
        wsConnected.value = true
        reconnectAttempts.value = 0
        sendWebSocketAuth()
        startHeartbeat()
      }

      ws.value.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data)
          const handled = handleWebSocketMessageType(message)
        } catch (error) {
        }
      }

      ws.value.onerror = () => {
        wsConnected.value = false
        stopHeartbeat()
        scheduleReconnect()
      }

      ws.value.onclose = () => {
        wsConnected.value = false
        stopHeartbeat()
        scheduleReconnect()
      }
    } catch (error) {
      wsConnected.value = false
      scheduleReconnect()
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

    // 清理所有待处理的操作
    pendingOperations.value.forEach((operation) => {
      clearTimeout(operation.timeout)
      operation.reject(new Error('WebSocket connection closed'))
    })
    pendingOperations.value.clear()

    if (ws.value) {
      ws.value.onclose = null
      ws.value.close()
      ws.value = null
    }
    wsConnected.value = false
    reconnectAttempts.value = 0
  }

  /**
   * 发送 WebSocket 消息并等待响应
   *
   * @param action - WebSocket 操作类型
   * @param data - 消息数据
   * @param opId - 操作ID（可选）
   * @param timeout - 超时时间（毫秒）
   * @returns Promise<响应数据>
   */
  async function sendWebSocketMessage(
    action: string,
    data: Record<string, any>,
    opId?: string,
    timeout = CHAT_CONSTANTS.WS_MESSAGE_TIMEOUT * 5,
  ): Promise<WebSocketResponse> {
    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket is not connected')
    }

    const operationId = opId || generateOperationId('op')

    return new Promise<WebSocketResponse>((resolve, reject) => {
      const timeoutId = window.setTimeout(() => {
        pendingOperations.value.delete(operationId)
        reject(new Error('Operation timeout'))
      }, timeout)

      pendingOperations.value.set(operationId, {
        type: 'send',
        resolve,
        reject,
        timeout: timeoutId,
      })

      try {
        ws.value!.send(JSON.stringify({
          action,
          data,
          op_id: operationId,
        }))
      } catch (error) {
        pendingOperations.value.delete(operationId)
        clearTimeout(timeoutId)
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

  return {
    // 状态
    ws,
    wsConnected,
    isMaxReconnectReached,

    // 方法
    connectWebSocket,
    closeWebSocket,
    manualReconnect,
    sendWebSocketMessage,
    registerMessageHandler,
  }
}
