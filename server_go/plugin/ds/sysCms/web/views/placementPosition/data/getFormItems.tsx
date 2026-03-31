import type { MaFormItem } from '@/components/ma-form'
import type { PlacementPositionVo } from '$/ds/sysCms/api/placementPosition.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: PlacementPositionVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.status = 1

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.PlacementPositionFields.code'), // '调用代码（唯一标识符，如：home_banner）'
      prop: 'code',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementPositionFields.code'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementPositionFields.name'), // '位置名称'
      prop: 'name',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementPositionFields.name'),
            },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('admin.PlacementPositionFields.name') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('crud.status'),
        dictName: 'placement-status',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
  ]
}
