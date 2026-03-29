<i18n lang="yaml">
en:
  searchPlaceholder: "Enter keywords to search"
  loadingText: "Loading..."
zh_CN:
  searchPlaceholder: "请输入关键词搜索"
  loadingText: "加载中..."
zh_TW:
  searchPlaceholder: "請輸入關鍵詞搜索"
  loadingText: "載入中..."
</i18n>

<template>
  <ElSelectV2
    ref="elSelectV2Ref"
    v-bind="$attrs"
    v-model="model"
    :options="options"
    clearable
    :filterable="false"
    @change="handleChange"
  >
    <template #header>
      <div class="search-header">
        <el-input
          v-model="searchInput"
          :placeholder="searchPlaceholder"
          size="small"
          clearable
          @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button :icon="Search" @click="handleSearch" />
          </template>
        </el-input>
      </div>
    </template>
    
    <template v-if="isLoading && options.length === 0" #empty>
      <div class="remote-search-loading">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span class="loading-text">{{ t('loadingText') }}</span>
      </div>
    </template>
    
    <template v-for="(_, name) in $slots" #[name]="scopedData">
      <slot :name="name" v-bind="scopedData" />
    </template>
  </ElSelectV2>
</template>

<script setup lang="ts">
import { ElSelectV2, ElInput, ElButton, ElIcon } from 'element-plus'
import { Search, Loading } from '@element-plus/icons-vue'
import { useMessage } from '@/hooks/useMessage.ts'
import { useLocalTrans } from '@/hooks/useLocalTrans.ts'
import useHttp from '@/hooks/auto-imports/useHttp.ts'

defineOptions({ name: 'MaRemoteSearch' })

const t = useLocalTrans()

const props = defineProps<{
  api?: <T>(...args: T[]) => Promise<T>
  url?: string
  axiosConfig?: {
    autoRequest: boolean
    method?: string
    params?: Record<string, any>
    data?: Record<string, any>
    header?: Record<string, any>
    timeout?: number
  }
  dataHandle?: (response: any) => any[]
  searchKey?: string
  searchPlaceholder?: string
}>()

const emit = defineEmits<{
  (event: 'select-item', value: Record<string, any>): void
  (event: 'change', value: any): void
  (event: 'search', keyword: string): void
}>()

const elSelectV2Ref = ref<any>()
const msg = useMessage()
const model = defineModel<any>()
const options = ref<any[]>([])
const isLoading = ref(false)
const searchInput = ref('')

const searchPlaceholder = computed(() => 
  props.searchPlaceholder || t('searchPlaceholder')
)

function handleChange(value: any) {
  emit('change', value)
  if (!elSelectV2Ref.value) return
  
  const key = elSelectV2Ref.value.valueKey || 'value'
  const selectedItem = options.value.find(item => item[key] === value)
  emit('select-item', selectedItem ?? null)
}

function handleSearch() {
  const keyword = searchInput.value
  request(keyword)
  emit('search', keyword)
}

function processResponseData(res: any): any[] {
  if (props?.dataHandle) {
    const data = props.dataHandle(res)
    if (data && data.length > 0) return data
  }
  
  if (!res?.data) return []
  
  const sourceData = Array.isArray(res.data) ? res.data : res.data?.data
  if (!Array.isArray(sourceData)) return []
  
  try {
    return JSON.parse(JSON.stringify(sourceData))
  } catch {
    return Array.from(sourceData) as any[]
  }
}

async function request(keyword: string = '') {
  if (isLoading.value) return
  
  isLoading.value = true
  
  const params = {
    [props.searchKey || 'keyword']: keyword
  }
  
  try {
    let res: any
    if (props?.api && typeof props.api === 'function') {
      res = await props.api(params)
    } else if (props?.url) {
      const method = useHttp()[props?.axiosConfig?.method ?? 'get']
      res = await method(props?.url, { 
        ...props.axiosConfig, 
        params 
      })
    } else {
      msg.error('MaRemoteSearch 组件未指定 api 或 url')
      return
    }
    options.value = processResponseData(res)
  } catch (err: any) {
    msg.error(err)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  if (props?.axiosConfig?.autoRequest ?? true) {
    request('')
  }
})

defineExpose({
  refresh: () => request(searchInput.value),
  selectRef: elSelectV2Ref,
  clearSearch: () => {
    searchInput.value = ''
    options.value = []
  }
})
</script>

<style scoped lang="scss">
.search-header {
  padding: 8px;
  .el-input {
    width: 100%;
  }
}

.remote-search-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8px;
  color: #909399;
  font-size: 12px;
  
  .loading-text {
    margin-left: 4px;
  }
}
</style>