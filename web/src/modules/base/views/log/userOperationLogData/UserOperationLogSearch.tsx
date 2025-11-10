

import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('baseOperationLog.username'),
      prop: 'username',
      render: 'input',
    },
    {
      label: () => t('baseOperationLog.router'),
      prop: 'router',
      render: 'input',
    },
    {
      label: () => t('baseOperationLog.service_name'),
      prop: 'service_name',
      render: 'input',
    },
    {
      label: () => t('baseOperationLog.ip'),
      prop: 'ip',
      render: 'input',
    },
  ]
}
