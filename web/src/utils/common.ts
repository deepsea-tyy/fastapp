// 常量定义
const DEFAULT_IMAGE = '/404.png'
const LANGUAGE_CODES = ['zh-CN', 'zh-TW', 'en', 'ja', 'ko', 'gm', 'ru', 'th', 'au'] as const

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
 * 获取当前本地语言代码（格式：zh-CN）
 * @returns 格式化的语言代码，将下划线替换为连字符
 */
export function getLocalLang(): string {
  const userStore = useUserStore()
  return userStore.getLanguage().replace(/_/g, '-')
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
 * 格式化单个图片路径
 */
function formatSingleImagePath(path: string | null | undefined, baseUrl: string): string {
  if (!path || (typeof path === 'string' && !path.trim())) {
    return DEFAULT_IMAGE
  }
  
  if (isFullUrl(path)) {
    return path
  }
  
  return baseUrl + path
}

/**
 * 格式化图片路径
 * @param obj - 图片路径，可以是字符串、字符串数组或包含 text 属性的对象
 * @returns 格式化后的图片路径或路径数组，如果为空则返回 404.png
 */
export function formatImagePath(obj: string | string[] | { text?: string } | null | undefined): string | string[] {
  const baseUrl = import.meta.env.VITE_APP_FILE_BASEURL || ''
  
  if (!obj) {
    return DEFAULT_IMAGE
  }
  
  if (typeof obj === 'string') {
    return formatSingleImagePath(obj, baseUrl)
  }
  
  if (Array.isArray(obj)) {
    return obj.length === 0 
      ? [DEFAULT_IMAGE]
      : obj.map(item => formatSingleImagePath(item, baseUrl))
  }
  
  if (typeof obj === 'object' && obj !== null) {
    return formatSingleImagePath(obj.text, baseUrl)
  }
  
  return DEFAULT_IMAGE
}
