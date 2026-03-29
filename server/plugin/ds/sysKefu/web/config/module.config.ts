/**
 * 客服模块 WebSocket 配置
 * 注册到全局 WebSocket 配置中心
 */

import { wsRegistry, type ModuleConfig } from '@/config/websocket.config'

/**
 * 客服模块 WebSocket 动作
 */
export const KEFU_WS_ACTIONS = {
  // 用户消息（客户端→服务器）
  USER_SEND: 'kefu_message_send',
  USER_READ: 'kefu_message_read',
  USER_END: 'kefu_message_end',

  // 游客消息（客户端→服务器）注意：游客动作有 visitor. 前缀
  VISITOR_SEND: 'visitor.kefu_message_send',
  VISITOR_END: 'visitor.kefu_message_end',

  // 推送消息（服务器→客户端）
  PUSH_USER_MESSAGE: 'kefu_message',
  PUSH_VISITOR_MESSAGE: 'kefu_visitor_message',
  PUSH_VISITOR_END: 'kefu_visitor_conversation_end',
} as const

/**
 * 客服模块业务常量
 */
export const KEFU_CONSTANTS = {
  // 分页配置
  PAGE_SIZE: 10,

  // 滚动配置
  SCROLL_THRESHOLD: 50,

  // 发送者类型
  SENDER_TYPE: {
    USER: 1, // 用户/游客
    KEFU: 2, // 客服
  },

  // 消息类型
  MESSAGE_TYPE: {
    TEXT: 1, // 文本
    IMAGE: 2, // 图片
    FILE: 3, // 文件
  },
} as const

/**
 * 客服模块配置
 */
export const kefuModuleConfig: ModuleConfig = {
  name: 'kefu',
  actions: KEFU_WS_ACTIONS,
  constants: KEFU_CONSTANTS,
  wsConfig: {
    url: import.meta.env.VITE_APP_WS_URL || 'ws://127.0.0.1:9502/ws',
    maxReconnectAttempts: 5,
    reconnectDelay: 3000,
    heartbeatInterval: 30000,
    messageTimeout: 5000,
  },
}

// 自动注册客服模块
wsRegistry.register(kefuModuleConfig)

// 导出类型
export type KefuWSActions = typeof KEFU_WS_ACTIONS
export type KefuConstants = typeof KEFU_CONSTANTS

// 导出统一的常量对象（方便使用）
export const CHAT_CONSTANTS = {
  ...KEFU_CONSTANTS,
  WS_ACTION: KEFU_WS_ACTIONS,
} as const
