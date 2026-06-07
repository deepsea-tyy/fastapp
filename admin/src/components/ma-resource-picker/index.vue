
<i18n lang="yaml">
en:
  title: Resource Picker (drag to upload)
zh_CN:
  title: 资源选择器（支持拖拽上传）
zh_TW:
  title: 資源選擇器（支援拖拽上傳）
</i18n>

<script setup lang="ts">
import { omit } from 'lodash-es'
import MaResourcePanel from './panel.vue'
import type { Resource } from './type.ts'
import { useLocalTrans } from '@/hooks/useLocalTrans.ts'

defineOptions({ name: 'MaResourcePicker' })

const emit = defineEmits<{
  cancel: []
  confirm: [selected: Resource[]]
}>()
const dialogVisible = defineModel<boolean>('visible', { default: false })

const attrs = omit(useAttrs(), ['onConfirm', 'onCancel'])
const t = useLocalTrans() as (key: string) => string

function onCancel() {
  dialogVisible.value = false
  emit('cancel')
}

function onConfirm(selected: Resource[]) {
  dialogVisible.value = false
  emit('confirm', selected)
}
</script>

<template>
  <MaDialog
    v-model="dialogVisible"
    :title="t('title')"
    append-to-body
    destroy-on-close
    align-center
    :footer="false"
  >
    <div class="h-[595px]">
      <MaResourcePanel v-bind="attrs" @cancel="onCancel" @confirm="onConfirm" />
    </div>
  </MaDialog>
</template>
