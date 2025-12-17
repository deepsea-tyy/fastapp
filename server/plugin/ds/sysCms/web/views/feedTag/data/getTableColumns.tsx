import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { FeedTagVo } from '$/ds/syscms/api/feedTag.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/syscms/api/feedTag.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'
import {formatLang} from "@/utils/common.ts";

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: FeedTagVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('article.CategoryFields.name'),
      minWidth: 120,
      prop: 'name',
      cellRender: ({ row }) => formatLang(row.name)
    },
    {
      label: () => t('admin.FeedTagFields.icon'), // '标签图标'
      minWidth: 150,
      prop: 'icon',
      cellRender: ({ row }) => (
        <div class="flex-center">
          <el-image class="max-w-32" src={(row.icon === '' || !row.icon) ? '' : row.icon} alt="" />
        </div>
      ),
    },
    {
      label: () => t('admin.FeedTagFields.color'), // '标签颜色'
      minWidth: 150,
      prop: 'color',
    },
    {
      label: () => t('admin.FeedTagFields.post_count'), // '内容数量'
      minWidth: 150,
      prop: 'post_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedTagFields.follow_count'), // '关注数'
      minWidth: 150,
      prop: 'follow_count',
      sortable: 'custom',
    },
    {
      label: () => t('admin.FeedTagFields.is_hot'), // '是否热门'
      minWidth: 100,
      prop: 'is_hot',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('system-yes-no', row.is_hot, 'i18n')
        return (
          <ElTag type={dictStore.t('system-yes-no', row.is_hot, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('crud.status'), // '状态'
      minWidth: 100,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('system-display', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('system-display', row.status, 'color') || undefined}>
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
            show: ({ row }) => showBtn('ds:syscms:feed_tag:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:syscms:feed_tag:delete', row),
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
