<template>
  <nav 
    v-if="toc && toc.links && toc.links.length > 0"
    class="bg-gray-100 rounded-lg border border-gray-200 p-4"
  >
    <button
      @click="isExpanded = !isExpanded"
      class="w-full flex items-center justify-between font-semibold text-gray-900 mb-3 md:hidden"
    >
      <span>目录</span>
      <svg 
        class="w-5 h-5 transition-transform"
        :class="{ 'rotate-180': isExpanded }"
        fill="none" 
        stroke="currentColor" 
        viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <h3 class="font-semibold mb-3 text-gray-900 hidden md:block">目录</h3>
    
    <ul 
      v-show="isExpanded || !isMobile"
      class="space-y-1"
    >
      <li 
        v-for="link in toc.links" 
        :key="link.id"
        :class="`pl-${(link.depth - 1) * 4}`"
      >
        <a 
          :href="`#${link.id}`" 
          class="block text-blue-600 hover:text-blue-800 hover:underline text-sm py-1 transition"
          @click="handleClick"
        >
          {{ link.text }}
        </a>
        <!-- 嵌套子目录 -->
        <ul v-if="link.children && link.children.length" class="ml-4 mt-1 space-y-1">
          <li 
            v-for="child in link.children" 
            :key="child.id"
            :class="`pl-${(child.depth - 1) * 4}`"
          >
            <a 
              :href="`#${child.id}`" 
              class="block text-blue-600 hover:text-blue-800 hover:underline text-sm py-1 transition"
              @click="handleClick"
            >
              {{ child.text }}
            </a>
          </li>
        </ul>
      </li>
    </ul>
  </nav>
</template>

<script setup lang="ts">
interface TocLink {
  id: string
  depth: number
  text: string
  children?: TocLink[]
}

interface Toc {
  links: TocLink[]
}

const props = defineProps<{
  toc: Toc
}>()

const isExpanded = ref(false)
const isMobile = ref(false)

// 检测是否为移动端
onMounted(() => {
  if (process.client) {
    isMobile.value = window.innerWidth < 768
    
    const handleResize = () => {
      isMobile.value = window.innerWidth < 768
      if (!isMobile.value) {
        isExpanded.value = true
      }
    }
    
    window.addEventListener('resize', handleResize)
    
    onUnmounted(() => {
      window.removeEventListener('resize', handleResize)
    })
  } else {
    isExpanded.value = true
  }
})

// 处理点击事件（平滑滚动）
const handleClick = (event: Event) => {
  const target = event.target as HTMLAnchorElement
  const href = target.getAttribute('href')
  
  if (href && href.startsWith('#')) {
    event.preventDefault()
    const id = href.slice(1)
    const element = document.getElementById(id)
    
    if (element) {
      const offsetTop = element.offsetTop - 100 // 留出顶部空间
      window.scrollTo({
        top: offsetTop,
        behavior: 'smooth'
      })
      
      // 移动端点击后折叠
      if (isMobile.value) {
        setTimeout(() => {
          isExpanded.value = false
        }, 300)
      }
    }
  }
}
</script>

<style scoped>
/* 确保不同深度的缩进正确显示 */
.pl-0 { padding-left: 0; }
.pl-4 { padding-left: 1rem; }
.pl-8 { padding-left: 2rem; }
.pl-12 { padding-left: 3rem; }
.pl-16 { padding-left: 4rem; }
</style>

