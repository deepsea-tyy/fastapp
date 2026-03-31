<script setup lang="ts">
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'

const props = defineProps<{
  copyable?: boolean // 是否可复制
  editable?: boolean // 是否可编辑
}>()

const copyStatus = ref('') // 用于复制状态的反馈
const i18n = useTrans() as TransType
const t = i18n.globalTrans
// 复制文本方法
async function copyText(text: string) {
  try {
    await navigator.clipboard.writeText(text)
    copyStatus.value = 'success'
    // 延迟0.1秒重置复制状态
    setTimeout(() => {
      copyStatus.value = ''
    }, 1000)
  }
  catch (error) {
    copyStatus.value = 'fail'
  }
}
</script>

<template>
  <el-space>
    <!-- 插槽内容作为文本 -->
    <el-text class="mx-1">
      <slot />
    </el-text>
    <!-- 复制按钮，仅在 copyable 为 true 时显示 -->
    <template v-if="props.copyable">
      <el-tooltip :content="copyStatus === 'success' ? t('systemMenu.confirmationMessages.copied') : t('systemMenu.confirmationMessages.copy')" placement="top">
        <ma-svg-icon
          class="cursor-pointer"
          :name="copyStatus === 'success' ? 'i-emojione:white-heavy-check-mark' : 'i-nimbus:copy'"
          @click="copyText($slots.default ? $slots.default()[0].children as string : '')"
        />
      </el-tooltip>
    </template>
  </el-space>
</template>

<style scoped lang="scss">
/* 添加你的样式 */
</style>
