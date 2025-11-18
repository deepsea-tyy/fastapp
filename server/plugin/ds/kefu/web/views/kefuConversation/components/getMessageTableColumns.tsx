import type { MaProTableColumns } from '@/components/ma-pro-table'
import { ElTag, ElImage } from 'element-plus'

export default function getMessageTableColumns(t: any): MaProTableColumns[] {
  const senderTypeMap: Record<number, { label: string, type: string }> = {
    1: { label: t('kefu.common.senderType.user'), type: 'primary' },
    2: { label: t('kefu.common.senderType.kefu'), type: 'success' },
  }

  const messageTypeMap: Record<number, { label: string }> = {
    1: { label: t('kefu.common.messageType.text') },
    2: { label: t('kefu.common.messageType.image') },
    3: { label: t('kefu.common.messageType.file') },
  }

  return [
    { type: 'index' },
    { label: () => t('kefu.KefuMessageFields.senderType'), prop: 'sender_type',
      cellRender: ({ row }) => {
        const type = senderTypeMap[row.sender_type]
        if (type) {
          return <ElTag type={type.type as any}>{type.label}</ElTag>
        }
        return '-'
      }
    },
    { label: () => t('kefu.KefuMessageFields.messageType'), prop: 'message_type',
      cellRender: ({ row }) => {
        const type = messageTypeMap[row.message_type]
        if (type) {
          return <ElTag type="info">{type.label}</ElTag>
        }
        return '-'
      }
    },
    { label: () => t('kefu.KefuMessageFields.content'), prop: 'content', minWidth: 200 },
    { label: () => t('kefu.KefuMessageFields.fileUrl'), prop: 'file_url',
      cellRender: ({ row }) => {
        if (row.file_url && (row.message_type === 2 || row.message_type === 3)) {
          if (row.message_type === 2) {
            return <ElImage style="width: 80px; height: 80px" src={row.file_url} preview-src-list={[row.file_url]} fit="cover" />
          } else {
            return <a href={row.file_url} target="_blank">{row.file_url}</a>
          }
        }
        return '-'
      }
    },
    { label: () => t('kefu.KefuMessageFields.isRead'), prop: 'is_read',
      cellRender: ({ row }) => {
        return row.is_read
          ? <ElTag type="success">{t('kefu.KefuMessageFields.read')}</ElTag>
          : <ElTag type="warning">{t('kefu.KefuMessageFields.unread')}</ElTag>
      }
    },
    { label: () => t('kefu.KefuMessageFields.readAt'), prop: 'read_at', mode: 'date', showTime: true },
    { label: () => t('kefu.KefuMessageFields.createdAt'), prop: 'created_at', mode: 'date', showTime: true },
  ]
}

