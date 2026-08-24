<i18n lang="yaml">
en:
  uploadVideo: Upload Video
  deleteVideo: Delete Video
  previewVideo: Preview Video
  uploading: Uploading...
zh_CN:
  uploadVideo: 上传视频
  deleteVideo: 删除视频
  previewVideo: 预览视频
  uploading: 上传中...
zh_TW:
  uploadVideo: 上載影片
  deleteVideo: 刪除影片
  previewVideo: 預覽影片
  uploading: 上傳中...
</i18n>

<script setup lang="tsx">
/**
 * MaUploadVideo Component
 *
 * 单文件视频上传组件，支持上传、预览和删除
 *
 * Features:
 * - 单文件视频上传
 * - 视频文件验证（类型和大小）
 * - 分片上传支持（大文件）
 * - 上传进度显示
 * - 视频预览和删除
 * - 本地化支持
 *
 * @example
 * <ma-upload-video
 *   v-model="videoUrl"
 *   :file-size="100 * 1024 * 1024"
 *   :file-type="['mp4', 'avi', 'mov']"
 * />
 */

import { useLocalTrans } from '@/hooks/useLocalTrans.ts'
import type { UploadUserFile } from 'element-plus'
import { uid } from 'radash'
import { useMessage } from '@/hooks/useMessage.ts'
import { uploadLocal } from '@/utils/uploadLocal.ts'
import { chunkUpload, shouldUseChunkUpload, type ChunkUploadOptions } from '@/utils/chunkUpload.ts'
import { formatFileUrl } from '@/utils/common.ts'
import MaVideoPlayer from '@/components/ma-video-player/index.vue'

defineOptions({ name: 'MaUploadVideo' })

const {
  modelValue = null,
  title = null,
  fileSize = 100 * 1024 * 1024, // 默认100MB
  fileType = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'],
  enableChunkUpload = true, // 是否启用分片上传
  chunkSize = 2 * 1024 * 1024, // 分片大小，默认2MB
  chunkThreshold = 10 * 1024 * 1024, // 分片上传阈值，默认10MB
} = defineProps<{
  modelValue: string | null
  title?: string
  fileSize?: number
  fileType?: string[]
  enableChunkUpload?: boolean
  chunkSize?: number
  chunkThreshold?: number
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: string | null): void
}>()

const msg = useMessage()
const t = useLocalTrans()

const fileList = ref<UploadUserFile[]>([])
const uploadProgress = ref(0) // 上传进度
const isUploading = ref(false) // 是否正在上传

function updateModelValue() {
  emit('update:modelValue', fileList.value[0]?.url || null)
}

function handleSuccess(res: any) {
  const index = fileList.value.findIndex((item: any) => item.response?.data.id === res.data.id)
  if (index !== -1) {
    fileList.value[index].name = res.data.origin_name
    fileList.value[index].url = res.data.url  // 保存原始URL
    fileList.value[index].status = 'success'
  }
  updateModelValue()
  msg.success('视频上传成功')
}

/**
 * 分片上传处理函数
 */
async function handleChunkUpload(options: any) {
  const { file } = options
  const fileId = uid(5)

  // 清空现有文件列表（单文件上传）
  fileList.value = []

  // 添加文件到列表，显示上传中状态
  const uploadFile: UploadUserFile = {
    name: file.name,
    status: 'uploading',
    uid: fileId,
    percentage: 0
  }

  fileList.value.push(uploadFile)
  isUploading.value = true
  uploadProgress.value = 0

  try {
    const chunkOptions: ChunkUploadOptions = {
      file,
      chunkSize,
      onProgress: (progress: number) => {
        uploadProgress.value = progress
        const fileIndex = fileList.value.findIndex(f => f.uid === fileId)
        if (fileIndex !== -1) {
          fileList.value[fileIndex].percentage = progress
        }
      },
      onChunkProgress: (chunkIndex: number, totalChunks: number) => {
        console.log(`分片 ${chunkIndex}/${totalChunks} 上传完成`)
      }
    }

    const result = await chunkUpload(chunkOptions)

    if (result.success && result.url) {
      // 上传成功
      const fileIndex = fileList.value.findIndex(f => f.uid === fileId)
      if (fileIndex !== -1) {
        fileList.value[fileIndex].status = 'success'
        fileList.value[fileIndex].url = result.url  // 保存原始URL
        fileList.value[fileIndex].percentage = 100
      }
      updateModelValue()
      msg.success('视频上传成功')
    } else {
      // 上传失败
      fileList.value = []
      msg.error(result.message || '视频上传失败')
    }
  } catch (error) {
    // 上传出错
    fileList.value = []
    msg.error('视频上传失败')
    console.error('分片上传错误:', error)
  } finally {
    isUploading.value = false
    uploadProgress.value = 0
  }
}

