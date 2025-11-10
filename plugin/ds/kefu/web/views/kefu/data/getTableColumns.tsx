import type {MaProTableColumns, MaProTableExpose} from '@/components/ma-pro-table'
import type {UseDrawerExpose} from '@/hooks/useDrawer.ts'

import defaultAvatar from '/defaultAvatar.jpg'
import {ElTag} from 'element-plus'
import {useMessage} from '@/hooks/useMessage.ts'
import {ResultCode} from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import {deleteByIds} from '$/ds/kefu/api/kefu.ts'
import {formatImagePath} from "@/utils/common.ts";

export default function getTableColumns(drawer: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  return [
    {type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection')},
    {label: () => t('kefu.KefuFields.nickname'), prop: 'nickname'},
    {
      label: () => t('kefu.KefuFields.avatar'), prop: 'avatar', width: '120px',
      cellRender: ({row}) => (
        <div class="flex-center">
          <el-avatar src={row.avatar ? formatImagePath(row.avatar) : defaultAvatar} alt={row.nickname}/>
        </div>
      ),
    },
    {
      label: () => t('kefu.KefuFields.status'), prop: 'status',
      cellRender: ({row}) => (
        <ElTag type={dictStore.t('system-status', row.status, 'color')}>
          {t(dictStore.t('system-status', row.status, 'i18n'))}
        </ElTag>
      ),
    },
    {
      label: () => t('kefu.KefuFields.maxConcurrent'), prop: 'max_concurrent',
      cellRender: ({row}) => row.max_concurrent ? row.max_concurrent : t('kefu.KefuFields.noLimit')
    },
    {label: () => t('kefu.KefuFields.currentConcurrent'), prop: 'current_concurrent'},
    {
      type: 'operation',
      width: 200,
      label: () => t('crud.operation'), operationConfigure: {
        type: 'tile',
        actions: [
          {
            name: 'edit',
            icon: 'material-symbols:person-edit',
            show: ({row}) => hasAuth('kefu:kefu:update'),
            text: () => t('crud.edit'),
            onClick: ({row}) => {
              drawer.setTitle(t('crud.edit'))
              drawer.open({formType: 'edit', data: row})
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
