import type { Dictionary } from '#/global'

export default [
  { label: '帖子', value: 1, i18n: 'admin.FeedDict.targetType.post', color: 'primary' },
  { label: '文章', value: 2, i18n: 'admin.FeedDict.targetType.article', color: 'success' },
  { label: '评论', value: 3, i18n: 'admin.FeedDict.targetType.comment', color: 'warning' },
] as Dictionary[]
