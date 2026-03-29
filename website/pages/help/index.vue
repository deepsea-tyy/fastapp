<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto px-4 py-12 md:px-8">
      <!-- 页面标题 -->
      <header class="text-center mb-12">
        <h1 class="text-4xl font-bold mb-4 text-gray-900">文档中心</h1>
        <p class="text-lg text-gray-600 max-w-2xl mx-auto">
          完整的 API 文档、交易指南和使用说明
        </p>
      </header>

      <!-- 搜索框 -->
      <div class="mb-8">
        <div class="relative max-w-2xl mx-auto">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索文档..."
            class="w-full px-4 py-3 pl-12 pr-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
            @input="handleSearch"
          />
          <svg 
            class="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400"
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
      </div>

      <!-- 文档列表 -->
      <div v-if="filteredDocs.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <NuxtLink
          v-for="doc in filteredDocs"
          :key="doc._path"
          :to="doc._path"
          class="bg-white rounded-lg shadow-md hover:shadow-lg transition p-6 group"
        >
          <h3 class="text-xl font-semibold mb-2 text-gray-900 group-hover:text-blue-600 transition">
            {{ doc.title || doc._path.split('/').pop() }}
          </h3>
          <p v-if="doc.description" class="text-gray-600 text-sm mb-4 line-clamp-2">
            {{ doc.description }}
          </p>
          <div class="flex items-center text-blue-600 text-sm">
            <span>阅读更多</span>
            <svg class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </NuxtLink>
      </div>

      <!-- 无搜索结果 -->
      <div v-else-if="searchQuery" class="text-center py-20">
        <svg 
          class="w-16 h-16 mx-auto text-gray-400 mb-4"
          fill="none" 
          stroke="currentColor" 
          viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <h3 class="text-xl font-semibold mb-2 text-gray-900">未找到相关文档</h3>
        <p class="text-gray-600 mb-4">请尝试其他关键词</p>
        <button 
          @click="searchQuery = ''"
          class="text-blue-600 hover:text-blue-800 underline"
        >
          清除搜索
        </button>
      </div>

      <!-- 加载中 -->
      <div v-else class="text-center py-20">
        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        <p class="mt-4 text-gray-600">加载中...</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const searchQuery = ref('')
const docs = ref<any[]>([])
const filteredDocs = ref<any[]>([])

// 获取所有文档
const { data: allDocs } = await useAsyncData('help-list', () =>
  queryContent('/help').find() as Promise<any[]>
)

// 初始化文档列表
if (allDocs.value && Array.isArray(allDocs.value)) {
  docs.value = allDocs.value.filter((doc: any) => doc._path !== '/help')
  filteredDocs.value = docs.value
}

// 搜索功能
const handleSearch = () => {
  if (!searchQuery.value.trim()) {
    filteredDocs.value = docs.value
    return
  }

  const query = searchQuery.value.toLowerCase()
  filteredDocs.value = docs.value.filter((doc: any) => {
    const title = (doc.title || '').toLowerCase()
    const description = (doc.description || '').toLowerCase()
    const path = doc._path.toLowerCase()
    
    return title.includes(query) || description.includes(query) || path.includes(query)
  })
}

// SEO
useHead({
  title: '文档中心 - 交易所文档',
  meta: [
    {
      name: 'description',
      content: '交易所文档中心，提供完整的 API 文档、交易指南和使用说明'
    }
  ]
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>

