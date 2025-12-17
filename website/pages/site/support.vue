<template>
  <div class="container mx-auto px-4 py-16">
    <h1 class="text-4xl font-bold mb-8 text-center">{{ $t('footer.support') }}</h1>
    <div class="max-w-3xl mx-auto">
      <div class="bg-white p-8 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-6">{{ $t('support.title') }}</h2>
        <div class="space-y-6">
          <div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('support.contact') }}</h3>
            <ul class="space-y-2 text-gray-600">
              <li>{{ $t('contact.email') }}: <a href="mailto:649909457@qq.com" class="hover:text-white transition">649909457@qq.com</a></li>
              <li>{{ $t('contact.telegram') }}: <a href="https://t.me/deepsea159" target="_blank" class="text-blue-600 hover:underline">@deepsea159</a></li>
            </ul>
          </div>
          <div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('support.faq') }}</h3>
            <p class="text-gray-600">{{ $t('support.faqDesc') }}</p>
          </div>
          <div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('support.issues') }}</h3>
            <p class="text-gray-600">{{ $t('support.issuesDesc') }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()

useHead({
  title: () => `${t('footer.support')} - FastApp`
})
</script>

