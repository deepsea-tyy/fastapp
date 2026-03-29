import type { MaFormItem } from '@/components/ma-form'
import type { KefuAutoReplyVo } from '$/ds/syskefu/api/kefuAutoReply.ts'
import MaJsonEditor from '@/components/ma-json-editor/index.vue'
import MaObjectForm from '@/components/ma-object-form/index.vue'
export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: KefuAutoReplyVo): MaFormItem[] {

        const defaultContent = {
            "text":""
        }
    // 新增默认值
  if (formType === 'add') {
    model.trigger_type = 1

    model.reply_type = 1

    model.lang = "zh_CN"

    model.priority = 0

    model.status = 1

    model.hit_count = 0

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.KefuAutoReplyFields.title'),
      prop: 'title',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.title'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.trigger_type'),
      prop: 'trigger_type',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.trigger_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.reply_type'),
      prop: 'reply_type',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.reply_type'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.lang'),
      prop: 'lang',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.lang'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.priority'),
      prop: 'priority',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.priority'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'),
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
          dictName:'system-status',
placeholder: t('crud.status'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.hit_count'),
      prop: 'hit_count',
      render: () => <el-input-number />,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.hit_count'),
        min: 0,
        precision: 2,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.keywords'),
      prop: 'keywords',
      render: () => MaJsonEditor,
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.keywords'),
            },
      cols: { lg: 24, md: 24 },
    },
    {
      label: () => t('admin.KefuAutoReplyFields.reply_content'),
      prop: 'reply_content',
      render: () => {


        const normalizedContent = { ...defaultContent, ...model.reply_content }

  const fields = [
    {
      title: t('common.content'),
      dataIndex: 'text',
      formType: 'input',
      placeholder: t('form.pleaseInput', { msg: t('common.content') }),
      labelWidth: '120px',
    }]
        return (
          <MaObjectForm
            modelValue={normalizedContent}
            onUpdate:modelValue={(val: any) => {
              ;(model as any).reply_content = val
            }}
            fieldList={fields}
            labelWidth="120px"
            defaultItemValue={defaultContent}
          />
        )},
      renderProps: {
placeholder: t('admin.KefuAutoReplyFields.reply_content'),
        type: 'textarea',
        rows: 3,
            },
      cols: { lg: 24, md: 24 },
    },
  ]
}
