
<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { SystemSettings } from '#/global'

const { locale } = useI18n()
const userStore = useUserStore()
const settingStore = useSettingStore()

function switchLanguage(language: string): void {
  locale.value = language
  userStore.setLanguage(language)
}

const title = import.meta.env.VITE_APP_TITLE

const setting: SystemSettings.copyright = settingStore.getSettings('copyright')
</script>

<template>
  <div class="copyright-wrapper w-full text-center text-sm text-gray-3 lg:text-gray-5">
    <div class="flex justify-center gap-x-2.5 flex-wrap">
      <p class="flex items-center justify-center text-sm">
        <ma-svg-icon name="lucide:copyright" />
      </p>
      <span class="whitespace-nowrap">{{ `${new Date().getFullYear()} ${title}` }}</span>
      <span class="whitespace-nowrap"><a href="https://beian.miit.gov.cn/" target="_blank" class="trans-link">{{ setting.putOnRecord }}</a></span>
    </div>
  </div>
</template>

<style scoped lang="scss">
.copyright-wrapper {
  max-width: 100%;
  padding: 0 1rem;
  
  @media (max-width: 768px) {
    padding: 0 0.5rem;
    font-size: 12px;
  }
}

.trans-link {
  @apply text-gray-3 lg:text-gray-7 cursor-pointer decoration-none;
  white-space: nowrap;
  transition: color 0.2s;
  
  &:hover {
    @apply text-gray-200;
  }
}
</style>
