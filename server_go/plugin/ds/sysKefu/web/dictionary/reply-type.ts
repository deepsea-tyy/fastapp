import type { Dictionary } from '#/global'

export default [
  { label: '纯文本', value: 1, i18n: 'admin.KefuAutoReplyDict.replyType.text', color: 'default' },
  { label: '图片', value: 2, i18n: 'admin.KefuAutoReplyDict.replyType.image', color: 'primary' },
  { label: '文件', value: 3, i18n: 'admin.KefuAutoReplyDict.replyType.file', color: 'success' },
  { label: '多条消息', value: 4, i18n: 'admin.KefuAutoReplyDict.replyType.multiple', color: 'warning' },
] as Dictionary[]
