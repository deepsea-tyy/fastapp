import type { MaProTableColumns } from '@/components/ma-pro-table'
import type { AppPageContentSyncVo } from '$/ds/sysCms/api/appPageContentSync.ts'
import { ElTag } from 'element-plus'
import { deleteByIds } from '$/ds/sysCms/api/appPageContentSync.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'

export default function getTableColumns(t: any, proTableRef?: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: AppPageContentSyncVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    {
      label: () => t('admin.AppPageContentSyncFields.version'),
      minWidth: 150,
      prop: 'version',
    },
    {
      label: () => t('admin.AppPageContentSyncFields.platform'),
      minWidth: 100,
      prop: 'platform',
      cellRender: ({ row }) => {
        const platformMap: Record<number, string> = { 1: 'Web', 2: 'App' }
        return <ElTag>{platformMap[row.platform] || '-'}</ElTag>
      },
    },
    {
      label: () => t('admin.AppPageContentSyncFields.file_path'),
      minWidth: 200,
      prop: 'file_path',
    },
    {
      label: () => t('admin.AppPageContentSyncFields.file_size'),
      minWidth: 120,
      prop: 'file_size',
      cellRender: ({ row }) => {
        const formatBytes = (bytes: number) => {
          if (bytes === 0) return '0 B'
          const k = 1024
          const sizes = ['B', 'KB', 'MB', 'GB']
          const i = Math.floor(Math.log(bytes) / Math.log(k))
          return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
        }
        return formatBytes(row.file_size)
      },
    },
    {
      label: () => t('admin.AppPageContentSyncFields.record_count'),
      minWidth: 120,
      prop: 'record_count',
    },
    {
      label: () => t('admin.AppPageContentSyncFields.generated_at'),
      minWidth: 180,
      prop: 'generated_at',
    },
    // 操作列
    {
      label: () => t('crud.operation'),
      fixed: 'right',
      width: 120,
      cellRender: ({ row }) => {
        return (
          <>
            {showBtn('ds:sysCms:app_page_content_sync:delete', row) && (
              <el-button
                link
                type="danger"
                onClick={() => {
                  msg.confirm(t('crud.delMessage')).then(async () => {
                    const response = await deleteByIds([row.id])
                    if (response.code === ResultCode.SUCCESS) {
                      msg.success(t('crud.delSuccess'))
                      // 刷新表格
                      if (proTableRef?.value) {
                        proTableRef.value.refresh()
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

