import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('crud.status'), // '状态：0=禁用，1=启用'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'system-status',
placeholder: t('crud.status'),
            },
    },
  ]
}
