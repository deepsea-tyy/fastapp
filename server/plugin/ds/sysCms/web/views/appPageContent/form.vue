<script setup lang="ts">
import type { AppPageContentVo } from '$/ds/sysCms/api/appPageContent.ts'
import { create, save } from '$/ds/sysCms/api/appPageContent.ts'
import getFormItems from './data/getFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import useFormResponsive from '@/hooks/useFormResponsive.ts'

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: AppPageContentVo | null
}>()

const t = useTrans().globalTrans
const maFormRef = ref<MaFormExpose>()
const formModel = ref<AppPageContentVo>({} as AppPageContentVo)

// 使用响应式表单布局 Hook
useFormResponsive(maFormRef)

useForm('maFormRef').then((form: MaFormExpose) => {
  if (formType === 'edit' && data) {
    Object.assign(formModel.value, data)
  }
  form.setItems(getFormItems(formType, t, formModel.value))
})

// 创建操作
function add(): Promise<any> {
  return create(formModel.value).then((res: any) => {
    if (res.code === ResultCode.SUCCESS) {
      return res
    }
    throw res
  })
}

// 更新操作
function edit(): Promise<any> {
  return save(formModel.value.id as number, formModel.value).then((res: any) => {
    if (res.code === ResultCode.SUCCESS) {
      return res
    }
    throw res
  })
}

defineExpose({
  add,
  edit,
  maForm: maFormRef,
})
</script>

<template>
  <ma-form ref="maFormRef" v-model="formModel" />
</template>

<style scoped lang="scss">
</style>

