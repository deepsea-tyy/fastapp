/**
 * 消息管理模块
 * 负责消息列表加载、发送、标记已读和会话结束
 */

import type { Message, Conversation } from '../types'
import type { UseConversationsReturn } from './useConversations'
import { getMessages, getMessageVisitor } from '$/ds/sysKefu/api/kefuConversation'
import useUserStore from '@/store/modules/useUserStore'
import useWebSocketStore, { WS_ACTION } from '@/store/modules/useWebSocketStore'
import { ResultCode } from '@/utils/ResultCode'
import { useThrottleFn } from '@vueuse/core'
import { CHAT_CONSTANTS } from '$/ds/sysKefu/config/module.config'
import {
  formatMessage,
  calculateHasMore,
  getUnreadMessageIds,
  createMessageFromData,
  isMessageExists as checkMessageExists,
} from '../helpers'

/**
 * useMessages 返回类型
 */
export interface UseMessagesReturn {
  // 状态
  messages: Ref<Message[]>
  messageContent: Ref<string>
  messagesLoading: Ref<boolean>
  messageListRef: Ref<HTMLElement | undefined>
  loadingMore: Ref<boolean>
  hasMore: Ref<boolean>
  currentPage: Ref<number>

  // 方法
  loadMessages: (conversationId: number, isVisitor?: boolean, visitorId?: string, kefuId?: string) => Promise<void>
  loadMoreMessages: () => Promise<void>
  handleSendMessage: () => Promise<void>
  endConversation: () => Promise<void>
  markConversationAsRead: (conversationId: number) => Promise<void>
  handleScroll: () => void
  addMessageToList: (message: Message) => void
}

/**
 * 消息管理 Hook
 *
 * @param conversationsModule - 会话管理模块实例
 * @param msg - 消息提示实例
 * @returns 消息管理接口
 */
