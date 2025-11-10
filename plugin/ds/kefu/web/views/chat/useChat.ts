import type { TransType } from '@/hooks/auto-imports/useTrans.ts'

import { Loading } from '@element-plus/icons-vue'
import { chatTree, chatVisitorTree, getMessages, getMessageVisitor } from '$/ds/kefu/api/kefuConversation.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import defaultAvatar from '/defaultAvatar.jpg'
import { useThrottleFn } from '@vueuse/core'

// 常量定义
const CONSTANTS = {
  PAGE_SIZE: 10,
  MAX_RECONNECT_ATTEMPTS: 5,
  RECONNECT_DELAY: 3000,
  SCROLL_THRESHOLD: 50,
  WS_MESSAGE_TIMEOUT: 1000,
  HEARTBEAT_INTERVAL: 30000, // 心跳间隔 30秒
  DEFAULT_WS_URL: 'ws://127.0.0.1:9502/ws',
  SENDER_TYPE: {
    USER: 1,
    KEFU: 2,
  },
  MESSAGE_TYPE: {
    TEXT: 1,
    IMAGE: 2,
    FILE: 3,
  },
} as const

// 类型定义
interface Conversation {
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

interface Message {
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

interface WebSocketMessage extends Message {
  action?: string
  type?: string
  timestamp?: number
  kefu_id?: number | string
  form_uid?: number
  to_uid?: number
}

interface AdminItem {
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

interface VisitorItem {
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

interface ConversationData {
  last_message_at?: string
  kefu_unread_count?: number
  unread_count?: number
}

export default function useChatLogic() {
  const i18n = useTrans() as TransType
  const t = i18n.globalTrans
  const msg = useMessage()
  const userStore = useUserStore()

  // WebSocket 相关
  const ws = ref<WebSocket | null>(null)
  const wsConnected = ref(false)
  const wsReconnectTimer = ref<number | null>(null)
  const reconnectAttempts = ref(0)
  const heartbeatTimer = ref<number | null>(null)

  // 树形数据
  const treeData = ref<Conversation[]>([])
  const visitorTreeData = ref<Conversation[]>([])
  const selectedConversation = ref<Conversation | null>(null)
  const messages = ref<Message[]>([])
  const messageContent = ref('')
  const loading = ref(false)
  const visitorLoading = ref(false)
  const messagesLoading = ref(false)
  const messageListRef = ref<HTMLElement>()

  // 分页相关
  const currentPage = ref(1)
  const hasMore = ref(true)
  const loadingMore = ref(false)

  // 发送消息后是否收到 WebSocket 消息的标记
  const sentMessageReceived = ref(false)
  const pendingConversationId = ref<number | null>(null)

  // WebSocket 操作ID跟踪
  const pendingOperations = ref<Map<string, {
    type: 'send' | 'read'
    resolve: (data: any) => void
    reject: (error: any) => void
    timeout: number
  }>>(new Map())

  // 缓存：会话ID到会话节点的映射
  const conversationCache = computed(() => {
    const cache = new Map<number, Conversation>()
    const traverse = (nodes: Conversation[]) => {
      nodes.forEach((node) => {
        if (node.conversation_id) {
          cache.set(node.conversation_id, node)
        }
        if (node.children) {
          traverse(node.children)
        }
      })
    }
    traverse(treeData.value)
    traverse(visitorTreeData.value)
    return cache
  })

  // 缓存：管理员ID到管理员节点的映射
  const adminCache = computed(() => {
    const cache = new Map<number, Conversation>()
    const traverse = (nodes: Conversation[]) => {
      nodes.forEach((node) => {
        if (node.type === 'admin' && node.kefu_id) {
          cache.set(node.kefu_id, node)
        }
        if (node.children) {
          traverse(node.children)
        }
      })
    }
    traverse(treeData.value)
    traverse(visitorTreeData.value)
    return cache
  })

  /**
   * 查找会话节点（使用缓存）
   */
  function findConversationNode(conversationId: number): Conversation | null {
    return conversationCache.value.get(conversationId) || null
  }

  /**
   * 查找管理员节点（使用缓存）
   */
  function findKefuNode(adminId: number): Conversation | null {
    return adminCache.value.get(adminId) || null
  }

  /**
   * 查找游客会话节点（工具函数）
   */
  function findVisitorConversation(visitorId: string): Conversation | null {
    return visitorTreeData.value
      .flatMap((admin) => admin.children || [])
      .find((conv) => conv.visitor_id === visitorId) || null
  }

  /**
   * 查找包含指定游客的管理员节点
   */
  function findKefuNodeByVisitor(visitorId: string): Conversation | null {
    return visitorTreeData.value.find((admin) => 
      admin.children?.some((child) => child.visitor_id === visitorId)
    ) || null
  }

  /**
   * 规范化 kefuId（统一转换为 number）
   */
  function normalizeKefuId(kefuId: number | string): number {
    return typeof kefuId === 'string' ? parseInt(kefuId) : kefuId
  }

  /**
   * 格式化消息（统一处理消息格式）
   */
  function formatMessage(msg: any): Message {
    return {
      ...msg,
      message_id: msg.message_id || msg.id,
      id: msg.id || msg.message_id,
      message_type: msg.message_type || CONSTANTS.MESSAGE_TYPE.TEXT,
      sender_type: msg.sender_type !== undefined && msg.sender_type !== null 
        ? msg.sender_type 
        : CONSTANTS.SENDER_TYPE.USER,
      sender_id: msg.sender_id || (msg.sender_type === CONSTANTS.SENDER_TYPE.KEFU ? parseInt(String(msg.kefu_id)) : undefined),
      conversation_id: msg.conversation_id,
      file_url: msg.file_url,
      is_read: msg.is_read,
    }
  }

  /**
   * 更新会话的最后消息时间
   */
  function updateConversationLastMessage(conversationId: number, lastMessageAt: string) {
    const conversation = findConversationNode(conversationId)
    if (conversation) {
      conversation.last_message_at = lastMessageAt
    }
  }

  /**
   * 重新计算管理员的未读总数（通用函数）
   */
  function recalculateKefuUnreadCount(kefuNode: Conversation) {
    if (kefuNode.children) {
      kefuNode.unread_count = kefuNode.children.reduce(
        (sum, child) => sum + (child.unread_count || 0),
        0,
      )
    }
  }

  /**
   * 重新计算管理员的未读总数（游客树）- 复用通用函数
   */
  const recalculateKefuUnreadCountForVisitor = recalculateKefuUnreadCount

  /**
   * 更新会话未读数
   */
  function updateConversationUnread(conversationId: number, unreadCount: number) {
    const conversation = findConversationNode(conversationId)
    if (!conversation) return

    conversation.unread_count = unreadCount

    // 更新选中会话的未读数
    if (selectedConversation.value?.conversation_id === conversationId) {
      selectedConversation.value.unread_count = unreadCount
    }

    // 重新计算管理员的未读总数
    const kefuNode = findKefuNode(conversation.kefu_id)
    if (kefuNode) {
      recalculateKefuUnreadCount(kefuNode)
    }
  }

  /**
   * 转换会话数据为树节点
   */
  function transformConversationToNode(
    conv: AdminItem['conversation'][0],
    adminId: number,
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
  function transformAdminToNode(adminItem: AdminItem): Conversation {
    const adminId = adminItem.id
    const adminName = adminItem.nickname || `${t('kefu.common.labels.admin')} ${adminId}`

    const children = (adminItem.conversation || []).map((conv) =>
      transformConversationToNode(conv, adminId),
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
  function transformSingleVisitorToNode(
    visitor: { kefu_id: string; visitor_id: string; conversation_id?: number },
    adminId: number,
  ): Conversation {
    const visitorId = visitor.visitor_id || ''
    const kefuId = parseInt(visitor.kefu_id || '0')
    const conversationId = visitor.conversation_id

    return {
      id: `visitor_${adminId}_${visitorId}`, // 使用 adminId + visitor_id 作为节点 ID，确保唯一性
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
   * 获取会话列表并按管理员分组
   */
  async function loadConversations() {
    loading.value = true
    try {
      const response = await chatTree()
      if (response.code === ResultCode.SUCCESS) {
        const adminList = (response.data || []) as AdminItem[]
        treeData.value = adminList.map(transformAdminToNode)

        // 会话列表加载完成后建立 WebSocket 连接
        if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
          connectWebSocket()
        }
      }
    } catch (error: any) {
      msg.alertError(error)
    } finally {
      loading.value = false
    }
  }

  /**
   * 获取游客会话列表并按管理员分组
   * 使用 visitor_id 作为主要标识来区分用户，同一个管理员下同一个 visitor_id 只出现一次
   */
  async function loadVisitorConversations() {
    visitorLoading.value = true
    try {
      const response = await chatVisitorTree()
      if (response.code === ResultCode.SUCCESS) {
        const visitorList = (response.data || []) as VisitorItem[]
        // 按管理员分组，每个管理员下使用 visitor_id 去重
        const adminMap = new Map<number, Conversation>()
        
        visitorList.forEach((visitorItem) => {
          const adminId = visitorItem.id
          const adminName = visitorItem.nickname || `${t('kefu.common.labels.admin')} ${adminId}`
          const visitors = visitorItem.visitor || []
          
          // 获取或创建管理员节点
          let adminNode: Conversation
          if (adminMap.has(adminId)) {
            adminNode = adminMap.get(adminId)!
          } else {
            adminNode = {
              id: `admin_${adminId}`,
              label: adminName,
              type: 'admin',
              kefu_id: adminId,
              avatar: visitorItem.avatar,
              unread_count: 0,
              children: [],
            }
            adminMap.set(adminId, adminNode)
          }
          
          // 确保 children 数组存在
          if (!adminNode.children) {
            adminNode.children = []
          }
          
          // 遍历该管理员下的所有游客
          visitors.forEach((visitor) => {
            const visitorId = visitor.visitor_id || ''
            // 检查该管理员下是否已存在相同的 visitor_id
            const exists = adminNode.children!.some((child) => child.visitor_id === visitorId)
            if (!exists && visitorId) {
              const visitorNode = transformSingleVisitorToNode(visitor, adminId)
              adminNode.children!.push(visitorNode)
            }
          })
        })
        
        visitorTreeData.value = Array.from(adminMap.values())
      }
    } catch (error: any) {
      msg.alertError(error)
    } finally {
      visitorLoading.value = false
    }
  }

  /**
   * 通过 WebSocket 标记未读消息为已读
   */
  async function markMessagesAsRead(conversationId: number, messageIds: number[]) {
    if (messageIds.length === 0) return

    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      return
    }

    const opId = generateOperationId('read')

    return new Promise<void>((resolve, reject) => {
      const timeout = window.setTimeout(() => {
        pendingOperations.value.delete(opId)
        reject(new Error('Operation timeout'))
      }, CONSTANTS.WS_MESSAGE_TIMEOUT * 5)

      pendingOperations.value.set(opId, {
        type: 'read',
        resolve: (response: any) => {
          if (response.data?.updated_count !== undefined) {
            updateConversationUnread(conversationId, 0)
          }
          resolve()
        },
        reject: (error: any) => {
          reject(error)
        },
        timeout,
      })

      try {
        ws.value!.send(JSON.stringify({
          action: 'kefu_message_read',
          data: {
            conversation_id: conversationId,
            sender_type: 2,
            message_ids: [],
          },
          op_id: opId,
        }))
      } catch (error) {
        pendingOperations.value.delete(opId)
        clearTimeout(timeout)
        reject(error)
      }
    })
  }

  /**
   * 获取未读消息ID列表
   */
  function getUnreadMessageIds(messages: Message[]): number[] {
    return messages
      .filter((msg) => msg.sender_type === CONSTANTS.SENDER_TYPE.USER && !msg.is_read)
      .map((msg) => msg.id!)
      .filter(Boolean)
  }

  /**
   * 标记当前会话的所有未读消息为已读（点击用户时调用）
   * 使用 loadMessages 已经加载的消息列表
   */
  async function markConversationAsRead(conversationId: number) {
    const conversation = findConversationNode(conversationId)
    if (!conversation) {
      return
    }

    // 使用当前已加载的消息列表来获取未读消息ID
    const messageIds = getUnreadMessageIds(messages.value)

    try {
      await markMessagesAsRead(conversationId, messageIds)
      updateConversationUnread(conversationId, 0)
    } catch (error) {
      // 标记已读失败不影响消息显示
    }
  }

  /**
   * 判断是否还有更多消息
   */
  function calculateHasMore(listLength: number, total: number, currentLength?: number) {
    const currentTotal = currentLength ?? listLength
    return listLength >= CONSTANTS.PAGE_SIZE && total > currentTotal
  }

  /**
   * 加载消息（首次加载或重新选择会话）
   */
  async function loadMessages(conversationId: number, isVisitor: boolean = false, visitorId?: string, kefuId?: string) {
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
          page_size: CONSTANTS.PAGE_SIZE,
        })
      } else {
        response = await getMessages({
          conversation_id: conversationId,
          page: 1,
          page_size: CONSTANTS.PAGE_SIZE,
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
   * 加载更多历史消息
   */
  async function loadMoreMessages() {
    if (!selectedConversation.value || loadingMore.value || !hasMore.value) {
      return
    }

    loadingMore.value = true
    const nextPage = currentPage.value + 1
    const scrollHeight = messageListRef.value?.scrollHeight || 0
    const isVisitor = selectedConversation.value.type === 'visitor' || selectedConversation.value.isVisitor

    try {
      let response
      if (isVisitor && selectedConversation.value.visitor_id && selectedConversation.value.kefu_id) {
        response = await getMessageVisitor({
          visitor_id: selectedConversation.value.visitor_id,
          kefu_id: String(selectedConversation.value.kefu_id),
          page: nextPage,
          page_size: CONSTANTS.PAGE_SIZE,
        })
      } else {
        response = await getMessages({
          conversation_id: selectedConversation.value.conversation_id!,
          page: nextPage,
          page_size: CONSTANTS.PAGE_SIZE,
        })
      }

      if (response.code === ResultCode.SUCCESS) {
        const pageData = response.data
        const list = (pageData?.list || []) as Message[]
        const total = pageData?.total || 0

        if (list.length > 0) {
          // 格式化消息列表
          const formattedList = list.map(formatMessage)

          // 将新消息插入到数组前面（历史消息在顶部）
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
    if (messageListRef.value.scrollTop <= CONSTANTS.SCROLL_THRESHOLD) {
      loadMoreMessages()
    }
  }, 300)

  /**
   * 检查消息是否已存在
   */
  function isMessageExists(message: Message): boolean {
    const messageId = message.message_id || message.id
    if (!messageId) return false
    return messages.value.some((msg) => (msg.message_id || msg.id) === messageId)
  }

  /**
   * 添加消息到列表
   */
  function addMessageToList(message: Message) {
    if (isMessageExists(message)) return

    messages.value.push(message)
    nextTick(() => {
      scrollToBottom()
    })
  }

  /**
   * 格式化时间
   */
  function formatTime(time: string): string {
    if (!time) return ''
    return useDayjs(time).format('YYYY-MM-DD HH:mm:ss')
  }
  /**
   * 滚动到底部
   */
  function scrollToBottom() {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  }

  /**
   * 更新会话信息
   */
  function updateConversationFromResponse(conversationId: number, conversationData: ConversationData) {
    const conversation = findConversationNode(conversationId)
    if (!conversation || !conversationData) return

    // 更新最后消息时间
    if (conversationData.last_message_at) {
      conversation.last_message_at = conversationData.last_message_at
    }

    // 更新未读数
    const unreadCount = conversationData.kefu_unread_count ?? conversationData.unread_count
    if (unreadCount !== undefined) {
      conversation.unread_count = unreadCount

      // 更新选中会话的未读数
      if (selectedConversation.value?.conversation_id === conversationId) {
        selectedConversation.value.unread_count = unreadCount
      }

      // 重新计算管理员的未读总数
      const kefuNode = findKefuNode(conversation.kefu_id)
      if (kefuNode) {
        recalculateKefuUnreadCount(kefuNode)
      }
    }
  }

  /**
   * 构造消息对象
   */
  function createMessageFromData(messageData: any): Message {
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
   * 发送消息（通过 WebSocket）
   */
  async function handleSendMessage() {
    if (!messageContent.value.trim() || !selectedConversation.value) {
      return
    }

    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      msg.error('WebSocket 未连接，请稍后重试')
      return
    }

    const content = messageContent.value.trim()
    const currentConversation = selectedConversation.value
    const isVisitor = currentConversation.type === 'visitor' || currentConversation.isVisitor === true
    const opId = generateOperationId('msg')

    try {
      // 先清空输入框，提升用户体验
      messageContent.value = ''

      // 根据会话类型发送不同的消息
      if (isVisitor && currentConversation.visitor_id && currentConversation.kefu_id) {
        // 游客会话：管理端发送消息给游客
        // 使用 kefu_message_visitor_send action
        // sender_type: 2 表示客服发送
        ws.value.send(JSON.stringify({
          action: 'kefu_message_visitor_send',
          data: {
            visitor_id: currentConversation.visitor_id,
            kefu_id: String(currentConversation.kefu_id),
            content: content,
            sender_type: 2,
          },
          op_id: opId,
        }))
      } else if (currentConversation.conversation_id) {
        // 用户会话：标准消息发送
        ws.value.send(JSON.stringify({
          action: 'kefu_message_send',
          data: {
            sender_type: 2,
            conversation_id: currentConversation.conversation_id,
            content: content,
            message_type: CONSTANTS.MESSAGE_TYPE.TEXT,
            file_url: null,
          },
          op_id: opId,
        }))
      } else {
        msg.error('会话信息不完整，无法发送消息')
        messageContent.value = content
        return
      }

      // 等待响应
      await new Promise<void>((resolve, reject) => {
        const timeout = window.setTimeout(() => {
          pendingOperations.value.delete(opId)
          reject(new Error('发送消息超时'))
        }, CONSTANTS.WS_MESSAGE_TIMEOUT * 5)

        pendingOperations.value.set(opId, {
          type: 'send',
          resolve: (response: any) => {
            clearTimeout(timeout)
            // 使用返回的数据添加到消息列表
            const messageData = response.data
            if (messageData) {
              // 重新获取当前选中的会话，确保使用最新值
              const currentConv = selectedConversation.value
              const isVisitorConv = currentConv && (currentConv.type === 'visitor' || currentConv.isVisitor === true)
              
              if (isVisitorConv && currentConv.visitor_id && currentConv.kefu_id) {
                // 游客会话消息
                const newMessage: Message = {
                  id: messageData.message_id,
                  message_id: messageData.message_id,
                  visitor_id: currentConv.visitor_id,
                  kefu_id: String(currentConv.kefu_id),
                  sender_id: userStore.getUserInfo().id,
                  sender_type: CONSTANTS.SENDER_TYPE.KEFU,
                  content: content,
                  message_type: CONSTANTS.MESSAGE_TYPE.TEXT,
                  created_at: messageData.created_at || new Date().toISOString(),
                }
                addMessageToList(newMessage)
              } else if (currentConv && currentConv.conversation_id) {
                // 用户会话消息
                const conversationId = currentConv.conversation_id
                const newMessage = createMessageFromData({
                  id: messageData.message_id,
                  conversation_id: conversationId,
                  sender_id: userStore.getUserInfo().id,
                  sender_type: CONSTANTS.SENDER_TYPE.KEFU,
                  content: content,
                  message_type: CONSTANTS.MESSAGE_TYPE.TEXT,
                  created_at: messageData.created_at,
                })
                addMessageToList(newMessage)

                // 更新会话信息
                if (messageData.conversation) {
                  updateConversationFromResponse(conversationId, messageData.conversation)
                } else if (messageData.created_at) {
                  updateConversationLastMessage(conversationId, messageData.created_at)
                }
              }
            }
            resolve()
          },
          reject: (error: any) => {
            clearTimeout(timeout)
            // 恢复输入框内容
            messageContent.value = content
            reject(error)
          },
          timeout,
        })
      })
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
    if (!selectedConversation.value) {
      return
    }

    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      msg.error('WebSocket 未连接，请稍后重试')
      return
    }

    const isVisitor = selectedConversation.value.type === 'visitor' || selectedConversation.value.isVisitor
    const opId = generateOperationId('end')

    try {
      // 根据会话类型发送不同的结束消息
      if (isVisitor && selectedConversation.value.visitor_id && selectedConversation.value.kefu_id) {
        // 游客会话：使用游客结束会话 action
        ws.value.send(JSON.stringify({
          action: 'kefu_message_visitor_end',
          data: {
            visitor_id: selectedConversation.value.visitor_id,
            kefu_id: String(selectedConversation.value.kefu_id),
            sender_type: 2,
          },
          op_id: opId,
        }))
      } else {
        // 用户会话：标准结束会话
        const conversationId = selectedConversation.value.conversation_id!
        ws.value.send(JSON.stringify({
          action: 'kefu_message_end',
          data: {
            conversation_id: conversationId,
          },
          op_id: opId,
        }))
      }

      // 等待响应
      await new Promise<void>((resolve, reject) => {
        const timeout = window.setTimeout(() => {
          pendingOperations.value.delete(opId)
          reject(new Error('结束会话超时'))
        }, CONSTANTS.WS_MESSAGE_TIMEOUT * 5)

        pendingOperations.value.set(opId, {
          type: 'send',
          resolve: (response: any) => {
            clearTimeout(timeout)
            // 结束会话成功后，刷新会话列表
            if (isVisitor) {
              loadVisitorConversations()
            } else {
              loadConversations()
            }
            // 清空当前选中的会话和消息
            selectedConversation.value = null
            messages.value = []
            msg.success('会话已结束')
            resolve()
          },
          reject: (error: any) => {
            clearTimeout(timeout)
            reject(error)
          },
          timeout,
        })
      })
    } catch (error: any) {
      msg.alertError(error)
    }
  }

  /**
   * 更新游客会话未读数
   * 使用 visitor_id 作为主要标识来区分用户
   */
  function updateVisitorConversationUnread(visitorId: string, kefuId: number, unreadCount: number) {
    const visitorConversation = findVisitorConversation(visitorId)
    if (!visitorConversation) {
      return
    }

    visitorConversation.unread_count = unreadCount

    // 更新选中会话的未读数
    if (selectedConversation.value?.type === 'visitor' && selectedConversation.value.visitor_id === visitorId) {
      selectedConversation.value.unread_count = unreadCount
    }

    // 重新计算管理员的未读总数
    const kefuNode = findKefuNodeByVisitor(visitorId)
    if (kefuNode) {
      recalculateKefuUnreadCountForVisitor(kefuNode)
    }
  }

  /**
   * 处理树节点点击
   */
  async function handleNodeClick(data: Conversation) {
    if (data.type === 'user' && data.conversation_id) {
      selectedConversation.value = data
      const conversationId = data.conversation_id

      // 先加载消息列表
      await loadMessages(conversationId, false)

      // 使用已加载的消息列表来标记已读，避免重复请求
      await markConversationAsRead(conversationId)
    } else if (data.type === 'visitor' && data.visitor_id && data.kefu_id) {
      selectedConversation.value = data
      const visitorId = data.visitor_id
      const kefuId = data.kefu_id

      // 先加载消息列表
      await loadMessages(0, true, visitorId, String(kefuId))

      // 点击游客会话时，清零未读数
      updateVisitorConversationUnread(visitorId, kefuId, 0)
    }
  }

  /**
   * 获取 WebSocket 地址
   */
  function getWebSocketUrl(): string {
    const env = import.meta.env
    return (env.VITE_APP_WS_URL as string) || CONSTANTS.DEFAULT_WS_URL
  }

  /**
   * 发送 WebSocket 认证消息
   */
  function sendWebSocketAuth() {
    if (ws.value && userStore.token) {
      userStore.getUserInfo();
      const authData: any = {
        action: 'login',
        data:{token: userStore.token}
      }

      ws.value.send(JSON.stringify(authData))
    }
  }

  /**
   * 生成操作ID
   */
  function generateOperationId(prefix: string = 'op'): string {
    return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  /**
   * 处理 WebSocket 响应消息（带 op_id）
   */
  function handleWebSocketResponse(message: any) {
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
   */
  function handleWebSocketMessageType(message: any): boolean {
    // 优先处理带 operation_id 的响应消息（如发送消息、标记已读等操作的响应）
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
    if (message.type === 'pong' || message.type === 'heartbeat' || message.action === 'pong') {
      return true
    }

    // 用户发送的消息
    if (message.action === 'kefu_message') {
      handleWebSocketMessage(message as WebSocketMessage)
      return true
    }

    // 游客消息推送
    if (message.type === 'push_message' && message.action === 'kefu_visitor_message') {
      handleVisitorWebSocketMessage(message)
      return true
    }

    // 游客会话结束推送
    if (message.type === 'push_message' && message.action === 'kefu_visitor_conversation_end') {
      // 刷新游客会话列表
      loadVisitorConversations()
      // 如果当前选中的是已结束的游客会话，清空选中状态
      if (
        selectedConversation.value &&
        selectedConversation.value.type === 'visitor' &&
        selectedConversation.value.visitor_id === message.visitor_id &&
        String(selectedConversation.value.kefu_id) === String(message.kefu_id)
      ) {
        selectedConversation.value = null
        messages.value = []
      }
      return true
    }

    return false
  }

  /**
   * 更新会话未读数（WebSocket 消息）
   */
  function updateConversationUnreadFromMessage(
    conversation: Conversation,
    message: WebSocketMessage,
    kefuNode: Conversation,
  ) {
    // 如果是用户发送的消息，增加客服未读数
    if (message.sender_type === CONSTANTS.SENDER_TYPE.USER) {
      conversation.unread_count = (conversation.unread_count || 0) + 1
    }

    // 重新计算管理员的未读总数
    recalculateKefuUnreadCount(kefuNode)
  }

  /**
   * 处理当前会话的 WebSocket 消息
   */
  function handleCurrentConversationMessage(
    message: WebSocketMessage,
    conversationId: number,
    conversation: Conversation,
    kefuNode: Conversation,
  ) {
    // 标记已收到发送的消息（如果是当前待处理会话）
    if (pendingConversationId.value === conversationId && message.sender_type === CONSTANTS.SENDER_TYPE.KEFU) {
      sentMessageReceived.value = true
      pendingConversationId.value = null
    }

    // 确保消息格式正确（新格式只有 id，需要设置 message_id）
    const formattedMessage: Message = {
      ...message,
      message_id: message.message_id || message.id,
      id: message.id || message.message_id,
      kefu_id: message.kefu_id ? String(message.kefu_id) : undefined,
    }

    // 添加到消息列表
    addMessageToList(formattedMessage)

    // 当前会话正在查看，如果是用户消息则清零未读数
    if (message.sender_type === CONSTANTS.SENDER_TYPE.USER) {
      conversation.unread_count = 0
      if (selectedConversation.value) {
        selectedConversation.value.unread_count = 0
      }
      recalculateKefuUnreadCount(kefuNode)
    }
  }


  /**
   * 创建新的游客会话节点
   * 使用 visitor_id 作为主要标识来区分用户
   */
  function createVisitorConversationNode(visitorId: string, kefuId: number | string): Conversation {
    const kefuIdNum = normalizeKefuId(kefuId)
    return {
      id: `visitor_${kefuIdNum}_${visitorId}`, // 使用 kefuId + visitor_id 作为节点 ID，确保唯一性
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
   * 将游客会话移到对应管理员节点的第一个位置，并将管理员节点也移到顶部
   */
  function moveVisitorConversationToTop(visitorConversation: Conversation, kefuId: number) {
    const kefuNode = visitorTreeData.value.find((admin) => admin.kefu_id === kefuId)
    if (!kefuNode) {
      return
    }

    if (!kefuNode.children) {
      kefuNode.children = []
    }

    // 从原位置移除会话，使用 visitor_id 作为主要标识
    const index = kefuNode.children.findIndex(
      (child) => child.visitor_id === visitorConversation.visitor_id,
    )
    if (index > -1) {
      kefuNode.children.splice(index, 1)
    }

    // 将会话添加到管理员节点的第一个位置
    kefuNode.children.unshift(visitorConversation)

    // 将管理员节点也移到游客树数据的第一个位置
    const adminIndex = visitorTreeData.value.findIndex((admin) => admin.kefu_id === kefuId)
    if (adminIndex > 0) {
      visitorTreeData.value.splice(adminIndex, 1)
      visitorTreeData.value.unshift(kefuNode)
    }
  }

  /**
   * 处理游客 WebSocket 消息
   */
  function handleVisitorWebSocketMessage(message: any) {
    const visitorId = message.visitor_id
    const kefuId = message.kefu_id

    if (!visitorId || !kefuId) {
      return
    }

    const kefuIdNum = normalizeKefuId(kefuId)

    // 查找游客会话节点，使用 visitor_id 作为主要标识来区分用户
    let visitorConversation = findVisitorConversation(visitorId)

    if (!visitorConversation) {
      // 如果没找到对应的游客会话，创建新会话并添加到顶部
      visitorConversation = createVisitorConversationNode(visitorId, kefuIdNum)

      // 查找或创建对应的管理员节点
      let kefuNode = visitorTreeData.value.find((admin) => admin.kefu_id === kefuIdNum)
      if (!kefuNode) {
        // 创建新的管理员节点
        kefuNode = {
          id: `admin_${kefuIdNum}`,
          label: `${t('kefu.common.labels.admin')} ${kefuIdNum}`,
          type: 'admin',
          kefu_id: kefuIdNum,
          avatar: undefined,
          unread_count: 0,
          children: [],
        }
        // 添加到游客树数据的第一个位置
        visitorTreeData.value.unshift(kefuNode)
      }

      // 确保 children 数组存在
      if (!kefuNode.children) {
        kefuNode.children = []
      }

      // 将会话添加到管理员节点的第一个位置
      kefuNode.children.unshift(visitorConversation)
      recalculateKefuUnreadCountForVisitor(kefuNode)
    }

    // 更新会话的最后消息时间
    visitorConversation.last_message_at = message.created_at

    // 每次收到消息都将会话移到对应管理员节点的第一个位置（确保位置重置到第一个）
    moveVisitorConversationToTop(visitorConversation, kefuIdNum)

    // 格式化游客消息
    const formattedMessage: Message = {
      ...formatMessage(message),
      visitor_id: visitorId,
      kefu_id: String(kefuId),
      content: message.content,
      created_at: message.created_at,
    }
    const senderType = formattedMessage.sender_type

    // 如果是游客发送的消息（sender_type === 1），增加客服未读数
    if (senderType === CONSTANTS.SENDER_TYPE.USER) {
      visitorConversation.unread_count = (visitorConversation.unread_count || 0) + 1
      
      // 更新选中会话的未读数（使用 visitor_id 作为主要标识）
      if (selectedConversation.value && 
          selectedConversation.value.type === 'visitor' &&
          selectedConversation.value.visitor_id === visitorId) {
        selectedConversation.value.unread_count = visitorConversation.unread_count
      }

      // 重新计算管理员的未读总数
      const kefuNode = findKefuNodeByVisitor(visitorId)
      if (kefuNode) {
        recalculateKefuUnreadCountForVisitor(kefuNode)
      }
    }

    // 如果消息属于当前选中的会话，则添加到消息列表（使用 visitor_id 作为主要标识）
    if (
      selectedConversation.value &&
      selectedConversation.value.type === 'visitor' &&
      selectedConversation.value.visitor_id === visitorId
    ) {
      addMessageToList(formattedMessage)
      
      // 如果当前正在查看，且是游客发送的消息，则清零未读数
      if (senderType === CONSTANTS.SENDER_TYPE.USER) {
        visitorConversation.unread_count = 0
        if (selectedConversation.value) {
          selectedConversation.value.unread_count = 0
        }
        // 重新计算管理员的未读总数
        const kefuNode = findKefuNodeByVisitor(visitorId)
        if (kefuNode) {
          recalculateKefuUnreadCountForVisitor(kefuNode)
        }
      }
    }
  }

  /**
   * 处理 WebSocket 消息
   */
  function handleWebSocketMessage(message: WebSocketMessage) {
    const conversationId = message.conversation_id

    // 先通过 conversation_id 查找会话
    let conversation: Conversation | null = null
    if (conversationId) {
      conversation = findConversationNode(conversationId)
    }
    
    // 如果没找到会话，但有 kefu_id，尝试通过 kefu_id 查找
    let kefuId: number | string | undefined = message.kefu_id
    if (!conversation && kefuId) {
      const kefuIdNum = typeof kefuId === 'string' ? parseInt(kefuId) : kefuId
      if (!isNaN(kefuIdNum)) {
        const kefuNode = findKefuNode(kefuIdNum)
        if (kefuNode) {
          // 刷新会话列表以获取最新的会话信息
          loadConversations()
          return
        }
      }
    }
    
    if (!conversation) {
      // 如果没找到对应的会话，刷新整个会话列表
      loadConversations()
      return
    }

    // 从会话中获取 kefu_id（如果消息中没有提供）
    if (!kefuId) {
      kefuId = conversation.kefu_id
    }
    
    const kefuIdNum = typeof kefuId === 'string' ? parseInt(kefuId) : kefuId
    if (kefuIdNum && !isNaN(kefuIdNum)) {
      const kefuNode = findKefuNode(kefuIdNum)
      if (!kefuNode) {
        // 如果没找到对应的客服节点，刷新整个会话列表
        loadConversations()
        return
      }

      // 更新会话的最后消息时间
      conversation.last_message_at = message.created_at

      // 更新未读数
      updateConversationUnreadFromMessage(conversation, message, kefuNode)

      // 如果消息属于当前选中的会话，则添加到消息列表
      if (selectedConversation.value && conversationId && conversationId === selectedConversation.value.conversation_id) {
        handleCurrentConversationMessage(message, conversationId, conversation, kefuNode)
      }
    }
  }

  /**
   * 连接 WebSocket
   */
  function connectWebSocket() {
    if (ws.value?.readyState === WebSocket.OPEN) {
      return
    }

    if (!userStore.token) {
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
          handleWebSocketMessageType(message)
        } catch (error) {
          // 忽略解析错误
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
   * 计划重连
   */
  function scheduleReconnect() {
    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
    }

    if (reconnectAttempts.value >= CONSTANTS.MAX_RECONNECT_ATTEMPTS) {
      return
    }

    reconnectAttempts.value++
    wsReconnectTimer.value = window.setTimeout(() => {
      connectWebSocket()
    }, CONSTANTS.RECONNECT_DELAY)
  }

  /**
   * 判断是否超过最大重连数
   */
  const isMaxReconnectReached = computed(() => {
    return !wsConnected.value && reconnectAttempts.value >= CONSTANTS.MAX_RECONNECT_ATTEMPTS
  })

  /**
   * 手动重新连接
   */
  function manualReconnect() {
    // 停止心跳
    stopHeartbeat()

    // 重置重连次数
    reconnectAttempts.value = 0

    // 清除现有的重连定时器
    if (wsReconnectTimer.value) {
      clearTimeout(wsReconnectTimer.value)
      wsReconnectTimer.value = null
    }

    // 关闭现有连接
    if (ws.value) {
      ws.value.onclose = null
      ws.value.close()
      ws.value = null
    }

    // 重新连接（连接成功后会自动启动心跳）
    connectWebSocket()
  }

  /**
   * 发送心跳（PING）
   * 注意：浏览器 WebSocket API 不支持直接发送 PING 控制帧（opcode 0x9）
   * 因此我们使用应用层消息来模拟心跳
   */
  function sendHeartbeat() {
    if (!ws.value || ws.value.readyState !== WebSocket.OPEN) {
      return false
    }

    try {
      // 方式1: 发送文本消息（JSON格式）
      ws.value.send(JSON.stringify({
        type: 'ping',
        timestamp: Date.now(),
      }))

      return true
    } catch (error) {
      // 发送心跳失败，可能是连接已断开
      return false
    }
  }

  /**
   * 启动心跳
   * 每间隔一定时间发送一次 PING 消息
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
          // 发送失败，停止心跳并触发重连
          stopHeartbeat()
          wsConnected.value = false
          scheduleReconnect()
        }
      } else {
        stopHeartbeat()
      }
    }, CONSTANTS.HEARTBEAT_INTERVAL)
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

  return {
    Loading,
    treeData,
    visitorTreeData,
    selectedConversation,
    messages,
    messageContent,
    loading,
    visitorLoading,
    messagesLoading,
    messageListRef,
    loadingMore,
    hasMore,
    wsConnected,
    isMaxReconnectReached,
    t,
    loadConversations,
    loadVisitorConversations,
    handleSendMessage,
    endConversation,
    handleNodeClick,
    formatTime,
    handleScroll,
    connectWebSocket,
    closeWebSocket,
    manualReconnect,
  }
}
