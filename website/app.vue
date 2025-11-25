<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup lang="ts">
onMounted(() => {
  if (process.client) {
    // 确保样式在客户端正确加载
    const html = document.documentElement
    html.classList.add('hydrated')
    
    // 强制重新计算样式
    void html.offsetHeight
  }
})
</script>