export function useMessages(
  conversationsModule: UseConversationsReturn,
  msg: any,
): UseMessagesReturn {
  const userStore = useUserStore()
  const wsStore = useWebSocketStore() // 直接在这里获取 store 实例

  // 消息相关状态
  const messages = ref<Message[]>([])
  const messageContent = ref('')
  const messagesLoading = ref(false)
  const messageListRef = ref<HTMLElement>()

  // 分页相关
  const currentPage = ref(1)
  const hasMore = ref(true)
  const loadingMore = ref(false)

  /**
   * 滚动到底部
   */
  function scrollToBottom() {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  }

  /**
   * 保持滚动位置
   */
  function maintainScrollPosition(previousScrollHeight: number) {
    nextTick(() => {
      if (messageListRef.value) {
        const newScrollHeight = messageListRef.value.scrollHeight
        messageListRef.value.scrollTop = newScrollHeight - previousScrollHeight
      }
    })
  }

  /**
   * 检查消息是否已存在
   */
  function isMessageExists(message: Message): boolean {
    return checkMessageExists(messages.value, message)
  }

  /**
   * 添加消息到列表
   */
  function addMessageToList(message: Message) {

    if (isMessageExists(message)) {
      return
    }

    messages.value.push(message)

    nextTick(() => {
      scrollToBottom()
    })
  }

  /**
   * 加载消息（首次加载或重新选择会话）
   */
  async function loadMessages(
    conversationId: number,
    isVisitor: boolean = false,
    visitorId?: string,
    kefuId?: string,
  ) {
    messagesLoading.value = true
    currentPage.value = 1
    hasMore.value = true

    try {
      let response
      if (isVisitor && visitorId && kefuId) {
        response = await getMessageVisitor({
          visitor_id: visitorId,
          kefu_id: kefuId,
          page: 1,
          page_size: CHAT_CONSTANTS.PAGE_SIZE,
        })
      } else {
        response = await getMessages({
          conversation_id: conversationId,
          page: 1,
          page_size: CHAT_CONSTANTS.PAGE_SIZE,
        })
      }

      if (response.code === ResultCode.SUCCESS) {
        const pageData = response.data
        const list = (pageData?.list || []) as Message[]
        const total = pageData?.total || 0

        // 格式化消息列表
        const formattedList = list.map(formatMessage)

        messages.value = formattedList
        hasMore.value = calculateHasMore(list.length, total)

        nextTick(() => {
          scrollToBottom()
        })
      }
    } catch (error: any) {
      msg.alertError(error)
    } finally {
      messagesLoading.value = false
    }
  }

  /**
   * 加载更多历史消息
   */
  async function loadMoreMessages() {
    if (!conversationsModule.selectedConversation.value || loadingMore.value || !hasMore.value) {
      return
    }

    loadingMore.value = true
    const nextPage = currentPage.value + 1
    const scrollHeight = messageListRef.value?.scrollHeight || 0
    const isVisitor = conversationsModule.selectedConversation.value.type === 'visitor' ||
      conversationsModule.selectedConversation.value.isVisitor

    try {
      let response
      if (isVisitor && conversationsModule.selectedConversation.value.visitor_id &&
        conversationsModule.selectedConversation.value.kefu_id) {
        response = await getMessageVisitor({
          visitor_id: conversationsModule.selectedConversation.value.visitor_id,
          kefu_id: String(conversationsModule.selectedConversation.value.kefu_id),
          page: nextPage,
          page_size: CHAT_CONSTANTS.PAGE_SIZE,
        })
      } else {
        response = await getMessages({
          conversation_id: conversationsModule.selectedConversation.value.conversation_id!,
          page: nextPage,
          page_size: CHAT_CONSTANTS.PAGE_SIZE,
        })
      }

      if (response.code === ResultCode.SUCCESS) {
        const pageData = response.data
        const list = (pageData?.list || []) as Message[]
        const total = pageData?.total || 0

        if (list.length > 0) {
          const formattedList = list.map(formatMessage)
          messages.value = [...formattedList, ...messages.value]
          currentPage.value = nextPage
          hasMore.value = calculateHasMore(list.length, total, messages.value.length)
          maintainScrollPosition(scrollHeight)
        } else {
          hasMore.value = false
        }
      }
    } catch (error: any) {
      msg.alertError(error)
    } finally {
      loadingMore.value = false
    }
  }

  /**
   * 处理滚动事件（使用节流优化性能）
   */
  const handleScroll = useThrottleFn(() => {
    if (!messageListRef.value || loadingMore.value || !hasMore.value) {
      return
    }

    // 当滚动到顶部时加载更多
    if (messageListRef.value.scrollTop <= CHAT_CONSTANTS.SCROLL_THRESHOLD) {
      loadMoreMessages()
    }
  }, 150, true, true)

  /**
   * 通过 WebSocket 标记未读消息为已读
   */
  async function markMessagesAsRead(conversationId: number, messageIds: number[]) {
    if (messageIds.length === 0) return

    if (!wsStore.wsConnected) {
      return
    }

    try {
      const response = await wsStore.sendWebSocketMessage(
        WS_ACTION.USER_READ,
        {
          conversation_id: conversationId,
          sender_type: 2,
          message_ids: [],
        },
      )

      if (response.data?.updated_count !== undefined) {
        conversationsModule.updateConversationUnread(conversationId, 0)
      }
    } catch (error) {
      // 标记已读失败不影响消息显示
    }
  }

  /**
   * 标记当前会话的所有未读消息为已读
   */
  async function markConversationAsRead(conversationId: number) {
    const conversation = conversationsModule.findConversationNode(conversationId)
    if (!conversation) {
      return
    }

    const messageIds = getUnreadMessageIds(messages.value)

    try {
      await markMessagesAsRead(conversationId, messageIds)
      conversationsModule.updateConversationUnread(conversationId, 0)
    } catch (error) {
      // 标记已读失败不影响消息显示
    }
  }

  /**
   * 发送消息（通过 WebSocket）
   */
  async function handleSendMessage() {
    if (!messageContent.value.trim() || !conversationsModule.selectedConversation.value) {
      return
    }

    if (!wsStore.wsConnected) {
      msg.error('WebSocket 未连接，请稍后重试')
      return
    }

    const content = messageContent.value.trim()
    const currentConversation = conversationsModule.selectedConversation.value
    const isVisitor = currentConversation.type === 'visitor' || currentConversation.isVisitor === true

    try {
      // 先清空输入框
      messageContent.value = ''

      let response
      if (isVisitor && currentConversation.visitor_id && currentConversation.kefu_id) {
        // 游客会话
        response = await wsStore.sendWebSocketMessage(
          WS_ACTION.VISITOR_SEND,
          {
            visitor_id: currentConversation.visitor_id,
            kefu_id: String(currentConversation.kefu_id),
            content: content,
            sender_type: 2,
          },
        )

        if (response.data) {
          const newMessage: Message = {
            id: response.data.message_id,
            message_id: response.data.message_id,
            visitor_id: currentConversation.visitor_id,
            kefu_id: String(currentConversation.kefu_id),
            sender_id: userStore.getUserInfo().id,
            sender_type: CHAT_CONSTANTS.SENDER_TYPE.KEFU,
            content: content,
            message_type: CHAT_CONSTANTS.MESSAGE_TYPE.TEXT,
            created_at: response.data.created_at || new Date().toISOString(),
          }
          addMessageToList(newMessage)
        }
      } else if (currentConversation.conversation_id) {
        // 用户会话
        response = await wsStore.sendWebSocketMessage(
          WS_ACTION.USER_SEND,
          {
            sender_type: 2,
            conversation_id: currentConversation.conversation_id,
            content: content,
            message_type: CHAT_CONSTANTS.MESSAGE_TYPE.TEXT,
            file_url: null,
          },
        )

        if (response.data) {
          const conversationId = currentConversation.conversation_id
          const newMessage = createMessageFromData({
            id: response.data.message_id,
            conversation_id: conversationId,
            sender_id: userStore.getUserInfo().id,
            sender_type: CHAT_CONSTANTS.SENDER_TYPE.KEFU,
            content: content,
            message_type: CHAT_CONSTANTS.MESSAGE_TYPE.TEXT,
            created_at: response.data.created_at,
          })
          addMessageToList(newMessage)

          // 更新会话信息
          if (response.data.conversation) {
            conversationsModule.updateConversationFromResponse(conversationId, response.data.conversation)
          } else if (response.data.created_at) {
            conversationsModule.updateConversationLastMessage(conversationId, response.data.created_at)
          }
        }
      } else {
        msg.error('会话信息不完整，无法发送消息')
        messageContent.value = content
        return
      }
    } catch (error: any) {
      // 恢复输入框内容
      messageContent.value = content
      msg.alertError(error)
    }
  }

  /**
   * 结束会话（通过 WebSocket）
   */
  async function endConversation() {
    if (!conversationsModule.selectedConversation.value) {
      return
    }

    if (!wsStore.wsConnected) {
      msg.error('WebSocket 未连接，请稍后重试')
      return
    }

    const isVisitor = conversationsModule.selectedConversation.value.type === 'visitor' ||
      conversationsModule.selectedConversation.value.isVisitor

    try {
      if (isVisitor && conversationsModule.selectedConversation.value.visitor_id &&
        conversationsModule.selectedConversation.value.kefu_id) {
        // 游客会话
        await wsStore.sendWebSocketMessage(
          WS_ACTION.VISITOR_END,
          {
            visitor_id: conversationsModule.selectedConversation.value.visitor_id,
            kefu_id: String(conversationsModule.selectedConversation.value.kefu_id),
            sender_type: 2,
          },
        )

        conversationsModule.loadVisitorConversations()
      } else {
        // 用户会话
        const conversationId = conversationsModule.selectedConversation.value.conversation_id!
        await wsStore.sendWebSocketMessage(
          WS_ACTION.USER_END,
          {
            conversation_id: conversationId,
          },
        )

        conversationsModule.loadConversations()
      }

      // 清空当前选中的会话和消息
      conversationsModule.selectedConversation.value = null
      messages.value = []
      msg.success('会话已结束')
    } catch (error: any) {
      msg.alertError(error)
    }
  }

  return {
    // 状态
    messages,
    messageContent,
    messagesLoading,
    messageListRef,
    loadingMore,
    hasMore,
    currentPage,

    // 方法
    loadMessages,
    loadMoreMessages,
    handleSendMessage,
    endConversation,
    markConversationAsRead,
    handleScroll,
    addMessageToList,
  }
}
