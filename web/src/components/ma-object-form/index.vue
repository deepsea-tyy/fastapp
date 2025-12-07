<!--
 * MaObjectForm - 将formList处理为对象的表单组件
-->
<script setup lang="ts">
import { ref, watch, computed, defineComponent, PropType, h } from 'vue'
import { ElInput, ElSelect, ElOption, ElDatePicker } from 'element-plus'
import MaEditor from '@/components/ma-editor/index.vue'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import type { ChildFormItem } from '@/components/ma-children-form/index.vue'

defineOptions({ name: 'MaObjectForm' })

// 定义组件的属性
const props = defineProps({
  // 组件的值，类型为对象
  modelValue: {
    type: Object as PropType<Record<string, any>>,
    default: () => ({})
  },
  // 子表单项配置
  fieldList: {
    type: Array as PropType<ChildFormItem[]>,
    default: () => []
  },
  // 标签宽度
  labelWidth: {
    type: String,
    default: '120px'
  },
  // 表单组件宽度
  itemWidth: {
    type: String,
    default: '100%'
  },
  // 新项的默认值
  defaultItemValue: {
    type: Object,
    default: () => ({})
  }
})

// 主题
const settingStore = useSettingStore()

// 定义组件的事件
const emit = defineEmits(['update:modelValue', 'change'])

// 内部数据对象
const itemData = ref<Record<string, any>>({ ...props.defaultItemValue, ...props.modelValue })

// 初始化默认值
const initDefaultValue = () => {
  const defaultValue = { ...props.defaultItemValue }

  // 如果有formList配置，则根据formList中的addDefaultValue设置默认值
  if (props.fieldList && props.fieldList.length > 0) {
    props.fieldList.forEach(item => {
      if (item.addDefaultValue !== undefined) {
        defaultValue[item.dataIndex] = item.addDefaultValue
      }
    })
  }

  return defaultValue
}

/**
 * 更新组件值
 * 触发update:modelValue事件，将当前itemData传递给父组件
 */
const updateValue = () => {
  emit('update:modelValue', itemData.value)
  emit('change', itemData.value)
}

// 初始化 - 参考 MaChildrenForm 的逻辑，只在真正需要时才初始化
// 如果 itemData 已经有值（即使是从 props.modelValue 合并来的），就不需要初始化
// 只有当 itemData 完全为空对象时，才初始化默认值，但不触发更新（避免递归）
if (Object.keys(itemData.value).length === 0) {
  itemData.value = initDefaultValue()
  // 注意：这里不调用 updateValue()，避免初始化时触发递归更新
  // 参考 MaChildrenForm：只有当 emptyRow > 0 且数组为空时才触发更新
  // 对于 MaObjectForm，我们只在用户真正修改数据时才触发更新
}

/**
 * 监听props.modelValue的变化
 * 当外部值变化时，更新内部itemData
 * 参考 MaChildrenForm 的逻辑：只有当值真正变化时才更新
 */
watch(() => props.modelValue, (newVal) => {
  if (newVal && typeof newVal === 'object' && JSON.stringify(newVal) !== JSON.stringify(itemData.value)) {
    itemData.value = { ...initDefaultValue(), ...newVal }
  } else if (!newVal || (typeof newVal === 'object' && Object.keys(newVal).length === 0)) {
    // 如果外部传入空对象，只有当内部数据不为空时才重置
    // 如果内部数据已经是空对象，就不需要重置，避免递归更新
    const currentKeys = Object.keys(itemData.value)
    if (currentKeys.length > 0) {
      const defaultValue = initDefaultValue()
      // 只有当默认值与当前值不同时才更新
      if (JSON.stringify(defaultValue) !== JSON.stringify(itemData.value)) {
        itemData.value = defaultValue
        updateValue()
      }
    }
  }
}, { deep: true })

/**
 * 更新指定字段的值
 * @param field - 字段名
 * @param value - 新的值
 */
const updateField = (field: string, value: any) => {
  itemData.value[field] = value
  updateValue()
}

/**
 * 根据formType获取对应的组件
 * @param formType - 表单类型
 */
