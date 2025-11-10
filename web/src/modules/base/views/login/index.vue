<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import './style.scss'
import LoginForm from './components/login-form.vue'
import Logo from './components/logo.vue'
import CopyRight from './components/copyright.vue'

defineOptions({ name: 'Login' })

// 常量定义
const PARTICLE_COUNT = 50

// 语言切换相关
const userStore = useUserStore()
const { locale, t } = useI18n()

// 获取语言列表并动态翻译标签
const locales = computed(() => {
  const rawLocales = userStore.getLocales()
  return rawLocales.map((item: any) => {
    // 将 value 从 zh_CN 格式转换为 zh-CN 格式用于翻译键
    const langKey = item.value.replace('_', '-')
    return {
      ...item,
      label: t(`language.${langKey}`) || item.label,
    }
  })
})

const currentLanguage = computed({
  get: () => locale.value,
  set: (value: string) => {
    changeLanguage(value)
  }
})

function changeLanguage(langValue: string) {
  userStore.setLanguage(langValue)
  locale.value = langValue
}

// 生成粒子样式（在组件挂载时生成一次，避免重复计算）
const particleStyles = ref<Array<Record<string, string>>>([])

onMounted(() => {
  particleStyles.value = Array.from({ length: PARTICLE_COUNT }, () => {
    const size = Math.random() * 4 + 2
    const duration = Math.random() * 20 + 10
    const delay = Math.random() * 5
    const x = Math.random() * 100
    const y = Math.random() * 100
    
    return {
      width: `${size}px`,
      height: `${size}px`,
      left: `${x}%`,
      top: `${y}%`,
      animationDuration: `${duration}s`,
      animationDelay: `${delay}s`,
    }
  })
})
</script>

<template>
  <div class="login-container">
    <!-- 背景粒子效果层 -->
    <div class="particles-background">
      <div 
        v-for="(style, index) in particleStyles" 
        :key="index" 
        class="particle" 
        :style="style"
      ></div>
    </div>

    <!-- 网格背景 -->
    <div class="grid-background"></div>

    <!-- 主要内容区 -->
    <div class="login-content">
      <!-- Logo区域 -->
      <div class="logo-section">
        <Logo />
      </div>

      <!-- 登录表单区域 -->
      <div class="form-section">
        <div class="form-card">
          <div class="card-glow"></div>
          <div class="card-content">
            <div class="form-header">
              <h2 class="form-title">{{ t('loginForm.welcomeBack') }}</h2>
              <el-select
                v-model="currentLanguage"
                class="language-select"
                size="small"
                @change="changeLanguage"
              >
                <el-option
                  v-for="item in locales"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </el-select>
            </div>
            <LoginForm />
          </div>
        </div>
      </div>

      <!-- 底部版权信息 -->
      <div class="footer-section">
        <CopyRight />
      </div>
    </div>
  </div>
</template>
