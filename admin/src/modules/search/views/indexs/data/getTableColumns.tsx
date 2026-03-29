import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { IndexsVo } from '~/search/api/indexs.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '~/search/api/indexs.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: IndexsVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('search.IndexsFields.target_type'), // '内容类型'
      minWidth: 150,
      prop: 'target_type',
      cellRender: ({ row }) => {
        const dict = dictStore.find('search-target-type')
        const item = dict.find(d => d.value === row.target_type)
        return item ? <ElTag type="primary">{t(`search.Dict.TargetType.${row.target_type}`)}</ElTag> : row.target_type
      },
    },
    {
      label: () => t('search.IndexsFields.target_id'), // '内容ID'
      minWidth: 150,
      prop: 'target_id',
      sortable: 'custom',
      cellRender: ({ row }) => row.target_id,
    },
    {
      label: () => t('search.IndexsFields.title'), // '标题'
      minWidth: 150,
      prop: 'title',
    },
    {
      label: () => t('search.IndexsFields.weight'), // '权重'
      minWidth: 150,
      prop: 'weight',
      sortable: 'custom',
    },
    {
      label: () => t('search.IndexsFields.click_count'), // '点击量'
      minWidth: 150,
      prop: 'click_count',
      sortable: 'custom',
      cellRender: ({ row }) => row.click_count || 0,
    },
    {
      label: () => t('crud.status'), // '状态'
      minWidth: 150,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => row.status,
    },
    {
      label: () => t('search.IndexsFields.last_at'), // '最新时间'
      minWidth: 150,
      prop: 'last_at',
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
            show: ({ row }) => showBtn('search:indexs:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('search:indexs:delete', row),
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
