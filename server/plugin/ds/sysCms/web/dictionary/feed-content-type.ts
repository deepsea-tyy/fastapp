import type { Dictionary } from '#/global'

export default [
  { label: '纯文本', value: 1, i18n: 'admin.FeedPostDict.contentType.text', color: 'default' },
  { label: '图文', value: 2, i18n: 'admin.FeedPostDict.contentType.image', color: 'primary' },
  { label: '视频', value: 3, i18n: 'admin.FeedPostDict.contentType.video', color: 'success' },
  { label: '链接', value: 4, i18n: 'admin.FeedPostDict.contentType.link', color: 'warning' },
] as Dictionary[]
