<script setup lang="ts">
import { ref, watch, computed, defineComponent, PropType, h } from 'vue'
import { Delete, Plus } from '@element-plus/icons-vue'
import { ElButton, ElInput, ElSelect, ElOption } from 'element-plus'
import MaEditor from '@/components/ma-editor/index.vue'
import MaUploadImage from '@/components/ma-upload-image/index.vue'
import MaUploadFile from '@/components/ma-upload-file/index.vue'
import MaUploadVideo from '@/components/ma-upload-video/index.vue'
import {formatImagePath} from "@/utils/common.ts";

defineOptions({ name: 'MaChildrenForm' })

// 定义子表单项配置类型
export interface ChildFormItem {
  // 标题/标签
  title: string;
  // 数据索引
  dataIndex: string;
  // 表单类型
  formType: string;
  // 宽度
  width?: number | string;
  // 标签宽度
  labelWidth?: string;
  // 字典配置
  dict?: {
    data: any[];
    translation?: boolean;
    props?: {
      label?: string;
      value?: string;
    }
  };
  // 默认值
  addDefaultValue?: any;
  // 自动大小（用于文本域）
  autoSize?: boolean | { minRows?: number; maxRows?: number };
  // 通用规则
  commonRules?: any[];
  // 占位符
  placeholder?: string;
  // 数字输入框属性
  min?: number;
  max?: number;
  step?: number;
  // 其他可能的属性
  [key: string]: any;
}

// 定义组件的属性
const props = defineProps({
  // 组件的值，类型为数组
  modelValue: {
    type: Array as PropType<any[]>,
    default: () => []
  },
  // 子表单配置项
  options: {
    type: Object,
    default: () => ({
      // 是否显示添加按钮
      showAddButton: true,
      // 添加按钮文本
      addButtonText: '添加项',
      // 是否显示删除按钮
      showDeleteButton: true,
      // 最小项数
      minItems: 1,
      // 最大项数，0表示不限制
      maxItems: 0,
      // 子表单项的布局方式：horizontal(水平) 或 vertical(垂直)
      layout: 'vertical',
      // 子表单项的类名
      itemClass: '',
      // 子表单项的样式
      itemStyle: {},
      // 空行数量
      emptyRow: 0,
      // 子表单项标题
      itemTitle: '选项',
      // 子表单项标签宽度
      itemLabelWidth: '80px',
      // 子表单项表单组件宽度
      itemWidth: '100%'
    })
  },
  // 子表单项配置
  formList: {
    type: Array as PropType<ChildFormItem[]>,
    default: () => []
  },
  // 子表单项的渲染函数（可选，优先级高于formList）
  renderItem: {
    type: Function,
    default: null
  },
  // 新项的默认值
  defaultItemValue: {
    type: Object,
    default: () => ({})
  },
  // 空行数量
  emptyRow: {
    type: Number,
    default: 0
  }
})

// 主题
const settingStore = useSettingStore()

// 定义组件的事件
const emit = defineEmits(['update:modelValue', 'add', 'remove', 'change'])

// 内部数据列表
const itemList = ref(props.modelValue || [])

// 初始化默认值
const initDefaultValue = () => {
  const defaultValue = { ...props.defaultItemValue }

  // 如果有formList配置，则根据formList中的addDefaultValue设置默认值
  if (props.formList && props.formList.length > 0) {
    props.formList.forEach(item => {
      if (item.addDefaultValue !== undefined) {
        defaultValue[item.dataIndex] = item.addDefaultValue
      }
    })
  }

  return defaultValue
}

/**
 * 更新组件值
 * 触发update:modelValue事件，将当前itemList传递给父组件
 */
const updateValue = () => {
  emit('update:modelValue', itemList.value)
  emit('change', itemList.value)
}

// 初始化空行
const initEmptyRows = () => {
  if (itemList.value.length === 0 && props.options.emptyRow > 0) {
    for (let i = 0; i < props.options.emptyRow; i++) {
      const defaultValue = initDefaultValue()
      itemList.value.push(defaultValue)
    }
    updateValue()
  }
}

// 初始化
initEmptyRows()

/**
 * 添加新项
 * 在列表中添加一个新的项
 */
const addItem = () => {
  // 检查是否达到最大项数限制
  if (props.options.maxItems > 0 && itemList.value.length >= props.options.maxItems) {
    return
  }

  // 添加新项
  itemList.value.push(initDefaultValue())
  updateValue()
  emit('add', itemList.value.length - 1, itemList.value)
}

/**
 * 删除指定索引的项
 * @param index - 要删除的项索引
 */
const removeItem = (index: number) => {
  // 检查是否达到最小项数限制
  if (itemList.value.length <= props.options.minItems) {
    return
  }

  // 删除项
  itemList.value.splice(index, 1)
  updateValue()
  emit('remove', index, itemList.value)
}

/**
 * 监听props.modelValue的变化
 * 当外部值变化时，更新内部itemList
 */
watch(() => props.modelValue, (newVal) => {
  if (newVal && JSON.stringify(newVal) !== JSON.stringify(itemList.value)) {
    itemList.value = newVal
    // 如果数组为空，初始化空行
    initEmptyRows()
  }
}, { deep: true })

