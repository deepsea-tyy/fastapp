import type { Dictionary } from '#/global'

export default [
  { label: '待审核', value: 0, i18n: 'admin.FeedPostDict.auditStatus.pending', color: 'warning' },
  { label: '已通过', value: 1, i18n: 'admin.FeedPostDict.auditStatus.approved', color: 'success' },
  { label: '已拒绝', value: 2, i18n: 'admin.FeedPostDict.auditStatus.rejected', color: 'danger' },
] as Dictionary[]
