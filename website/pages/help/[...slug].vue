<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 响应式布局容器 -->
    <div class="flex flex-col md:flex-row">
      <!-- 移动端菜单按钮 -->
      <button 
        @click="sidebarOpen = !sidebarOpen"
        class="md:hidden fixed top-4 left-4 z-50 bg-white p-2 rounded-lg shadow-lg hover:bg-gray-100 transition"
        aria-label="切换侧边栏"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      <!-- 移动端遮罩层 -->
      <div 
        v-if="sidebarOpen"
        class="md:hidden fixed inset-0 bg-black bg-opacity-50 z-30"
        @click="sidebarOpen = false"
      />

      <!-- 侧边栏导航 -->
      <aside 
        :class="[
          'fixed md:sticky top-0 h-screen w-64 bg-white border-r border-gray-200 overflow-y-auto z-40 transition-transform duration-300',
          sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        ]"
      >
        <DocsSidebar @close="sidebarOpen = false" />
      </aside>

      <!-- 主内容区 -->
      <main class="flex-1 min-h-screen">
        <article v-if="page" class="max-w-4xl mx-auto px-4 py-8 md:px-8">
          <!-- 文档标题 -->
          <header class="mb-8">
            <h1 class="text-4xl font-bold mb-4 text-gray-900">
              {{ page.title || '文档' }}
            </h1>
            <p v-if="page.description" class="text-lg text-gray-600">
              {{ page.description }}
            </p>
          </header>
          
          <!-- 文章目录（移动端可折叠） -->
          <DocsTOC v-if="page.toc && page.toc.links?.length" :toc="page.toc" class="mb-8" />

          <!-- Markdown 内容渲染 -->
          <div class="prose prose-lg max-w-none">
            <ContentRenderer :value="page" />
          </div>
          
          <!-- 导航链接 -->
          <nav v-if="surround" class="mt-12 pt-8 border-t border-gray-200 flex justify-between">
            <NuxtLink 
              v-if="surround.prev"
              :to="surround.prev._path"
              class="flex items-center text-blue-600 hover:text-blue-800 transition"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
              <span>{{ surround.prev.title }}</span>
            </NuxtLink>
            <NuxtLink 
              v-if="surround.next"
              :to="surround.next._path"
              class="flex items-center text-blue-600 hover:text-blue-800 transition ml-auto"
            >
              <span>{{ surround.next.title }}</span>
              <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </NuxtLink>
          </nav>
        </article>
        
        <!-- 404 页面 -->
        <div v-else class="text-center py-20">
          <h1 class="text-4xl font-bold mb-4 text-gray-900">文档未找到</h1>
          <p class="text-gray-600 mb-8">抱歉，您访问的文档不存在。</p>
          <NuxtLink 
            to="/help"
            class="inline-block bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition"
          >
            返回文档首页
          </NuxtLink>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()

// 获取当前页面内容
const { data: page } = await useAsyncData(`help-${route.path}`, () => 
  queryContent(route.path).findOne()
)

// 获取前后文档导航
const { data: surround } = await useAsyncData(`help-surround-${route.path}`, () =>
  queryContent(route.path).findSurround()
)

// 响应式侧边栏控制
const sidebarOpen = ref(false)

// 移动端点击外部区域关闭侧边栏
onMounted(() => {
  if (process.client && window.innerWidth < 768) {
    sidebarOpen.value = false
  }
  
  // 监听路由变化，移动端自动关闭侧边栏
  watch(() => route.path, () => {
    if (process.client && window.innerWidth < 768) {
      sidebarOpen.value = false
    }
  })
})

// SEO
useHead({
  title: () => page.value?.title ? `${page.value.title} - 文档中心` : '文档中心',
  meta: [
    {
      name: 'description',
      content: () => page.value?.description || '交易所文档中心'
    }
  ]
})
</script>

<style scoped>
/* 自定义 Markdown 样式 */
:deep(.prose) {
  @apply text-gray-800;
}

:deep(.prose h2) {
  @apply text-3xl font-bold mt-8 mb-4 text-gray-900 border-b border-gray-200 pb-2;
}

:deep(.prose h3) {
  @apply text-2xl font-semibold mt-6 mb-3 text-gray-800;
}

:deep(.prose h4) {
  @apply text-xl font-semibold mt-4 mb-2 text-gray-700;
}

:deep(.prose code) {
  @apply bg-gray-100 px-2 py-1 rounded text-sm font-mono text-pink-600;
}

:deep(.prose pre) {
  @apply bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto my-4;
}

:deep(.prose pre code) {
  @apply bg-transparent text-gray-100 p-0;
  color: inherit;
}

:deep(.prose table) {
  @apply w-full border-collapse border border-gray-300 my-4;
}

:deep(.prose th) {
  @apply bg-gray-100 border border-gray-300 px-4 py-2 text-left font-semibold;
}

:deep(.prose td) {
  @apply border border-gray-300 px-4 py-2;
}

:deep(.prose a) {
  @apply text-blue-600 hover:text-blue-800 hover:underline;
}

:deep(.prose blockquote) {
  @apply border-l-4 border-blue-500 pl-4 italic text-gray-600 my-4;
}

:deep(.prose img) {
  @apply rounded-lg shadow-md my-4;
}

:deep(.prose ul),
:deep(.prose ol) {
  @apply my-4;
}

:deep(.prose li) {
  @apply my-2;
}

:deep(.prose strong) {
  @apply font-semibold text-gray-900;
}

:deep(.prose hr) {
  @apply border-gray-300 my-8;
}
</style>

