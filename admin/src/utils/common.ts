const DEFAULT_IMAGE = '/404.png'
const LANGUAGE_CODES = ['zh_CN', 'zh_TW', 'en', 'ja', 'ko', 'gm', 'ru', 'th', 'au'] as const

export interface LangOption {
  label: string
  value: string
}

type TranslateFunction = (key: string) => string

export function lang(t: TranslateFunction): LangOption[] {
  return LANGUAGE_CODES.map(code => ({
    label: t(`language.${code}`),
    value: code,
  }))
}

export function getLocalLang(): string {
  const userStore = useUserStore()
  return userStore.getLanguage()
}

interface LangItem {
  lang: string
  text: string
}

export function formatLang(obj: LangItem[] | unknown): string | unknown {
  if (!obj || typeof obj !== 'object' || !Array.isArray(obj)) {
    return obj
  }
  if (obj.length === 0) {
    return ''
  }
  const currentLang = getLocalLang()
  const currentLangItem = obj.find((item: LangItem) => item.lang === currentLang)
  return currentLangItem?.text || obj[0]?.text || ''
}

function isFullUrl(url: string): boolean {
  return url.startsWith('http://') || url.startsWith('https://')
}

function getPathname(url: string): string {
  try {
    return new URL(url).pathname
  }
  catch {
    return url
  }
}

export function formatFileUrl(url: string): string {
  const trimmed = (url ?? '').trim()
  if (!trimmed) return ''

  const fileBase = (import.meta.env.VITE_APP_FILE_BASEURL ?? '').trim()
  const apiBase = (import.meta.env.VITE_APP_API_BASEURL ?? '').trim()

  let path = isFullUrl(trimmed) ? getPathname(trimmed) : trimmed
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

/** 相对 API 路径（如 /api/ds/...）拼上 VITE_APP_API_BASEURL；已是绝对地址则原样返回 */
export function resolveApiUrl(url: string): string {
  if (!url) return ''
  if (isFullUrl(url)) return url
  const apiBase = (import.meta.env.VITE_APP_API_BASEURL ?? '').trim().replace(/\/$/, '')
  const path = url.startsWith('/') ? url : `/${url}`
  return apiBase ? `${apiBase}${path}` : path
}

function resolveStoragePath(path: string | null | undefined): string {
  if (!path || !path.trim() || path === DEFAULT_IMAGE) return ''
  if (isFullUrl(path)) {
    const pathname = getPathname(path)
    return pathname.startsWith('/uploads/') ? formatFileUrl(pathname) : path
  }
  return formatFileUrl(path)
}

export function formatImagePath(obj: string | string[] | { text?: string } | null | undefined): string | string[] {
  if (!obj) return DEFAULT_IMAGE

  if (typeof obj === 'string') {
    return resolveStoragePath(obj) || DEFAULT_IMAGE
  }

  if (Array.isArray(obj)) {
    return obj.length === 0 ? [DEFAULT_IMAGE] : obj.map(item => resolveStoragePath(item) || DEFAULT_IMAGE)
  }

  if (typeof obj === 'object') {
    return resolveStoragePath((obj as { text?: string }).text) || DEFAULT_IMAGE
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

export function generateOperationId(prefix: string = 'op'): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
}