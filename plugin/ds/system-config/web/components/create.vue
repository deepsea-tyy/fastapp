<script setup lang="ts">
import type { UseDialogExpose } from '@/hooks/useDialog.ts'
import ConfigForm from '$/ds/system-config/views/configForm.vue'

import useDialog from '@/hooks/useDialog.ts'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import type { ConfigVo } from '$/ds/system-config/api/config.ts'

const { formType = 'add', data = null } = defineProps<{
  formType?: 'add' | 'edit'
  data?: ConfigVo | null
}>()
// 定义事件用于通知父组件
const emit = defineEmits(['createSuccess', 'createError'])
const formRef = ref()
const i18n = useTrans() as TransType
const t = i18n.globalTrans
const msg = useMessage()
// 弹窗配置
const maDialog: UseDialogExpose = useDialog({
  alignCenter: true,
  width: '40%',
  ok: ({ formType }, okLoadingState: (state: boolean) => void) => {
    okLoadingState(true)
    if (['add', 'edit'].includes(formType)) {
      const elForm = formRef.value.maForm.getElFormRef()
      // 验证通过后
      elForm.validate().then(() => {
        switch (formType) {
          // 新增
          case 'add':
            formRef.value.add().then((res: any) => {
              res.code === ResultCode.SUCCESS ? msg.success(t('crud.createSuccess')) : msg.error(res.message)
              emit('createSuccess', res.data) // 通知父组件创建成功
              maDialog.close()
            }).catch((err: any) => {
              msg.alertError(err)
            })
            break
          // 修改
          case 'edit':
            formRef.value.edit().then((res: any) => {
              res.code === 200 ? msg.success(t('crud.updateSuccess')) : msg.error(res.message)
              maDialog.close()
            }).catch((err: any) => {
              msg.alertError(err)
            })
            break
        }
      }).catch()
    }
    okLoadingState(false)
  },
})
</script>

<template>
  <el-button
    v-bind="$attrs"
    @click="() => {
      maDialog.setTitle(t('systemMenu.systemConfig.addConfig'))
      maDialog.open({ formType: 'add', data })
    }"
  >
    {{ t('systemMenu.systemConfig.addConfig') }}
  </el-button>
  <component :is="maDialog.Dialog">
    <template #default="{ formType, data }">
      <!-- 添加配置项 -->
      <ConfigForm ref="formRef" :form-type="formType" :data="data" />
    </template>
  </component>
</template>

<style scoped lang="scss">

</style>
