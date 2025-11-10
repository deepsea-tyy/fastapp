
<script setup lang="ts">
import type { ConfigGroupVo } from '$/ds/system-config/api/configGroup.ts'
import { create, save } from '$/ds/system-config/api/configGroup.ts'
import getSysGroupFormItems from './data/getSysGroupFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import useFormResponsive from '@/hooks/useFormResponsive.ts'
import { ResultCode } from '@/utils/ResultCode.ts'

defineOptions({ name: 'system:group:form' })

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: ConfigGroupVo | null
}>()

const t = useTrans().globalTrans
const defaultForm = ref<MaFormExpose>()
const defaultModel = ref<ConfigGroupVo>({})

useForm('defaultForm').then((form: MaFormExpose) => {
  if (formType === 'edit' && data) {
    Object.keys(data).map((key: string) => {
      defaultModel.value[key] = data[key]
    })
  }
  form.setItems(getSysGroupFormItems(formType, t, defaultModel.value))
})

// 响应式布局
useFormResponsive(defaultForm, {
  xsLabelPosition: 'top',
  smLabelPosition: 'right',
  lgLabelPosition: 'right',
  lgLabelWidth: '120px',
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
    save(defaultModel.value.id as number, defaultModel.value).then((res: any) => {
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
