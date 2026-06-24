/**
 * 客服聊天相关类型定义
 */

// 会话类型
export interface Conversation {
  id: string
  label: string
  type: 'admin' | 'user' | 'visitor'
  conversation_id?: number
  user_id?: number
  visitor_id?: string
  kefu_id: number
  avatar?: string
  unread_count: number
  status?: number
  last_message_at?: string | null
  children?: Conversation[]
  isVisitor?: boolean
}

// 消息类型
export interface Message {
  id?: number
  message_id?: number
  conversation_id?: number
  visitor_id?: string
  kefu_id?: string | number
  sender_id?: number
  sender_type: number
  content: string
  message_type?: number
  file_url?: string
  created_at: string
  updated_at?: string
  is_read?: number
}

// WebSocket 消息类型
export interface WebSocketMessage extends Message {
  action?: string
  type?: string
  timestamp?: number
  form_uid?: number
  to_uid?: number
}

// 管理员数据类型
export interface AdminItem {
  id: number
  nickname: string
  avatar?: string
  status: number
  max_concurrent: number
  current_concurrent: number
  created_at: string
  updated_at: string
  conversation: Array<{
    id: number
    kefu_id: number
    user_id: number
    status: number
    last_message_at: string | null
    kefu_unread_count: number
    unread_count: number
    created_at: string
    updated_at: string
    profile?: {
      user_id: number
      avatar?: string
      nickname?: string
    }
  }>
}

// 游客数据类型
export interface VisitorItem {
  id: number
  nickname: string
  avatar?: string
  status: number
  max_concurrent: number
  current_concurrent: number
  created_at: string
  updated_at: string
  visitor: Array<{
    kefu_id: string
    visitor_id: string
    conversation_id?: number
  }>
}

// 会话数据类型
export interface ConversationData {
  last_message_at?: string
  kefu_unread_count?: number
  unread_count?: number
}

// WebSocket 操作类型
export interface PendingOperation {
  type: 'send' | 'read'
  resolve: (data: any) => void
  reject: (error: any) => void
}

// WebSocket 请求消息
export interface WebSocketRequest {
  action: string
  data: Record<string, any>
  op_id?: string
}

// WebSocket 响应消息
export interface WebSocketResponse<T = any> {
  success: boolean
  message?: string
  data?: T
  op_id?: string
  type?: string
  action?: string
}

// WebSocket 推送消息
export interface WebSocketPushMessage extends WebSocketMessage {
  type: 'push_message'
}

// 发送消息响应
export interface SendMessageResponse {
  message_id: number
  created_at: string
  conversation?: ConversationData
}

// 标记已读响应
export interface ReadMessageResponse {
  updated_count: number
}

// 结束会话响应
export interface EndConversationResponse {
  conversation_id: number
}
