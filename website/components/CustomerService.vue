<template>
  <!-- 浮动客服按钮 -->
  <div class="fixed top-1/2 -translate-y-1/2 right-6 z-50 flex flex-col items-end">
    <!-- 聊天窗口 -->
    <div
      v-if="isOpen"
      class="bg-white rounded-lg shadow-2xl w-96 h-[600px] flex flex-col mb-4 border border-gray-200"
    >
      <!-- 窗口头部 -->
      <div class="bg-blue-600 text-white px-4 py-3 rounded-t-lg flex justify-between items-center">
        <div class="flex items-center gap-2">
          <div class="w-2 h-2 rounded-full" :class="wsConnected ? 'bg-green-400' : 'bg-red-400'"></div>
          <span class="font-semibold">{{ $t('customerService.title') }}</span>
        </div>
        <button
          @click="toggleChat"
          class="text-white hover:text-gray-200 transition"
          :aria-label="$t('customerService.close')"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- 消息列表 -->
      <div ref="messagesContainer" class="flex-1 overflow-y-auto p-4 bg-gray-50 space-y-3">
        <div
          v-for="(msg, index) in messages"
          :key="index"
          :class="[
            'flex',
            msg.type === 'self' ? 'justify-end' : 'justify-start'
          ]"
        >
          <div
            :class="[
              'max-w-[80%] rounded-lg px-4 py-2',
              msg.type === 'self'
                ? 'bg-blue-600 text-white'
                : msg.type === 'system'
                ? 'bg-yellow-100 text-yellow-800 text-center w-full'
                : msg.type === 'error'
                ? 'bg-red-100 text-red-800 text-center w-full'
                : 'bg-white text-gray-800 border border-gray-200'
            ]"
          >
            <div v-if="msg.sender" class="text-xs opacity-75 mb-1">{{ msg.sender }}</div>
            <div class="text-sm whitespace-pre-wrap">{{ msg.content }}</div>
            <div class="text-xs opacity-75 mt-1">{{ msg.time }}</div>
          </div>
        </div>
      </div>

      <!-- 输入区域 -->
      <div class="border-t border-gray-200 p-4 bg-white rounded-b-lg">
        <div v-if="!wsConnected" class="mb-2">
          <button
            @click="connect"
            :disabled="loading"
            class="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed text-sm"
          >
            {{ loading ? $t('customerService.connecting') : $t('customerService.consult') }}
          </button>
        </div>
        <div v-else class="space-y-2">
          <textarea
            v-model="inputMessage"
            @keydown.enter.exact.prevent="sendMessage"
            :placeholder="$t('customerService.inputPlaceholder')"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
            rows="2"
          ></textarea>
          <div class="flex gap-2">
            <button
              @click="sendMessage"
              :disabled="!inputMessage.trim() || sending"
              class="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed text-sm"
            >
              {{ sending ? $t('customerService.sending') : $t('customerService.send') }}
            </button>
            <button
              @click="disconnect"
              class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition text-sm"
            >
              {{ $t('customerService.end') }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 浮动按钮 -->
    <button
      v-if="!isOpen"
      @click="toggleChat"
      class="bg-blue-600 text-white rounded-full w-14 h-14 shadow-lg hover:bg-blue-700 transition flex items-center justify-center"
      :aria-label="$t('customerService.open')"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
      </svg>
      <span
        v-if="unreadCount > 0"
        class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center"
      >
        {{ unreadCount > 9 ? '9+' : unreadCount }}
      </span>
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick, computed } from 'vue'

// 禁用 SSR
defineOptions({ ssr: false })

// i18n
const { t, locale } = useI18n()

// 类型定义
type MessageType = 'self' | 'other' | 'system' | 'error'

interface Message {
  type: MessageType
  content: string
  sender?: string
  time: string
}

interface VisitorKefuResponse {
  code: number
  message: string
  data: {
    kefu_id: number
    visitor_id: string
  }
}

// 常量
const HEARTBEAT_INTERVAL = 30000 // 30秒
const FILTERED_MESSAGES = ['connected successfully']

// 配置
const config = useRuntimeConfig()
const wsUrl = config.public?.wsUrl as string || 'ws://127.0.0.1:9502/ws'
const apiBaseUrl = config.public?.apiBaseUrl as string || 'http://127.0.0.1:9501'

// 状态
const kefuId = ref<number>(0)
const visitorId = ref<string>('')
const isOpen = ref(false)
const wsConnected = ref(false)
const loading = ref(false)
const sending = ref(false)
const unreadCount = ref(0)
const inputMessage = ref('')
const messages = ref<Message[]>([])
const messagesContainer = ref<HTMLElement | null>(null)

// WebSocket 实例
let ws: WebSocket | null = null
let heartbeatTimer: NodeJS.Timeout | null = null

// UI 操作
function toggleChat() {
  isOpen.value = !isOpen.value
  if (isOpen.value) {
    unreadCount.value = 0
    nextTick(scrollToBottom)
  }
}

function scrollToBottom() {
  messagesContainer.value?.scrollTo({ top: messagesContainer.value.scrollHeight, behavior: 'smooth' })
}

function addMessage(content: string, type: MessageType = 'other', sender?: string) {
  // 过滤不需要显示的消息
  if (FILTERED_MESSAGES.some(msg => content.toLowerCase().includes(msg.toLowerCase()))) {
    return
  }

  const localeStr = locale.value === 'zh' ? 'zh-CN' : 'en-US'
  messages.value.push({
    type,
    content,
    sender,
    time: new Date().toLocaleTimeString(localeStr, { hour: '2-digit', minute: '2-digit' })
  })
  
  nextTick(scrollToBottom)
  
  if (!isOpen.value && type === 'other') {
    unreadCount.value++
  }
}

