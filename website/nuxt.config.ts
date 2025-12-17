// https://nuxt.com/docs/api/configuration/nuxt-config
// @ts-ignore
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  
  experimental: {
    payloadExtraction: false
  },
  
  // 优化构建性能
  vite: {
    build: {
      chunkSizeWarningLimit: 1000
    }
  },
  
  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/i18n',
    '@nuxt/content'
  ],

  // Nuxt Content 配置
  content: {
    // Markdown 配置
    markdown: {
      toc: { depth: 3, searchDepth: 3 },
      remarkPlugins: [],
      rehypePlugins: []
    },
    // 代码高亮配置
    highlight: {
      theme: 'github-dark',
      preload: ['javascript', 'typescript', 'vue', 'bash', 'json', 'yaml', 'markdown']
    }
  },

  css: ['~/assets/css/main.css'],

  i18n: {
    locales: [
      {
        code: 'zh',
        iso: 'zh-CN',
        name: '简体中文',
        file: 'zh.json'
      },
      {
        code: 'en',
        iso: 'en-US',
        name: 'English',
        file: 'en.json'
      }
    ],
    defaultLocale: 'zh',
    strategy: 'prefix_except_default',
    detectBrowserLanguage: false,
    // 确保客户端导航正常工作
    compilation: {
      strictMessage: false
    }
  },

  app: {
    head: {
      title: 'FastApp - 企业级全栈应用框架',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'FastApp 是一个企业级全栈应用框架，包含移动端、Web端、后台管理系统、企业官网和后端服务。' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    },
    pageTransition: { name: 'page', mode: 'out-in' }
  },

  router: {
    options: {
      linkActiveClass: 'active',
      linkExactActiveClass: 'exact-active'
    }
  },

  ssr: true,

  runtimeConfig: {
    public: {
      wsUrl: process.env.WS_URL || 'ws://127.0.0.1:9502/ws',
      apiBaseUrl: process.env.API_BASE_URL || 'http://127.0.0.1:9501'
    }
  }
})

