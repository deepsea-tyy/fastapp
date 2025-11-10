// utils/tools.ts
import type { ConfigItem } from '$/ds/system-config/utils/type.ts'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'
import MaDictRadio from '@/components/ma-dict-picker/ma-dict-radio.vue'
import MaKeyValue from '@/components/ma-key-value/index.vue'
import MaUploadImage from '@/components/ma-upload-image/index.vue'
import NmTinyMCE from '@/components/ma-editor/index.vue'

export function buildRenderProps(item: ConfigItem) {
  const isSelect = item.input_type === 'select'
  const renderProps: Record<string, any> = { placeholder: `请输入${item.name}` }

  if (isSelect) {
    try {
      const configData = Array.isArray(item.config_select_data)
        ? item.config_select_data
        : JSON.parse(item.config_select_data || '[]')
      if (Array.isArray(configData)) {
        renderProps.data = configData
      }
    }
    catch (error) {
      console.error(`Invalid JSON format for ${item.key}:`, error)
    }
  }

  return renderProps
}

export function shouldShowDataButton(inputType: string) {
  return ['select', 'radio', 'switch', 'checkbox'].includes(inputType)
}

export function renderInputTypeComponent(inputType: string, item: ConfigItem) {
  switch (inputType) {
    case 'select':
      return <MaDictSelect modelValue={item.value} data={item.config_select_data} onUpdate:modelValue={v => (item.value = v)} />
    case 'radio':
      return <MaDictRadio modelValue={item.value} data={item.config_select_data} onUpdate:modelValue={v => (item.value = v)} />
    case 'switch':
      return (
        <el-switch
          modelValue={item.value}
          active-value={item.config_select_data[0]?.value}
          inactive-value={item.config_select_data[1]?.value}
          onUpdate:modelValue={v => (item.value = v)}
        />
      )
    case 'checkbox':
      return (
        <el-checkbox-group modelValue={item.value} onUpdate:modelValue={v => (item.value = v)}>
          {item.config_select_data.map((option, index) => (
            <el-checkbox key={index} value={option.value}>{option.label}</el-checkbox>
          ))}
        </el-checkbox-group>
      )
    case 'keyValuePair':
      return <MaKeyValue modelValue={item.config_select_data} onUpdate:modelValue={v => (item.config_select_data = v)} />
    case 'imageUpload':
      return <MaUploadImage modelValue={item.value} onUpdate:modelValue={v => (item.value = v)} />
    case 'textarea':
      return <el-input type="textarea" modelValue={item.value} onUpdate:modelValue={v => (item.value = v)} />
    case 'editor':
      return <NmTinyMCE modelValue={item.value} onUpdate:modelValue={v => (item.value = v)} />
    default:
      return <el-input modelValue={item.value} onUpdate:modelValue={v => (item.value = v)} />
  }
}
