import type { Dictionary } from '#/global'

export default [
  { label: '草稿', value: 0, i18n: 'admin.FeedPostDict.status.draft', color: 'default' },
  { label: '已发布', value: 1, i18n: 'admin.FeedPostDict.status.published', color: 'success' },
  { label: '已下架', value: 2, i18n: 'admin.FeedPostDict.status.offline', color: 'warning' },
] as Dictionary[]
