import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.FeedReportFields.handled_at'), // '处理时间'
      prop: 'handled_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.FeedReportFields.handled_at'),
            },
    },
  ]
}
