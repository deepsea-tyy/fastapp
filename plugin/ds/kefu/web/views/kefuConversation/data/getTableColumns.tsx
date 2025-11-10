import type {MaProTableColumns, MaProTableExpose} from '@/components/ma-pro-table'
import type {UseDrawerExpose} from '@/hooks/useDrawer.ts'

import defaultAvatar from '/defaultAvatar.jpg'
import {ElTag} from 'element-plus'
import {useMessage} from '@/hooks/useMessage.ts'
import {ResultCode} from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import {deleteByIds} from '$/ds/kefu/api/kefuConversation.ts'

export default function getTableColumns(drawerDetail: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
    const msg = useMessage()

    const statusMap: Record<number, { label: string, type: string }> = {
        1: {label: t('kefu.common.conversationStatus.ongoing'), type: 'success'},
        2: {label: t('kefu.common.conversationStatus.ended'), type: 'info'},
    }

    return [
        {type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection')},
        {label: () => t('kefu.KefuConversationFields.id'), prop: 'id'},
        {
            width: 200, label: () => t('kefu.KefuConversationFields.userId'), prop: 'user_id',
            cellRender: ({row}) => {
                const avatarSrc = row.profile?.avatar || defaultAvatar
                return (
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <img
                            src={avatarSrc}
                            alt=""
                            height={50}
                        />
                        <span>{[row.profile?.user_id, row.profile?.nickname].filter(Boolean).join('|') || '-'}</span>
                    </div>
                )
            }
        },
        {
            width: 200, label: () => t('kefu.KefuConversationFields.status'), prop: 'status',
            cellRender: ({row}) => {
                const status = statusMap[row.status]
                if (status) {
                    return <ElTag type={status.type as any}>{status.label}</ElTag>
                }
                return '-'
            }
        },
        {width: 200, label: () => t('kefu.KefuConversationFields.lastMessageAt'), prop: 'last_message_at', mode: 'date', showTime: true},
        {width: 200, label: () => t('kefu.KefuConversationFields.unreadCount'), prop: 'unread_count'},
        {width: 200, label: () => t('kefu.KefuConversationFields.kefuUnreadCount'), prop: 'kefu_unread_count'},
        {width: 200, label: () => t('kefu.KefuConversationFields.createdAt'), prop: 'created_at', mode: 'date', showTime: true},
        {width: 200, label: () => t('kefu.KefuConversationFields.updatedAt'), prop: 'updated_at', mode: 'date', showTime: true},
        {
            type: 'operation',
            fixed: 'right',
            width: 200,
            label: () => t('crud.operation'), operationConfigure: {
                type: 'tile',
                actions: [
                    {
                        name: 'detail',
                        icon: 'material-symbols:visibility',
                        text: () => t('kefu.KefuConversationFields.detail.title'),
                        onClick: ({row}) => {
                            drawerDetail.setTitle(t('kefu.KefuConversationFields.detail.title'))
                            drawerDetail.open({data: row})
                        }
                    },
                    {
                        name: 'del',
                        icon: 'mdi:delete',
                        text: () => t('crud.delete'),
                        show: ({row}) => hasAuth('kefu:kefu:delete'),
                        onClick: ({row}, proxy: MaProTableExpose) => {
                            msg.delConfirm(t('crud.delDataMessage')).then(async () => {
                                const response = await deleteByIds([row.id])
                                if (response.code === ResultCode.SUCCESS) {
                                    msg.success(t('crud.delSuccess'))
                                    proxy.refresh()
                                }
                            })
                        }
                    },
                ]
            }
        },
    ]
}
