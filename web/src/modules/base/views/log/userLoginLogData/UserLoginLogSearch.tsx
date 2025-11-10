

import type { MaSearchItem } from '@/components/ma-search'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('baseLoginLog.username'),
      prop: 'username',
      render: 'input',
    },
    {
      label: () => t('baseLoginLog.ip'),
      prop: 'ip',
      render: 'input',
    },
    {
      label: () => t('baseLoginLog.status'),
      prop: 'status',
      render: () => MaDictSelect,
      renderProps: {
        clearable: true,
        placeholder: '',
        dictName: 'system-state',
      },
    },
  ]
}
