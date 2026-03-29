import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('crud.status'), // '状态'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
    }
  ]
}