/**
 * 更新指定索引的项
 * @param index - 要更新的项索引
 * @param field - 字段名
 * @param value - 新的值
 */
const updateItemField = (index: number, field: string, value: any) => {
  if (itemList.value[index]) {
    itemList.value[index][field] = value
    updateValue()
  }
}

/**
 * 更新整个项
 * @param index - 要更新的项索引
 * @param value - 新的值
 */
const updateItem = (index: number, value: any) => {
  itemList.value[index] = value
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
    'radio': 'el-radio-group',
    'checkbox': 'el-checkbox-group',
    'switch': 'el-switch',
    'date': 'el-date-picker',
    'time': 'el-time-picker',
    'datetime': 'el-date-picker',
    'textarea': 'el-input',
    'number': 'el-input-number',
    'slider': 'el-slider',
    'rate': 'el-rate',
    'color': 'el-color-picker',
    'cascader': 'el-cascader',
    'upload': 'ma-upload-image',
    'uploadFile': 'ma-upload-file',
    'uploadVideo': 'ma-upload-video',
    'editor': 'ma-editor',
    'tree': 'el-tree-select',
    'transfer': 'el-transfer'
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
      // 添加filterable属性
      props.filterable = true
      break
    case 'date':
      props.type = 'date'
      break
    case 'datetime':
      props.type = 'datetime'
      break
    case 'number':
      if (item.min !== undefined) props.min = item.min
      if (item.max !== undefined) props.max = item.max
      if (item.step !== undefined) props.step = item.step
      break
    case 'editor':
      // 富文本编辑器属性
      if (item.height !== undefined) props.height = item.height
      if (item.min_height !== undefined) props.min_height = item.min_height
      if (item.width !== undefined) props.width = item.width
      if (item.menubar !== undefined) props.menubar = item.menubar
      if (item.plugins !== undefined) props.plugins = item.plugins
      if (item.toolbar !== undefined) props.toolbar = item.toolbar
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

const renderCache = new WeakMap()

/**
 * 渲染基于配置的子表单项
 * @param rowData - 行数据
 * @param rowIndex - 行索引
 */
const renderConfigItem = (rowData: any, rowIndex: number) => {
  if (renderCache.has(rowData)) {
    return renderCache.get(rowData)
  }
  const result =  props.formList.map((item, colIndex) => {
    return defineComponent({
      setup() {
        const component = getComponentByFormType(item.formType)
        const componentProps = getComponentProps(item)

        // 处理值绑定
        const modelValue = computed({
          get: () => {
            return rowData[item.dataIndex]
          },
          set: (val) => {
            updateItemField(rowIndex, item.dataIndex, val)
          }
        })

        return () => {
          // 获取标签宽度：优先使用item的labelWidth，其次使用options的itemLabelWidth
          const labelWidth = item.labelWidth || props.options.itemLabelWidth || '80px'

          // 获取表单组件宽度：优先使用item的width，其次使用options.itemWidth
          let componentWidth
          if (item.width !== undefined) {
            // 如果是数字类型，添加px单位
            if (typeof item.width === 'number') {
              componentWidth = `${item.width}px`
            } else {
              // 字符串类型直接使用
              componentWidth = item.width
            }
          } else {
            // 使用全局配置
            componentWidth = props.options.itemWidth || '100%'
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
            // 处理选择器
            const options = item.dict.data.map((opt: any) => {
              const labelKey = item.dict?.props?.label || 'label'
              const valueKey = item.dict?.props?.value || 'value'

              return {
                label: opt[labelKey],
                value: opt[valueKey]
              }
            })

            // 渲染选择器
            content = h(ElSelect, controlProps, () => options.map(opt =>
              h(ElOption, {
                key: opt.value,
                label: opt.label,
                value: opt.value
              })
            ))
          } else if (component === 'ma-editor') {
            // 渲染富文本编辑器 - 只传递必要的属性
            const editorProps = {
              height: componentProps.height || 400,
              language: componentProps.language || 'zh_CN',
              toolbar: componentProps.toolbar
            }
            content = h(MaEditor, {
              ...editorProps,
              modelValue: modelValue.value,
              'onUpdate:modelValue': (val: any) => {
                modelValue.value = val
              }
            })
          } else if (component === 'ma-upload-image') {
            // 渲染图片上传组件
            content = h(MaUploadImage, {
              ...controlProps,
              modelValue: formatImagePath(modelValue.value),
              'onUpdate:modelValue': (val: any) => {
                modelValue.value = val
              }
            })
          } else if (component === 'ma-upload-file') {
            // 渲染文件上传组件
            content = h(MaUploadFile, {
              ...controlProps,
              modelValue: formatImagePath(modelValue.value),
              'onUpdate:modelValue': (val: any) => {
                modelValue.value = val
              }
            })
          } else if (component === 'ma-upload-video') {
            // 渲染视频上传组件
            content = h(MaUploadVideo, {
              ...controlProps,
              modelValue: formatImagePath(modelValue.value),
              'onUpdate:modelValue': (val: any) => {
                modelValue.value = val
              }
            })
          } else if (component === 'el-input' && componentProps.type === 'textarea') {
            // 渲染文本域
            content = h(ElInput, {
              ...controlProps,
              type: 'textarea',
              autosize: componentProps.autosize
            })
          } else if (component === 'el-input-number') {
            // 渲染 number
            content = h(ElInput, {
              ...controlProps,
              type: 'number',
              autosize: componentProps.autosize
            })
          } else {
            // 渲染文本框
            content = h(ElInput, {
              ...controlProps,
              type: componentProps.type,
              autosize: componentProps.autosize
            })
          }

          // 返回完整的字段
          return h('div', {
            class: 'ma-children-form-field',
            style: {
              display: 'flex',
              flexDirection: 'row',
              alignItems: 'flex-start',
              marginBottom: '8px',
              width: '100%'
            }
          }, [
            h('div', {
              class: 'ma-children-form-field-label',
              style: {
                fontSize: '14px',
                color: '#606266',
                fontWeight: '500',
                width: labelWidth,
                textAlign: 'right',
                flexShrink: '0',
                lineHeight: '32px'
              }
            }, item.title),
            h('div', {
              class: 'ma-children-form-field-content',
              style: {
                paddingLeft: '12px',
                width: componentWidth,
                boxSizing: 'border-box' as const,
                maxWidth: '100%'
              }
            }, [content])
          ])
        }
      }
    })
  })
  renderCache.set(rowData, result)
  return result

}

// 暴露组件方法
defineExpose({
  addItem,
  removeItem,
  updateItem,
  updateItemField,
  getItems: () => itemList.value
})
</script>

<template>
  <div class="ma-children-form" :style="{ backgroundColor: settingStore.colorMode === 'dark' ? '#141414' : '#ffffff' }">
    <!-- 子表单项列表 -->
    <div
      v-for="(item, index) in itemList"
      :key="index"
      :class="[
        'ma-children-form-item',
        props.options.itemClass,
        settingStore.colorMode === 'dark' ? 'ma-children-form-item-dark' : 'ma-children-form-item-light'
      ]"
      :style="props.options.itemStyle"
    >
      <!-- 标题行 -->
      <div class="ma-children-form-item-header" :class="[settingStore.colorMode === 'dark' ? 'ma-children-form-item-header-dark' : 'ma-children-form-item-header-light']">
        <div class="ma-children-form-item-title">
          {{ props.options.itemTitle || '选项' }} - {{ index + 1 }}
        </div>

        <!-- 操作按钮 -->
        <div class="ma-children-form-item-action">
          <!-- 添加按钮，只在最后一项显示 -->
          <el-button
            v-if="props.options.showAddButton && index === itemList.length - 1"
            type="primary"
            plain
            circle
            @click="addItem"
            :disabled="props.options.maxItems > 0 && itemList.length >= props.options.maxItems"
          >
            <el-icon><Plus /></el-icon>
          </el-button>

          <!-- 删除按钮 -->
          <el-button
            v-if="props.options.showDeleteButton"
            type="danger"
            plain
            circle
            @click="removeItem(index)"
            :disabled="itemList.length <= props.options.minItems"
          >
            <el-icon><Delete /></el-icon>
          </el-button>
        </div>
      </div>

      <!-- 内容区域 -->
      <div class="ma-children-form-item-content">
        <template v-if="props.renderItem">
          <component
            :is="props.renderItem(item, index, updateItem)"
          />
        </template>
        <template v-else-if="props.formList && props.formList.length > 0">
          <div class="ma-children-form-fields">
            <component
              v-for="(field, fieldIndex) in renderConfigItem(item, index)"
              :key="fieldIndex"
              :is="field"
            />
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>
.ma-children-form {
  width: 100%;
}

