<i18n lang="yaml">
en:
  uploadVideo: Upload Video
zh_CN:
  uploadVideo: 上传视频
zh_TW:
  uploadVideo: 上載影片
</i18n>

<script setup lang="tsx">
/**
 * MaUploadVideo Component
 * 
 * A video upload component with file validation, size limits, and type restrictions.
 * Supports single and multiple file uploads with progress tracking.
 * 
 * Features:
 * - Video file validation (type and size)
 * - Multiple file upload support
 * - File size and type restrictions
 * - Localization support
 * - Customizable upload limits
 * - Integration with local upload utility
 * 
 * @example
 * <ma-upload-video
 *   v-model="videoUrl"
 *   :file-size="50 * 1024 * 1024"
 *   :file-type="['mp4', 'avi']"
 *   :limit="3"
 *   :multiple="true"
 * />
 */

import { useLocalTrans } from '@/hooks/useLocalTrans.ts'
import type { UploadUserFile } from 'element-plus'
import { isArray, uid } from 'radash'
import { useMessage } from '@/hooks/useMessage.ts'
import { uploadLocal } from '@/utils/uploadLocal.ts'
import { chunkUpload, shouldUseChunkUpload, type ChunkUploadOptions } from '@/utils/chunkUpload.ts'

defineOptions({ name: 'MaUploadVideo' })

const {
  modelValue = null,
  title = null,
  fileSize = 100 * 1024 * 1024, // 默认100MB
  fileType = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'],
  limit = 1,
  multiple = false,
  enableChunkUpload = true, // 是否启用分片上传
  chunkSize = 2 * 1024 * 1024, // 分片大小，默认2MB
  chunkThreshold = 10 * 1024 * 1024, // 分片上传阈值，默认10MB
} = defineProps<{
  modelValue: string | string[] | null
  title?: string
  fileSize?: number
  fileType?: string[]
  limit?: number
  multiple?: boolean
  enableChunkUpload?: boolean
  chunkSize?: number
  chunkThreshold?: number
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: string | string[]): void
}>()

const id = uid(5)
const msg = useMessage()
const t = useLocalTrans()

const fileList = ref<UploadUserFile[]>([])
const uploadProgress = ref<Record<string, number>>({}) // 上传进度
const isUploading = ref(false) // 是否正在上传

function updateModelValue() {
  emit(
    'update:modelValue',
    (multiple ? fileList.value.map(file => file.url!) : fileList.value[0]?.url) as string | string[],
  )
}

function handleSuccess(res: any) {
  const index = fileList.value.findIndex((item: any) => item.response?.data.id === res.data.id)
  fileList.value[index].name = res.data.origin_name
  fileList.value[index].url = res.data.url

  updateModelValue()
}

/**
 * 分片上传处理函数
 */
async function handleChunkUpload(options: any) {
  const { file } = options
  const fileId = uid(5)
  
  // 添加文件到列表，显示上传中状态
  const uploadFile: UploadUserFile = {
    name: file.name,
    status: 'uploading',
    uid: fileId,
    percentage: 0
  }
  
  fileList.value.push(uploadFile)
  isUploading.value = true
  
  try {
    const chunkOptions: ChunkUploadOptions = {
      file,
      chunkSize,
      onProgress: (progress: number) => {
        uploadProgress.value[fileId] = progress
        const fileIndex = fileList.value.findIndex(f => f.uid === fileId)
        if (fileIndex !== -1) {
          fileList.value[fileIndex].percentage = progress
        }
      },
      onChunkProgress: (chunkIndex: number, totalChunks: number) => {
        // 可以在这里添加分片级别的进度显示
        console.log(`分片 ${chunkIndex}/${totalChunks} 上传完成`)
      }
    }
    
    const result = await chunkUpload(chunkOptions)
    
    if (result.success && result.url) {
      // 上传成功
      const fileIndex = fileList.value.findIndex(f => f.uid === fileId)
      if (fileIndex !== -1) {
        fileList.value[fileIndex].status = 'success'
        fileList.value[fileIndex].url = result.url
        fileList.value[fileIndex].percentage = 100
      }
      updateModelValue()
      msg.success('视频上传成功')
    } else {
      // 上传失败
      const fileIndex = fileList.value.findIndex(f => f.uid === fileId)
      if (fileIndex !== -1) {
        fileList.value[fileIndex].status = 'fail'
        fileList.value[fileIndex].percentage = 0
      }
      msg.error(result.message || '视频上传失败')
    }
  } catch (error) {
    // 上传出错
    const fileIndex = fileList.value.findIndex(f => f.uid === fileId)
    if (fileIndex !== -1) {
      fileList.value[fileIndex].status = 'fail'
      fileList.value[fileIndex].percentage = 0
    }
    msg.error('视频上传失败')
    console.error('分片上传错误:', error)
  } finally {
    isUploading.value = false
    delete uploadProgress.value[fileId]
  }
}

