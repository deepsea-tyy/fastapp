import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { DepartmentVo } from '~/base/api/department.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '~/base/api/department.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '../../../../../../utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: DepartmentVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('permission.DepartmentFields.name'), // '部门名称'
      minWidth: 120,
      prop: 'name',
    },
    {
      label: () => t('permission.DepartmentFields.code'), // '部门代码'
      minWidth: 120,
      prop: 'code',
    },
    {
      label: () => t('crud.sort'), // '排序'
      minWidth: 120,
      prop: 'sort',
      sortable: 'custom',
    },
    {
      label: () => t('crud.status'), // '状态'
      minWidth: 120,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('system-status', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('system-status', row.status, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('crud.remark'), // '备注'
      minWidth: 120,
      prop: 'remark',
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
            show: ({ row }) => showBtn('permission:department:update', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('permission:department:delete', row),
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
