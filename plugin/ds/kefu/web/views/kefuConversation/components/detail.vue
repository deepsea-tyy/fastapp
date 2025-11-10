
<script setup lang="ts">
import type { MaProTableOptions, MaProTableSchema } from '@/components/ma-pro-table'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'

import { getMessages } from '$/ds/kefu/api/kefuConversation.ts'
import messageTableColumns from './getMessageTableColumns.tsx'

defineOptions({ name: 'kefu:kefuConversation:detail' })

const props = defineProps<{
  data?: any
}>()

const i18n = useTrans() as TransType
const t = i18n.globalTrans

const conversationId = computed(() => {
  if (!props.data) return 0
  // 如果 data 是对象且包含 data 属性，取 data.id
  if (props.data.data && props.data.data.id) {
    return props.data.data.id
  }
  // 否则直接取 id
  return props.data.id || 0
})

const messageOptions = ref<MaProTableOptions>({
  header: { show: false },
  toolbar: false,
  requestOptions: {
    api: getMessages,
    requestParams: computed(() => {
      return { conversation_id: conversationId.value }
    })
  },
})
const messageSchema = ref<MaProTableSchema>({
  tableColumns: messageTableColumns(t)
})
</script>
<template>
  <MaProTable ref="messageTableRef" :options="messageOptions" :schema="messageSchema"></MaProTable>
</template>

<style scoped lang="scss">
</style>

