const DEFAULT_IMAGE = '/404.png'
const LANGUAGE_CODES = ['zh_CN', 'zh_TW', 'en', 'ja', 'ko', 'gm', 'ru', 'th', 'au'] as const

/**
 * 语言选项类型
 */
export interface LangOption {
  label: string
  value: string
}

/**
 * 翻译函数类型
 */
type TranslateFunction = (key: string) => string

/**
 * 获取语言选项列表
 * @param t - 翻译函数
 * @returns 语言选项数组
 */
export function lang(t: TranslateFunction): LangOption[] {
  return LANGUAGE_CODES.map(code => ({
    label: t(`language.${code}`),
    value: code,
  }))
}

/**
 * 获取当前本地语言代码（格式：zh_CN）
 * @returns 格式化的语言代码，将下划线替换为连字符
 */
export function getLocalLang(): string {
  const userStore = useUserStore()
  return userStore.getLanguage()
}

/**
 * 多语言对象类型
 */
interface LangItem {
  lang: string
  text: string
}

/**
 * 格式化多语言对象，根据当前语言返回对应的文本
 * @param obj - 多语言对象数组或原始值
 * @returns 当前语言对应的文本，如果不存在则返回第一个文本，如果都不是则返回原值
 */
export function formatLang(obj: LangItem[] | any): string | any {
  if (typeof obj !== 'object' || !obj || !Array.isArray(obj)) {
    return obj
  }
  if (obj.length === 0) {
    return ''
  }
  const currentLang = getLocalLang()
  const currentLangItem = obj.find((item: LangItem) => item.lang === currentLang)
  return currentLangItem?.text || obj[0]?.text || ''
}

/**
 * 检查是否是完整 URL
 */
function isFullUrl(url: string): boolean {
  return url.startsWith('http://') || url.startsWith('https://')
}

/**
 * 将 storage 路径转为 /api/file 访问地址
 */
export function formatFileUrl(url: string): string {
  const trimmed = (url ?? '').trim()
  if (!trimmed) return ''

  const fileBase = (import.meta.env.VITE_APP_FILE_BASEURL ?? '').trim()
  const apiBase = (import.meta.env.VITE_APP_API_BASEURL ?? '').trim()

  let path = trimmed
  if (isFullUrl(trimmed)) {
    try {
      path = new URL(trimmed).pathname
    }
    catch {
      return trimmed
    }
  }

  if (!path.startsWith('/')) {
    path = `/${path}`
  }

  if (fileBase.includes('/api/file')) {
    return fileBase + encodeURIComponent(path)
  }

  if (apiBase) {
    return `${apiBase}/api/file?path=${encodeURIComponent(path)}`
  }

  return path
}

function resolveStoragePath(path: string | null | undefined): string {
  if (!path || !path.trim() || path === DEFAULT_IMAGE) return ''
  if (isFullUrl(path)) {
    try {
      const pathname = new URL(path).pathname
      if (pathname.startsWith('/uploads/')) {
        return formatFileUrl(pathname)
      }
      return path
    }
    catch {
      return path
    }
  }
  return formatFileUrl(path)
}

/**
 * 格式化图片路径
 * @param obj - 图片路径，可以是字符串、字符串数组或包含 text 属性的对象
 * @returns 格式化后的图片路径或路径数组，如果为空则返回 404.png
 */
export function formatImagePath(obj: string | string[] | { text?: string } | null | undefined): string | string[] {
  if (!obj) {
    return DEFAULT_IMAGE
  }

  if (typeof obj === 'string') {
    const resolved = resolveStoragePath(obj)
    return resolved || DEFAULT_IMAGE
  }

  if (Array.isArray(obj)) {
    return obj.length === 0
      ? [DEFAULT_IMAGE]
      : obj.map((item) => {
          const resolved = resolveStoragePath(item)
          return resolved || DEFAULT_IMAGE
        })
  }

  if (typeof obj === 'object' && obj !== null) {
    const resolved = resolveStoragePath(obj.text)
    return resolved || DEFAULT_IMAGE
  }

  return DEFAULT_IMAGE
}

export function processUrl(url: string | null | undefined): string {
  if (!url || typeof url !== 'string' || !url.trim()) {
    return ''
  }

  const baseUrl = import.meta.env.VITE_APP_FILE_BASEURL || ''
  if (!baseUrl) {
    return url.trim()
  }

  if (url.startsWith(baseUrl)) {
    return url.replace(baseUrl, '')
  }

  if (isFullUrl(url)) {
    return url
  }

  return url.trim()
}
