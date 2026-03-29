import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { PlacementContentVo } from '$/ds/sysCms/api/placementContent.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/sysCms/api/placementContent.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: PlacementContentVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.PlacementContentFields.code'), // '调用代码'
      minWidth: 150,
      prop: 'code',
    },
    {
      label: () => t('admin.PlacementPosition'),
      prop: 'positions',
      cellRender: ({ row }) => {
        return row.positions?.map((item)=>{
          return item.name + (item.code ? '|' + item.code : '')
        }) ?? '-'
      },
    },
    {
      label: () => t('admin.PlacementContentFields.name'), // '内容名称'
      minWidth: 150,
      prop: 'name',
    },
    {
      label: () => t('admin.PlacementContentFields.object_type'), // '数据类型：1链接 2视频 3分享 4文章 5路径'
      minWidth: 150,
      prop: 'object_type',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('placement-object-type', row.object_type, 'i18n')
        return (
          <ElTag type={dictStore.t('placement-object-type', row.object_type, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.PlacementContentFields.object_id'), // '关联数据ID（根据object_type关联不同表，object_type=4时关联article表）'
      minWidth: 150,
      prop: 'object_id',
      sortable: 'custom',
    },
    {
      label: () => t('admin.PlacementContentFields.url'), // '链接地址（object_type=1）'
      minWidth: 150,
      prop: 'url',
    },
    {
      label: () => t('admin.PlacementContentFields.target'), // '链接打开方式：1当前窗口 2新窗口'
      minWidth: 150,
      prop: 'target',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('placement-target', row.target, 'i18n')
        return (
          <ElTag type={dictStore.t('placement-target', row.target, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.PlacementContentFields.start_at'), // '开始时间（时间戳）'
      minWidth: 150,
      prop: 'start_at',
      sortable: 'custom',
    },
    {
      label: () => t('admin.PlacementContentFields.end_at'), // '结束时间（时间戳）'
      minWidth: 150,
      prop: 'end_at',
      sortable: 'custom',
    },
    {
      label: () => t('admin.PlacementContentFields.fixed'), // '永久有效：1是 0否'
      minWidth: 150,
      prop: 'fixed',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('system-yes-no', row.fixed, 'i18n')
        return (
          <ElTag type={dictStore.t('system-yes-no', row.fixed, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      minWidth: 150,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('placement-status', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('placement-status', row.status, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('crud.sort'), // '排序'
      minWidth: 150,
      prop: 'sort',
      sortable: 'custom',
    },
    {
      label: () => t('admin.PlacementContentFields.views'), // '展示次数'
      minWidth: 150,
      prop: 'views',
      sortable: 'custom',
    },
    {
      label: () => t('admin.PlacementContentFields.clicks'), // '点击次数'
      minWidth: 150,
      prop: 'clicks',
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
            show: ({ row }) => showBtn('ds:sysCms:placement_content:save', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('ds:sysCms:placement_content:delete', row),
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
