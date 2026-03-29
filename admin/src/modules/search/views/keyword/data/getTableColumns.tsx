import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { KeywordVo } from '~/search/api/keyword.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '~/search/api/keyword.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'
import MaSvgIcon from '@/components/ma-svg-icon/index.vue'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: KeywordVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('search.KeywordFields.keyword'), // '搜索关键词'
      minWidth: 150,
      prop: 'keyword',
    },
    {
      label: () => t('search.KeywordFields.hit_count'), // '命中次数'
      minWidth: 150,
      prop: 'hit_count',
      sortable: 'custom',
    },
    {
      label: () => t('search.KeywordFields.icon'), // '图标名称'
      minWidth: 150,
      prop: 'icon',
      cellRender: ({ row }) => {
        const iconDict = dictStore.find('search-keyword-icon')
        const iconItem = iconDict?.find((item: any) => item.value === row.icon)
        // 优先使用自定义颜色，如果没有则使用字典中的颜色
        const displayColor = row.color || iconItem?.color || '#666'

        return row.icon ? (
          <div class="flex items-center gap-2">
            <MaSvgIcon name={row.icon} size={20} style={{ color: displayColor }} />
            <span>{iconItem ? (iconItem.i18n ? t(iconItem.i18n) : iconItem.label) : row.icon}</span>
          </div>
        ) : (
          <span class="text-gray-400">-</span>
        )
      },
    },
    {
      label: () => t('search.KeywordFields.source'), // '来源'
      minWidth: 150,
      prop: 'source',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('search-keyword-source', row.source, 'i18n')
        return (
          <ElTag type={dictStore.t('search-keyword-source', row.source, 'color') || 'undefined'}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
      sortable: 'custom',
    },
    {
      label: () => t('search.KeywordFields.sort'), // '排序'
      minWidth: 100,
      prop: 'sort',
      sortable: 'custom',
    },
    {
      label: () => t('search.KeywordFields.last_searched_at'), // '最后搜索时间'
      minWidth: 150,
      prop: 'last_searched_at',
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
            show: ({ row }) => showBtn('search:keyword:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('search:keyword:delete', row),
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
