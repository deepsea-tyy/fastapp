
<script setup lang="ts">
import getFormItems from './data/getFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import useFormResponsive from '@/hooks/useFormResponsive.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import { create, save } from '$/ds/kefu/api/kefu.ts'

defineOptions({ name: 'kefu:kefu:form' })

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: any | null
}>()

const t = useTrans().globalTrans
const formRef = ref<MaFormExpose>()
const formData = ref<any>({})

useForm('formRef').then((form: MaFormExpose) => {
  if (formType === 'edit' && data) {
    Object.keys(data).map((key: string) => {
      formData.value[key] = data[key]
    })
  }
  form.setItems(getFormItems(formType, t, formData.value))
})

// 响应式布局
useFormResponsive(formRef, {
  xsLabelPosition: 'top',
  smLabelPosition: 'right',
  lgLabelPosition: 'right',
  lgLabelWidth: '100px',
})

// 创建操作
function add(): Promise<any> {
  return new Promise((resolve, reject) => {
    create(formData.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {

    })
  })
}
// 更新操作
function edit(): Promise<any> {
  return new Promise((resolve, reject) => {
    save(formData.value.id as number, formData.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {

    })
  })
}

defineExpose({
  add,
  edit,
  maForm: formRef
})
</script>

<template>
  <ma-form ref="formRef" v-model="formData" />
</template>

<style scoped lang="scss">

</style>
