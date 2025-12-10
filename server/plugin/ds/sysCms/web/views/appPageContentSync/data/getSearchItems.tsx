import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.AppPageContentFields.platform'),
      prop: 'platform',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.platform'),
        dictName: 'app-page-content-platform',
        clearable: true,
      },
    },
  ]
}

