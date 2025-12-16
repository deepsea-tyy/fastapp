import type { Dictionary } from '#/global'

export default [
  { label: '待处理', value: 0, i18n: 'admin.FeedReportDict.handleStatus.pending', color: 'warning' },
  { label: '已处理', value: 1, i18n: 'admin.FeedReportDict.handleStatus.handled', color: 'success' },
  { label: '已忽略', value: 2, i18n: 'admin.FeedReportDict.handleStatus.ignored', color: 'default' },
] as Dictionary[]
