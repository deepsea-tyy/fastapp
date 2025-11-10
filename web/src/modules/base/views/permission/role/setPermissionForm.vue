
<script setup lang="tsx">
import type { MaFormExpose } from '@/components/ma-form'
import type { RoleVo } from '~/base/api/role.ts'
import { getRolePermission, setRolePermission, getRoleDepartments, setRoleDepartments } from '~/base/api/role.ts'
import { page } from '~/base/api/menu.ts'
import { selectDept } from '~/base/api/department.ts'

import useForm from '@/hooks/useForm.ts'

import MaTree from '@/components/ma-tree/index.vue'
import { ResultCode } from '@/utils/ResultCode.ts'

const { data = null } = defineProps<{
  data?: RoleVo | null
}>()

const t = useTrans().globalTrans
const userRoleForm = ref<MaFormExpose>()
const userModel = ref<{ id?: number; data_scope?: number }>({})
const checkStrictly = ref<boolean>(false)

const permissionTreeRef = ref<any>()
const departmentTreeRef = ref<any>()
const showDepartmentTree = ref<boolean>(false)

useForm('userRoleForm').then(async (form: MaFormExpose) => {
  const names: string[] = []
  const departmentIds: number[] = []
  
  if (data?.id) {
    userModel.value.id = data.id
    userModel.value.data_scope = data.data_scope
    
    // 获取角色权限
    const response: any = await getRolePermission(data?.id)
    if (response.code === ResultCode.SUCCESS && response.data) {
      response.data.map((item: any) => {
        names.push(item.name)
      })
      checkStrictly.value = true
    }
    
    // 获取角色部门（当data_scope为2时）
    if (data.data_scope === 2) {
      showDepartmentTree.value = true
      const deptResponse: any = await getRoleDepartments(data?.id)
      if (deptResponse.code === ResultCode.SUCCESS && deptResponse.data) {
        deptResponse.data.map((item: any) => {
          departmentIds.push(item.id)
        })
      }
    }
  }

  // 获取菜单树
  const menuRes = await page()
  
  // 获取部门树
  const deptRes = await selectDept()
  const departmentTreeData = deptRes.code === ResultCode.SUCCESS ? deptRes.data : []

  const formItems: any[] = [
    {
      label: () => t('baseRoleManage.permission'),
      prop: 'permission_id',
      render: () => MaTree,
      renderProps: {
        ref: (el: any) => permissionTreeRef.value = el,
        class: 'w-full',
        showCheckbox: true,
        treeKey: 'meta.title',
        placeholder: t('form.pleaseSelect', { msg: t('baseRoleManage.permission') }),
        nodeKey: 'name',
        data: menuRes.data,
      },
      renderSlots: {
        default: ({ data }) => {
          return (
            <div class="mine-tree-node">
              <div class="label">
                { data.meta?.icon && <ma-svg-icon name={data.meta?.icon} size={16} />}
                { data.meta?.i18n ? t(data.meta?.i18n) : data.meta.title ?? 'unknown' }
              </div>
            </div>
          )
        },
      },
    },
  ]

  // 如果是自定义数据权限，添加部门选择
  if (userModel.value.data_scope === 2) {
    formItems.push({
      label: () => t('baseRoleManage.departments'),
      prop: 'department_ids',
      render: () => MaTree,
      renderProps: {
        ref: (el: any) => departmentTreeRef.value = el,
        class: 'w-full',
        showCheckbox: true,
        treeKey: 'name',
        placeholder: t('form.pleaseSelect', { msg: t('baseRoleManage.departments') }),
        nodeKey: 'id',
        data: departmentTreeData,
      },
      itemProps: {
        rules: [
          {
            validator: (_rule: any, value: any, callback: any) => {
              if (userModel.value.data_scope === 2 && (!value || value.length === 0)) {
                callback(new Error(t('form.requiredSelect', { msg: t('baseRoleManage.departments') })))
              } else {
                callback()
              }
            },
          },
        ],
      },
    })
  }

  form.setItems(formItems)
  form.setOptions({
    labelWidth: '80px',
  })

  await nextTick(() => {
    permissionTreeRef.value?.setCheckStrictly(!!userModel.value?.id)
    setTimeout(() => {
      permissionTreeRef.value?.elTree?.setCheckedKeys?.(names)
      if (departmentIds.length > 0) {
        departmentTreeRef.value?.elTree?.setCheckedKeys?.(departmentIds)
      }
    }, 50)
  })
})

// 保存用户角色
function saveUserRole(): Promise<any> {
  return new Promise((resolve, reject) => {
    const elTree = permissionTreeRef.value.elTree
    const permissions = elTree.getCheckedKeys() as string[]
    
    setRolePermission(userModel.value.id as number, permissions).then(async (res: any) => {
      if (res.code === ResultCode.SUCCESS) {
        // 如果是自定义数据权限，需要设置部门
        if (userModel.value.data_scope === 2 && departmentTreeRef.value) {
          const deptTree = departmentTreeRef.value.elTree
          const departments = deptTree.getCheckedKeys() as number[]
          const deptRes = await setRoleDepartments(userModel.value.id as number, departments)
          if (deptRes.code === ResultCode.SUCCESS) {
            resolve(res)
          } else {
            reject(deptRes)
          }
        } else {
          resolve(res)
        }
      } else {
        reject(res)
      }
    }).catch((err) => {
      reject(err)
    })
  })
}

defineExpose({
  saveUserRole,
  maForm: userRoleForm,
})
</script>

<template>
  <ma-form ref="userRoleForm" v-model="userModel" />
</template>

<style scoped lang="scss">

</style>
