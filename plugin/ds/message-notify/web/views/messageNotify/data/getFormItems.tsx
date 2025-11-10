import type { MaFormItem } from '@/components/ma-form'
import type { MessageNotifyVo } from '$/ds/message-notify/api/messageNotify.ts'
import MaChildrenForm from '@/components/ma-children-form/index.vue'
import { lang } from '@/utils/common.ts'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: MessageNotifyVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.type = Number(1)
    model.user_id = Number(0)
    model.notify_type = Number(1)
    // 初始化多语言字段
    if (!model.title || !Array.isArray(model.title)) {
      model.title = [{ lang: 'zh-CN', text: '' }]
    }
    if (!model.content || !Array.isArray(model.content)) {
      model.content = [{ lang: 'zh-CN', text: '' }]
    }
  }

  // 编辑默认值
  if (formType === 'edit') {
    // 确保多语言字段是数组格式
    if (!model.title || !Array.isArray(model.title)) {
      model.title = [{lang: 'zh-CN', text: model.title}]
    }
    if (!model.content || !Array.isArray(model.content)) {
      model.content = [{lang: 'zh-CN', text: model.content}]
    }
  }


  return [
    {
      label: () => t('admin.MessageNotifyFields.title'), // '通知标题'
      prop: 'title',
      render: () => MaChildrenForm,
      renderProps: {
        options: {
          showAddButton: true,
          showDeleteButton: true,
          minItems: 1,
          emptyRow: 1,
          itemTitle: t('common.language') || '语言',
          itemLabelWidth: '80px',
          itemWidth: '100%',
        },
        formList: [
          {
            title: t('common.language') || '语言',
            dataIndex: 'lang',
            formType: 'select',
            dict: {
              data: lang(t),
            },
            addDefaultValue: 'zh-CN',
          },
          {
            title: t('common.content') || '内容',
            dataIndex: 'text',
            formType: 'input',
            commonRules: [
              { required: true, message: t('form.pleaseInput', { msg: t('common.content') }) },
            ],
          },
        ],
        defaultItemValue: { lang: 'zh-CN', text: '' },
        placeholder: t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.title') }),
      },
      itemProps: {
        rules: [
          {
            required: true,
            message: t('form.requiredInput', { msg: t('admin.MessageNotifyFields.title') }) || t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.title') }),
            validator: (_rule: any, value: any, callback: any) => {
              if (!value || !Array.isArray(value) || value.length === 0) {
                callback(new Error(t('form.requiredInput', { msg: t('admin.MessageNotifyFields.title') }) || t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.title') })))
                return
              }
              // 检查是否至少有一个非空的文本
              const hasText = value.some((item: any) => item?.text && item.text.trim() !== '')
              if (!hasText) {
                callback(new Error(t('form.requiredInput', { msg: t('admin.MessageNotifyFields.title') }) || t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.title') })))
                return
              }
              callback()
            },
          },
        ],
      },
    },
    {
      label: () => t('admin.MessageNotifyFields.content'), // '通知内容'
      prop: 'content',
      render: () => MaChildrenForm,
      renderProps: {
        options: {
          showAddButton: true,
          showDeleteButton: true,
          minItems: 1,
          emptyRow: 1,
          itemTitle: t('common.language') || '语言',
          itemLabelWidth: '80px',
          itemWidth: '100%',
        },
        formList: [
          {
            title: t('common.language') || '语言',
            dataIndex: 'lang',
            formType: 'select',
            dict: {
              data: lang(t),
            },
            addDefaultValue: 'zh-CN',
          },
          {
            title: t('common.content') || '内容',
            dataIndex: 'text',
            formType: 'textarea',
            commonRules: [
              { required: true, message: t('form.pleaseInput', { msg: t('common.content') }) },
            ],
          },
        ],
        defaultItemValue: { lang: 'zh-CN', text: '' },
        placeholder: t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.content') }),
      },
      itemProps: {
        rules: [
          {
            required: true,
            message: t('form.requiredInput', { msg: t('admin.MessageNotifyFields.content') }) || t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.content') }),
            validator: (_rule: any, value: any, callback: any) => {
              if (!value || !Array.isArray(value) || value.length === 0) {
                callback(new Error(t('form.requiredInput', { msg: t('admin.MessageNotifyFields.content') }) || t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.content') })))
                return
              }
              // 检查是否至少有一个非空的文本
              const hasText = value.some((item: any) => item?.text && item.text.trim() !== '')
              if (!hasText) {
                callback(new Error(t('form.requiredInput', { msg: t('admin.MessageNotifyFields.content') }) || t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.content') })))
                return
              }
              callback()
            },
          },
        ],
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
      label: () => t('admin.MessageNotifyFields.link'), // '跳转链接'
      prop: 'link',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('form.pleaseInput', { msg: t('admin.MessageNotifyFields.link') }),
      },
    },
  ]
}
