
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
import { useI18n } from 'vue-i18n'
import MaResourcePanel from './panel.vue'
import type { Resource } from './type.ts'

defineOptions({ name: 'MaResourcePicker' })
const { t } = useI18n({ useScope: 'local' })

const emit = defineEmits<{
  cancel: []
  confirm: [selected: Resource[]]
}>()
const dialogVisible = defineModel<boolean>('visible', { default: false })

const attrs = omit(useAttrs(), ['onConfirm', 'onCancel'])

function close() {
  dialogVisible.value = false
}

function onCancel() {
  close()
  emit('cancel')
}

function onConfirm(selected: Resource[]) {
  close()
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
    <div class="ma-resource-picker-shell">
      <MaResourcePanel v-bind="attrs" @cancel="onCancel" @confirm="onConfirm" />
    </div>
  </MaDialog>
</template>

<style scoped lang="scss">
.ma-resource-picker-shell {
  display: flex;
  flex-direction: column;
  min-height: 0;
  height: calc(100vh - 12rem);
  min-height: 420px;
}
</style>
