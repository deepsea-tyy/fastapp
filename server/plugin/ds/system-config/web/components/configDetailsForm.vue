<script setup lang="tsx">
import MaKeyValue from '@/components/ma-key-value/index.vue'
import useDialog from '@/hooks/useDialog.ts'
import type { UseDialogExpose } from '@/hooks/useDialog.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import type { ConfigItem } from '$/ds/system-config/utils/type.ts'
import { buildRenderProps, renderInputTypeComponent, shouldShowDataButton } from '$/ds/system-config/utils/tools.tsx'
import { deleteByKey } from '$/ds/system-config/api/config.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import {formatLang} from "@/utils/common.ts";
// 引入抽离的方法
const emit = defineEmits<{
  (e: 'onDelete'): void
}>()
const model = defineModel<any>()
const formRef = ref()
const maKeyValueRef = ref()
const defaultModel = reactive<Record<string, any>>({})
const items = reactive<any[]>([])
const i18n = useTrans() as TransType
const t = i18n.globalTrans
const msg = useMessage()

const maDialog: UseDialogExpose = useDialog({
  alignCenter: true,
  footer: false,
})

function updateDefaultModel(newValue: ConfigItem[]) {
  Object.assign(
    defaultModel,
    newValue.reduce((acc, item) => {
      acc[item.key] = item.value || ''
      return acc
    }, {} as Record<string, any>),
  )
}

// 初始化表单项
function initFormItems(data: any) {
  return data.map((item, index) => ({
    label: formatLang(item.name),
    prop: item.key,
    itemProps: { labelWidth: '170px' },
    itemSlots: {
      label: () => (
        <div class="flex items-center gap1">
          <span>{formatLang(item.name)}</span>
          <el-tooltip content={item.key}>
            <ma-svg-icon name="i-stash:info-circle" size={20} />
          </el-tooltip>
        </div>
      ),
    },
    render: () => renderFormItem(item.input_type, item, index),
    renderProps: buildRenderProps(item),
  }))
}

function renderFormItem(inputType: string, item: ConfigItem, index: number) {
  if (inputType === 'checkbox') {
    if (typeof item.value === 'string') {
      item.value = item.value.split(',').map(val => val.trim())
      model.value[index].value = item.value // 确保同步更新响应式对象
    }
    else if (!Array.isArray(item.value)) {
      item.value = []
    }
  }

  return (
    <div class="w-full justify-between gap-2 lg:flex">
      <div class="flex-1">
        {renderInputTypeComponent(inputType, item)}
      </div>
      <div>
        {shouldShowDataButton(inputType) && (
          <el-button
            text
            type="primary"
            onClick={() => {
              maDialog.setTitle(t('systemMenu.confirmationMessages.modifyDataSource'))
              maDialog.open({ formType: 'add', index })
            }}
          >
            {t('systemMenu.systemConfig.field.data')}
          </el-button>
        )}
        {renderDeleteButton(item)}
      </div>
    </div>
  )
}

function renderDeleteButton(item: ConfigItem) {
  const msg = useMessage()
  return (
    <el-button
      text
      type="danger"
      onClick={() => {
        msg.confirm(t('systemMenu.confirmationMessages.deleteDataSource')).then(async () => {
          const response = await deleteByKey(item.key)
          if (response.code === ResultCode.SUCCESS) {
            msg.success(t('crud.delSuccess'))
            emit('onDelete')
          }
        })
      }}
    >
      {t('systemMenu.confirmationMessages.delete')}
    </el-button>
  )
}

function updateItems(newValue: any) {
  // 直接将新值赋给 items，避免清空再添加
  items.splice(0, items.length, ...initFormItems(newValue))
}

onMounted(() => {
  if (model.value) {
    updateDefaultModel(model.value)
    updateItems(model.value)
  }
})

watch(
  () => model.value,
  (newVal) => {
    newVal.forEach((item: ConfigItem) => {
      if (item.input_type === 'switch' && Array.isArray(item.config_select_data) && item.config_select_data.length > 2) {
        item.config_select_data = item.config_select_data.slice(0, 2)
        msg.error(t('systemMenu.confirmationMessages.switchLimit'))
      }
    })
    updateDefaultModel(newVal)
    updateItems(newVal)
  },
  { deep: true },
)

defineExpose({
  maForm: formRef,
})
</script>

<template>
  <ma-form ref="formRef" v-model="defaultModel" :items="items" />
  <component :is="maDialog.Dialog">
    <template #default="{ index }">
      <MaKeyValue
        ref="maKeyValueRef"
        v-model="model[index].config_select_data"
      />
    </template>
  </component>
</template>
