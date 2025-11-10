import type { MaSearchItem } from '@/components/ma-search'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectCategory} from "$/ds/article/api/category.ts";
import MaDictSelect from "@/components/ma-dict-picker/ma-dict-select.vue";

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('crud.status'),
      prop: 'status',
      render: () => MaDictSelect,
      renderProps: {
        clearable: true,
        placeholder: '',
        dictName: 'system-display',
      },
    },
    {
      label: () => t('crud.category'),
      prop: 'category_id',
      render: () => MaRemoteSelect,
      renderProps: {
        api: selectCategory,
        placeholder: t('form.pleaseSelect', { msg: t('crud.category') }),
      },
    },
  ]
}
