import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { KefuAutoReplyVo } from '$/ds/syskefu/api/kefuAutoReply.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/syskefu/api/kefuAutoReply.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: KefuAutoReplyVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.KefuAutoReplyFields.title'),
      minWidth: 150,
      prop: 'title',
    },
    {
      label: () => t('admin.KefuAutoReplyFields.trigger_type'),
      minWidth: 150,
      prop: 'trigger_type',
      sortable: 'custom',
      cellRender: ({ row }) => row.trigger_type,
    },
    {
      label: () => t('admin.KefuAutoReplyFields.reply_type'),
      minWidth: 150,
      prop: 'reply_type',
      sortable: 'custom',
      cellRender: ({ row }) => row.reply_type,
    },
    {
      label: () => t('admin.KefuAutoReplyFields.lang'),
      minWidth: 150,
      prop: 'lang',
    },
    {
      label: () => t('admin.KefuAutoReplyFields.priority'),
      minWidth: 150,
      prop: 'priority',
      sortable: 'custom',
    },
    {
      label: () => t('crud.status'),
      minWidth: 150,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => row.status,
    },
    {
      label: () => t('admin.KefuAutoReplyFields.hit_count'),
      minWidth: 150,
      prop: 'hit_count',
      sortable: 'custom',
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
            show: ({ row }) => showBtn('ds:syskefu:kefu_auto_reply:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:syskefu:kefu_auto_reply:delete', row),
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
