<template>
  <div>
    <section class="bg-gradient-to-r from-blue-600 to-blue-800 text-white py-20">
      <div class="container mx-auto px-4 text-center">
        <h1 class="text-5xl font-bold mb-6">{{ $t('home.title') }}</h1>
        <p class="text-xl mb-8 text-blue-100">
          {{ $t('home.subtitle') }}
        </p>
        <p class="text-lg mb-10 text-blue-200 max-w-2xl mx-auto">
          {{ $t('home.description') }}
        </p>
        <div class="flex justify-center space-x-4">
          <NuxtLink
            :to="localePath('/site/about')"
            class="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-blue-50 transition"
          >
            {{ $t('home.getStarted') }}
          </NuxtLink>
          <NuxtLink
            :to="localePath('/site/products')"
            class="bg-transparent border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-600 transition"
          >
            {{ $t('home.learnMore') }}
          </NuxtLink>
        </div>
      </div>
    </section>

    <section class="py-20 bg-gray-50">
      <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-center mb-12">{{ $t('home.features') }}</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-4xl mb-4">🚀</div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('home.highPerformance') }}</h3>
            <p class="text-gray-600">
              {{ $t('home.highPerformanceDesc') }}
            </p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-4xl mb-4">🔐</div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('home.permission') }}</h3>
            <p class="text-gray-600">
              {{ $t('home.permissionDesc') }}
            </p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-4xl mb-4">📱</div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('home.crossPlatform') }}</h3>
            <p class="text-gray-600">
              {{ $t('home.crossPlatformDesc') }}
            </p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-4xl mb-4">🎨</div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('home.modernUI') }}</h3>
            <p class="text-gray-600">
              {{ $t('home.modernUIDesc') }}
            </p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-4xl mb-4">🤖</div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('home.aiAssist') }}</h3>
            <p class="text-gray-600">
              {{ $t('home.aiAssistDesc') }}
            </p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-4xl mb-4">🔌</div>
            <h3 class="text-xl font-semibold mb-3">{{ $t('home.pluginSystem') }}</h3>
            <p class="text-gray-600">
              {{ $t('home.pluginSystemDesc') }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <section class="py-20">
      <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-center mb-12">{{ $t('home.techStack') }}</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
          <div class="p-6 bg-gray-50 rounded-lg">
            <div class="text-2xl font-semibold mb-2">Flutter</div>
            <div class="text-gray-600">{{ $t('footer.mobile') }}</div>
          </div>
          <div class="p-6 bg-gray-50 rounded-lg">
            <div class="text-2xl font-semibold mb-2">Vue3</div>
            <div class="text-gray-600">{{ $t('footer.admin') }}</div>
          </div>
          <div class="p-6 bg-gray-50 rounded-lg">
            <div class="text-2xl font-semibold mb-2">Nuxt.js</div>
            <div class="text-gray-600">{{ $t('products.website') }}</div>
          </div>
          <div class="p-6 bg-gray-50 rounded-lg">
            <div class="text-2xl font-semibold mb-2">Hyperf</div>
            <div class="text-gray-600">{{ $t('footer.backend') }}</div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()
const localePath = useLocalePath()

useHead({
  title: () => `${t('home.title')} - ${t('home.subtitle')}`,
  meta: [
    {
      name: 'description',
      content: () => t('home.description')
    }
  ]
})
</script>

