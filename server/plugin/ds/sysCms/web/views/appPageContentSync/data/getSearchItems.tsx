import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.AppPageContentSyncFields.platform'),
      prop: 'platform',
      render: () => <el-select />,
      renderProps: {
        placeholder: t('admin.AppPageContentSyncFields.platform'),
        clearable: true,
      },
      options: [
        { label: 'Web', value: 1 },
        { label: 'App', value: 2 },
      ],
    },
  ]
}

