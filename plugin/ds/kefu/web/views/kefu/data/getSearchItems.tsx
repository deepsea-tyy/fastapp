import type { MaSearchItem } from '@/components/ma-search'
import MaDictSelect from "@/components/ma-dict-picker/ma-dict-select.vue";

export default function getSearchItems(t: any): MaSearchItem[] {
    return [
    {
      label: () => t('kefu.KefuFields.status'),
      prop: 'status',
      render: () => MaDictSelect,
      renderProps: {
        clearable: true,
        dictName: 'system-status',
        placeholder: t('form.pleaseInput', {msg: t('kefu.KefuFields.status')})
      }
    },
  ]
}
