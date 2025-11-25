<template>
  <header class="bg-white shadow-sm sticky top-0 z-50">
    <nav class="container mx-auto px-4 py-4">
      <div class="flex items-center justify-between">
        <NuxtLink :to="localePath('/')" prefetch class="flex items-center gap-2 text-2xl font-bold text-blue-600">
          <img :src="logoUrl" alt="FastApp" class="h-8 w-auto" />
          <span>FastApp</span>
        </NuxtLink>
        
        <!-- 导航菜单 -->
        <div class="flex items-center gap-4 md:gap-6">
          <!-- 导航链接 -->
          <ul
            :class="[
              'flex items-center transition-all duration-300',
              'fixed md:static top-16 left-0 right-0 md:top-auto',
              'bg-white md:bg-transparent',
              'flex-col md:flex-row',
              'space-y-3 md:space-y-0 md:space-x-6',
              'pt-4 pb-4 md:pt-0 md:pb-0',
              'border-t border-gray-200 md:border-0',
              'shadow-md md:shadow-none',
              isMobileMenuOpen ? 'opacity-100 visible' : 'opacity-0 invisible md:opacity-100 md:visible'
            ]"
          >
            <li>
              <NuxtLink
                :to="localePath('/')"
                prefetch
                @click="closeMobileMenu"
                :class="[
                  'block md:inline transition py-2 md:py-0',
                  isActive('/') ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600'
                ]"
              >
                {{ $t('nav.home') }}
              </NuxtLink>
            </li>
            <li>
              <NuxtLink
                :to="localePath('/about')"
                prefetch
                @click="closeMobileMenu"
                :class="[
                  'block md:inline transition py-2 md:py-0',
                  isActive('/about') ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600'
                ]"
              >
                {{ $t('nav.about') }}
              </NuxtLink>
            </li>
            <li>
              <NuxtLink
                :to="localePath('/products')"
                prefetch
                @click="closeMobileMenu"
                :class="[
                  'block md:inline transition py-2 md:py-0',
                  isActive('/products') ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600'
                ]"
              >
                {{ $t('nav.products') }}
              </NuxtLink>
            </li>
            <li>
              <NuxtLink
                :to="localePath('/contact')"
                prefetch
                @click="closeMobileMenu"
                :class="[
                  'block md:inline transition py-2 md:py-0',
                  isActive('/contact') ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600'
                ]"
              >
                {{ $t('nav.contact') }}
              </NuxtLink>
            </li>
            <li>
              <a
                href="/docs/index.html"
                target="_blank"
                rel="noopener noreferrer"
                @click="closeMobileMenu"
                class="block md:inline text-gray-700 hover:text-blue-600 transition py-2 md:py-0"
              >
                {{ $t('footer.docs') }}
              </a>
            </li>
          </ul>

          <!-- 语言选择器 -->
          <div class="flex items-center border-l border-gray-200 md:pl-6 pl-4">
            <select
              :value="currentLocale"
              @change="handleChange"
              class="px-2 md:px-3 py-1 md:py-1.5 rounded text-sm border border-gray-300 bg-white text-gray-700 hover:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition cursor-pointer"
            >
              <option
                v-for="locale in availableLocales"
                :key="locale.code"
                :value="locale.code"
              >
                {{ locale.name }}
              </option>
            </select>
          </div>

          <!-- 移动端菜单按钮 -->
          <button
            @click="toggleMobileMenu"
            class="md:hidden text-gray-700 hover:text-blue-600 focus:outline-none focus:text-blue-600 transition"
            aria-label="菜单"
          >
            <svg v-if="!isMobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
            <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </nav>
  </header>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const { locale, locales } = useI18n()
const switchLocalePath = useSwitchLocalePath()
const localePath = useLocalePath()
const route = useRoute()

const currentLocale = computed(() => locale.value)

// 获取正确的 logo URL，避免 i18n 路由影响
const logoUrl = '/logo.svg'

// 移动端菜单状态
const isMobileMenuOpen = ref(false)

const availableLocales = computed(() => {
  return locales.value as any[]
})

const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value
}

const closeMobileMenu = () => {
  isMobileMenuOpen.value = false
}

// 判断路径是否激活
const isActive = (path: string) => {
  const currentPath = route.path
  // 移除语言前缀进行比较
  const normalizedCurrentPath = currentPath.replace(/^\/[a-z]{2}(\/|$)/, '/') || '/'
  const normalizedPath = path === '/' ? '/' : path
  return normalizedCurrentPath === normalizedPath
}

const handleChange = async (event: Event) => {
  const target = event.target as HTMLSelectElement
  const newCode = target.value as 'zh' | 'en'
  
  if (newCode === locale.value) {
    return
  }
  
  // 使用 switchLocalePath 获取新路径
  const newPath = switchLocalePath(newCode)
  
  if (newPath && newPath !== route.path) {
    // 使用 navigateTo 进行客户端导航，确保 external: false
    await navigateTo(newPath, { external: false })
  }
}
</script>

