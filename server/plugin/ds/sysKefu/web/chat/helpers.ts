/**
 * 客服聊天辅助函数
 */

import type { Conversation, Message, AdminItem, VisitorItem } from './types'
import { CHAT_CONSTANTS } from './constants'
import defaultAvatar from '/defaultAvatar.jpg'

/**
 * 规范化 kefuId（统一转换为 number）
 */
export function normalizeKefuId(kefuId: number | string): number {
  return typeof kefuId === 'string' ? parseInt(kefuId) : kefuId
}

/**
 * 格式化消息（统一处理消息格式）
 */
export function formatMessage(msg: any): Message {
  return {
    ...msg,
    message_id: msg.message_id || msg.id,
    id: msg.id || msg.message_id,
    message_type: msg.message_type || CHAT_CONSTANTS.MESSAGE_TYPE.TEXT,
    sender_type: msg.sender_type !== undefined && msg.sender_type !== null
      ? msg.sender_type
      : CHAT_CONSTANTS.SENDER_TYPE.USER,
    sender_id: msg.sender_id || (msg.sender_type === CHAT_CONSTANTS.SENDER_TYPE.KEFU ? parseInt(String(msg.kefu_id)) : undefined),
    conversation_id: msg.conversation_id,
    file_url: msg.file_url,
    is_read: msg.is_read,
  }
}

/**
 * 判断是否还有更多消息
 */
export function calculateHasMore(listLength: number, total: number, currentLength?: number): boolean {
  const currentTotal = currentLength ?? listLength
  return listLength >= CHAT_CONSTANTS.PAGE_SIZE && total > currentTotal
}

/**
 * 获取未读消息ID列表
 */
export function getUnreadMessageIds(messages: Message[]): number[] {
  return messages
    .filter((msg) => msg.sender_type === CHAT_CONSTANTS.SENDER_TYPE.USER && !msg.is_read)
    .map((msg) => msg.id!)
    .filter(Boolean)
}

/**
 * 生成操作ID
 */
export function generateOperationId(prefix: string = 'op'): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
}

/**
 * 格式化时间
 */
export function formatTime(time: string): string {
  if (!time) return ''
  return useDayjs(time).format('YYYY-MM-DD HH:mm:ss')
}

/**
 * 转换会话数据为树节点
 */
export function transformConversationToNode(
  conv: AdminItem['conversation'][0],
  adminId: number,
  t: (key: string) => string,
): Conversation {
  const avatarSrc = conv.profile?.avatar || defaultAvatar
  return {
    id: `user_${conv.user_id}_${conv.id}`,
    label: conv.profile?.nickname || `${t('kefu.common.labels.uid')} ${conv.user_id}`,
    type: 'user',
    conversation_id: conv.id,
    user_id: conv.user_id,
    kefu_id: adminId,
    avatar: avatarSrc,
    unread_count: conv.kefu_unread_count || 0,
    status: conv.status,
    last_message_at: conv.last_message_at,
  }
}

/**
 * 转换管理员数据为树节点
 */
export function transformAdminToNode(adminItem: AdminItem, t: (key: string) => string): Conversation {
  const adminId = adminItem.id
  const adminName = adminItem.nickname || `${t('kefu.common.labels.admin')} ${adminId}`

  const children = (adminItem.conversation || []).map((conv) =>
    transformConversationToNode(conv, adminId, t),
  )

  const totalUnread = children.reduce((sum, child) => sum + (child.unread_count || 0), 0)

  return {
    id: `admin_${adminId}`,
    label: adminName,
    type: 'admin',
    kefu_id: adminId,
    avatar: adminItem.avatar,
    unread_count: totalUnread,
    children,
  }
}

/**
 * 转换单个游客数据为树节点
 */
export function transformSingleVisitorToNode(
  visitor: { kefu_id: string; visitor_id: string; conversation_id?: number },
  adminId: number,
  t: (key: string) => string,
): Conversation {
  const visitorId = visitor.visitor_id || ''
  const kefuId = parseInt(visitor.kefu_id || '0')
  const conversationId = visitor.conversation_id

  return {
    id: `visitor_${adminId}_${visitorId}`,
    label: `${t('kefu.common.labels.visitor')} ${visitorId}`,
    type: 'visitor',
    conversation_id: conversationId,
    visitor_id: visitorId,
    kefu_id: kefuId,
    avatar: defaultAvatar,
    unread_count: 0,
    isVisitor: true,
  }
}

/**
 * 创建新的游客会话节点
 */
export function createVisitorConversationNode(
  visitorId: string,
  kefuId: number | string,
  t: (key: string) => string,
): Conversation {
  const kefuIdNum = normalizeKefuId(kefuId)
  return {
    id: `visitor_${kefuIdNum}_${visitorId}`,
    label: `${t('kefu.common.labels.visitor')} ${visitorId}`,
    type: 'visitor',
    visitor_id: visitorId,
    kefu_id: kefuIdNum,
    avatar: defaultAvatar,
    unread_count: 0,
    isVisitor: true,
    last_message_at: null,
  }
}

/**
 * 重新计算管理员的未读总数
 */
export function recalculateKefuUnreadCount(kefuNode: Conversation): void {
  if (kefuNode.children) {
    kefuNode.unread_count = kefuNode.children.reduce(
      (sum, child) => sum + (child.unread_count || 0),
      0,
    )
  }
}

/**
 * 创建消息对象
 */
export function createMessageFromData(messageData: any): Message {
  return {
    id: messageData.id,
    message_id: messageData.id,
    conversation_id: messageData.conversation_id,
    sender_id: messageData.sender_id,
    sender_type: messageData.sender_type,
    content: messageData.content,
    message_type: messageData.message_type,
    file_url: messageData.file_url,
    created_at: messageData.created_at,
  }
}

/**
 * 检查消息是否已存在
 */
export function isMessageExists(messages: Message[], message: Message): boolean {
  const messageId = message.message_id || message.id
  console.log('[isMessageExists] 检查消息是否存在:', {
    messageId,
    message,
    existingMessages: messages.map(m => ({ id: m.id, message_id: m.message_id })),
  })

  if (!messageId) {
    console.log('[isMessageExists] 消息没有ID，返回false')
    return false
  }

  const exists = messages.some((msg) => (msg.message_id || msg.id) === messageId)
  console.log('[isMessageExists] 检查结果:', exists)
  return exists
}
