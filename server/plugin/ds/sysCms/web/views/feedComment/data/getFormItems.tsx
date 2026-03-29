import type { MaFormItem } from '@/components/ma-form'
import type { FeedCommentVo } from '$/ds/syscms/api/feedComment.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: FeedCommentVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.parent_id = 0

    model.root_id = 0

    model.like_count = 0

    model.reply_count = 0

    model.status = 1

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.FeedCommentFields.target_type'), // '目标类型：1帖子 2文章'
      prop: 'target_type',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedCommentFields.target_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedCommentFields.content'), // '评论内容'
      prop: 'content',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedCommentFields.content'),
        type: 'textarea',
        rows: 3,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedCommentFields.images'), // '图片列表（JSON数组）'
      prop: 'images',
      render: () => <ma-upload-image />,
      renderProps: {
placeholder: t('admin.FeedCommentFields.images'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedCommentFields.like_count'), // '点赞数'
      prop: 'like_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedCommentFields.like_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedCommentFields.reply_count'), // '回复数'
      prop: 'reply_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedCommentFields.reply_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
      cols: { lg: 12, md: 24 },
    },
  ]
}
