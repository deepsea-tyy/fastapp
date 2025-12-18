import type { MaFormItem } from '@/components/ma-form'
import type { FeedPostVo } from '$/ds/syscms/api/feedPost.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: FeedPostVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.content_type = 1

    model.audit_status = 0

    model.is_top = 0

    model.is_hot = 0

    model.status = 1

    model.view_count = 0

    model.like_count = 0

    model.comment_count = 0

    model.share_count = 0

    model.collect_count = 0

    model.quote_count = 0

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.FeedPostFields.content_type'), // '内容类型：1纯文本 2图文 3视频 4链接'
      prop: 'content_type',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'feed-content-type',
placeholder: t('admin.FeedPostFields.content_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.title'), // '标题（可选）'
      prop: 'title',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedPostFields.title'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.images'), // '图片列表（JSON数组）'
      prop: 'images',
      render: () => <ma-upload-image />,
      renderProps: {
          multiple:true,
placeholder: t('admin.FeedPostFields.images'),
            },
    },
    {
      label: () => t('admin.FeedPostFields.link_url'), // '外链地址'
      prop: 'link_url',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedPostFields.link_url'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.link_meta'), // '链接元数据（标题、描述、封面等）'
      prop: 'link_meta',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedPostFields.link_meta'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.quoted_type'), // '引用类型：1帖子 2文章'
      prop: 'quoted_type',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'feed-target-type',
placeholder: t('admin.FeedPostFields.quoted_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.audit_status'), // '审核状态：0待审核 1已通过 2已拒绝'
      prop: 'audit_status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedPostFields.audit_status'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.audited_at'), // '审核时间'
      prop: 'audited_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.FeedPostFields.audited_at'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.is_top'), // '是否置顶：0否 1是'
      prop: 'is_top',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'feed-audit-status',
placeholder: t('admin.FeedPostFields.is_top'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.is_hot'), // '是否热门：0否 1是'
      prop: 'is_hot',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'system-yes-no',
placeholder: t('admin.FeedPostFields.is_hot'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'system-display',
placeholder: t('crud.status'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.view_count'), // '浏览次数'
      prop: 'view_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedPostFields.view_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.like_count'), // '点赞数'
      prop: 'like_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedPostFields.like_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.comment_count'), // '评论数'
      prop: 'comment_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedPostFields.comment_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.share_count'), // '分享数'
      prop: 'share_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedPostFields.share_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.collect_count'), // '收藏数'
      prop: 'collect_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedPostFields.collect_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.quote_count'), // '引用数'
      prop: 'quote_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.FeedPostFields.quote_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.ip'), // '发布IP'
      prop: 'ip',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.FeedPostFields.ip'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.device_type'), // '设备类型：ios, android, web'
      prop: 'device_type',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedPostFields.device_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.FeedPostFields.content'), // '内容'
      prop: 'content',
      render: () => <ma-editor />,
      renderProps: {
placeholder: t('admin.FeedPostFields.content'),
        type: 'textarea',
        rows: 3,
            },
    },
  ]
}
