<!--
 * MaNestedObjectForm - 嵌套对象表单组件
 * 支持配置嵌套对象结构，如 {k1:{k1:v1,k2:v2}}
-->
<script setup lang="ts">
import { ref, watch } from 'vue'
import { ElInput, ElInputNumber } from 'element-plus'
import type { PropType } from 'vue'

defineOptions({ name: 'MaNestedObjectForm' })

// 字段定义类型
interface FieldConfig {
  key: string
  label: string
  type?: 'number' | 'text'
  placeholder?: string
  precision?: number
  step?: number
  min?: number
  max?: number
  [key: string]: any
}

// 对象配置类型
interface ObjectConfig {
  key: string
  label: string
  fields: FieldConfig[]
}

// 定义组件的属性
const props = defineProps({
  // 组件的值
  modelValue: {
    type: Object as PropType<Record<string, any>>,
    default: () => ({})
  },
  // 对象配置
  objectConfigs: {
    type: Array as PropType<ObjectConfig[]>,
    required: true
  }
})

// 定义组件的事件
const emit = defineEmits(['update:modelValue', 'change'])

// 内部数据
const formData = ref<Record<string, any>>({ ...props.modelValue })

// 初始化默认值
const initDefaultValue = () => {
  const defaultValue: Record<string, any> = {}
  props.objectConfigs.forEach(objConfig => {
    if (!formData.value[objConfig.key]) {
      const fieldDefaults: Record<string, any> = {}
      objConfig.fields.forEach(field => {
        fieldDefaults[field.key] = field.type === 'number' ? 0 : ''
      })
      defaultValue[objConfig.key] = fieldDefaults
    }
  })
  return { ...formData.value, ...defaultValue }
}

// 初始化
if (Object.keys(formData.value).length === 0) {
  formData.value = initDefaultValue()
}

/**
 * 更新组件值
 */
const updateValue = () => {
  emit('update:modelValue', formData.value)
  emit('change', formData.value)
}

/**
 * 更新指定对象的字段值
 */
const updateFieldValue = (objectKey: string, fieldKey: string, value: any) => {
  if (!formData.value[objectKey]) {
    formData.value[objectKey] = {}
  }
  formData.value[objectKey][fieldKey] = value
  updateValue()
}

/**
 * 获取字段值
 */
const getFieldValue = (objectKey: string, fieldKey: string): any => {
  return formData.value[objectKey]?.[fieldKey] ?? (props.objectConfigs.find(c => c.key === objectKey)?.fields.find(f => f.key === fieldKey)?.type === 'number' ? 0 : '')
}

// 监听外部值变化
watch(() => props.modelValue, (newVal) => {
  if (newVal && typeof newVal === 'object' && JSON.stringify(newVal) !== JSON.stringify(formData.value)) {
    formData.value = { ...initDefaultValue(), ...newVal }
  }
}, { deep: true })
</script>

<template>
  <div class="ma-nested-object-form">
    <div class="ma-nested-object-form-content">
      <div
        v-for="objConfig in objectConfigs"
        :key="objConfig.key"
        class="ma-nested-object-form-item"
      >
        <div class="ma-nested-object-form-item-label">
          {{ objConfig.label }}
        </div>
        <div class="ma-nested-object-form-item-fields">
          <div
            v-for="field in objConfig.fields"
            :key="field.key"
            class="ma-nested-object-form-field"
          >
            <label class="ma-nested-object-form-field-label">{{ field.label }}</label>
            <el-input-number
              v-if="field.type === 'number'"
              :model-value="getFieldValue(objConfig.key, field.key)"
              @update:model-value="(val) => updateFieldValue(objConfig.key, field.key, val ?? 0)"
              :precision="field.precision ?? 4"
              :step="field.step ?? 0.0001"
              :min="field.min ?? 0"
              :max="field.max"
              :placeholder="field.placeholder"
              style="width: 100%"
            />
            <el-input
              v-else
              :model-value="getFieldValue(objConfig.key, field.key)"
              @update:model-value="(val) => updateFieldValue(objConfig.key, field.key, val)"
              :placeholder="field.placeholder"
              style="width: 100%"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.ma-nested-object-form {
  width: 100%;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #ebeef5;
  background-color: var(--el-bg-color);
}

.ma-nested-object-form-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.ma-nested-object-form-item {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  padding: 12px;
  border-radius: 6px;
  background-color: var(--el-fill-color-lighter);
  border: 1px solid var(--el-border-color-light);
}

.ma-nested-object-form-item-label {
  min-width: 120px;
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
  line-height: 32px;
  padding-right: 16px;
  flex-shrink: 0;
}

.ma-nested-object-form-item-fields {
  display: flex;
  flex-direction: row;
  gap: 16px;
  flex: 1;
}

.ma-nested-object-form-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.ma-nested-object-form-field-label {
  font-size: 13px;
  color: var(--el-text-color-regular);
  font-weight: 400;
}

@media (max-width: 768px) {
  .ma-nested-object-form-item {
    flex-direction: column;
  }

  .ma-nested-object-form-item-label {
    min-width: auto;
    padding-right: 0;
    padding-bottom: 8px;
  }

  .ma-nested-object-form-item-fields {
    flex-direction: column;
    width: 100%;
  }
}
</style>
