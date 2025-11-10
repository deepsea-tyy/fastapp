import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { MessageNotifyVo } from '$/ds/message-notify/api/messageNotify.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/message-notify/api/messageNotify.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { formatLang } from '@/utils/common.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: MessageNotifyVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.MessageNotifyFields.title'), // '通知标题'
      minWidth: 150,
      prop: 'title',
      cellRender: ({ row }) => {
        const title = row.title
        if (Array.isArray(title)) {
          return formatLang(title) || '-'
        }
        return title || '-'
      },
    },
    {
      label: () => t('admin.MessageNotifyFields.content'), // '通知内容'
      minWidth: 200,
      prop: 'content',
      cellRender: ({ row }) => {
        const content = row.content
        if (Array.isArray(content)) {
          const text = formatLang(content)
          return text ? (text.length > 50 ? `${text.substring(0, 50)}...` : text) : '-'
        }
        return content ? (content.length > 50 ? `${content.substring(0, 50)}...` : content) : '-'
      },
    },
    {
      label: () => t('admin.MessageNotifyFields.notify_type'), // '通知分类'
      minWidth: 120,
      prop: 'notify_type',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const notifyTypeMap: Record<number, string> = {
          1: t('admin.MessageNotifyFields.notifyTypeSystem') || '系统通知',
          2: t('admin.MessageNotifyFields.notifyTypeBusiness') || '业务通知',
          3: t('admin.MessageNotifyFields.notifyTypeOther') || '其他',
        }
        const type = notifyTypeMap[row.notify_type]
        const tagType = row.notify_type === 1 ? 'warning' : row.notify_type === 2 ? 'primary' : 'info'
        return <ElTag type={tagType}>{type || row.notify_type}</ElTag>
      },
    },
    {
      label: () => t('admin.MessageNotifyFields.link'), // '跳转链接'
      minWidth: 120,
      prop: 'link',
    },
    {
      label: () => t('crud.createdAt'), // '创建时间'
      minWidth: 120,
      prop: 'created_at',
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
            show: ({ row }) => showBtn('ds:message-notify:message_notify:update', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:message-notify:message_notify:delete', row),
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
