<script setup lang="ts">
import type { CategoryVo } from '$/ds/article/api/category.ts'
import { create, save } from '$/ds/article/api/category.ts'
import getFormItems from './data/getFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import { ResultCode } from '@/utils/ResultCode.ts'

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: CategoryVo | null
}>()

const t = useTrans().globalTrans
const maFormRef = ref<MaFormExpose>()
const formModel = ref<CategoryVo>({})

useForm('maFormRef').then((form: MaFormExpose) => {
  if (formType === 'edit' && data) {
    Object.keys(data).map((key: string) => {
      formModel.value[key] = data[key]
    })
  }
  form.setItems(getFormItems(formType, t, formModel.value))
  form.setOptions({
    labelWidth: '120px',
  })
})

// 创建操作
function add(): Promise<any> {
  return new Promise((resolve, reject) => {
    create(formModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
  })
}

// 更新操作
function edit(): Promise<any> {
  return new Promise((resolve, reject) => {
    save(formModel.value.id as number, formModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
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
