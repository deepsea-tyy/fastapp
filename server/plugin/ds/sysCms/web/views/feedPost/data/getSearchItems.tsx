import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.FeedPostFields.audited_at'), // '审核时间'
      prop: 'audited_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.FeedPostFields.audited_at'),
            },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
    },
  ]
}
