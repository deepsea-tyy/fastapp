<script setup lang="ts">
import { ElMessageBox } from 'element-plus'
import defaultAvatar from '/defaultAvatar.jpg'
import './chat.scss'
import useChatLogic from './useChat.ts'
import getOnlyWorkAreaHeight from '@/utils/getOnlyWorkAreaHeight.ts'

defineOptions({ name: 'kefu:kefuConversation:chat' })

const chatContainerRef = ref<HTMLElement>()
const userTreeRef = ref<any>()
const visitorTreeRef = ref<any>()

function updateHeight() {
  if (chatContainerRef.value) {
    chatContainerRef.value.style.height = `${getOnlyWorkAreaHeight()}px`
  }
}

const {
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
  handleNodeClick: originalHandleNodeClick,
  formatTime,
  handleScroll,
  connectWebSocket,
  closeWebSocket,
  manualReconnect
} = useChatLogic()

// 包装节点点击处理函数，确保切换树时清除另一个树的选中状态
function handleNodeClick(data: any, isVisitor: boolean = false) {
  // 清除另一个树的选中状态
  if (isVisitor) {
    // 点击的是游客树，清除用户树的选中状态
    if (userTreeRef.value) {
      userTreeRef.value.setCurrentKey(null)
    }
  } else {
    // 点击的是用户树，清除游客树的选中状态
    if (visitorTreeRef.value) {
      visitorTreeRef.value.setCurrentKey(null)
    }
  }
  
  // 调用原始的处理函数
  originalHandleNodeClick(data)
}

// 确认结束会话
function handleEndConversation() {
  ElMessageBox.confirm(
    t('kefu.KefuChatFields.endConversationConfirm'),
    t('kefu.KefuChatFields.endConversationTitle'),
    {
      confirmButtonText: t('crud.ok'),
      cancelButtonText: t('crud.cancel'),
      type: 'warning',
    },
  )
    .then(() => {
      endConversation()
    })
    .catch(() => {
      // 用户取消
    })
}

// 初始化
onMounted(() => {
  updateHeight()
  window.addEventListener('resize', updateHeight)
  loadConversations()
  loadVisitorConversations()
})

// 组件卸载时关闭 WebSocket 和移除监听器
onUnmounted(() => {
  window.removeEventListener('resize', updateHeight)
  closeWebSocket()
})
</script>

