import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { FeedReportVo } from '$/ds/syscms/api/feedReport.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/syscms/api/feedReport.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: FeedReportVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.FeedReportFields.user_id'), // '举报用户ID'
      minWidth: 150,
      prop: 'user_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.user_id,
    },
    {
      label: () => t('admin.FeedReportFields.target_type'), // '目标类型'
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
      label: () => t('admin.FeedReportFields.target_id'), // '目标ID'
      minWidth: 150,
      prop: 'target_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.target_id,
    },
    {
      label: () => t('admin.FeedReportFields.report_type'), // '举报原因'
      minWidth: 120,
      prop: 'report_type',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('feed-report-type', row.report_type, 'i18n')
        return (
          <ElTag type={dictStore.t('feed-report-type', row.report_type, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.FeedReportFields.handle_status'), // '处理状态'
      minWidth: 120,
      prop: 'handle_status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('feed-handle-status', row.handle_status, 'i18n')
        return (
          <ElTag type={dictStore.t('feed-handle-status', row.handle_status, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.FeedReportFields.handled_at'), // '处理时间'
      minWidth: 150,
      prop: 'handled_at',
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
            show: ({ row }) => showBtn('ds:syscms:feed_report:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:syscms:feed_report:delete', row),
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
