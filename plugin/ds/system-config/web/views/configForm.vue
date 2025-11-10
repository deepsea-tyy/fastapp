<script setup lang="ts">
import type { ConfigVo } from '$/ds/system-config/api/config.ts'
import type { ConfigGroupVo } from '$/ds/system-config/api/configGroup.ts'
import { create, save } from '$/ds/system-config/api/config.ts'
import getSettingConfigFormItems from './data/getSysConfigFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import { ResultCode } from '@/utils/ResultCode.ts'

defineOptions({ name: 'system:group:form' })

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: ConfigGroupVo | null
}>()

const t = useTrans().globalTrans
const defaultForm = ref<MaFormExpose>()
const defaultModel = ref<ConfigVo>({})

useForm('defaultForm').then((form: MaFormExpose) => {
  if (data && typeof data === 'object' && !Array.isArray(data)) {
    defaultModel.value.group_id = data.id
    defaultModel.value.group_code = data.code
  }
  form.setItems(getSettingConfigFormItems(formType, t, defaultModel.value))
  form.setOptions({
    labelWidth: '120px',
  })
})

// 创建操作
function add(): Promise<any> {
  return new Promise((resolve, reject) => {
    create(defaultModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
  })
}

// 更新操作
function edit(): Promise<any> {
  return new Promise((resolve, reject) => {
    save(defaultModel.value.key, defaultModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
  })
}

defineExpose({
  add,
  edit,
  maForm: defaultForm,
})
</script>

<template>
  <ma-form ref="defaultForm" v-model="defaultModel" />
</template>

<style scoped lang="scss">

</style>
