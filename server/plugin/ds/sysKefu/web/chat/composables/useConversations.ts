/**
 * 会话列表管理模块
 * 负责用户会话和游客会话的加载、缓存和未读数管理
 */

import type { Conversation, AdminItem, VisitorItem, ConversationData, WebSocketMessage } from '../types'
import type { UseWebSocketReturn } from './useWebSocket'
import { chatTree, chatVisitorTree } from '$/ds/sysKefu/api/kefuConversation'
import { useMessage } from '@/hooks/useMessage'
import { ResultCode } from '@/utils/ResultCode'
import defaultAvatar from '/defaultAvatar.jpg'
import { CHAT_CONSTANTS } from '../constants'
import {
  transformAdminToNode,
  transformSingleVisitorToNode,
  createVisitorConversationNode,
  recalculateKefuUnreadCount,
  normalizeKefuId,
} from '../helpers'

/**
 * useConversations 返回类型
 */
export interface UseConversationsReturn {
  // 状态
  treeData: Ref<Conversation[]>
  visitorTreeData: Ref<Conversation[]>
  selectedConversation: Ref<Conversation | null>
  loading: Ref<boolean>
  visitorLoading: Ref<boolean>
  conversationCache: ComputedRef<Map<number, Conversation>>
  adminCache: ComputedRef<Map<number, Conversation>>

  // 方法
  loadConversations: () => Promise<void>
  loadVisitorConversations: () => Promise<void>
  findConversationNode: (conversationId: number) => Conversation | null
  findKefuNode: (adminId: number) => Conversation | null
  findVisitorConversation: (visitorId: string) => Conversation | null
  findKefuNodeByVisitor: (visitorId: string) => Conversation | null
  updateConversationUnread: (conversationId: number, unreadCount: number) => void
  updateConversationLastMessage: (conversationId: number, lastMessageAt: string) => void
  updateConversationFromResponse: (conversationId: number, conversationData: ConversationData) => void
  updateVisitorConversationUnread: (visitorId: string, kefuId: number, unreadCount: number) => void
  handleWebSocketConversationUpdate: (message: WebSocketMessage) => void
  handleVisitorWebSocketMessage: (message: any) => void
}

/**
 * 会话列表管理 Hook
 *
 * @param wsModule - WebSocket 模块实例
 * @param t - 国际化函数
 * @returns 会话管理接口
 */
