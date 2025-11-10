import type { MaFormItem } from '@/components/ma-form'
import type { DepartmentVo } from '~/base/api/department.ts'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectDept} from "~/base/api/department.ts";

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: DepartmentVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.parent_id = Number(0)
    model.sort = Number(0)
    model.status = Number(1)
    model.remark = String('')
  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('permission.DepartmentFields.parent_id'), // '上级'
      prop: 'parent_id',
      render: () => MaRemoteSelect,
      renderProps: {
        api: selectDept,
        placeholder: t('form.pleaseInput', { msg: t('permission.DepartmentFields.parent_id') }),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('permission.DepartmentFields.name') }) }],
      },
    },
    {
      label: () => t('permission.DepartmentFields.name'), // '部门名称'
      prop: 'name',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('permission.DepartmentFields.name') }),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('permission.DepartmentFields.name') }) }],
      },
    },
    {
      label: () => t('permission.DepartmentFields.code'), // '部门代码'
      prop: 'code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('permission.DepartmentFields.code') }),
      },
    },
    {
      label: () => t('crud.sort'), // '排序'
      prop: 'sort',
      render: () => <el-input />,
      renderProps: {
        type: 'number',
        placeholder: t('crud.sort'),
      },
    },
    {
      label: () => t('crud.status'), // '状态'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('crud.status'),
        clearable: true,
        dictName: 'system-status',
      },
    },
    {
      label: () => t('crud.remark'), // '备注'
      prop: 'remark',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('crud.remark'),
        type: 'textarea',
      },
    },
  ]
}
