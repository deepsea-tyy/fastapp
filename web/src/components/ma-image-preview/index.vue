<
<i18n lang="yaml">
en:
  copyLink: "Copy Link"
  close: "Close"
  imagePreview: "Image Preview"
  noImagesWarning: "No images available for preview"
  loading: "Loading..."
  loadFailed: "Load failed"
  checkImageUrl: "Please check if the image URL is correct"
  keyboardHint: "Use ← → arrow keys to switch images"
zh_CN:
  copyLink: "复制链接"
  close: "关闭"
  imagePreview: "图片预览"
  noImagesWarning: "暂无图片可预览"
  loading: "图片加载中..."
  loadFailed: "加载失败"
  checkImageUrl: "请检查图片链接是否正确"
  keyboardHint: "使用 ← → 方向键切换图片"
zh_TW:
  copyLink: "複製連結"
  close: "關閉"
  imagePreview: "圖片預覽"
  noImagesWarning: "暫無圖片可預覽"
  loading: "圖片載入中..."
  loadFailed: "載入失敗"
  checkImageUrl: "請檢查圖片連結是否正確"
  keyboardHint: "使用 ← → 方向鍵切換圖片"
</i18n>

<template>
  <div class="ma-image-preview">
    <!-- 预览触发区域 -->
    <div class="preview-trigger" @click="openPreview">
      <slot name="trigger">
        <div class="default-trigger">
          <img
            :src="formatImagePath(images[currentIndex])"
            :key="currentIndex"
            class="trigger-image"
            @error="handleTriggerImageError"
          />
          <div v-if="images.length > 1" class="image-count">
            {{ currentIndex + 1 }}/{{ images.length }}
          </div>
        </div>
      </slot>
    </div>

    <!-- 预览模态框 -->
    <el-dialog
      v-model="previewVisible"
      :title="previewTitle"
      width="90%"
      top="5vh"
      class="preview-dialog"
      :show-close="false"
      append-to-body
      destroy-on-close
    >
      <template #header>
        <div class="preview-header">
          <span class="preview-title">{{ previewTitle }}</span>
          <div class="preview-actions">

            <el-button
              type="primary"
              link
              @click="copyImageUrl"
              :disabled="!currentImageUrl"
            >
              <el-icon><CopyDocument /></el-icon>
              {{ t('copyLink') }}
            </el-button>
            <el-button type="primary" link @click="previewVisible = false">
              <el-icon><Close /></el-icon>
              {{ t('close') }}
            </el-button>
          </div>
        </div>
      </template>

      <div class="preview-content">
        <!-- 上一张按钮 -->
        <div
          v-if="images.length > 1"
          class="nav-button prev-button"
          @click="prevImage"
          :class="{ disabled: currentIndex === 0 }"
        >
          <el-icon><ArrowLeft /></el-icon>
        </div>

        <!-- 图片显示区域 -->
        <div class="image-container">
          <el-image
            :src="currentImageUrl"
            fit="contain"
            class="preview-image"
            :z-index="9999"
            hide-on-click-modal
            @load="onImageLoad"
            @error="onImageError"
          >
            <template #placeholder>
              <div class="image-loading">
                <el-icon class="is-loading"><Loading /></el-icon>
                <span>{{ t('loading') }}</span>
              </div>
            </template>
            <template #error>
              <div class="image-error-large">
                <el-icon><Picture /></el-icon>
                <span>{{ t('loadFailed') }}</span>
                <p>{{ t('checkImageUrl') }}</p>
              </div>
            </template>
          </el-image>
        </div>

        <!-- 下一张按钮 -->
        <div
          v-if="images.length > 1"
          class="nav-button next-button"
          @click="nextImage"
          :class="{ disabled: currentIndex === images.length - 1 }"
        >
          <el-icon><ArrowRight /></el-icon>
        </div>
      </div>

      <!-- 缩略图导航 -->
      <div v-if="images.length > 1" class="thumbnail-nav">
        <div
          v-for="(image, index) in images"
          :key="index"
          class="thumbnail-item"
          :class="{ active: index === currentIndex }"
          @click="switchToImage(index)"
        >
          <img
            :src="formatImagePath(image)"
            class="thumbnail-image"
            @error="handleThumbnailError"
          />
        </div>
      </div>

      <!-- 键盘导航提示 -->
      <div v-if="images.length > 1" class="keyboard-hint">
        <span>{{ t('keyboardHint') }}</span>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
