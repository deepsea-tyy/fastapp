import type { MaFormItem } from '@/components/ma-form'
import type { IndexsVo } from '~/search/api/indexs.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: IndexsVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.weight = 1
  }

  return [
    {
      label: () => t('search.IndexsFields.target_type'), // '内容类型'
      prop: 'target_type',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('search.IndexsFields.target_type'),
        dictName: 'search-target-type',
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('permission.IndexsFields.keyword') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.target_id'),
      prop: 'target_id',
      render: () => <el-input />,
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('permission.IndexsFields.target_id') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.title'), // '标题'
      prop: 'title',
      render: () => <el-input />,
      renderProps: {
placeholder: t('search.IndexsFields.title'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.weight'), // '权重'
      prop: 'weight',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('search.IndexsFields.weight'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.keyword'), // '关键词数组'
      prop: 'keyword',
      render: () => <ma-json-editor />,
      renderProps: {
        type: 'array',
        height: '200px',
      },
      cols: { lg: 24, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.tags'), // '标签数组'
      prop: 'tags',
      render: () => <ma-json-editor />,
      renderProps: {
        type: 'array',
        height: '200px',
      },
      cols: { lg: 24, md: 24 },
    },
  ]
}