const getComponentByFormType = (formType: string) => {
  const componentMap: Record<string, string> = {
    'input': 'el-input',
    'select': 'el-select',
    'date': 'el-date-picker',
    'datetime': 'el-date-picker',
    'textarea': 'el-input',
    'number': 'el-input',
    'editor': 'ma-editor',
    'remote-select': 'ma-remote-select'
  }

  return componentMap[formType] || 'el-input'
}

/**
 * 获取组件的属性
 * @param item - 表单项配置
 */
const getComponentProps = (item: ChildFormItem) => {
  const props: Record<string, any> = {
    placeholder: item.placeholder || `请输入${item.title}`
  }

  // 根据不同的表单类型设置不同的属性
  switch (item.formType) {
    case 'textarea':
      props.type = 'textarea'
      if (item.autoSize) {
        props.autosize = item.autoSize
      }
      break
    case 'select':
      // 处理字典数据
      if (item.dict && item.dict.data) {
        props.options = item.dict.data
      }
      props.filterable = true
      break
    case 'date':
      props.type = item.showTime ? 'datetime' : 'date'
      if (item.dateFormat) {
        props.format = item.dateFormat
      }
      if (item.showTime !== undefined) {
        props['show-time'] = item.showTime
      }
      break
    case 'datetime':
      props.type = 'datetime'
      if (item.dateFormat) {
        props.format = item.dateFormat
      }
      if (item.showTime !== undefined) {
        props['show-time'] = item.showTime
      }
      break
    case 'number':
      if (item.min !== undefined) props.min = item.min
      if (item.max !== undefined) props.max = item.max
      if (item.step !== undefined) props.step = item.step
      break
    case 'editor':
      if (item.height !== undefined) props.height = item.height
      if (item.min_height !== undefined) props.min_height = item.min_height
      if (item.width !== undefined) props.width = item.width
      if (item.menubar !== undefined) props.menubar = item.menubar
      if (item.plugins !== undefined) props.plugins = item.plugins
      if (item.toolbar !== undefined) props.toolbar = item.toolbar
      break
    case 'remote-select':
      if (item.api !== undefined) props.api = item.api
      if (item.url !== undefined) props.url = item.url
      if (item.axiosConfig !== undefined) props.axiosConfig = item.axiosConfig
      if (item.dataHandle !== undefined) props.dataHandle = item.dataHandle
      if (item.multiple !== undefined) props.multiple = item.multiple
      if (item.filterable !== undefined) props.filterable = item.filterable
      break
  }

  // 添加其他自定义属性
  Object.keys(item).forEach(key => {
    if (!['title', 'dataIndex', 'formType', 'dict', 'commonRules', 'addDefaultValue', 'labelWidth', 'width'].includes(key)) {
      props[key] = item[key]
    }
  })

  return props
}

/**
 * 渲染基于配置的表单项
 * @param item - 表单项配置
 */
