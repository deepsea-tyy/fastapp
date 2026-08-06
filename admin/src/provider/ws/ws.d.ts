
// WebSocket 请求消息
export interface WebSocketRequest {
  action: string
  data: Record<string, any>
  op_id?: string
}
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

// WebSocket 操作类型
export interface PendingOperation {
  type: 'send' | 'read'
  resolve: (data: any) => void
  reject: (error: any) => void
}
