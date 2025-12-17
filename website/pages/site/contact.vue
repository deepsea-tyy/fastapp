<template>
  <div class="container mx-auto px-4 py-16">
    <h1 class="text-4xl font-bold mb-12 text-center">{{ $t('contact.title') }}</h1>
    <div class="max-w-2xl mx-auto">
      <div class="bg-white p-8 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-6">{{ $t('contact.contactInfo') }}</h2>
        <div class="space-y-4">
          <div>
            <h3 class="font-semibold mb-2">{{ $t('contact.email') }}</h3>
            <p class="text-gray-600"><a href="mailto:649909457@qq.com" class="text-blue-600 hover:text-blue-700 transition">649909457@qq.com</a></p>
          </div>
          <div>
            <h3 class="font-semibold mb-2">{{ $t('contact.telegram') }}</h3>
            <p class="text-gray-600">
              <a href="https://t.me/deepsea159" target="_blank" class="text-blue-600 hover:underline">
                @deepsea159
              </a>
            </p>
          </div>
          <div>
            <h3 class="font-semibold mb-2">{{ $t('contact.author') }}</h3>
            <p class="text-gray-600">deepsea</p>
          </div>
        </div>
        <div class="mt-8 pt-8 border-t">
          <h3 class="font-semibold mb-4">{{ $t('contact.support') }}</h3>
          <p class="text-gray-600">
            {{ $t('contact.supportDesc') }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()

useHead({
  title: () => `${t('contact.title')} - FastApp`
})
</script>