const renderConfigItem = (item: ChildFormItem) => {
  return defineComponent({
    setup() {
      const component = getComponentByFormType(item.formType)
      const componentProps = getComponentProps(item)

      // 处理值绑定
      const modelValue = computed({
        get: () => {
          return itemData.value[item.dataIndex]
        },
        set: (val) => {
          updateField(item.dataIndex, val)
        }
      })

      return () => {
        // 获取标签宽度
        const labelWidth = item.labelWidth || props.labelWidth || '120px'

        // 获取表单组件宽度
        let componentWidth
        if (item.width !== undefined) {
          if (typeof item.width === 'number') {
            componentWidth = `${item.width}px`
          } else {
            componentWidth = item.width
          }
        } else {
          componentWidth = props.itemWidth || '100%'
        }

        // 渲染内容
        let content

        // 控件通用属性
        const controlProps = {
          modelValue: modelValue.value,
          'onUpdate:modelValue': (val: any) => {
            modelValue.value = val
          },
          placeholder: componentProps.placeholder,
          clearable: true,
          ...componentProps
        }

        if (item.formType === 'select' && item.dict && item.dict.data) {
          const options = item.dict.data.map((opt: any) => {
            const labelKey = item.dict?.props?.label || 'label'
            const valueKey = item.dict?.props?.value || 'value'

            return {
              label: opt[labelKey],
              value: opt[valueKey]
            }
          })

          content = h(ElSelect, controlProps, () => options.map(opt =>
            h(ElOption, {
              key: opt.value,
              label: opt.label,
              value: opt.value
            })
          ))
        } else if (component === 'ma-editor') {
          content = h(MaEditor, {
            ...controlProps,
            height: componentProps.height || 400,
            min_height: componentProps.min_height,
            width: componentProps.width,
            menubar: componentProps.menubar,
            plugins: componentProps.plugins,
            toolbar: componentProps.toolbar
          })
        } else if (component === 'ma-remote-select') {
          content = h(MaRemoteSelect, {
            ...controlProps,
            api: componentProps.api,
            url: componentProps.url,
            axiosConfig: componentProps.axiosConfig,
            dataHandle: componentProps.dataHandle,
            multiple: componentProps.multiple,
            filterable: componentProps.filterable
          })
        } else if (component === 'el-input' && componentProps.type === 'textarea') {
          content = h(ElInput, {
            ...controlProps,
            type: 'textarea',
            autosize: componentProps.autosize
          })
        } else if (component === 'el-input-number') {
          content = h(ElInput, {
            ...controlProps,
            type: 'number',
            autosize: componentProps.autosize
          })
        } else if (component === 'el-date-picker') {
          content = h(ElDatePicker, {
            ...controlProps,
            type: componentProps.type,
            format: componentProps.format,
            'value-format': componentProps.format || (componentProps.type === 'datetime' ? 'YYYY-MM-DD HH:mm:ss' : 'YYYY-MM-DD'),
            'show-time': componentProps['show-time'] !== undefined ? componentProps['show-time'] : (componentProps.type === 'datetime')
          })
        } else if (item.render && typeof item.render === 'function') {
          const CustomComponent = item.render()
          content = h(CustomComponent, {
            ...controlProps,
            ...(item.renderProps || {})
          })
        } else {
          content = h(ElInput, {
            ...controlProps,
            type: componentProps.type,
            autosize: componentProps.autosize
          })
        }

        // 返回完整的字段
        return h('div', {
          class: 'ma-object-form-field',
          style: {
            display: 'flex',
            flexDirection: 'row',
            alignItems: 'flex-start',
            marginBottom: '16px',
            width: '100%'
          }
        }, [
          h('div', {
            class: 'ma-object-form-field-label',
            style: {
              fontSize: '14px',
              color: '#606266',
              fontWeight: '500',
              width: labelWidth,
              textAlign: 'right',
              flexShrink: '0',
              lineHeight: '32px',
              paddingRight: '12px'
            }
          }, item.title),
          h('div', {
            class: 'ma-object-form-field-content',
            style: {
              width: componentWidth,
              boxSizing: 'border-box' as const,
              maxWidth: '100%'
            }
          }, [content])
        ])
      }
    }
  })
}

// 暴露组件方法
defineExpose({
  updateField,
  getData: () => itemData.value
})
</script>

<template>
  <div class="ma-object-form" :style="{ backgroundColor: settingStore.colorMode === 'dark' ? '#141414' : '#ffffff' }">
    <div class="ma-object-form-content">
      <component
        v-for="(item, index) in fieldList"
        :key="index"
        :is="renderConfigItem(item)"
      />
    </div>
  </div>
</template>

<style scoped>
.ma-object-form {
  width: 100%;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #ebeef5;
}

.ma-object-form-content {
  display: flex;
  flex-direction: column;
  gap: 0;
  width: 100%;
}

/* 确保表单控件能够正确应用宽度 */
.ma-object-form-field-content {
  display: block;
}

.ma-object-form-field-content :deep(.el-input),
.ma-object-form-field-content :deep(.el-select),
.ma-object-form-field-content :deep(.el-date-picker),
.ma-object-form-field-content :deep(.el-input-number) {
  width: 100% !important;
}
</style>

