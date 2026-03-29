<script setup lang="ts">
import { ref, watch, computed, nextTick } from 'vue'
import { VAceEditor } from 'vue3-ace-editor'
import 'ace-builds/src-noconflict/mode-json'
import 'ace-builds/src-noconflict/theme-dawn'
import 'ace-builds/src-noconflict/theme-github_dark'
import { useColorMode } from '@vueuse/core'
import { useMessage } from '@/hooks/useMessage.ts'

defineOptions({ name: 'MaJsonEditor' })

const props = defineProps<{
  modelValue: any
  type?: 'object' | 'array' // 数据类型：object 或 array
  height?: string // 编辑器高度
}>()

const emit = defineEmits<{
  'update:modelValue': [value: any]
}>()

const color = useColorMode()
const msg = useMessage()
const jsonString = ref('')
const isUpdating = ref(false)

const theme = computed(() => color.value === 'dark' ? 'github_dark' : 'dawn')
const editorHeight = computed(() => props.height || '300px')

// 格式化 JSON
function formatJson(value: any): string {
  if (value === null || value === undefined) {
    return props.type === 'object' ? '{}' : '[]'
  }
  try {
    return JSON.stringify(value, null, 2)
  } catch (error) {
    return String(value)
  }
}

// 初始化 JSON 字符串
function initJsonString() {
  if (isUpdating.value) {
    return
  }
  
  const formatted = formatJson(props.modelValue)
  if (jsonString.value !== formatted) {
    jsonString.value = formatted
  }
}

// 验证并解析 JSON
function parseJson(value: string): any {
  try {
    const parsed = JSON.parse(value)
    
    // 验证类型
    if (props.type === 'object') {
      if (typeof parsed !== 'object' || Array.isArray(parsed)) {
        throw new Error('必须是有效的 JSON 对象')
      }
    } else if (props.type === 'array') {
      if (!Array.isArray(parsed)) {
        throw new Error('必须是有效的 JSON 数组')
      }
    }
    
    return parsed
  } catch (error) {
    throw error
  }
}

// 监听外部值变化
watch(() => props.modelValue, () => {
  initJsonString()
}, { immediate: true, deep: true })

// 监听编辑器内容变化
let validateTimer: ReturnType<typeof setTimeout> | null = null

watch(jsonString, (newValue) => {
  if (isUpdating.value) {
    return
  }
  
  // 清除之前的定时器
  if (validateTimer) {
    clearTimeout(validateTimer)
  }
  
  // 延迟验证，避免输入过程中频繁触发
  validateTimer = setTimeout(() => {
    try {
      const parsed = parseJson(newValue)
      isUpdating.value = true
      emit('update:modelValue', parsed)
      // 格式化输出
      jsonString.value = formatJson(parsed)
      nextTick(() => {
        isUpdating.value = false
      })
    } catch (error) {
      // JSON 格式错误时不更新，但也不阻止用户输入
      // 可以在界面上显示错误提示
    }
    validateTimer = null
  }, 500)
})

// 格式化按钮
function handleFormat() {
  try {
    const parsed = parseJson(jsonString.value)
    jsonString.value = formatJson(parsed)
    msg.success('格式化成功')
  } catch (error: any) {
    msg.error(error.message || 'JSON 格式错误，无法格式化')
  }
}

// 验证按钮
function handleValidate() {
  try {
    parseJson(jsonString.value)
    msg.success('JSON 格式正确')
  } catch (error: any) {
    msg.error(error.message || 'JSON 格式错误')
  }
}
</script>

<template>
  <div class="ma-json-editor">
    <div class="ma-json-editor-toolbar">
      <el-button size="small" @click="handleFormat">格式化</el-button>
      <el-button size="small" @click="handleValidate">验证</el-button>
    </div>
    <VAceEditor
      v-model:value="jsonString"
      lang="json"
      :theme="theme"
      :style="{ height: editorHeight }"
      class="ma-json-editor-content"
    />
  </div>
</template>

<style scoped lang="scss">
.ma-json-editor {
  width: 100%;
  border: 1px solid var(--el-border-color);
  border-radius: 4px;
  overflow: hidden;
}

.ma-json-editor-toolbar {
  display: flex;
  gap: 8px;
  padding: 8px;
  background-color: var(--el-bg-color-page);
  border-bottom: 1px solid var(--el-border-color);
}

.ma-json-editor-content {
  width: 100%;
  font-size: 14px;
}
</style>

