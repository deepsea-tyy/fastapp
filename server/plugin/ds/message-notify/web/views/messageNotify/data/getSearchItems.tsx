import type { MaSearchItem } from '@/components/ma-search'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'
import MaRemoteSearch from '@/components/ma-remote-search/index.vue'
import { selectUser } from '~/base/api/user.ts'

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
    {
      label: () => t('common.user'),
      prop: 'user_id',
      render: () => MaRemoteSearch,
      renderProps: {
        placeholder: t('form.pleaseSelect', { msg: t('common.user') }),
        api: (params: any) => selectUser({ ...params, page_size: 999 }),
        searchKey: 'keyword',
        searchPlaceholder: t('form.pleaseInput', { msg: t('common.user') }),
        dataHandle: (response: any) => {
          return response.data.list?.map((item: any) => {
            return { label: `${item.nickname || item.username} (${item.username})`, value: item.id }
          }) || []
        },
      },
    },
  ]
}
