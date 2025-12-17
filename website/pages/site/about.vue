<template>
  <div class="container mx-auto px-4 py-16">
    <h1 class="text-4xl font-bold mb-8 text-center">{{ $t('about.title') }}</h1>
    <div class="max-w-3xl mx-auto">
      <div class="prose prose-lg">
        <p class="text-gray-700 leading-relaxed mb-6">
          {{ $t('about.intro1') }}
        </p>
        <p class="text-gray-700 leading-relaxed mb-6">
          {{ $t('about.intro2') }}
        </p>
        <h2 class="text-2xl font-semibold mt-8 mb-4">{{ $t('about.mission') }}</h2>
        <p class="text-gray-700 leading-relaxed mb-6">
          {{ $t('about.missionDesc') }}
        </p>
        <h2 class="text-2xl font-semibold mt-8 mb-4">{{ $t('about.techAdvantage') }}</h2>
        <ul class="list-disc list-inside text-gray-700 space-y-2 mb-6">
          <li>{{ $t('about.techAdvantage1') }}</li>
          <li>{{ $t('about.techAdvantage2') }}</li>
          <li>{{ $t('about.techAdvantage3') }}</li>
          <li>{{ $t('about.techAdvantage4') }}</li>
          <li>{{ $t('about.techAdvantage5') }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()

useHead({
  title: () => `${t('about.title')} - FastApp`
})
</script>