/**
 * 自定义上传函数
 */
async function customUpload(options: any) {
  const { file } = options
  
  // 检查是否应该使用分片上传
  if (enableChunkUpload && shouldUseChunkUpload(file, chunkThreshold)) {
    await handleChunkUpload(options)
  } else {
    // 使用普通上传
    return uploadLocal(options)
  }
}

function beforeUpload(rawFile: File) {
  let fileExtension = ''
  if (rawFile.name.includes('.')) {
    fileExtension = rawFile.name.slice(rawFile.name.lastIndexOf('.') + 1)
  }

  const isAllowFile = fileType.some((type: string) => {
    if (rawFile.type.includes(type)) {
      return true
    }
    return !!(fileExtension && fileExtension.includes(type))
  })
  if (!isAllowFile) {
    msg.error(`只允许上传：${fileType.join(', ')}`)
    return false
  }
  if (fileSize < rawFile.size) {
    msg.error(`只允许上传${fileSize}字节大小的文件`)
    return false
  }

  return true
}

function handleExceed() {
  msg.error(`当前最多只能上传 ${limit} 个视频文件，请重新选择上传！`)
}

function handleError() {
  msg.error(`视频上传失败，请您重新上传！`)
}

watch(
  () => fileList.value.length,
  (length: number) => {
    const uploadTextDom: HTMLElement | null = document.querySelector(`.ma-upload-${id} .el-upload--text`)
    if (uploadTextDom) {
      uploadTextDom.style.display = length > 0 ? 'none' : 'block'
    }
  },
  { immediate: true },
)

watch(
  () => modelValue,
  (val: string | string[] | null) => {
    if (!val) {
      return false
    }

    if (isArray(val)) {
      fileList.value = val.map((item: string) => {
        return {
          name: item.split('/').pop() as string,
          url: item,
        }
      })
    }
    else {
      fileList.value = [{ name: val?.split('/')?.pop() as string, url: val }]
    }
  },
  { immediate: true, deep: true },
)
</script>

<template>
  <el-upload
    v-model:file-list="fileList"
    :before-upload="beforeUpload"
    :http-request="customUpload"
    :on-success="handleSuccess"
    :on-exceed="handleExceed"
    :on-error="handleError"
    :multiple="multiple"
    :limit="limit"
    :disabled="isUploading"
    v-bind="$attrs"
    class="w-full"
  >
    <slot name="default">
      <el-button type="primary">
        {{ title ?? t('uploadVideo') }}
      </el-button>
    </slot>
    <template #tip>
      <div v-if="fileList.length < 1" class="pt-1 text-sm text-dark-50 dark-text-gray-3">
        <slot name="tip">
          {{ $attrs?.tip }}
        </slot>
      </div>
      <div v-if="isUploading" class="pt-1 text-sm text-blue-500">
        正在上传中，请稍候...
      </div>
    </template>
  </el-upload>
</template>

<style scoped lang="scss">
</style>