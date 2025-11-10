

import type { MaSearchItem } from '@/components/ma-search'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('baseRoleManage.name'),
      prop: 'name',
      render: 'input',
    },
    {
      label: () => t('baseRoleManage.code'),
      prop: 'code',
      render: 'input',
    },
    {
      label: () => t('crud.status'),
      prop: 'status',
      render: () => MaDictSelect,
      renderProps: {
        clearable: true,
        placeholder: '',
        dictName: 'system-status',
      },
    },
  ]
}
