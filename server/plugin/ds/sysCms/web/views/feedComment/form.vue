<script setup lang="ts">
import type { FeedCommentVo } from '$/ds/syscms/api/feedComment.ts'
import { create, save } from '$/ds/syscms/api/feedComment.ts'
import getFormItems from './data/getFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import useFormResponsive from '@/hooks/useFormResponsive.ts'

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: FeedCommentVo | null
}>()

const t = useTrans().globalTrans
const maFormRef = ref<MaFormExpose>()
const formModel = ref<FeedCommentVo>({} as FeedCommentVo)

// 使用响应式表单布局 Hook
// 当 labelPosition 为 'top' 时，会自动设置 labelWidth 为 '100%' 以确保标签占整行
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
