
<i18n lang="yaml">
en:
  searchPlaceholder: Search for icons under this category
  tips: Are you sure you want to delete this data?
  cancelMessage: Deletion operation has been canceled
  errorMessage: An error occurred during the deletion process
  all: All
  image: Image
  video: Video
  audio: Audio
  document: Document
  maxSelect: You can select up to {limit} items.
  select: Select current type
  deselect: Deselect
  view: View
  delete: Delete current item
  cancel: Cancel
  confirm: Confirm
  uploading: Uploading
  uploadSuccess: Upload successful
  uploadFailed: Upload failed
  uploadError: Upload error
  uploadNotConfigured: Upload function not configured
  uploadProcessingError: Upload processing error, please try again later
  imageUpload: Image Upload
  fileUpload: File Upload
  videoUpload: Video Upload
  operationGuide: Operation Guide
  clickDescription: 'Click: Select/deselect resource'
  doubleClickDescription: 'Double-click: Quickly select and confirm'
  rightClickDescription: 'Right-click: Show operation menu (select current type, deselect, view, delete)'
  selectCurrentTypeDescription: 'Select current type: Select all resources of the same type'
  deselectDescription: 'Deselect: Cancel selection of current resource'
zh_CN:
  searchPlaceholder: 搜索此分类下的资源
  tips: 你确定要删除这条数据吗？
  cancelMessage: 删除操作已取消
  errorMessage: 删除过程中发生了错误
  all: 所有
  image: 图片
  video: 视频
  audio: 音频
  document: 文档
  maxSelect: 最多选择{limit}个
  select: 选中当前类型
  deselect: 取消选中
  view: 查看
  delete: 删除当前项
  cancel: 取消
  confirm: 确认
  uploading: 正在上传
  uploadSuccess: 上传成功
  uploadFailed: 上传失败
  uploadError: 上传错误
  uploadNotConfigured: 上传功能未配置
  uploadProcessingError: 上传处理出错，请稍后重试
  imageUpload: 图片上传
  fileUpload: 文件上传
  videoUpload: 视频上传
  operationGuide: 操作说明
  clickDescription: '单击：选择/取消选择资源'
  doubleClickDescription: '双击：快速选择并确认'
  rightClickDescription: '右键：显示操作菜单（选中当前类型、取消选中、查看、删除）'
  selectCurrentTypeDescription: '选中当前类型：选择所有相同类型的资源'
  deselectDescription: '取消选中：取消选择当前资源'

zh_TW:
  searchPlaceholder: 搜索此分類下的資源
  tips: 你確定要刪除這條資料嗎？
  cancelMessage: 刪除操作已取消
  errorMessage: 刪除過程中發生了錯誤
  all: 所有
  image: 圖片
  video: 視頻
  audio: 音頻
  document: 文件
  maxSelect: 最多選擇{limit}個
  select: 選中當前類型
  deselect: 取消選中
  view: 查看
  delete: 刪除當前項
  cancel: 取消
  confirm: 確認
  uploading: 正在上傳
  uploadSuccess: 上傳成功
  uploadFailed: 上傳失敗
  uploadError: 上傳錯誤
  uploadNotConfigured: 上傳功能未配置
  uploadProcessingError: 上傳處理出錯，請稍後重試
  imageUpload: 圖片上傳
  fileUpload: 文件上傳
  videoUpload: 視頻上傳
  operationGuide: 操作說明
  clickDescription: '單擊：選擇/取消選擇資源'
  doubleClickDescription: '雙擊：快速選擇並確認'
  rightClickDescription: '右鍵：顯示操作菜單（選中當前類型、取消選中、查看、刪除）'
  selectCurrentTypeDescription: '選中當前類型：選擇所有相同類型的資源'
  deselectDescription: '取消選中：取消選擇當前資源'
</i18n>

<script setup lang="ts">
import { OverlayScrollbarsComponent } from 'overlayscrollbars-vue'
import { useResourcePanel } from './panel.ts'
import type { ResourcePanelProps } from './type.ts'

defineOptions({ name: 'MaResourcePanel' })

