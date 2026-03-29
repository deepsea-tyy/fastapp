import type { Dictionary } from '#/global'

export default [
  { label: '垃圾广告', value: 1, i18n: 'admin.FeedReportDict.reportType.spam', color: 'warning' },
  { label: '色情低俗', value: 2, i18n: 'admin.FeedReportDict.reportType.pornography', color: 'danger' },
  { label: '违法违规', value: 3, i18n: 'admin.FeedReportDict.reportType.illegal', color: 'danger' },
  { label: '侮辱谩骂', value: 4, i18n: 'admin.FeedReportDict.reportType.abuse', color: 'warning' },
  { label: '其他', value: 5, i18n: 'admin.FeedReportDict.reportType.other', color: 'default' },
] as Dictionary[]
