import type { MaFormItem } from '@/components/ma-form'
import type { IndexsVo } from '~/search/api/indexs.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: IndexsVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.weight = 1

    model.view_count = 0

    model.like_count = 0

    model.status = 1

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
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
      label: () => t('search.IndexsFields.author'), // '作者/发布者'
      prop: 'author',
      render: () => <el-input />,
      renderProps: {
placeholder: t('search.IndexsFields.author'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.weight'), // '权重'
      prop: 'weight',
      render: () => <el-input />,
      renderProps: {
placeholder: t('search.IndexsFields.weight'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.view_count'), // '浏览量'
      prop: 'view_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('search.IndexsFields.view_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'), // '状态'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.IndexsFields.published_at'), // '发布时间'
      prop: 'published_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('search.IndexsFields.published_at'),
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
    {
      label: () => t('search.IndexsFields.extra'), // '扩展字段JSON'
      prop: 'extra',
      render: () => <ma-json-editor />,
      renderProps: {
        type: 'object',
        height: '200px',
      },
      cols: { lg: 24, md: 24 },
    },
  ]
}
