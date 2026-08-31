
<i18n lang="yaml">
en:
  searchPlaceholder: Search for icons under this category
  tips: Are you sure you want to delete this data?
  batchDeleteTips: Are you sure you want to delete {count} items?
  errorMessage: An error occurred during the deletion process
  all: All
  image: Image
  video: Video
  audio: Audio
  document: Document
  maxSelect: You can select up to {limit} items.
  view: View
  play: Play
  delete: Delete
  selectAll: Select all
  clearSelection: Clear selection
  selectedCount: '{count} selected'
  cancel: Cancel
  confirm: Confirm
  confirmTitle: System prompts
  uploading: Uploading
  uploadSuccess: Upload successful
  uploadFailed: Upload failed
  uploadNotConfigured: Upload function not configured
  fileLimit: You can select up to {limit} files
  imageUpload: Image Upload
  fileUpload: File Upload
  videoUpload: Video Upload
  audioUpload: Audio Upload
  dropToUpload: Release to upload
  noUrl: Resource URL does not exist
  playFailed: Playback failed
  videoPreview: Video preview
  textPreview: Text preview
zh_CN:
  searchPlaceholder: 搜索此分类下的资源
  tips: 你确定要删除这条数据吗？
  batchDeleteTips: 确定要删除选中的 {count} 项吗？
  errorMessage: 删除过程中发生了错误
  all: 所有
  image: 图片
  video: 视频
  audio: 音频
  document: 文档
  maxSelect: 最多选择{limit}个
  view: 查看
  play: 播放
  delete: 删除
  selectAll: 全选
  clearSelection: 清空
  selectedCount: 已选 {count} 项
  cancel: 取消
  confirm: 确认
  confirmTitle: 系统提示
  uploading: 正在上传
  uploadSuccess: 上传成功
  uploadFailed: 上传失败
  uploadNotConfigured: 上传功能未配置
  fileLimit: 最多只能选择 {limit} 个文件
  imageUpload: 图片上传
  fileUpload: 文件上传
  videoUpload: 视频上传
  audioUpload: 音频上传
  dropToUpload: 松开以上传
  noUrl: 资源地址不存在
  playFailed: 播放失败
  videoPreview: 视频预览
  textPreview: 文本预览
zh_TW:
  searchPlaceholder: 搜索此分類下的資源
  tips: 你確定要刪除這條資料嗎？
  batchDeleteTips: 確定要刪除選中的 {count} 項嗎？
  errorMessage: 刪除過程中發生了錯誤
  all: 所有
  image: 圖片
  video: 視頻
  audio: 音頻
  document: 文件
  maxSelect: 最多選擇{limit}個
  view: 查看
  play: 播放
  delete: 刪除
  selectAll: 全選
  clearSelection: 清空
  selectedCount: 已選 {count} 項
  cancel: 取消
  confirm: 確認
  confirmTitle: 系統提示
  uploading: 正在上傳
  uploadSuccess: 上傳成功
  uploadFailed: 上傳失敗
  uploadNotConfigured: 上傳功能未配置
  fileLimit: 最多只能選擇 {limit} 個文件
  imageUpload: 圖片上傳
  fileUpload: 文件上傳
  videoUpload: 視頻上傳
  audioUpload: 音頻上傳
  dropToUpload: 鬆開以上傳
  noUrl: 資源地址不存在
  playFailed: 播放失敗
  videoPreview: 視頻預覽
  textPreview: 文本預覽
</i18n>

<script setup lang="ts">
import { OverlayScrollbarsComponent } from 'overlayscrollbars-vue'
import { useResourcePanel } from './panel.ts'
import type { ResourcePanelProps } from './type.ts'
import { useI18n } from 'vue-i18n'

defineOptions({ name: 'MaResourcePanel' })

const props = withDefaults(defineProps<ResourcePanelProps>(), {
  multiple: false,
  limit: undefined,
  showAction: true,
  pageSize: 40,
})
const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'confirm', value: any[]): void
}>()

