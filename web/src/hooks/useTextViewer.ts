import {createApp, h, onMounted, ref} from 'vue'
import ElementPlus, {ElDialog} from 'element-plus'
import pinia from '@/store'
import {useMessage} from '@/hooks/useMessage.ts'
import {createI18n, useI18n} from 'vue-i18n'
import messages from '@intlify/unplugin-vue-i18n/messages'
import useUserStore from '@/store/modules/useUserStore.ts'

type Options = {
  title?: string
  width?: string
  zIndex?: number
}

export function useTextViewer(textUrl: string, options?: Options) {
  const textViewerDom = document.createElement('div')
  document.body.appendChild(textViewerDom)
  
  const defaultOptions: Options = {
    title: '',
    width: '80%',
    zIndex: 2500,
    ...options,
  }

  let app: any = null

  const close = () => {
    if (app && textViewerDom.parentNode) {
      app.unmount()
      textViewerDom.parentNode.removeChild(textViewerDom)
      app = null
    }
  }

  const TextViewerComponent = {
    setup() {
      const visible = ref(true)
      const loading = ref(true)
      const content = ref('')
      const error = ref(false)
      const msg = useMessage()
      const {t} = useI18n()

      const title = defaultOptions.title || t('common.textPreview')

      const handleClose = () => {
        visible.value = false
        setTimeout(() => {
          close()
        }, 300)
      }

      // 加载文本内容
      const loadText = async () => {
        try {
          loading.value = true
          error.value = false
          const response = await fetch(textUrl)
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`)
          }
          content.value = await response.text()
        }
        catch (err) {
          console.error('加载文本失败:', err)
          error.value = true
          msg.error(t('common.loadTextError'))
        }
        finally {
          loading.value = false
        }
      }

      // 组件挂载时加载文本
      onMounted(() => {
        loadText()
      })

      const textContent = () => h('div', {
        class: 'text-viewer-content',
        style: {
          maxHeight: '70vh',
          overflow: 'auto',
          padding: '20px',
          backgroundColor: 'var(--el-bg-color)',
          borderRadius: '4px',
        },
      }, [
        loading.value
          ? h('div', {
            style: {
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              minHeight: '200px',
              color: 'var(--el-text-color-regular)',
            },
          }, [t('common.loading')])
          : error.value
            ? h('div', {
              style: {
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center',
                minHeight: '200px',
                color: 'var(--el-color-error)',
              },
            }, [t('common.loadFailed')])
            : h('pre', {
              style: {
                margin: 0,
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-word',
                fontFamily: 'monospace',
                fontSize: '14px',
                lineHeight: '1.6',
                color: 'var(--el-text-color-primary)',
              },
            }, content.value),
      ])

      return () => h(ElDialog, {
        modelValue: visible.value,
        'onUpdate:modelValue': (val: boolean) => {
          visible.value = val
          if (!val) {
            handleClose()
          }
        },
        title,
        width: defaultOptions.width,
        zIndex: defaultOptions.zIndex,
        destroyOnClose: true,
        appendToBody: true,
        closeOnClickModal: true,
        onClose: handleClose,
      }, {
        default: textContent,
      })
    },
  }

  app = createApp(TextViewerComponent)
  
  // 安装必要的插件
  app.use(pinia)
  app.use(ElementPlus, {})
  
  // 创建 i18n 实例（复用主应用的配置）
  try {
    // 处理 messages，与主应用保持一致
    const processedMessages: any = {}
    Object.keys(messages as any).forEach((name: string) => {
      const matchValue = name.match(/(\w+)/) as RegExpMatchArray | null
      if (messages && matchValue) {
        processedMessages[matchValue[1]] = (messages as any)[name]
      }
    })
    
    const i18n = createI18n({
      legacy: false,
      globalInjection: true,
      fallbackLocale: 'zh_CN',
      locale: useUserStore().getLanguage(),
      silentTranslationWarn: true,
      silentFallbackWarn: true,
      messages: processedMessages,
    })
    
    app.use(i18n)
  } catch (e) {
    // 如果创建 i18n 失败，跳过安装（组件仍可工作，但可能无法使用 i18n）
  }
  
  app.mount(textViewerDom)
}

