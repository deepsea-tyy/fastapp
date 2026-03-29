import type { MaFormItem } from '@/components/ma-form'
import type { FeedReportVo } from '$/ds/syscms/api/feedReport.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: FeedReportVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.handle_status = 0

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.FeedReportFields.target_type'), // '目标类型：1帖子 2文章 3评论'
      prop: 'target_type',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedReportFields.target_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedReportFields.report_type'), // '举报原因：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他'
      prop: 'report_type',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedReportFields.report_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedReportFields.content'), // '举报说明'
      prop: 'content',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedReportFields.content'),
        type: 'textarea',
        rows: 3,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedReportFields.handle_status'), // '处理状态：0待处理 1已处理 2已忽略'
      prop: 'handle_status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedReportFields.handle_status'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedReportFields.handled_at'), // '处理时间'
      prop: 'handled_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.FeedReportFields.handled_at'),
            },
      cols: { lg: 12, md: 24 },
    },
  ]
}