.ma-children-form-item {
  display: flex;
  flex-direction: column;
  margin-bottom: 16px;
  border-radius: 8px;
  padding: 16px;
  position: relative;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

  .ma-children-form-item-light {
    border: 1px solid #ebeef5;
}

.ma-children-form-item-dark {
  border: 1px solid #4c4d4f;
}

.ma-children-form-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 12px;
  margin-bottom: 12px;
}

.ma-children-form-item-header-light {
  border-bottom: 1px solid #ebeef5;
}

.ma-children-form-item-header-dark {
  border-bottom: 1px solid #4c4d4f;
}

.ma-children-form-item-title {
  font-size: 14px;
  font-weight: 500;
}

.ma-children-form-item-title-light {
  color: #303133;
}

.ma-children-form-item-title-dark {
  color: #cfd3dc;
}

.ma-children-form-item-action {
  display: flex;
}

.ma-children-form-item-content {
  width: 100%;
}

.ma-children-form-fields {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

/* 确保表单控件能够正确应用宽度 */
.ma-children-form-field-content {
  display: block;
}

.ma-children-form-field-content :deep(.el-input),
.ma-children-form-field-content :deep(.el-select),
.ma-children-form-field-content :deep(.el-date-picker),
.ma-children-form-field-content :deep(.el-input-number) {
  width: 100% !important;
}

.mr-1 {
  margin-right: 4px;
}
</style>
