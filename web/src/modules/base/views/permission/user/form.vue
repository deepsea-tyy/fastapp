
<script setup lang="ts">
import type { UserVo } from '~/base/api/user'
import { create, save } from '~/base/api/user'
import getFormItems from './data/getFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import { ResultCode } from '@/utils/ResultCode.ts'

defineOptions({ name: 'permission:user:form' })

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: UserVo | null
}>()

const t = useTrans().globalTrans
const userForm = ref<MaFormExpose>()
const userModel = ref<UserVo>({})

useForm('userForm').then((form: MaFormExpose) => {
  if (formType === 'edit' && data) {
    Object.keys(data).map((key: string) => {
      userModel.value[key] = data[key]
    })
  }
  form.setItems(getFormItems(formType, t, userModel.value))
  form.setOptions({
    labelWidth: '80px',
  })
})

// 创建操作
function add(): Promise<any> {
  return new Promise((resolve, reject) => {
    create(userModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
  })
}

// 更新操作
function edit(): Promise<any> {
  return new Promise((resolve, reject) => {
    save(userModel.value.id as number, userModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
  })
}

defineExpose({
  add,
  edit,
  maForm: userForm,
})
</script>

<template>
  <ma-form ref="userForm" v-model="userModel" />
</template>

<style scoped lang="scss">

</style>
