import type { MaSearchItem } from '@/components/ma-search'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: t('permission.DepartmentFields.name'), // '部门名称'
      prop: 'name',
      render: () => <el-input />,
    },
    {
      label: () => t('crud.status'), // '状态'
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
