import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { PlacementPositionVo } from '$/ds/sysCms/api/placementPosition.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/sysCms/api/placementPosition.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: PlacementPositionVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.PlacementPositionFields.code'), // '调用代码（唯一标识符，如：home_banner）'
      minWidth: 150,
      prop: 'code',
    },
    {
      label: () => t('admin.PlacementPositionFields.name'), // '位置名称'
      minWidth: 150,
      prop: 'name',
    },
    {
      label: () => t('crud.status'), // '状态：1启用 0禁用'
      minWidth: 150,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('placement-status', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('placement-status', row.status, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    // 操作列
    {
      type: 'operation',
      label: () => t('crud.operation'),
      fixed: 'right',
      width: '260px',
      operationConfigure: {
        type: 'tile',
        actions: [
          {
            name: 'edit',
            icon: 'i-heroicons:pencil',
            show: ({ row }) => showBtn('ds:sysCms:placement_position:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:sysCms:placement_position:delete', row),
            icon: 'i-heroicons:trash',
            text: () => t('crud.delete'),
            linkProps: { type: 'danger' },
            onClick: ({ row }, proxy: MaProTableExpose) => {
              msg.delConfirm(t('crud.delDataMessage')).then(async () => {
                const response = await deleteByIds([row.id])
                if (response.code === ResultCode.SUCCESS) {
                  msg.success(t('crud.delSuccess'))
                  await proxy.refresh()
                }
              })
            },
          },
        ],
      },
    },
  ]
}
