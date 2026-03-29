<template>
  <div></div>
</template>

<script setup lang="ts">
const localePath = useLocalePath()

// 重定向到 /site
await navigateTo(localePath('/site'), { redirectCode: 301 })
</script>

