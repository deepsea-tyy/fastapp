import type { MaFormItem } from '@/components/ma-form'
import type { FeedTagVo } from '$/ds/syscms/api/feedTag.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: FeedTagVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.post_count = 0

    model.follow_count = 0

    model.is_hot = 0

    model.status = 1

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.FeedTagFields.name'), // '标签名称（多语言）'
      prop: 'name',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedTagFields.name'),
            },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('admin.FeedTagFields.name') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedTagFields.icon'), // '标签图标'
      prop: 'icon',
      render: () => <ma-upload-image />,
      renderProps: {
placeholder: t('admin.FeedTagFields.icon'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedTagFields.color'), // '标签颜色'
      prop: 'color',
      render: () => <el-color-picker />,
      renderProps: {
placeholder: t('admin.FeedTagFields.color'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedTagFields.post_count'), // '内容数量'
      prop: 'post_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedTagFields.post_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedTagFields.follow_count'), // '关注数'
      prop: 'follow_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedTagFields.follow_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedTagFields.is_hot'), // '是否热门'
      prop: 'is_hot',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedTagFields.is_hot'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'), // '状态：1启用 0禁用'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
      cols: { lg: 12, md: 24 },
    },
  ]
}
