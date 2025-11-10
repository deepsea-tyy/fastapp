import type { MaSearchItem } from '@/components/ma-search'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.MessageNotifyFields.type'), // '通知类型'
      prop: 'type',
      render: () => MaDictSelect,
      renderProps: {
        placeholder: t('form.pleaseSelect', { msg: t('admin.MessageNotifyFields.type') }),
        dictName: 'message-notify-type',
        clearable: true,
      },
    },
    {
      label: () => t('admin.MessageNotifyFields.notify_type'), // '通知分类'
      prop: 'notify_type',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('form.pleaseSelect', { msg: t('admin.MessageNotifyFields.notify_type') }),
        dictName: 'message-notify-notify-type',
        clearable: true,
      },
    },
  ]
}
