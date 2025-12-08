import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { AppPageContentVo } from '$/ds/sysCms/api/appPageContent.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/sysCms/api/appPageContent.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: AppPageContentVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('admin.AppPageContentFields.code'),
      minWidth: 150,
      prop: 'code',
    },
    {
      label: () => t('admin.AppPageContentFields.page_code'),
      minWidth: 120,
      prop: 'page_code',
    },
    {
      label: () => t('admin.AppPageContentFields.component_code'),
      minWidth: 120,
      prop: 'component_code',
    },
    {
      label: () => t('admin.AppPageContentFields.content_type'),
      minWidth: 120,
      prop: 'content_type',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('app-page-content-type', row.content_type, 'i18n')
        return (
          <ElTag type={dictStore.t('app-page-content-type', row.content_type, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.AppPageContentFields.platform'),
      minWidth: 100,
      prop: 'platform',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('app-page-content-platform', row.platform, 'i18n')
        return (
          <ElTag type={dictStore.t('app-page-content-platform', row.platform, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('admin.AppPageContentFields.fixed'),
      minWidth: 100,
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
      label: () => t('crud.status'),
      minWidth: 100,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('system-status', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('system-status', row.status, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('crud.sort'),
      minWidth: 100,
      prop: 'sort',
      sortable: 'custom',
    },
    {
      label: () => t('crud.createdAt'),
      minWidth: 180,
      prop: 'created_at',
      sortable: 'custom',
    },
    // 操作列
    {
      label: () => t('crud.operation'),
      fixed: 'right',
      width: 200,
      cellRender: ({ row }) => {
        return (
          <>
            {showBtn('ds:sysCms:app_page_content:save', row) && (
              <el-button
                link
                type="primary"
                onClick={() => {
                  dialog.setTitle(t('crud.edit'))
                  dialog.open({ formType: 'edit', data: row })
                }}
              >
                {t('crud.edit')}
              </el-button>
            )}
            {showBtn('ds:sysCms:app_page_content:delete', row) && (
              <el-button
                link
                type="danger"
                onClick={() => {
                  msg.confirm(t('crud.delMessage')).then(async () => {
                    const response = await deleteByIds([row.id])
                    if (response.code === ResultCode.SUCCESS) {
                      msg.success(t('crud.delSuccess'))
                      // 刷新表格
                      const proTable = formRef.value?.proTableRef
                      if (proTable) {
                        proTable.refresh()
                      }
                    }
                  })
                }}
              >
                {t('crud.delete')}
              </el-button>
            )}
          </>
        )
      },
    },
  ]
}

