import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.AppPageContentFields.page_code'),
      prop: 'page_code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.page_code'),
      },
    },
    {
      label: () => t('admin.AppPageContentFields.component_code'),
      prop: 'component_code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.component_code'),
      },
    },
    {
      label: () => t('admin.AppPageContentFields.content_type'),
      prop: 'content_type',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.content_type'),
        dictName: 'app-page-content-type',
        clearable: true,
      },
    },
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
    {
      label: () => t('crud.status'),
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('crud.status'),
        dictName: 'system-status',
        clearable: true,
      },
    },
  ]
}

