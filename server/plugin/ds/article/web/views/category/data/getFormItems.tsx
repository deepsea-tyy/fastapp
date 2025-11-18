import type { MaFormItem } from '@/components/ma-form'
import type { CategoryVo } from '~/article/api/category.ts'
import MaChildrenForm from '@/components/ma-children-form/index.vue'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {lang} from "@/utils/common.ts";
import {selectCategory} from "$/ds/article/api/category.ts";

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: CategoryVo): MaFormItem[] {

  return [
    {
      label: () => t('article.CategoryFields.code'), // '调用代码'
      prop: 'code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('article.CategoryFields.code') }),
      },
    },
    {
      label: () => t('article.CategoryFields.parent_id'), // '上级'
      prop: 'parent_id',
      render: () => MaRemoteSelect,
      renderProps: {
        api: selectCategory,
        placeholder: t('form.pleaseSelect', { msg: t('article.CategoryFields.parent_id') }),
      },
    },
    {
      label: () => t('article.CategoryFields.name'), // '名称'
      prop: 'name',
      render: () => MaChildrenForm,
      renderProps: {
        options: {
          showAddButton: true,
          showDeleteButton: true,
          minItems: 1,
          emptyRow: 1,
          itemTitle: t('common.language'),
          itemLabelWidth: '80px',
          itemWidth: '100%'
        },
        formList: [
          {
            title: t('common.language'),
            dataIndex: 'lang',
            formType: 'select',
            dict: {
              data: lang(t),
            },
            addDefaultValue: 'zh-CN',
          },
          {
            title: t('common.content'),
            dataIndex: 'text',
            formType: 'textarea',
          }
        ],
        defaultItemValue: {lang: 'zh-CN', text: ''},
        placeholder: t('form.pleaseInput', { msg: t('article.CategoryFields.name') }),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('article.CategoryFields.name') }) }],
      },
    },
    {
      label: () => t('article.CategoryFields.icon'), // 'icon'
      prop: 'icon',
      render: () => <ma-upload-image />,
      renderProps: {
        placeholder: t('form.pleaseSelect', { msg: t('article.CategoryFields.icon') }),
      },
    },
    {
      label: () => t('crud.sort'), // '排序'
      prop: 'sort',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('crud.sort'),
      },
    },
    {
      label: () => t('crud.status'), // '1显示'
      prop: 'status',
      render: () => <ma-dict-select/>,
      renderProps: {
        placeholder: t('crud.status'),
        clearable: true,
        dictName: 'system-display',
      },
    },
    {
      label: () => t('crud.remark'), // '备注'
      prop: 'remark',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('crud.remark'),
        type: 'textarea',
        rows: 3,
      },
    },
  ]
}
