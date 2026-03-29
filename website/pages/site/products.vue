<template>
  <div class="container mx-auto px-4 py-16">
    <h1 class="text-4xl font-bold mb-12 text-center">{{ $t('products.title') }}</h1>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <div class="bg-white p-6 rounded-lg shadow-md">
        <h3 class="text-2xl font-semibold mb-4">{{ $t('products.mobile') }}</h3>
        <p class="text-gray-600 mb-4">
          {{ $t('products.mobileDesc') }}
        </p>
        <ul class="text-sm text-gray-500 space-y-2">
          <li>✓ MobX + Provider 状态管理</li>
          <li>✓ 跨平台部署</li>
          <li>✓ 现代化 UI 设计</li>
        </ul>
      </div>
      <div class="bg-white p-6 rounded-lg shadow-md">
        <h3 class="text-2xl font-semibold mb-4">{{ $t('products.admin') }}</h3>
        <p class="text-gray-600 mb-4">
          {{ $t('products.adminDesc') }}
        </p>
        <ul class="text-sm text-gray-500 space-y-2">
          <li>✓ Vue3 + TypeScript</li>
          <li>✓ Element Plus UI 组件</li>
          <li>✓ Pinia 状态管理</li>
        </ul>
      </div>
      <div class="bg-white p-6 rounded-lg shadow-md">
        <h3 class="text-2xl font-semibold mb-4">{{ $t('products.website') }}</h3>
        <p class="text-gray-600 mb-4">
          {{ $t('products.websiteDesc') }}
        </p>
        <ul class="text-sm text-gray-500 space-y-2">
          <li>✓ Nuxt.js 4.2</li>
          <li>✓ SSR/SSG 支持</li>
          <li>✓ SEO 优化</li>
        </ul>
      </div>
      <div class="bg-white p-6 rounded-lg shadow-md">
        <h3 class="text-2xl font-semibold mb-4">{{ $t('products.backend') }}</h3>
        <p class="text-gray-600 mb-4">
          {{ $t('products.backendDesc') }}
        </p>
        <ul class="text-sm text-gray-500 space-y-2">
          <li>✓ Hyperf 3.1 + Swoole</li>
          <li>✓ 高并发支持</li>
          <li>✓ WebSocket 服务</li>
        </ul>
      </div>
      <div class="bg-white p-6 rounded-lg shadow-md">
        <h3 class="text-2xl font-semibold mb-4">{{ $t('products.permission') }}</h3>
        <p class="text-gray-600 mb-4">
          {{ $t('products.permissionDesc') }}
        </p>
        <ul class="text-sm text-gray-500 space-y-2">
          <li>✓ RBAC 权限模型</li>
          <li>✓ 角色管理</li>
          <li>✓ 权限控制</li>
        </ul>
      </div>
      <div class="bg-white p-6 rounded-lg shadow-md">
        <h3 class="text-2xl font-semibold mb-4">{{ $t('products.plugin') }}</h3>
        <p class="text-gray-600 mb-4">
          {{ $t('products.pluginDesc') }}
        </p>
        <ul class="text-sm text-gray-500 space-y-2">
          <li>✓ 插件扩展</li>
          <li>✓ 模块化设计</li>
          <li>✓ 易于集成</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()

useHead({
  title: () => `${t('products.title')} - FastApp`
})
</script>

