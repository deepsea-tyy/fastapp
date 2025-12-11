
<script setup lang="ts">
import { ElSelectV2 } from 'element-plus'
import { useMessage } from '@/hooks/useMessage.ts'

defineOptions({ name: 'MaRemoteSelect' })

const props = defineProps<{
  api?: <T>(...args: T[]) => Promise<T>
  url?: string
  axiosConfig?: {
    autoRequest?: boolean
    method?: string
    params?: Record<string, any>
    data?: Record<string, any>
    header?: Record<string, any>
    timeout?: number
    [key: string]: any // 支持其他参数直接传递
  }
  dataHandle?: (response: any) => any[]
}>()

const emit = defineEmits<{
  (event: 'select-item', value: Record<string, any>): void
  (event: 'change', value: any): void
}>()

const elSelectV2Ref = ref<any>()
const msg = useMessage()
const model = defineModel<any>()
const options = ref<any[]>([])

function handleChange(value: any) {
  emit('change', value)
  const key = elSelectV2Ref.value.valueKey
  emit('select-item', options.value.find(item => item[key] === value) ?? null)
}

function getRequestParams() {
  if (!props.axiosConfig) {
    return {}
  }
  
  const config = props.axiosConfig
  const reservedKeys = ['autoRequest', 'method', 'data', 'header', 'timeout', 'params']
  
  // 如果明确指定了 params，直接使用 params
  if (config.params) {
    return config.params
  }
  
  // 否则，将 axiosConfig 中除了保留字段外的其他字段作为 params
  const params: Record<string, any> = {}
  Object.keys(config).forEach(key => {
    if (!reservedKeys.includes(key)) {
      params[key] = config[key]
    }
  })
  
  return params
}

function request() {
  if (props?.api && typeof props.api === 'function') {
    const params = getRequestParams()
    props.api(params).then((res: any) => {
      const data = props?.dataHandle?.(res) ?? res.data
      options.value = Array.isArray(data) ? data : []
    }).catch((err) => {
      msg.error(err)
    })
  }
  else if (props?.url) {
    const method = useHttp()[props?.axiosConfig?.method ?? 'get']
    const requestConfig: any = {}
    
    // 保留原有的配置项
    if (props.axiosConfig?.data) {
      requestConfig.data = props.axiosConfig.data
    }
    if (props.axiosConfig?.header) {
      requestConfig.header = props.axiosConfig.header
    }
    if (props.axiosConfig?.timeout) {
      requestConfig.timeout = props.axiosConfig.timeout
    }
    
    // 处理 params - 直接作为查询参数，不包装
    const params = getRequestParams()
    if (Object.keys(params).length > 0) {
      // 对于 GET 请求，参数应该直接作为查询参数
      if (props.axiosConfig?.method === 'get' || !props.axiosConfig?.method) {
        Object.assign(requestConfig, params)
      } else {
        requestConfig.params = params
      }
    }
    
    method(props?.url, requestConfig).then((res: any) => {
      const data = props?.dataHandle?.(res) ?? res.data
      options.value = Array.isArray(data) ? data : []
    }).catch((err: any) => {
      msg.error(err)
    })
  }
  else {
    msg.error('MaRemoteSelect 组件未指定 api 或 url ')
    console.error('[ma-remote-select]：api() or url error')
  }
}

(props?.axiosConfig?.autoRequest ?? true) && request()

defineExpose({
  refresh: () => request(),
  selectRef: elSelectV2Ref,
})
</script>

<template>
  <ElSelectV2
    ref="elSelectV2Ref"
    v-bind="$attrs"
    v-model="model"
    :options="options"
    clearable
    @change="handleChange"
  >
    <template v-for="(_, name) in $slots" #[name]="scopedData">
      <slot :name="name" v-bind="scopedData" />
    </template>
  </ElSelectV2>
</template>

<style scoped lang="scss">

</style>
