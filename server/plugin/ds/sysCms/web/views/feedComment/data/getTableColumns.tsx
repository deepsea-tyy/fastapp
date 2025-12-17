import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { FeedCommentVo } from '$/ds/syscms/api/feedComment.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/syscms/api/feedComment.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: FeedCommentVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.FeedCommentFields.target_type'), // '目标类型'
      minWidth: 120,
      prop: 'target_type',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('feed-target-type', row.target_type, 'i18n')
        return (
          <ElTag type={dictStore.t('feed-target-type', row.target_type, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.FeedCommentFields.target_id'), // '目标ID'
      minWidth: 150,
      prop: 'target_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.target_id,
    },
    {
      label: () => t('admin.FeedCommentFields.user_id'), // '评论用户ID'
      minWidth: 150,
      prop: 'user_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.user_id,
    },
    {
      label: () => t('admin.FeedCommentFields.parent_id'), // '父评论ID（0为顶级评论）'
      minWidth: 150,
      prop: 'parent_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.parent_id,
    },
    {
      label: () => t('admin.FeedCommentFields.root_id'), // '根评论ID（用于楼中楼）'
      minWidth: 150,
      prop: 'root_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.root_id,
    },
    {
      label: () => t('admin.FeedCommentFields.reply_to_user_id'), // '回复的用户ID'
      minWidth: 150,
      prop: 'reply_to_user_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.reply_to_user_id,
    },
    {
      label: () => t('admin.FeedCommentFields.like_count'), // '点赞数'
      minWidth: 150,
      prop: 'like_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedCommentFields.reply_count'), // '回复数'
      minWidth: 150,
      prop: 'reply_count',
      sortable: 'custom',
    },
    {
      label: () => t('crud.status'), // '状态'
      minWidth: 100,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('feed-status', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('feed-status', row.status, 'color') || undefined}>
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
            show: ({ row }) => showBtn('ds:syscms:feed_comment:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:syscms:feed_comment:delete', row),
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
