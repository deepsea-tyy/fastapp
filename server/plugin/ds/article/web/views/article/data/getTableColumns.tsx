import type { MaProTableColumns, MaProTableExpose } from '@/components/ma-pro-table'
import type { ArticleVo } from '~/article/api/article.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { useMessage } from '@/hooks/useMessage.ts'
import { deleteByIds } from '$/ds/article/api/article.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import hasAuth from '@/utils/permission/hasAuth.ts'
import { ElTag } from 'element-plus'
import {formatLang} from "@/utils/common.ts";
import MaImagePreview from '@/components/ma-image-preview/index.vue'

export default function getTableColumns(dialog: UseDrawerExpose, formRef: any, t: any): MaProTableColumns[] {
  const dictStore = useDictStore()
  const msg = useMessage()

  const showBtn = (auth: string | string[], row: ArticleVo) => {
    return hasAuth(auth)
  }

  return [
    // 多选列
    { type: 'selection', showOverflowTooltip: false, label: () => t('crud.selection') },
    // 索引序号列
    { type: 'index' },
    // 普通列
    {
      label: () => t('article.ArticleFields.code'), // '调用代码'
      minWidth: 120,
      prop: 'code',
    },
    {
      label: () => t('crud.category'), // '作者'
      minWidth: 120,
      prop: 'categories',

      cellRender: ({row}) => {
        const cate = row.categories.map(item=>formatLang(item.name))
        return cate.join(',')
      }
    },
    {
      label: () => t('article.ArticleFields.author'), // '作者'
      minWidth: 120,
      prop: 'author',
    },
    {
      label: () => t('article.ArticleFields.release_at'), // '发布日期'
      minWidth: 120,
      prop: 'release_at',
    },
    {
      label: () => t('article.ArticleFields.title'), // '标题'
      minWidth: 120,
      prop: 'title',
      cellRender: ({row}) => formatLang(row.title)
    },
    {
      label: () => t('article.ArticleFields.cover'), // '封面'
      minWidth: 120,
        prop: 'title',
        cellRender: ({row}) => <MaImagePreview images={row.cover}/>
    },
    {
      label: () => t('crud.remark'), // '备注'
      minWidth: 120,
      prop: 'remark',
    },
    {
      label: () => t('crud.sort'), // '排序'
      minWidth: 120,
      prop: 'sort',
      sortable: 'custom',
    },
    {
      label: () => t('article.ArticleFields.comment'), // '评论数'
      minWidth: 120,
      prop: 'comment',
      sortable: 'custom',
    },
    {
      label: () => t('article.ArticleFields.views'), // '浏览数'
      minWidth: 120,
      prop: 'views',
      sortable: 'custom',
    },
    {
      label: () => t('article.ArticleFields.like'), // '点赞数'
      minWidth: 120,
      prop: 'like',
      sortable: 'custom',
    },
    {
      label: () => t('crud.status'), // '1显示'
      minWidth: 120,
      prop: 'status',
      sortable: 'custom',
      cellRender: ({ row }) => {
        const i18nKey = dictStore.t('system-display', row.status, 'i18n')
        return (
          <ElTag type={dictStore.t('system-display', row.status, 'color') || undefined}>
            {i18nKey ? t(i18nKey) : ''}
          </ElTag>
        )
      },
    },
    {
      label: () => t('crud.createdAt'), // '创建时间'
      minWidth: 200,
      prop: 'created_at',
      sortable: 'custom',
    },
    {
      label: () => t('crud.updatedAt'), // '更新时间'
      minWidth: 200,
      prop: 'updated_at',
      sortable: 'custom',
    },
    // 操作列
    {
      type: 'operation',
      label: () => t('crud.operation'),
      fixed: 'right',
      width: '260px',
      operationConfigure: {
        type: 'tile',
        actions: [
          {
            name: 'edit',
            icon: 'i-heroicons:pencil',
            show: ({ row }) => showBtn('article:article:update', row),
            text: () => t('crud.edit'),
            linkProps: { type: 'primary' },
            onClick: ({ row }) => {
              dialog.setTitle(t('crud.edit'))
              dialog.open({ formType: 'edit', data: row })
            },
          },
          {
            name: 'del',
            show: ({ row }) => showBtn('article:article:delete', row),
            icon: 'i-heroicons:trash',
            text: () => t('crud.delete'),
            linkProps: { type: 'danger' },
            onClick: ({ row }, proxy: MaProTableExpose) => {
              msg.delConfirm(t('crud.delDataMessage')).then(async () => {
                const response = await deleteByIds([row.id])
                if (response.code === ResultCode.SUCCESS) {
                  msg.success(t('crud.delSuccess'))
                  await proxy.refresh()
                }
              })
            },
          },
        ],
      },
    },
  ]
}
