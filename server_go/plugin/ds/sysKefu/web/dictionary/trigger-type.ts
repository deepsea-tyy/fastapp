import type { Dictionary } from '#/global'

export default [
  { label: '关键词精确匹配', value: 1, i18n: 'admin.KefuAutoReplyDict.triggerType.exact', color: 'primary' },
  { label: '关键词模糊匹配', value: 2, i18n: 'admin.KefuAutoReplyDict.triggerType.fuzzy', color: 'success' },
  { label: '正则匹配', value: 3, i18n: 'admin.KefuAutoReplyDict.triggerType.regex', color: 'warning' },
] as Dictionary[]
