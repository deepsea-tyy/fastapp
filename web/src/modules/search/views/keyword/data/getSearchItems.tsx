import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('search.KeywordFields.last_searched_at'), // '最后搜索时间'
      prop: 'last_searched_at',
      render: () => <el-date-picker />,
      renderProps: {
        placeholder: t('search.KeywordFields.last_searched_at'),
      },
    },
  ]
}
