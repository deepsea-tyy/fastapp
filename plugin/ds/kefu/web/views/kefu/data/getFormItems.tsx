import type {MaFormItem} from '@/components/ma-form'
import {concat} from 'lodash-es'
import MaDictSelect from "@/components/ma-dict-picker/ma-dict-select.vue";
import MaUploadImage from '@/components/ma-upload-image/index.vue'


export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: any): MaFormItem[] {


  return concat([
    {
      label: () => t('kefu.KefuFields.nickname'),
      prop: 'nickname',
      render: 'input',
      renderProps: {placeholder: t('form.pleaseInput', {msg: t('kefu.KefuFields.nickname')})}
    },
    {label: () => t('kefu.KefuFields.avatar'), prop: 'avatar', render: () => MaUploadImage, multiple: false},
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
    {
      label: () => t('kefu.KefuFields.maxConcurrent'),
      prop: 'max_concurrent',
      render: 'input',
      renderProps: {placeholder: t('form.pleaseInput', {msg: t('kefu.KefuFields.maxConcurrent')})}
    },
  ]);
}