// API 调用
async function getVisitorKefu(): Promise<boolean> {
  try {
    loading.value = true
    const response = await $fetch<VisitorKefuResponse>(`${apiBaseUrl}/api/kefu/message/getVisitorKefu`)
    
    if (response.code === 200 && response.data) {
      kefuId.value = response.data.kefu_id
      visitorId.value = response.data.visitor_id
      return true
    }
    
    addMessage(`${t('customerService.getKefuFailed')}: ${response.message || t('customerService.unknownError')}`, 'error')
    return false
  } catch (error) {
    addMessage(`${t('customerService.getKefuFailed')}: ${error instanceof Error ? error.message : t('customerService.unknownError')}`, 'error')
    return false
  } finally {
    loading.value = false
  }
}

function validateConfig(): boolean {
  if (!kefuId.value || !visitorId.value) {
    addMessage(t('customerService.configIncomplete'), 'error')
    return false
  }
  return true
}

// WebSocket 连接
async function connect() {
  if (ws?.readyState === WebSocket.OPEN) return

  addMessage(t('customerService.allocating'), 'system')
  if (!(await getVisitorKefu()) || !validateConfig()) {
    return
  }

  try {
    ws = new WebSocket(wsUrl)
    setupWebSocketHandlers()
  } catch (error) {
    addMessage(`${t('customerService.connectFailed')}: ${error instanceof Error ? error.message : t('customerService.unknownError')}`, 'error')
  }
}

function setupWebSocketHandlers() {
  if (!ws) return

  ws.onopen = () => {
    wsConnected.value = true
    bindVisitor()
    startHeartbeat()
  }

  ws.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      handleWebSocketMessage(data)
    } catch {
      addMessage(`${t('customerService.nonJsonMessage')}: ${event.data}`, 'system')
    }
  }

  ws.onerror = () => {
    addMessage(t('customerService.wsError'), 'error')
    wsConnected.value = false
  }

  ws.onclose = () => {
    wsConnected.value = false
    addMessage(t('customerService.wsClosed'), 'system')
    stopHeartbeat()
  }
}

function handleWebSocketMessage(data: any) {
  // 忽略心跳响应
  if (['ping', 'heartbeat'].includes(data.action) || data.type === 'pong') {
    return
  }

  // 处理推送消息
  if (data.type === 'push_message') {
    if (['kefu_message', 'kefu_visitor_message'].includes(data.action)) {
      addMessage(data.content || t('customerService.noContent'), 'other', `${t('customerService.kefu')} ${data.kefu_id}`)
    } else if (['kefu_message_end', 'kefu_visitor_conversation_end'].includes(data.action)) {
      addMessage(t('customerService.sessionEnded'), 'system')
    }
    return
  }

  // 处理普通响应
  if (data.success) {
    if (data.message?.includes('Bind key successfully')) {
      addMessage(t('customerService.connected'), 'system')
    } else if (data.message && !data.message.includes('sent successfully')) {
      addMessage(data.message, 'system')
    }
  } else {
    addMessage(`${t('customerService.error')}: ${data.message || t('customerService.operationFailed')}`, 'error')
  }
}

function disconnect() {
  stopHeartbeat()
  ws?.close()
  ws = null
  wsConnected.value = false
  addMessage(t('customerService.disconnected'), 'system')
}

function bindVisitor() {
  if (!ws || ws.readyState !== WebSocket.OPEN || !visitorId.value) {
    if (!visitorId.value) {
      addMessage(t('customerService.bindFailed'), 'error')
    }
    return
  }

  sendWebSocketMessage({
    action: 'kefu_message_visitor_bind_fd',
    data: { bind_key: visitorId.value },
    op_id: `bind_${Date.now()}`
  })
}

function sendMessage() {
  const content = inputMessage.value.trim()
  if (!content || sending.value) return

  if (!ws || ws.readyState !== WebSocket.OPEN) {
    addMessage(t('customerService.pleaseConnect'), 'error')
    return
  }

  if (!validateConfig()) {
    addMessage(t('customerService.sendFailedConfig'), 'error')
    return
  }

  sending.value = true
  addMessage(content, 'self', locale.value === 'zh' ? '我' : 'Me')

  sendWebSocketMessage({
    action: 'kefu_message_visitor_send',
    data: {
      visitor_id: visitorId.value,
      kefu_id: kefuId.value,
      content
    },
    op_id: `visitor_send_${Date.now()}`
  })

  inputMessage.value = ''
  sending.value = false
}

function sendWebSocketMessage(data: any) {
  if (ws?.readyState === WebSocket.OPEN) {
    try {
      ws.send(JSON.stringify(data))
    } catch (error) {
      addMessage(`${t('customerService.sendFailed')}: ${error instanceof Error ? error.message : t('customerService.unknownError')}`, 'error')
    }
  }
}

// 心跳机制
function startHeartbeat() {
  stopHeartbeat()
  sendHeartbeat()
  heartbeatTimer = setInterval(sendHeartbeat, HEARTBEAT_INTERVAL)
}

function stopHeartbeat() {
  if (heartbeatTimer) {
    clearInterval(heartbeatTimer)
    heartbeatTimer = null
  }
}

function sendHeartbeat() {
  if (ws?.readyState === WebSocket.OPEN) {
    sendWebSocketMessage({
      action: 'ping',
      op_id: `heartbeat_${Date.now()}`
    })
  }
}

// 生命周期
onMounted(() => {
  addMessage(t('customerService.welcome'), 'system')
})

onUnmounted(() => {
  disconnect()
})
</script>

<style scoped>
/* 自定义滚动条样式 */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>

