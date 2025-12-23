/**
 * 客服聊天主入口模块
 * 组合 WebSocket、会话管理和消息管理三个模块，提供统一接口
 */

import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import type { Conversation } from '../types'
import { Loading } from '@element-plus/icons-vue'
import { useMessage } from '@/hooks/useMessage.ts'
import useUserStore from '@/store/modules/useUserStore'
import { formatTime } from '../helpers'
import { useWebSocket } from './useWebSocket'
import { useConversations } from './useConversations'
import { useMessages } from './useMessages'
import { CHAT_CONSTANTS } from '../constants'

/**
 * 客服聊天主 Hook
 *
 * @returns 客服聊天完整接口
 */
export default function useChatLogic() {
  const i18n = useTrans() as TransType
  const t = i18n.globalTrans
  const msg = useMessage()
  const userStore = useUserStore()

  // 1. 初始化 WebSocket 模块
  const wsModule = useWebSocket(userStore.token)

  // 2. 初始化会话管理模块（依赖 WebSocket）
  const conversationsModule = useConversations(wsModule, t)

  // 3. 初始化消息管理模块（依赖 WebSocket 和会话管理）
  const messagesModule = useMessages(wsModule, conversationsModule, msg)

  // 4. 注册 WebSocket 消息处理器
  wsModule.registerMessageHandler(
    CHAT_CONSTANTS.WS_ACTION.PUSH_USER_MESSAGE,
    conversationsModule.handleWebSocketConversationUpdate,
  )

  wsModule.registerMessageHandler(
    CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_MESSAGE,
    (message: any) => {

      // 处理游客消息
      conversationsModule.handleVisitorWebSocketMessage(message)

      // 如果当前正在查看该游客会话，同时更新消息列表
      if (conversationsModule.selectedConversation.value &&
        conversationsModule.selectedConversation.value.type === 'visitor' &&
        conversationsModule.selectedConversation.value.visitor_id === message.visitor_id) {
        const formattedMessage = {
          ...message,
          message_id: message.message_id || message.id,
          id: message.id || message.message_id,
        }
        messagesModule.addMessageToList(formattedMessage)

        // 如果是游客发送的消息，清零未读数
        if (message.sender_type === CHAT_CONSTANTS.SENDER_TYPE.USER) {
          conversationsModule.updateVisitorConversationUnread(
            message.visitor_id,
            message.kefu_id,
            0,
          )
        }
      } else {
      }
    },
  )

  wsModule.registerMessageHandler(
    CHAT_CONSTANTS.WS_ACTION.PUSH_VISITOR_END,
    (message: any) => {
      // 刷新游客会话列表
      conversationsModule.loadVisitorConversations()

      // 如果当前选中的是已结束的游客会话，清空选中状态
      if (conversationsModule.selectedConversation.value &&
        conversationsModule.selectedConversation.value.type === 'visitor' &&
        conversationsModule.selectedConversation.value.visitor_id === message.visitor_id &&
        String(conversationsModule.selectedConversation.value.kefu_id) === String(message.kefu_id)) {
        conversationsModule.selectedConversation.value = null
        messagesModule.messages.value = []
      }
    },
  )

  // 注册用户消息推送处理器，同时处理会话和消息列表
  wsModule.registerMessageHandler(
    CHAT_CONSTANTS.WS_ACTION.PUSH_USER_MESSAGE,
    (message: any) => {
      // 更新会话信息
      conversationsModule.handleWebSocketConversationUpdate(message)

      // 如果消息属于当前选中的会话，则添加到消息列表
      if (conversationsModule.selectedConversation.value &&
        message.conversation_id &&
        message.conversation_id === conversationsModule.selectedConversation.value.conversation_id) {
        const formattedMessage = {
          ...message,
          message_id: message.message_id || message.id,
          id: message.id || message.message_id,
          kefu_id: message.kefu_id ? String(message.kefu_id) : undefined,
        }
        messagesModule.addMessageToList(formattedMessage)

        // 当前会话正在查看，如果是用户消息则清零未读数
        if (message.sender_type === CHAT_CONSTANTS.SENDER_TYPE.USER) {
          const conversation = conversationsModule.findConversationNode(message.conversation_id)
          if (conversation) {
            conversation.unread_count = 0
            if (conversationsModule.selectedConversation.value) {
              conversationsModule.selectedConversation.value.unread_count = 0
            }

            // 重新计算管理员未读数
            const kefuNode = conversationsModule.findKefuNode(conversation.kefu_id)
            if (kefuNode) {
              kefuNode.unread_count = (kefuNode.children || []).reduce(
                (sum, child) => sum + (child.unread_count || 0),
                0,
              )
            }
          }
        }
      }
    },
  )

  /**
   * 处理树节点点击（协调会话选择和消息加载）
   */
  async function handleNodeClick(data: Conversation) {
    // 如果点击的是管理员节点，不做处理（仅展开/收起）
    if (data.type === 'admin') {
      return
    }

    if (data.type === 'user' && data.conversation_id) {
      conversationsModule.selectedConversation.value = data
      const conversationId = data.conversation_id

      // 先加载消息列表
      await messagesModule.loadMessages(conversationId, false)

      // 标记已读
      await messagesModule.markConversationAsRead(conversationId)
    } else if (data.type === 'visitor' && data.visitor_id && data.kefu_id) {
      conversationsModule.selectedConversation.value = data
      const visitorId = data.visitor_id
      const kefuId = data.kefu_id

      // 先加载消息列表
      await messagesModule.loadMessages(0, true, visitorId, String(kefuId))

      // 点击游客会话时，清零未读数
      conversationsModule.updateVisitorConversationUnread(visitorId, kefuId, 0)
    } else {
      // 数据不完整，输出警告
    }
  }

  // 6. 统一导出接口
  return {
    // 图标
    Loading,

    // 国际化
    t,

    // WebSocket 模块
    ws: wsModule.ws,
    wsConnected: wsModule.wsConnected,
    isMaxReconnectReached: wsModule.isMaxReconnectReached,
    connectWebSocket: wsModule.connectWebSocket,
    closeWebSocket: wsModule.closeWebSocket,
    manualReconnect: wsModule.manualReconnect,

    // 会话管理模块
    treeData: conversationsModule.treeData,
    visitorTreeData: conversationsModule.visitorTreeData,
    selectedConversation: conversationsModule.selectedConversation,
    loading: conversationsModule.loading,
    visitorLoading: conversationsModule.visitorLoading,
    loadConversations: conversationsModule.loadConversations,
    loadVisitorConversations: conversationsModule.loadVisitorConversations,

    // 消息管理模块
    messages: messagesModule.messages,
    messageContent: messagesModule.messageContent,
    messagesLoading: messagesModule.messagesLoading,
    messageListRef: messagesModule.messageListRef,
    loadingMore: messagesModule.loadingMore,
    hasMore: messagesModule.hasMore,
    handleSendMessage: messagesModule.handleSendMessage,
    endConversation: messagesModule.endConversation,
    handleScroll: messagesModule.handleScroll,

    // 工具函数
    formatTime,

    // 协调方法
    handleNodeClick,
  }
}
