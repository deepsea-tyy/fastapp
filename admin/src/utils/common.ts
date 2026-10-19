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

function fileBase(): string {
  return (import.meta.env.VITE_APP_FILE_BASEURL ?? '/api/file').replace(/\/$/, '')
}

function formatFileUrlOne(input: string | number): string {
  if (typeof input === 'number') {
    return input > 0 ? `${fileBase()}?id=${input}` : ''
  }

  const trimmed = input.trim()
  if (!trimmed || trimmed === DEFAULT_IMAGE)
    return trimmed === DEFAULT_IMAGE ? DEFAULT_IMAGE : ''

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
    return trimmed

  if (/^\d+$/.test(trimmed)) {
    const id = Number(trimmed)
    return id > 0 ? `${fileBase()}?id=${id}` : ''
  }

  if (trimmed.includes('/api/file?')) {
    const q = trimmed.includes('?') ? trimmed.slice(trimmed.indexOf('?')) : ''
    return `${fileBase()}${q}`
  }

  const path = trimmed.startsWith('/') ? trimmed : `/${trimmed}`
  return `${fileBase()}?path=${encodeURIComponent(path)}`
}

/** 项目唯一文件 URL 入口：id（number）或 path（string）；数组 / { text } 用于 UI 批量与占位图 */
export function formatFileUrl(
  input: string | number | string[] | { text?: string } | null | undefined,
): string | string[] {
  if (typeof input === 'number')
    return formatFileUrlOne(input)

  if (input == null)
    return DEFAULT_IMAGE

  if (Array.isArray(input)) {
    return input.length === 0
      ? [DEFAULT_IMAGE]
      : input.map(item => formatFileUrlOne(String(item ?? '')) || DEFAULT_IMAGE)
  }

  if (typeof input === 'object') {
    const text = (input as { text?: string }).text
    return text ? (formatFileUrlOne(text) || DEFAULT_IMAGE) : DEFAULT_IMAGE
  }

  const trimmed = String(input).trim()
  if (!trimmed)
    return DEFAULT_IMAGE

  return formatFileUrlOne(trimmed) || DEFAULT_IMAGE
}

/** 从 formatFileUrl 结果还原存储 path（落库用） */
export function parseFilePath(url: string | null | undefined): string {
  if (!url?.trim())
    return ''

  const trimmed = url.trim()
  if (trimmed === DEFAULT_IMAGE)
    return ''

  const base = fileBase()
  if (trimmed.startsWith(base)) {
    const query = trimmed.slice(base.length)
    const params = new URLSearchParams(query.startsWith('?') ? query.slice(1) : query)
    const path = params.get('path')
    if (path)
      return path.startsWith('/') ? path : `/${path}`
    return trimmed
  }

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
    return trimmed

  return trimmed
}

export function generateOperationId(prefix: string = 'op'): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
}
