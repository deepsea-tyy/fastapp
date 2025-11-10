import type { MaSearchItem } from '@/components/ma-search'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectCategory} from "$/ds/article/api/category.ts";

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('article.CategoryFields.parent_id'), // '上级'
      prop: 'parent_id',
      render: () => MaRemoteSelect,
      renderProps: {
        api: selectCategory,
        placeholder: t('form.pleaseSelect', { msg: t('article.CategoryFields.parent_id') }),
      },
    },
  ]
}
