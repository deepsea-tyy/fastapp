
<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import LogoSvg from '/logo.svg'

const { t } = useI18n()

const appTitle = ref<string>(import.meta.env.VITE_APP_TITLE)
</script>

<template>
  <div class="relative w-auto flex items-center gap-x-3">
    <img :alt="appTitle" :src="LogoSvg" class="login-logo" style="height: 64px; width: 64px; max-height: 64px; max-width: 64px; object-fit: contain;">
    <h3 class="text-2xl text-white tracking-[3px]">
      {{ appTitle }}
    </h3>
  </div>
</template>
