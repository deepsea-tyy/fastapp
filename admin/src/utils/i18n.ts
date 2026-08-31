
import type { I18n, Composer, ComposerTranslation } from 'vue-i18n'
import { createI18n } from 'vue-i18n'
import type { WritableComputedRef } from 'vue'
import messages from '@intlify/unplugin-vue-i18n/messages'

let i18nInstance: I18n | null = null

/**
 * 初始化 i18n 实例（在 main.ts/bootstrap 中调用一次）
 */
export function createI18nInstance(locale: string = 'zh_CN'): I18n {
  // 处理 messages 的 key 格式转换
  const processedMessages: Record<string, any> = { ...messages } as any
  Object.keys(processedMessages).map((name: string) => {
    const matchValue = name.match(/(\w+)/) as RegExpMatchArray | null
    if (matchValue) {
      processedMessages[matchValue[1]] = processedMessages[name]
      if (matchValue[1] !== name) {
        delete processedMessages[name]
      }
    }
  })

  i18nInstance = createI18n({
    legacy: false,
    globalInjection: true,
    fallbackLocale: 'zh_CN',
    locale,
    silentTranslationWarn: true,
    silentFallbackWarn: true,
    messages: processedMessages,
  })

  return i18nInstance
}

/**
 * 获取 i18n 实例
 */
export function getI18n(): I18n {
  if (!i18nInstance) {
    throw new Error('[i18n] i18n 实例尚未初始化，请先调用 createI18nInstance()')
  }
  return i18nInstance
}

/**
 * 获取全局 Composer 实例
 */
function getComposer(): Composer {
  return getI18n().global as unknown as Composer
}

// ==================== 响应式 Composable（推荐在 store / 组件 setup 中使用） ====================

export interface UseI18nGlobalReturn {
  /** 响应式翻译函数 */
  t: ComposerTranslation
  /** 检查 key 是否存在翻译（响应式） */
  te: (key: string) => boolean
  /** 当前语言（响应式 ref） */
  locale: WritableComputedRef<string>
  /** Composer 实例 */
  composer: Composer
}

/**
 * 全局 i18n composable
 *
 * 在 store 的 setup 函数或组件中使用，返回的 t / locale 都是响应式的，
 * 语言切换时会自动触发更新。
 *
 * @example
 * ```ts
 * // 在 store 中
 * const useXxxStore = defineStore('xxx', () => {
 *   const { t, locale } = useI18nGlobal()
 *   const title = computed(() => t('some.key'))
 *   return { title }
 * })
 * ```
 */
export function useI18nGlobal(): UseI18nGlobalReturn {
  const composer = getComposer()
  return {
    t: composer.t,
    te: composer.te,
    locale: composer.locale,
    composer,
  }
}

// ==================== 非响应式工具函数（用于普通 ts 函数 / 非 setup 上下文） ====================

/**
 * 翻译函数（非响应式，用于普通 ts 上下文）
 *
 * 注意：此函数调用时返回当前语言的翻译结果，但不会追踪语言变化。
 * 如果需要响应式，请使用 `useI18nGlobal()`。
 */
export function t(key: string, ...args: any[]): string {
  if (!i18nInstance) {
    console.warn('[i18n] i18n 实例尚未初始化，返回原始 key')
    return key
  }
  return getComposer().t(key, ...args)
}

/**
 * 检查 key 是否存在翻译（非响应式）
 */
export function te(key: string): boolean {
  if (!i18nInstance) {
    return false
  }
  return getComposer().te(key)
}

/**
 * 获取当前语言（非响应式，返回 string 值而非 ref）
 */
export function getLocale(): string {
  if (!i18nInstance) {
    return 'zh_CN'
  }
  return getComposer().locale.value
}

/**
 * 设置当前语言
 */
export function setLocale(locale: string): void {
  if (!i18nInstance) {
    console.warn('[i18n] i18n 实例尚未初始化，无法设置语言')
    return
  }
  getComposer().locale.value = locale
}

export default {
  createI18nInstance,
  getI18n,
  useI18nGlobal,
  t,
  te,
  getLocale,
  setLocale,
}
