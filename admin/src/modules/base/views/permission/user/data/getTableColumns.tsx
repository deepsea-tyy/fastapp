
import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { UserVo } from '~/base/api/user.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import defaultAvatar from '/defaultAvatar.jpg'
import { ElTag } from 'element-plus'
import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds, resetPassword } from '~/base/api/user.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import {formatFileUrl} from "@/utils/common.ts";

export default function getTableColumns(drawer: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: UserVo) => {
    return hasAuth(auth) && row.id !== 1
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection'),
      cellRender: ({ row }): any => row.id === 1 ? '-' : undefined,
      selectable: (row: UserVo) => ![1].includes(row.id as number),
    },
    // 索引序号列
    { type: 'index' },
    // 普通列
    { label: () => t('baseUserManage.username'), prop: 'username' },
    { label: () => t('baseUserManage.loginMobile'), prop: 'mobile' },
    { label: () => t('baseUserManage.email'), prop: 'email', sortable: 'custom' },
    { label: () => t('baseUserManage.userType'), prop: 'user_type',
      sortable: 'custom',
      cellRender: ({ row }) => (
        <ElTag type={dictStore.t('base-userType', row.user_type, 'color')}>
          {t(dictStore.t('base-userType', row.user_type, 'i18n'))}
        </ElTag>
      ),
    },
    { label: () => t('crud.status'), prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => (
        <ElTag type={dictStore.t('system-status', row.status, 'color')}>
          {t(dictStore.t('system-status', row.status, 'i18n'))}
        </ElTag>
      ),
    },
    { label: () => t('baseUserManage.avatar'), prop: 'avatar', width: '120px',
      cellRender: ({ row }) => (
        <div class="flex-center">
          <el-avatar src={(row.avatar === '' || !row.avatar) ? defaultAvatar : formatFileUrl(row.avatar)} alt={row.username} />
        </div>
      ),
    },
    { label: () => t('baseUserManage.nickname'), prop: 'nickname' },
    { label: () => t('baseUserManage.phone'), prop: 'phone' },
    { label: () => t('baseMenuManage.remark'), prop: 'remark' },
    // 操作列
    {
      type: 'operation',
      width: 200,
      fixed: 'right',
      label: () => t('crud.operation'),
      operationConfigure: {
        actions: [
          {
            name: 'edit',
            icon: 'material-symbols:person-edit',
            show: ({ row }) => showBtn('permission:user:update', row),
            text: () => t('crud.edit'),
            onClick: ({ row }) => {
              drawer.setTitle(t('crud.edit'))
              drawer.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('permission:user:delete', row),
            icon: 'mdi:delete',
            text: () => t('crud.delete'),
            onClick: ({ row }, proxy: MaProTableExpose) => {
              msg.delConfirm(t('crud.delDataMessage')).then(async () => {
                const response = await deleteByIds([row.id])
                if (response.code === ResultCode.SUCCESS) {
                  msg.success(t('crud.delSuccess'))
                  proxy.refresh()
                }
              })
            },
          },
          {
            name: 'setRole',
            show: ({ row }) => showBtn(['permission:user:getRole', 'permission:user:setRole'], row),
            icon: 'material-symbols:person-add-rounded',
            text: () => t('baseUserManage.setRole'),
            onClick: ({ row }) => {
              drawer.setTitle(t('baseUserManage.setRole'))
              drawer.open({ formType: 'setRole', data: row })
            },
          },
          {
            name: 'initPassword',
            show: ({ row }) => showBtn('permission:user:password', row),
            icon: 'material-symbols:passkey',
            text: () => t('baseUserManage.initPassword'),
            onClick: ({ row }) => {
              msg.confirm(t('baseUserManage.setPassword')).then(async () => {
                const response = await resetPassword(row.id)
                if (response.code === ResultCode.SUCCESS) {
                  msg.success(t('baseUserManage.setPasswordSuccess'))
                }
              })
            },
          },
          {
            name: 'noAllowSuperAdmin',
            show: ({ row }) => row.id === 1,
            disabled: () => true,
            text: () => t('crud.superAdminNoEdit'),
          },
        ],
      },
    },
  ]
}
