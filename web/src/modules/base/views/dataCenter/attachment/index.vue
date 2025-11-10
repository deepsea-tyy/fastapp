
<script setup lang="ts">
import MaResourcePanel from '@/components/ma-resource-picker/panel.vue'
import getOnlyWorkAreaHeight from '@/utils/getOnlyWorkAreaHeight.ts'

defineOptions({ name: 'dataCenter:attachment' })

const model = ref<any>()

onMounted(() => {
  const dom = document.querySelector('.resource-page') as HTMLElement
  dom.style.height = `${getOnlyWorkAreaHeight()}px`
})
</script>

<template>
  <div class="mine-card resource-page">
    <MaResourcePanel v-model="model" :show-action="false" />
  </div>
</template>

<style scoped lang="scss">

</style>
