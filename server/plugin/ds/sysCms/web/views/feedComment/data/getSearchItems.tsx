import type { MaSearchItem } from '@/components/ma-search'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.FeedCommentFields.parent_id'), // '父评论ID（0为顶级评论）'
      prop: 'parent_id',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.FeedCommentFields.parent_id'),
            },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
    },
  ]
}