const modelValue = defineModel<string | string[] | undefined>()

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
  isDragging,
  playingAudio,
  audioPaused,
  hasSelection,
  canPreviewSelection,
  resourceStore,
  getResourceList,
  onfileTypesChange,
  getCover,
  getResourceIcon,
  isSelected,
  isAudio,
  isVideo,
  isPlayingAudio,
  canPreview,
  handleClick,
  handleDbClick,
  handleFile,
  handleDragEnter,
  handleDragOver,
  handleDragLeave,
  handleDrop,
  selectAllPage,
  clearSelected,
  previewResource,
  previewSelected,
  batchDeleteSelected,
  onDel,
  toggleAudio,
  stopAudio,
  cancel,
  confirm,
} = useResourcePanel(props, emit, modelValue)

const { t } = useI18n({ useScope: 'local' })

const scrollOptions = { scrollbars: { autoHide: 'leave', autoHideDelay: 100 } }

function onPageChange(p: number) {
  queryParams.page = p
  getResourceList(queryParams)
}
</script>

<template>
  <div class="ma-resource-panel">
    <header class="ma-resource-panel__head">
      <div class="ma-resource-panel__filters">
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
        <el-input
          v-model="queryParams.origin_name"
          :placeholder="t('searchPlaceholder')"
          clearable
          @input="getResourceList(queryParams)"
        >
          <template #suffix>
            <ma-svg-icon name="i-material-symbols:search-rounded" :size="20" />
          </template>
        </el-input>
      </div>

      <div class="resource-toolbar">
        <div class="resource-toolbar__actions">
          <el-button size="small" @click="selectAllPage">
            {{ t('selectAll') }}
          </el-button>
          <el-button size="small" :disabled="!hasSelection" @click="clearSelected">
            {{ t('clearSelection') }}
          </el-button>
          <el-button size="small" :disabled="!canPreviewSelection" @click="previewSelected">
            {{ t('view') }}
          </el-button>
          <el-button size="small" type="danger" :disabled="!hasSelection" @click="batchDeleteSelected">
            {{ t('delete') }}<template v-if="hasSelection"> ({{ selectedKeys.length }})</template>
          </el-button>
        </div>
        <span v-if="hasSelection" class="resource-toolbar__count">
          {{ t('selectedCount', { count: selectedKeys.length }) }}
        </span>
      </div>
    </header>

    <main
      class="ma-resource-panel__body"
      @dragenter="handleDragEnter"
      @dragover="handleDragOver"
      @dragleave="handleDragLeave"
      @drop="handleDrop"
    >
      <div v-if="isDragging" class="resource-drop-overlay">
        <ma-svg-icon name="solar:upload-square-broken" :size="40" class="mb-2" />
        <span>{{ t('dropToUpload') }}</span>
      </div>

      <OverlayScrollbarsComponent
        v-if="loading || resources.length" class="h-full"
        :options="scrollOptions"
      >
        <div class="flex flex-wrap px-[2px] pt-[2px]">
          <el-space fill wrap :fill-ratio="9">
            <template v-for="resource in resources" :key="resource.id">
              <div
                class="resource-item"
                :class="{
                  active: isSelected(resource),
                  playing: isPlayingAudio(resource),
                }"
                @click="handleClick(resource)"
                @dblclick="handleDbClick(resource)"
              >
                <div class="resource-item__cover">
                  <el-image
                    v-if="getCover(resource)"
                    :src="getCover(resource)"
                    fit="cover"
                    class="resource-item__cover-image"
                    lazy
                  >
                    <template #error>
                      <div class="resource-item__fallback">
                        {{ resource.origin_name }}
                      </div>
                    </template>
                  </el-image>
                  <div v-else class="resource-item__fallback resource-item__fallback--icon">
                    <ma-svg-icon
                      v-if="getResourceIcon(resource)" :name="getResourceIcon(resource)!" :size="48"
                    />
                    <span>{{ resource.origin_name }}</span>
                  </div>
                </div>
                <div v-if="getCover(resource)" class="resource-item__name cursor-default">
                  {{ resource.origin_name }}
                </div>
                <div class="resource-item__actions" @click.stop>
                  <button
                    v-if="isAudio(resource)"
                    class="resource-item__action-btn"
                    :title="t('play')"
                    @click="toggleAudio(resource)"
                  >
                    <ma-svg-icon
                      :name="isPlayingAudio(resource) ? 'ri:pause-fill' : 'ri:play-fill'"
                      :size="14"
                    />
                  </button>
                  <button
                    v-if="isVideo(resource)"
                    class="resource-item__action-btn"
                    :title="t('play')"
                    @click="previewResource(resource)"
                  >
                    <ma-svg-icon name="ri:play-fill" :size="14" />
                  </button>
                  <button
                    v-if="canPreview(resource) && !isAudio(resource) && !isVideo(resource)"
                    class="resource-item__action-btn"
                    :title="t('view')"
                    @click="previewResource(resource)"
                  >
                    <ma-svg-icon name="i-ri:search-eye-line" :size="14" />
                  </button>
                  <button
                    v-if="resource.id != undefined"
                    class="resource-item__action-btn resource-item__action-btn--danger"
                    :title="t('delete')"
                    @click="onDel(resource.id!)"
                  >
                    <ma-svg-icon name="i-material-symbols:delete-outline" :size="14" />
                  </button>
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
      <div v-else class="ma-resource-panel__empty">
        <el-empty />
      </div>
    </main>

    <div v-if="playingAudio" class="audio-mini-bar">
      <button class="audio-mini-bar__btn" @click="playingAudio && toggleAudio(playingAudio)">
        <ma-svg-icon :name="audioPaused ? 'ri:play-fill' : 'ri:pause-fill'" :size="18" />
      </button>
      <span class="audio-mini-bar__name">{{ playingAudio.origin_name }}</span>
      <button class="audio-mini-bar__close" @click="stopAudio">
        <ma-svg-icon name="ri:close-line" :size="16" />
      </button>
    </div>

    <footer class="ma-resource-panel__foot">
      <div class="ma-resource-panel__foot-bar">
        <div class="ma-resource-panel__foot-pagination">
          <el-tag
            v-if="multiple && limit" size="large"
            :class="{ 'color-[var(--el-color-danger)]': limit && selectedKeys.length >= limit }"
          >
            {{ selectedKeys.length }}/{{ limit }}
          </el-tag>
          <el-pagination
            v-model:current-page="queryParams.page" :disabled="loading" :total="total"
            :page-size="queryParams.page_size" background layout="prev, pager, next" :pager-count="5"
            @change="onPageChange"
          />
        </div>

        <div class="ma-resource-dock">
          <div v-for="btn in resourceStore.getAllButton()" :key="btn.name" class="res-app-container">
            <label class="res-app" :class="{ uploading: isUploading && uploadFileName }">
              <input
                type="file"
                class="hidden"
                :multiple="!(btn?.uploadConfig?.multiple === false || btn?.uploadConfig?.limit === 1)"
                :accept="btn?.uploadConfig?.accept"
                :disabled="isUploading"
                @change="(e: Event) => handleFile(e, btn)"
              >
              <m-tooltip :text="t(btn.label)">
                <ma-svg-icon :name="btn.icon" class="res-app-icon" />
              </m-tooltip>
            </label>
          </div>
        </div>

        <div v-if="showAction" class="ma-resource-panel__foot-buttons">
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
    </footer>

    <div v-if="isUploading" class="upload-progress-overlay">
      <div class="upload-progress-content">
        <div class="upload-progress-header">
          <ma-svg-icon name="solar:upload-square-broken" :size="20" class="mr-2" />
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