<template>
  <div ref="chatContainerRef" class="chat-container">
    <div class="chat-layout">
      <!-- 左侧菜单 -->
      <div class="chat-sidebar">
        <div class="sidebar-header">
          <h3>{{ t('kefu.KefuChat') }}</h3>
          <div class="header-connection-wrapper">
            <el-tag :type="wsConnected ? 'success' : 'danger'" size="small">
              <ma-svg-icon
                :name="wsConnected ? 'mdi:check-circle' : 'mdi:close-circle'"
                :size="14"
                style="margin-right: 4px"
              />
              {{ wsConnected ? t('kefu.KefuChatFields.wsConnected') : t('kefu.KefuChatFields.wsDisconnected') }}
            </el-tag>
            <el-button
              v-if="isMaxReconnectReached"
              type="primary"
              size="small"
              style="margin-left: 8px"
              @click="manualReconnect"
            >
              {{ t('kefu.KefuChatFields.reconnect') }}
            </el-button>
          </div>
        </div>
        <div v-loading="loading" class="sidebar-content">
          <!-- 管理员用户会话列表 -->
           <!--标签表示是管理员用户会话列表-->
           <el-tag type="primary" size="small">
            {{ t('kefu.KefuChatFields.adminUserConversation') }}
           </el-tag>
          <el-tree
            ref="userTreeRef"
            :data="treeData"
            :props="{ children: 'children', label: 'label' }"
            node-key="id"
            highlight-current
            default-expand-all
            @node-click="(data) => handleNodeClick(data, false)"
          >
            <template #default="{ node, data }">
              <div class="tree-node">
                <div v-if="data.type === 'admin'" class="node-admin">
                  <el-avatar v-if="data.avatar" :src="data.avatar" :size="32" class="node-avatar" />
                  <ma-svg-icon v-else name="mdi:account" :size="18" />
                  <span class="node-label">{{ data.label }}</span>
                  <div v-if="data.unread_count > 0" class="node-badge">
                    <el-badge :value="data.unread_count" :max="99" />
                  </div>
                </div>
                <div v-else class="node-user">
                  <el-avatar :src="data.avatar" :size="32" class="node-avatar" />
                  <div class="node-user-info">
                    <div class="node-label">{{ data.label }}</div>
                    <div v-if="data.unread_count > 0" class="node-badge">
                      <el-badge :value="data.unread_count" :max="99" />
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </el-tree>
          <!-- 游客会话列表 -->
          <el-tag type="success" size="small" style="margin-top: 16px">
            {{ t('kefu.KefuChatFields.visitorConversation') }}
          </el-tag>
          <el-tree
            ref="visitorTreeRef"
            v-loading="visitorLoading"
            :data="visitorTreeData"
            :props="{ children: 'children', label: 'label' }"
            node-key="id"
            highlight-current
            default-expand-all
            @node-click="(data) => handleNodeClick(data, true)"
          >
            <template #default="{ node, data }">
              <div class="tree-node">
                <div v-if="data.type === 'admin'" class="node-admin">
                  <el-avatar v-if="data.avatar" :src="data.avatar" :size="32" class="node-avatar" />
                  <ma-svg-icon v-else name="mdi:account" :size="18" />
                  <span class="node-label">{{ data.label }}</span>
                  <div v-if="data.unread_count > 0" class="node-badge">
                    <el-badge :value="data.unread_count" :max="99" />
                  </div>
                </div>
                <div v-else class="node-user">
                  <el-avatar :src="data.avatar || defaultAvatar" :size="32" class="node-avatar" />
                  <div class="node-user-info">
                    <div class="node-label">{{ data.label }}</div>
                    <div v-if="data.unread_count > 0" class="node-badge">
                      <el-badge :value="data.unread_count" :max="99" />
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </el-tree>
        </div>
      </div>

      <!-- 右侧聊天框 -->
      <div class="chat-main">
        <div v-if="!selectedConversation" class="chat-empty">
          <el-empty :description="t('kefu.KefuChatFields.selectUser')" />
        </div>
        <div v-else class="chat-content">
          <!-- 聊天头部 -->
          <div class="chat-header">
            <div class="header-user">
              <el-avatar :src="selectedConversation.avatar || defaultAvatar" :size="40" />
              <div class="header-info">
                <div class="header-name-wrapper">
                  <span class="header-name">{{ selectedConversation.label }}</span>
                  <el-badge
                    v-if="selectedConversation.unread_count > 0"
                    :value="selectedConversation.unread_count"
                    :max="99"
                    class="header-badge"
                  />
                </div>
                <div class="header-status">
                  <template v-if="selectedConversation.type === 'visitor'">
                    {{ t('kefu.KefuConversationFields.visitorId') || '游客ID' }}: {{ selectedConversation.visitor_id }}
                  </template>
                  <template v-else>
                    {{ t('kefu.KefuConversationFields.userId') }}: {{ selectedConversation.user_id }}
                  </template>
                  <span v-if="selectedConversation.unread_count > 0" class="unread-tip">
                    ({{ t('kefu.KefuConversationFields.kefuUnreadCount') }}: {{ selectedConversation.unread_count }})
                  </span>
                </div>
              </div>
            </div>
            <div class="header-actions">
              <el-button type="danger" size="small" @click="handleEndConversation">
                <ma-svg-icon name="mdi:close-circle" :size="16" style="margin-right: 4px" />
                {{ t('kefu.KefuChatFields.endConversation') }}
              </el-button>
            </div>
          </div>

          <!-- 消息列表 -->
          <div
            ref="messageListRef"
            v-loading="messagesLoading"
            class="chat-messages"
            @scroll="handleScroll"
          >
            <!-- 加载更多提示 -->
            <div v-if="loadingMore" class="load-more-tip">
              <el-icon class="is-loading"><Loading /></el-icon>
              <span>{{ t('kefu.KefuChatFields.loading') }}</span>
            </div>
            <div v-else-if="!hasMore && messages.length > 0" class="load-more-tip no-more">
              {{ t('kefu.KefuChatFields.noMoreMessages') }}
            </div>
            <div
              v-for="message in messages"
              :key="message.message_id || message.id"
              :class="['message-item', message.sender_type === 2 ? 'message-kefu' : 'message-user']"
            >
              <div class="message-avatar">
                <el-avatar
                  v-if="message.sender_type === 1"
                  :src="selectedConversation.avatar"
                  :size="36"
                />
                <el-avatar
                  v-else
                  :src="defaultAvatar"
                  :size="36"
                />
              </div>
              <div class="message-content-wrapper">
                <div class="message-info">
                  <span class="message-sender">
                    {{
                      message.sender_type === 2
                        ? t('kefu.common.senderType.kefu')
                        : t('kefu.common.senderType.user')
                    }}
                  </span>
                  <span class="message-time">{{ formatTime(message.created_at) }}</span>
                </div>
                <div class="message-bubble">
                  <div v-if="message.message_type === 1" class="message-text">
                    {{ message.content }}
                  </div>
                  <div v-else-if="message.message_type === 2" class="message-image">
                  <el-image
                    :src="message.file_url || ''"
                    :preview-src-list="[message.file_url || '']"
                    fit="cover"
                    style="max-width: 200px; max-height: 200px;"
                  />
                  </div>
                  <div v-else-if="message.message_type === 3" class="message-file">
                    <el-link :href="message.file_url" target="_blank" type="primary">
                      {{ message.content || t('kefu.KefuMessageFields.fileUrl') }}
                    </el-link>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 发送框 -->
          <div class="chat-input">
            <el-input
              v-model="messageContent"
              type="textarea"
              :rows="3"
              :placeholder="t('kefu.KefuChatFields.inputPlaceholder')"
              @keydown.ctrl.enter="handleSendMessage"
            />
            <div class="input-actions">
              <el-button type="primary" :disabled="!messageContent.trim()" @click="handleSendMessage">
                {{ t('kefu.KefuChatFields.send') }}
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
