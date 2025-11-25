<template>
  <div class="container mx-auto px-4 py-16">
    <h1 class="text-4xl font-bold mb-8 text-center">{{ $t('footer.blog') }}</h1>
    <div class="max-w-3xl mx-auto">
      <div class="bg-white p-8 rounded-lg shadow-md text-center">
        <p class="text-gray-600 text-lg">
          {{ $t('blog.comingSoon') }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()

useHead({
  title: () => `${t('footer.blog')} - FastApp`
})
</script>