/**
 * MaImagePreview Component
 * 
 * A comprehensive image preview component with multi-image support, navigation controls,
 * keyboard shortcuts, and thumbnail navigation.
 * 
 * Features:
 * - Multi-image display with navigation (previous/next)
 * - Keyboard navigation (arrow keys, escape)
 * - Thumbnail navigation bar
 * - Image loading states and error handling
 * - Copy image URL functionality
 * - Customizable trigger area
 * 
 * @example
 * <ma-image-preview
 *   :images="imageList"
 *   :current-index="currentIndex"
 *   title="Image Preview"
 *   @change="handleImageChange"
 * />
 */

import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useMessage } from '@/hooks/useMessage.ts'
import { useLocalTrans } from '@/hooks/useLocalTrans.ts'
import { formatImagePath } from "@/utils/common.ts"
import {
  Picture,
  CopyDocument,
  Close,
  ArrowLeft,
  ArrowRight,
  Loading
} from '@element-plus/icons-vue'

defineOptions({ name: 'MaImagePreview' })

const t = useLocalTrans()

interface ImagePreviewProps {
  // 图片数据，支持字符串数组或逗号分隔的字符串
  images?: string[] | string
  // 当前显示的图片索引
  currentIndex?: number
  // 预览标题
  title?: string
  // 是否显示预览
  visible?: boolean
}

const props = withDefaults(defineProps<ImagePreviewProps>(), {
  images: () => [],
  currentIndex: 0,
  title: '图片预览',
  visible: false
})

const emit = defineEmits(['update:visible', 'update:currentIndex', 'change'])

const msg = useMessage()
const previewVisible = ref(props.visible)
const currentIndex = ref(props.currentIndex)
const imageLoaded = ref(false)

// 处理图片数据
const images = computed(() => {
  if (typeof props.images === 'string') {
    return props.images.split(',').filter(img => img.trim())
  }
  return props.images || []
})

// 可预览的图片URL列表
const previewableImages = computed(() => {
  return images.value.map(img => formatImagePath(img))
})

// 当前显示的图片URL
const currentImageUrl = computed(() => {
  if (images.value.length === 0) return ''
  return formatImagePath(images.value[currentIndex.value])
})

// 预览标题
const previewTitle = computed(() => {
  if (images.value.length <= 1) {
    return props.title || t('imagePreview')
  }
  return `${props.title || t('imagePreview')} (${currentIndex.value + 1}/${images.value.length})`
})

// 打开预览
const openPreview = () => {
  if (images.value.length === 0) {
    msg.warning(t('noImagesWarning'))
    return
  }
  previewVisible.value = true
  emit('update:visible', true)
}

// 关闭预览
const closePreview = () => {
  previewVisible.value = false
  emit('update:visible', false)
}

// 切换到上一张图片
const prevImage = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
    updateCurrentIndex()
  }
}

// 切换到下一张图片
const nextImage = () => {
  if (currentIndex.value < images.value.length - 1) {
    currentIndex.value++
    updateCurrentIndex()
  }
}

// 切换到指定图片
const switchToImage = (index: number) => {
  if (index >= 0 && index < images.value.length) {
    currentIndex.value = index
    updateCurrentIndex()
  }
}

// 更新当前索引并触发事件
const updateCurrentIndex = () => {
  emit('update:currentIndex', currentIndex.value)
  emit('change', currentIndex.value, images.value[currentIndex.value])
  imageLoaded.value = false
}



// 复制图片链接
const copyImageUrl = async () => {
  if (!currentImageUrl.value) return
  
  try {
    await navigator.clipboard.writeText(currentImageUrl.value)
    msg.success('图片链接已复制到剪贴板')
  } catch (error) {
    console.error('复制链接失败:', error)
    msg.error('复制链接失败')
  }
}

// 图片加载完成
const onImageLoad = () => {
  imageLoaded.value = true
}

// 加载失败
const onImageError = () => {
  imageLoaded.value = false
  msg.error(t('loadFailed'))
}

// 处理触发图片错误
const handleTriggerImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  img.style.display = 'none'
  // 显示错误占位符
  const errorDiv = document.createElement('div')
  errorDiv.className = 'image-error'
  errorDiv.innerHTML = `
    <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; width: 100%; text-align: center;">
      <el-icon><Picture /></el-icon>
      <span style="margin-top: 8px;">加载失败</span>
    </div>
  `
  img.parentNode?.appendChild(errorDiv)
}

