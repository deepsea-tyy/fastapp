/**
 * 客服聊天常量配置
 */

export const CHAT_CONSTANTS = {
  // 分页配置
  PAGE_SIZE: 10,

  // WebSocket 配置
  MAX_RECONNECT_ATTEMPTS: 5,
  RECONNECT_DELAY: 3000,
  WS_MESSAGE_TIMEOUT: 1000,
  HEARTBEAT_INTERVAL: 30000, // 30秒
  DEFAULT_WS_URL: 'ws://127.0.0.1:9502/ws',

  // 滚动配置
  SCROLL_THRESHOLD: 50,

  // 发送者类型
  SENDER_TYPE: {
    USER: 1,    // 用户/游客
    KEFU: 2,    // 客服
  },

  // 消息类型
  MESSAGE_TYPE: {
    TEXT: 1,    // 文本
    IMAGE: 2,   // 图片
    FILE: 3,    // 文件
  },

  // WebSocket Action
  WS_ACTION: {
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

    // 系统消息
    LOGIN: 'login',
    PING: 'ping',
    PONG: 'pong',
  },
} as const