/**
 * 自定义上传函数
 */
async function customUpload(options: any) {
  const { file } = options

  // 单文件上传：清空现有文件
  if (fileList.value.length > 0) {
    fileList.value = []
  }

  // 检查是否应该使用分片上传
  if (enableChunkUpload && shouldUseChunkUpload(file, chunkThreshold)) {
    await handleChunkUpload(options)
  } else {
    // 使用普通上传
    isUploading.value = true
    try {
      return await uploadLocal(options)
    } finally {
      isUploading.value = false
    }
  }
}

function beforeUpload(rawFile: File) {
  let fileExtension = ''
  if (rawFile.name.includes('.')) {
    fileExtension = rawFile.name.slice(rawFile.name.lastIndexOf('.') + 1).toLowerCase()
  }

  const isAllowFile = fileType.some((type: string) => {
    if (rawFile.type.includes(type)) {
      return true
    }
    return !!(fileExtension && fileExtension === type.toLowerCase())
  })

  if (!isAllowFile) {
    msg.error(`只允许上传：${fileType.join(', ')} 格式的视频文件`)
    return false
  }

  if (fileSize < rawFile.size) {
    const sizeMB = (fileSize / 1024 / 1024).toFixed(0)
    msg.error(`视频文件大小不能超过 ${sizeMB}MB`)
    return false
  }

  return true
}

function handleError() {
  msg.error('视频上传失败，请重新上传')
  fileList.value = []
  isUploading.value = false
}

function handleRemove() {
  fileList.value = []
  updateModelValue()
}

// 获取显示用的视频URL
const displayVideoUrl = computed(() => {
  const url = fileList.value[0]?.url
  return url ? formatFileUrl(url) : null
})

watch(
  () => modelValue,
  (val: string | null) => {
    if (!val) {
      fileList.value = []
      return
    }

    // 保存原始URL
    fileList.value = [{
      name: val.split('/').pop() as string,
      url: val,
      status: 'success',
    }]
  },
  { immediate: true },
)
</script>

<template>
  <div class="ma-upload-video-wrapper">
    <!-- 已上传的视频显示 -->
    <div v-if="fileList.length > 0 && !isUploading" class="video-preview-container">
      <div class="video-info">
        <MaVideoPlayer
          v-if="displayVideoUrl"
          :src="displayVideoUrl"
          height="400px"
        />
        <div class="video-name">{{ fileList[0]?.name }}</div>
      </div>
      <div class="video-actions">
        <el-button
          type="danger"
          size="small"
          @click="handleRemove"
        >
          {{ t('deleteVideo') }}
        </el-button>
      </div>
    </div>

    <!-- 上传按钮 -->
    <el-upload
      v-show="fileList.length === 0"
      v-model:file-list="fileList"
      :before-upload="beforeUpload"
      :http-request="customUpload"
      :on-success="handleSuccess"
      :on-error="handleError"
      :show-file-list="false"
      :disabled="isUploading"
      v-bind="$attrs"
      class="upload-container"
    >
      <slot name="default">
        <el-button type="primary" :loading="isUploading">
          {{ isUploading ? t('uploading') : (title ?? t('uploadVideo')) }}
        </el-button>
      </slot>

      <template #tip>
        <div class="pt-1 text-sm text-dark-50 dark-text-gray-3">
          <slot name="tip">
            {{ $attrs?.tip }}
          </slot>
        </div>
      </template>
    </el-upload>

    <!-- 上传进度 -->
    <div v-if="isUploading" class="upload-progress">
      <el-progress :percentage="uploadProgress" :stroke-width="6" />
      <div class="progress-text">{{ uploadProgress }}%</div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.ma-upload-video-wrapper {
  width: 100%;
}

.video-preview-container {
  @apply b-1 b-solid b-gray-3 dark-b-dark-50 rounded-md p-3 bg-gray-50 dark-bg-dark-5;

  .video-info {
    @apply mb-3;

    :deep(.ma-video-player) {
      width: 100%;
      max-height: 400px;
      @apply rounded-md mb-2;
    }

    .video-name {
      @apply text-sm text-gray-6 dark-text-gray-3 truncate;
    }
  }

  .video-actions {
    @apply flex justify-end;
  }
}

.upload-container {
  width: 100%;
}

.upload-progress {
  @apply mt-3;

  .progress-text {
    @apply text-center text-sm text-blue-500 mt-1;
  }
}
</style>