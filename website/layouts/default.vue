<template>
  <div class="min-h-screen flex flex-col">
    <AppHeader />
    <main class="flex-grow">
      <slot />
    </main>
    <AppFooter />
    <CustomerService />
  </div>
</template>

<script setup lang="ts">
</script>

