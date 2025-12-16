import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { FeedPostVo } from '$/ds/syscms/api/feedPost.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/syscms/api/feedPost.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: FeedPostVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.FeedPostFields.user_id'), // '发布用户ID'
      minWidth: 150,
      prop: 'user_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.user_id,
    },
    {
      label: () => t('admin.FeedPostFields.title'), // '标题（可选）'
      minWidth: 150,
      prop: 'title',
    },
    {
      label: () => t('admin.FeedPostFields.link_url'), // '外链地址'
      minWidth: 150,
      prop: 'link_url',
    },
    {
      label: () => t('admin.FeedPostFields.quoted_type'), // '引用类型：1帖子 2文章'
      minWidth: 150,
      prop: 'quoted_type',
      sortable: 'custom',
      cellRender: ({ row }) => row.quoted_type,
    },
    {
      label: () => t('admin.FeedPostFields.quoted_id'), // '引用的内容ID'
      minWidth: 150,
      prop: 'quoted_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.quoted_id,
    },
    {
      label: () => t('admin.FeedPostFields.audit_status'), // '审核状态：0待审核 1已通过 2已拒绝'
      minWidth: 150,
      prop: 'audit_status',
      sortable: 'custom',
      cellRender: ({ row }) => row.audit_status,
    },
    {
      label: () => t('admin.FeedPostFields.audited_at'), // '审核时间'
      minWidth: 150,
      prop: 'audited_at',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.is_top'), // '是否置顶：0否 1是'
      minWidth: 150,
      prop: 'is_top',
      sortable: 'custom',
      cellRender: ({ row }) => (
        <ElTag type={row.is_top == 1 ? 'success' : 'danger'}>
          {row.is_top}
        </ElTag>
      ),
    },
    {
      label: () => t('admin.FeedPostFields.is_hot'), // '是否热门：0否 1是'
      minWidth: 150,
      prop: 'is_hot',
      sortable: 'custom',
      cellRender: ({ row }) => (
        <ElTag type={row.is_hot == 1 ? 'success' : 'danger'}>
          {row.is_hot}
        </ElTag>
      ),
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      minWidth: 150,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => row.status,
    },
    {
      label: () => t('admin.FeedPostFields.view_count'), // '浏览次数'
      minWidth: 150,
      prop: 'view_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.like_count'), // '点赞数'
      minWidth: 150,
      prop: 'like_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.comment_count'), // '评论数'
      minWidth: 150,
      prop: 'comment_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.share_count'), // '分享数'
      minWidth: 150,
      prop: 'share_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.collect_count'), // '收藏数'
      minWidth: 150,
      prop: 'collect_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.quote_count'), // '引用数'
      minWidth: 150,
      prop: 'quote_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedPostFields.ip'), // '发布IP'
      minWidth: 150,
      prop: 'ip',
    },
    {
      label: () => t('admin.FeedPostFields.device_type'), // '设备类型：ios, android, web'
      minWidth: 150,
      prop: 'device_type',
      cellRender: ({ row }) => row.device_type,
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
            show: ({ row }) => showBtn('ds:syscms:feed_post:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:syscms:feed_post:delete', row),
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
