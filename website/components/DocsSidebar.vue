<template>
  <nav class="p-4">
    <!-- 标题 -->
    <div class="mb-6">
      <NuxtLink 
        to="/help"
        class="text-xl font-bold text-gray-900 hover:text-blue-600 transition flex items-center"
        @click="$emit('close')"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
        </svg>
        文档中心
      </NuxtLink>
    </div>

    <!-- 文档列表 -->
    <ul v-if="docs.length > 0" class="space-y-1">
      <li v-for="doc in docs" :key="doc._path">
        <NuxtLink 
          :to="doc._path"
          class="block px-3 py-2 rounded hover:bg-gray-100 transition text-gray-700"
          :class="{ 
            'bg-blue-50 text-blue-600 font-semibold': isActive(doc._path)
          }"
          @click="$emit('close')"
        >
          {{ doc.title || getDocName(doc._path) }}
        </NuxtLink>
      </li>
    </ul>

    <!-- 加载中 -->
    <div v-else class="text-center py-8">
      <div class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
      <p class="mt-2 text-sm text-gray-500">加载中...</p>
    </div>

    <!-- 返回首页链接 -->
    <div class="mt-8 pt-6 border-t border-gray-200">
      <NuxtLink 
        to="/"
        class="flex items-center text-gray-600 hover:text-gray-900 transition text-sm"
        @click="$emit('close')"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        返回首页
      </NuxtLink>
    </div>
  </nav>
</template>

<script setup lang="ts">
const route = useRoute()
const docs = ref<any[]>([])

// 获取所有文档
const { data: allDocs } = await useAsyncData('help-sidebar', () =>
  queryContent('/help').find()
)

// 初始化文档列表（排除首页）
if (allDocs.value) {
  docs.value = allDocs.value.filter((doc: any) => doc._path !== '/help')
}

// 检查当前路径是否激活
const isActive = (path: string) => {
  return route.path === path
}

// 获取文档名称
const getDocName = (path: string) => {
  const parts = path.split('/')
  const name = parts[parts.length - 1]
  // 将 kebab-case 转换为 Title Case
  return name
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

defineEmits<{
  close: []
}>()
</script>

