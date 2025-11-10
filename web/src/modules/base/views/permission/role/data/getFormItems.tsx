
import type { MaFormItem } from '@/components/ma-form'
import type { RoleVo } from '~/base/api/role.ts'
import MaDictRadio from '@/components/ma-dict-picker/ma-dict-radio.vue'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectDept} from "~/base/api/department.ts";

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: RoleVo): MaFormItem[] {
  if (formType === 'add') {
    model.status = 1
    model.sort = 0
    model.data_scope = 5
  }

  return [
    {
      label: () => t('baseRoleManage.name'),
      prop: 'name',
      render: 'input',
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('baseRoleManage.name') }),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.requiredInput', { msg: t('baseRoleManage.name') }) }],
      },
    },
    {
      label: () => t('baseRoleManage.code'),
      prop: 'code',
      render: 'input',
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('baseRoleManage.code') }),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.requiredInput', { msg: t('baseRoleManage.code') }) }],
      },
    },
    {
      label: () => t('crud.sort'),
      prop: 'sort',
      render: 'inputNumber',
      cols: { md: 12, xs: 24 },
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('crud.sort') }),
        class: 'w-full',
      },
    },
    {
      label: () => t('crud.status'),
      prop: 'status',
      render: () => MaDictRadio,
      cols: { md: 12, xs: 24 },
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('crud.status') }),
        dictName: 'system-status',
      },
    },
    {
      label: () => t('crud.remark'),
      prop: 'remark',
      render: 'input',
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('crud.remark') }),
        type: 'textarea',
      },
    },
    {
      label: () => t('baseRoleManage.dataScope'),
      prop: 'data_scope',
      render: () => MaDictSelect,
      renderProps: {
        placeholder: t('form.pleaseSelect', { msg: t('baseRoleManage.dataScope') }),
        dictName: 'role-dataScope',
        class: 'w-full',
      },
      itemProps: {
        rules: [{ required: true, message: t('form.requiredSelect', { msg: t('baseRoleManage.dataScope') }) }],
      },
    },
    {
      label: () => t('permission.Department'), // '部门'
      prop: 'dept_id',
      render: () => MaRemoteSelect,
      renderProps: {
        api: selectDept,
        multiple: true,
        placeholder: t('form.pleaseInput', { msg: t('permission.Department') }),
      },
    },
  ]
}