export function useConversations(
  wsModule: UseWebSocketReturn,
  t: (key: string) => string,
): UseConversationsReturn {
  const msg = useMessage()

  // 树形数据
  const treeData = ref<Conversation[]>([])
  const visitorTreeData = ref<Conversation[]>([])
  const selectedConversation = ref<Conversation | null>(null)
  const loading = ref(false)
  const visitorLoading = ref(false)

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
   * 查找游客会话节点
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
      admin.children?.some((child) => child.visitor_id === visitorId),
    ) || null
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
   * 获取会话列表并按管理员分组
   */
  async function loadConversations() {
    loading.value = true
    try {
      const response = await chatTree()
      if (response.code === ResultCode.SUCCESS) {
        const adminList = (response.data || []) as AdminItem[]
        treeData.value = adminList.map((item) => transformAdminToNode(item, t))

        // 会话列表加载完成后建立 WebSocket 连接
        if (!wsModule.ws.value || wsModule.ws.value.readyState !== WebSocket.OPEN) {
          wsModule.connectWebSocket()
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
   */
  async function loadVisitorConversations() {
    visitorLoading.value = true
    try {
      const response = await chatVisitorTree()
      if (response.code === ResultCode.SUCCESS) {
        const visitorList = (response.data || []) as VisitorItem[]
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

          // 遍历该管理员下的所有游客，使用 visitor_id 去重
          visitors.forEach((visitor) => {
            const visitorId = visitor.visitor_id || ''
            const exists = adminNode.children!.some((child) => child.visitor_id === visitorId)
            if (!exists && visitorId) {
              const visitorNode = transformSingleVisitorToNode(visitor, adminId, t)
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
   * 更新游客会话未读数
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
      recalculateKefuUnreadCount(kefuNode)
    }
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
    if (message.sender_type === CHAT_CONSTANTS.SENDER_TYPE.USER) {
      conversation.unread_count = (conversation.unread_count || 0) + 1
    }

    // 重新计算管理员的未读总数
    recalculateKefuUnreadCount(kefuNode)
  }

  /**
   * 将游客会话移到对应管理员节点的第一个位置
   */
  function moveVisitorConversationToTop(visitorConversation: Conversation, kefuId: number) {
    const kefuNode = visitorTreeData.value.find((admin) => admin.kefu_id === kefuId)
    if (!kefuNode) {
      return
    }

    if (!kefuNode.children) {
      kefuNode.children = []
    }

    // 从原位置移除会话
    const index = kefuNode.children.findIndex(
      (child) => child.visitor_id === visitorConversation.visitor_id,
    )
    if (index > -1) {
      kefuNode.children.splice(index, 1)
    }

    // 将会话添加到第一个位置
    kefuNode.children.unshift(visitorConversation)

    // 将管理员节点也移到顶部
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

    // 查找游客会话节点
    let visitorConversation = findVisitorConversation(visitorId)

    if (!visitorConversation) {
      // 创建新会话
      visitorConversation = createVisitorConversationNode(visitorId, kefuIdNum, t)

      // 查找或创建管理员节点
      let kefuNode = visitorTreeData.value.find((admin) => admin.kefu_id === kefuIdNum)
      if (!kefuNode) {
        kefuNode = {
          id: `admin_${kefuIdNum}`,
          label: `${t('kefu.common.labels.admin')} ${kefuIdNum}`,
          type: 'admin',
          kefu_id: kefuIdNum,
          avatar: undefined,
          unread_count: 0,
          children: [],
        }
        visitorTreeData.value.unshift(kefuNode)
      }

      if (!kefuNode.children) {
        kefuNode.children = []
      }

      kefuNode.children.unshift(visitorConversation)
      recalculateKefuUnreadCount(kefuNode)
    }

    // 更新最后消息时间
    visitorConversation.last_message_at = message.created_at

    // 移到顶部
    moveVisitorConversationToTop(visitorConversation, kefuIdNum)

    // 如果是游客发送的消息，增加未读数
    const senderType = message.sender_type
    if (senderType === CHAT_CONSTANTS.SENDER_TYPE.USER) {
      visitorConversation.unread_count = (visitorConversation.unread_count || 0) + 1

      // 更新选中会话的未读数
      if (selectedConversation.value &&
        selectedConversation.value.type === 'visitor' &&
        selectedConversation.value.visitor_id === visitorId) {
        selectedConversation.value.unread_count = visitorConversation.unread_count
      }

      // 重新计算管理员未读数
      const kefuNode = findKefuNodeByVisitor(visitorId)
      if (kefuNode) {
        recalculateKefuUnreadCount(kefuNode)
      }
    }
  }

  /**
   * 处理 WebSocket 消息（用户会话）
   */
  function handleWebSocketConversationUpdate(message: WebSocketMessage) {
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
          // 刷新会话列表以获取最新信息
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

    // 从会话中获取 kefu_id
    if (!kefuId) {
      kefuId = conversation.kefu_id
    }

    const kefuIdNum = typeof kefuId === 'string' ? parseInt(kefuId) : kefuId
    if (kefuIdNum && !isNaN(kefuIdNum)) {
      const kefuNode = findKefuNode(kefuIdNum)
      if (!kefuNode) {
        loadConversations()
        return
      }

      // 更新会话的最后消息时间
      conversation.last_message_at = message.created_at

      // 更新未读数
      updateConversationUnreadFromMessage(conversation, message, kefuNode)
    }
  }

  return {
    // 状态
    treeData,
    visitorTreeData,
    selectedConversation,
    loading,
    visitorLoading,
    conversationCache,
    adminCache,

    // 方法
    loadConversations,
    loadVisitorConversations,
    findConversationNode,
    findKefuNode,
    findVisitorConversation,
    findKefuNodeByVisitor,
    updateConversationUnread,
    updateConversationLastMessage,
    updateConversationFromResponse,
    updateVisitorConversationUnread,
    handleWebSocketConversationUpdate,
    handleVisitorWebSocketMessage,
  }
}