const props = withDefaults(defineProps<ResourcePanelProps>(), {
  multiple: false,
  limit: undefined,
  showAction: true,
  pageSize: 30,
  dbClickConfirm: false,
})
const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'confirm', value: any[]): void
}>()

const modelValue = defineModel<string | string[] | undefined>()

// 使用 composable
const {
  loading,
  resources,
  total,
  selectedKeys,
  fileTypeSelected,
  fileTypes,
  queryParams,
  skeletonNum,
  isUploading,
  uploadProgress,
  uploadFileName,
  resourceStore,
  getResourceList,
  onfileTypesChange,
  getCover,
  getResourceIcon,
  isSelected,
  handleClick,
  handleDbClick,
  executeContextmenu,
  handleFile,
  cancel,
  confirm,
  t,
} = useResourcePanel(props, emit, modelValue)
</script>

<template>
  <div class="ma-resource-panel h-full flex flex-col">
    <!-- 操作说明 -->
    <div class="operation-guide mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
      <div class="flex items-start gap-2">
        <ma-svg-icon name="i-material-symbols:info-outline" :size="20" class="text-blue-600 dark:text-blue-400 mt-0.5 flex-shrink-0" />
        <div class="text-sm text-blue-800 dark:text-blue-200">
          <div class="font-medium mb-1">{{ t('operationGuide') }}：</div>
          <ul class="space-y-1 text-xs">
            <li>• {{ t('clickDescription') }}</li>
            <li>• {{ t('doubleClickDescription') }}</li>
            <li>• {{ t('rightClickDescription') }}</li>
            <li>• {{ t('selectCurrentTypeDescription') }}</li>
            <li>• {{ t('deselectDescription') }}</li>
          </ul>
        </div>
      </div>
    </div>
    
    <div class="flex flex-col justify-between gap-y-1 md:flex-row">
      <div>
        <el-segmented
          v-model="fileTypeSelected"
          :options="fileTypes as any" size="default"
          block
          @change="onfileTypesChange"
        >
          <template #default="{ item }">
            <div class="flex items-center justify-center">
              <ma-svg-icon
                v-if="item?.icon" :name="item!.icon" :size="17"
                class="mr-1 flex items-center justify-center"
              />
              <span>{{ typeof item.label === 'function' ? item.label() : item.label }}</span>
            </div>
          </template>
        </el-segmented>
      </div>

      <div class="flex justify-end">
        <el-input
          v-model="queryParams.origin_name" :placeholder="t('searchPlaceholder')" clearable class="w-full md:w-[180px]" @input="() => {
            getResourceList(queryParams)
          }"
        >
          <template #suffix>
            <ma-svg-icon name="i-material-symbols:search-rounded" :size="20" />
          </template>
        </el-input>
      </div>
    </div>
    <div class="mt-2 min-h-0 flex-1">
      <OverlayScrollbarsComponent
        v-if="loading || resources.length" class="max-h-full"
        :options="{ scrollbars: { autoHide: 'leave', autoHideDelay: 100 } }"
      >
        <div class="flex flex-wrap px-[2px] pt-[2px]">
          <el-space fill wrap :fill-ratio="9">
            <template v-for="resource in resources" :key="resource.id">
              <div
                class="resource-item" :class="{ active: isSelected(resource) }" @click="(e: MouseEvent) => handleClick(resource, e)"
                @dblclick="handleDbClick(resource)" @contextmenu.prevent.stop="(e: MouseEvent) => executeContextmenu(e, resource)"
              >
                <div class="resource-item__cover">
                  <template v-if="getCover(resource)">
                    <el-image :src="getCover(resource)" fit="cover" class="h-full w-full" lazy>
                      <template #error>
                        <div
                          class="relative m-[8px] h-[calc(100%-16px)] w-[calc(100%-16px)] flex items-center justify-center overflow-hidden"
                        >
                          <div class="cursor-default overflow-hidden text-ellipsis whitespace-pre-wrap">
                            {{ resource.origin_name }}
                          </div>
                        </div>
                      </template>
                    </el-image>
                  </template>
                  <template v-else>
                    <div
                      class="relative m-[8px] h-[calc(100%-16px)] w-[calc(100%-16px)] flex flex-col items-center justify-center overflow-hidden"
                    >
                      <ma-svg-icon
                        v-if="getResourceIcon(resource)" :name="getResourceIcon(resource)!" :size="48"
                        class="mb-2 text-gray-500 dark:text-gray-400"
                      />
                      <div class="cursor-default overflow-hidden text-ellipsis whitespace-pre-wrap text-center text-xs">
                        {{ resource.origin_name }}
                      </div>
                    </div>
                  </template>
                </div>
                <div v-if="getCover(resource)" class="resource-item__name cursor-default">
                  {{ resource.origin_name }}
                </div>
                <div class="resource-item__selected">
                  <ma-svg-icon class="resource-item__selected-icon" name="gravity-ui:circle-check-fill" :size="18" />
                </div>
              </div>
            </template>
            <template v-if="resources.length === 0">
              <el-skeleton v-for="i in skeletonNum" :key="i" class="resource-skeleton relative" animated>
                <template #template>
                  <el-skeleton-item class="absolute h-full w-full" variant="rect" />
                </template>
              </el-skeleton>
            </template>
            <div v-for="i in 10" :key="i" class="resource-placeholder" />
          </el-space>
        </div>
      </OverlayScrollbarsComponent>
      <div v-else class="h-full w-full flex flex-1 items-center justify-center">
        <el-empty />
      </div>
    </div>
    <div class="ma-resource-panel__footer flex justify-between pt-2">
      <div class="flex items-center">
        <el-tag
          v-if="props.multiple && props.limit" size="large" class="mr-2"
          :class="{ 'color-[var(--el-color-danger)]': props.limit && selectedKeys.length >= props.limit }"
        >
          {{ selectedKeys.length }}
          <template v-if="props.multiple && props.limit">
            /{{ props.limit }}
          </template>
        </el-tag>
        <el-pagination
          v-model:current-page="queryParams.page" :disabled="loading" :total="total"
          :page-size="queryParams.page_size" background layout="prev, pager, next" :pager-count="5"
          @change="(p: number) => {
            queryParams.page = p
            getResourceList(queryParams)
          }"
        />
      </div>
      <div v-if="props.showAction">
        <slot name="actions">
          <el-button @click="cancel">
            {{ t('cancel') }}
          </el-button>
          <el-button type="primary" @click="confirm">
            {{ t('confirm') }}
          </el-button>
        </slot>
      </div>
    </div>

    <div class="ma-resource-dock">
      <template v-for="btn in resourceStore.getAllButton()">
        <div class="res-app-container">
          <div class="res-app" :class="{ 'uploading': isUploading && uploadFileName }">
            <m-tooltip :text="t(btn.label)">
              <input
                type="file"
                :name="btn.name"
                class="hidden"
                :multiple="!(btn?.uploadConfig?.multiple === false || btn?.uploadConfig?.limit === 1)"
                :accept="btn?.uploadConfig?.accept"
                @change="(e: Event) => handleFile(e, btn)"
                @click.stop="() => {}"
                :disabled="isUploading"
              >
              <ma-svg-icon :name="btn.icon" class="res-app-icon" />
            </m-tooltip>
          </div>
        </div>
      </template>
    </div>
    
    <!-- 上传进度显示 -->
    <div v-if="isUploading" class="upload-progress-overlay">
      <div class="upload-progress-content">
        <div class="upload-progress-header">
          <ma-svg-icon name="solar:video-camera-broken" :size="20" class="mr-2" />
          <span class="font-medium">{{ t('uploading') }}</span>
        </div>
        <div class="upload-progress-filename">{{ uploadFileName }}</div>
        <div class="upload-progress-bar">
          <div class="upload-progress-fill" :style="{ width: `${uploadProgress}%` }"></div>
        </div>
        <div class="upload-progress-percentage">{{ Math.round(uploadProgress) }}%</div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
@use './panel.scss';
</style>