// 处理缩略图错误
const handleThumbnailError = (event: Event) => {
  const img = event.target as HTMLImageElement
  img.style.display = 'none'
  // 显示错误占位符
  const errorDiv = document.createElement('div')
  errorDiv.className = 'thumbnail-error'
  errorDiv.innerHTML = '<el-icon><Picture /></el-icon>'
  img.parentNode?.appendChild(errorDiv)
}

// 键盘事件处理
const handleKeydown = (event: KeyboardEvent) => {
  if (!previewVisible.value) return
  
  switch (event.key) {
    case 'ArrowLeft':
      event.preventDefault()
      prevImage()
      break
    case 'ArrowRight':
      event.preventDefault()
      nextImage()
      break
    case 'Escape':
      event.preventDefault()
      closePreview()
      break
  }
}

// 监听props变化
watch(() => props.visible, (val) => {
  previewVisible.value = val
})

watch(() => props.currentIndex, (val) => {
  currentIndex.value = val
})

// 监听currentIndex变化，更新触发区域图片
watch(currentIndex, () => {
  // 强制更新触发区域的图片
  const triggerImage = document.querySelector('.trigger-image') as HTMLImageElement
  if (triggerImage && images.value.length > 0) {
    triggerImage.src = formatImagePath(images.value[currentIndex.value])
  }
})

watch(previewVisible, (val) => {
  emit('update:visible', val)
  if (val) {
    document.addEventListener('keydown', handleKeydown)
  } else {
    document.removeEventListener('keydown', handleKeydown)
  }
})

// 组件挂载和卸载
onMounted(() => {
  if (previewVisible.value) {
    document.addEventListener('keydown', handleKeydown)
  }
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.ma-image-preview {
  display: inline-block;
}

.preview-trigger {
  cursor: pointer;
  transition: all 0.3s ease;
}

.preview-trigger:hover {
  transform: scale(1.02);
}

.default-trigger {
  position: relative;
  width: 70px;
  height: 70px;
  border-radius: 6px;
  overflow: hidden;
  border: 1px solid #e4e7ed;
}

.trigger-image {
  width: 100%;
  height: 100%;
}

.image-count {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.6);
  color: white;
  text-align: center;
  padding: 4px;
  font-size: 12px;
}

.preview-dialog {
  :deep(.el-dialog__body) {
    padding: 0;
  }
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.preview-title {
  font-size: 16px;
  font-weight: 600;
}

.preview-actions {
  display: flex;
  gap: 8px;
}

.preview-content {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  background: #f5f7fa;
  padding: 20px;
}

.image-container {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  max-width: calc(100% - 120px);
  height: 100%;
}

.preview-image {
  max-width: 100%;
  max-height: 70vh;
  object-fit: contain;
}

.nav-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 50px;
  height: 50px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid #dcdfe6;
  z-index: 10;
}

.nav-button:hover {
  background: #409eff;
  color: white;
  border-color: #409eff;
}

.nav-button.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.nav-button.disabled:hover {
  background: rgba(255, 255, 255, 0.9);
  color: inherit;
  border-color: #dcdfe6;
}

.prev-button {
  left: 20px;
}

.next-button {
  right: 20px;
}

.thumbnail-nav {
  display: flex;
  justify-content: center;
  gap: 10px;
  padding: 20px;
  background: white;
  border-top: 1px solid #e4e7ed;
  overflow-x: auto;
}

.thumbnail-item {
  width: 60px;
  height: 60px;
  border-radius: 4px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.thumbnail-item:hover {
  border-color: #409eff;
}

.thumbnail-item.active {
  border-color: #409eff;
  box-shadow: 0 0 8px rgba(64, 158, 255, 0.4);
}

.thumbnail-image {
  width: 100%;
  height: 100%;
}

.keyboard-hint {
  text-align: center;
  padding: 10px;
  background: #f5f7fa;
  color: #909399;
  font-size: 12px;
  border-top: 1px solid #e4e7ed;
}

.image-loading,
.image-error,
.image-error-large,
.thumbnail-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #909399;
}

.image-error,
.thumbnail-error {
  width: 100%;
  height: 100%;
  background: #f5f7fa;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.image-error-large {
  width: 100%;
  height: 300px;
  background: #f5f7fa;
}

.image-error-large p {
  margin-top: 8px;
  font-size: 14px;
}

.is-loading {
  animation: rotating 2s linear infinite;
}

@keyframes rotating {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>