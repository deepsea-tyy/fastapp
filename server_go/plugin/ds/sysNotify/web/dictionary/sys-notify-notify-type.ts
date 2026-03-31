import type { Dictionary } from '#/global'

export default [
  { label: '系统通知', value: 1, i18n: 'admin.MessageNotifyFields.notifyTypeSystem', color: 'warning' },
  { label: '业务通知', value: 2, i18n: 'admin.MessageNotifyFields.notifyTypeBusiness', color: 'primary' },
  { label: '其他', value: 3, i18n: 'admin.MessageNotifyFields.notifyTypeOther', color: 'info' },
] as Dictionary[]

