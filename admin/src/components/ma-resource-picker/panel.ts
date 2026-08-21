import type { Ref } from 'vue'
import { ElMessageBox } from 'element-plus'

import type { Resources } from '#/global'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import type { FileType, Resource, ResourcePanelProps } from './type.ts'

import { deleteById } from '~/base/api/attachment.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import { formatFileUrl } from '@/utils/common.ts'
import { useImageViewer } from '@/hooks/useImageViewer.ts'
import { useVideoViewer } from '@/hooks/useVideoViewer.ts'
import { useTextViewer } from '@/hooks/useTextViewer.ts'
import { useMessage } from '@/hooks/useMessage.ts'

const DEFAULT_SKELETON_NUM = 30
const AUDIO_SUFFIXES = ['mp3', 'wav', 'ogg', 'wma', 'aac', 'flac', 'm4a', 'webm', 'ape']
const VIDEO_SUFFIXES = ['mp4', 'avi', 'wmv', 'mov', 'flv', 'mkv', 'webm']

interface EnhancedArgs {
  btn: Resources.Button
  getResourceList: () => void
  onProgress: (progress: number, currentIndex?: number, totalCount?: number) => void
  onError: (error: string) => void
  files?: FileList
}

export function useResourcePanel(
  props: Readonly<ResourcePanelProps>,
  emit: {
    (e: 'cancel'): void
    (e: 'confirm', value: Resource[]): void
  },
  modelValue: Ref<string | string[] | undefined>,
) {
  const i18n = useTrans() as TransType
  const t = i18n.localTrans
  const msg = useMessage()
  const resourceStore = useResourceStore()

  function confirmDelete(message: string) {
    return ElMessageBox.confirm(message, t('confirmTitle'), {
      confirmButtonText: t('confirm'),
      cancelButtonText: t('cancel'),
      type: 'warning',
    })
  }

  const isUploading = ref<boolean>(false)
  const uploadProgress = ref<number>(0)
  const uploadFileName = ref<string>('')
  const isDragging = ref<boolean>(false)
  let dragCounter = 0

  const playingAudio = ref<Resource | null>(null)
  const audioPaused = ref<boolean>(false)
  let audioEl: HTMLAudioElement | null = null
  let onAudioEnded: (() => void) | null = null
  let onAudioError: (() => void) | null = null

  function detachAudioListeners(el: HTMLAudioElement): void {
    if (onAudioEnded) el.removeEventListener('ended', onAudioEnded)
    if (onAudioError) el.removeEventListener('error', onAudioError)
    onAudioEnded = null
    onAudioError = null
  }

  const fileTypeSelected = ref<string>(props.defaultFileType ?? '')

  const fileTypes = ref<FileType[]>([
    { label: () => t('all'), value: '', icon: 'ri:gallery-view-2', suffix: '' },
    { label: () => t('image'), value: 'image', icon: 'ri:image-line', suffix: 'png,jpg,jpeg,gif,bmp' },
    { label: () => t('video'), value: 'video', icon: 'ri:folder-video-line', suffix: 'mp4,avi,wmv,mov,flv,mkv,webm' },
    { label: () => t('audio'), value: 'audio', icon: 'ri:file-music-line', suffix: 'mp3,wav,ogg,wma,aac,flac,ape,wavpack' },
    { label: () => t('document'), value: 'document', icon: 'ri:file-text-line', suffix: 'doc,docx,xls,xlsx,ppt,pptx,pdf' },
  ])

  const loading = ref<boolean>(false)
  const resources = ref<Resource[]>([])
  const total = ref<number>(0)
  const selectedKeys = ref<Array<string | number>>([])
  const selected = ref<Resource[]>([])

  const queryParams = ref<{
    page: number
    page_size: number
    origin_name: string
    suffix: string[]
  }>({
    page: 1,
    page_size: props.pageSize ?? 30,
    origin_name: '',
    suffix: [],
  })

  async function getResourceList(params: Partial<Resource> | Record<string, any> = {}): Promise<void> {
    loading.value = true
    try {
      const { data } = await useHttp().get(
        '/attachment/list',
        { params: Object.assign({ page_size: queryParams.value.page_size, page: queryParams.value.page }, params) },
      )
      total.value = data.total
      resources.value = data.list
    }
    finally {
      loading.value = false
    }
  }

  watch(() => modelValue.value, (newValue) => {
    selectedKeys.value = Array.isArray(newValue) ? newValue : newValue ? [newValue] : []
  }, { deep: true })

  watch(() => selectedKeys.value, (newKeys) => {
    if (props.multiple) {
      modelValue.value = newKeys as string[]
      return
    }
    if (newKeys.length <= 1) {
      modelValue.value = newKeys[0] as string
    }
  }, { deep: true })

  const skeletonNum = computed<number>(() => {
    return loading.value ? queryParams.value.page_size : DEFAULT_SKELETON_NUM
  })

  const hasSelection = computed(() => selectedKeys.value.length > 0)

  const canPreviewSelection = computed(() =>
    selected.value.some(r => canPreview(r)),
  )

  function onfileTypesChange(value: string): void {
    fileTypeSelected.value = value
    const selectedType = fileTypes.value.find(i => i.value === value)
    queryParams.value.suffix = selectedType?.suffix ? selectedType.suffix.split(',') : []
    getResourceList(queryParams.value)
  }

  function getResourceKey(resource: Resource): number | undefined {
    return resource.id
  }

  function getCover(resource: Resource): string | undefined {
    if (resource?.mime_type?.startsWith('image')) {
      return formatFileUrl(resource.url ?? '') || undefined
    }
    return undefined
  }

  function isSelected(resource: Resource): boolean {
    const key = getResourceKey(resource)
    if (key == undefined) return false
    return selectedKeys.value.includes(key)
  }

  const previewableTypes = {
    mimeTypePrefixes: ['image', 'video'],
    suffixes: ['xls', 'xlsx', 'doc', 'docx', 'txt', 'pdf'],
    mimeTypes: [
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
      'application/pdf',
    ],
  }

  function canPreview(resource: Resource): boolean {
    if (!resource) return false
    if (isAudio(resource)) return true
    if (isVideo(resource)) return true

    const mimeType = resource.mime_type || ''
    const suffix = resource.suffix?.toLowerCase() || ''

    if (previewableTypes.mimeTypePrefixes.some(prefix => mimeType.startsWith(prefix))) {
      return true
    }

    if (previewableTypes.mimeTypes.includes(mimeType.toLowerCase())) {
      return true
    }

    return !!(suffix && previewableTypes.suffixes.includes(suffix))
  }

  function isVideo(resource: Resource): boolean {
    if (resource?.mime_type?.startsWith('video')) return true
    const suffix = resource?.suffix?.toLowerCase() || ''
    return VIDEO_SUFFIXES.includes(suffix)
  }

  function isAudio(resource: Resource): boolean {
    if (resource?.mime_type?.startsWith('audio')) return true
    const suffix = resource?.suffix?.toLowerCase() || ''
    return AUDIO_SUFFIXES.includes(suffix)
  }

  function isTextFile(resource: Resource): boolean {
    const mimeType = resource?.mime_type?.toLowerCase() || ''
    const suffix = resource?.suffix?.toLowerCase() || ''
    return mimeType == 'text/plain' || suffix == 'txt'
  }

  function getResourceIcon(resource: Resource): string | undefined {
    if (resource?.mime_type?.startsWith('image')) {
      return undefined
    }
    if (isVideo(resource)) {
      return 'ri:file-video-line'
    }
    if (isAudio(resource)) {
      return 'ri:file-music-line'
    }
    const suffix = resource?.suffix?.toLowerCase()
    if (suffix == 'xls' || suffix == 'xlsx') {
      return 'mdi:microsoft-excel'
    }
    return 'mdi:file-document-multiple-outline'
  }

  function isPlayingAudio(resource: Resource): boolean {
    const key = getResourceKey(resource)
    const playingKey = playingAudio.value ? getResourceKey(playingAudio.value) : undefined
    return key != undefined && key == playingKey && !audioPaused.value
  }

  function stopAudio(): void {
    if (audioEl) {
      const el = audioEl
      audioEl = null
      detachAudioListeners(el)
      el.pause()
    }
    playingAudio.value = null
    audioPaused.value = false
  }

  async function playAudio(resource: Resource): Promise<void> {
    if (!resource?.url) {
      msg.warning(t('noUrl'))
      return
    }
    stopAudio()
    const url = formatFileUrl(resource.url)
    if (!url) {
      msg.warning(t('noUrl'))
      return
    }
    const el = new Audio(url)
    audioEl = el
    playingAudio.value = resource
    audioPaused.value = false
    onAudioEnded = () => stopAudio()
    onAudioError = () => {
      if (audioEl != el) return
      msg.error(t('playFailed'))
      stopAudio()
    }
    el.addEventListener('ended', onAudioEnded)
    el.addEventListener('error', onAudioError)
    try {
      await el.play()
    }
    catch {
      if (audioEl == el) {
        msg.error(t('playFailed'))
        stopAudio()
      }
    }
  }

  async function toggleAudio(resource: Resource): Promise<void> {
    const key = getResourceKey(resource)
    const playingKey = playingAudio.value ? getResourceKey(playingAudio.value) : undefined
    if (key == playingKey) {
      if (audioEl && !audioPaused.value) {
        audioEl.pause()
        audioPaused.value = true
      }
      else if (audioEl) {
        try {
          await audioEl.play()
          audioPaused.value = false
        }
        catch {
          msg.error(t('playFailed'))
          stopAudio()
        }
      }
      return
    }
    await playAudio(resource)
  }

  function select(resource: Resource): void {
    const key = getResourceKey(resource)
    if (key == undefined) return

    if (props.limit && selectedKeys.value.length >= props.limit) {
      msg.warning(t('maxSelect', { limit: props.limit }))
      return
    }
    if (!selectedKeys.value.includes(key)) {
      selectedKeys.value.push(key)
    }
    if (!selected.value.find(i => getResourceKey(i) == key)) {
      selected.value.push(resource)
    }
  }

  function unSelect(resource: Resource): void {
    const key = getResourceKey(resource)
    if (key == undefined) return

    selectedKeys.value = selectedKeys.value.filter(i => i !== key)
    selected.value = selected.value.filter(i => getResourceKey(i) !== key)
  }

  function clearSelected(): void {
    selectedKeys.value = []
    selected.value = []
  }

  function selectAllPage(): void {
    for (const resource of resources.value) {
      const key = getResourceKey(resource)
      if (key == undefined) continue
      if (props.limit && selectedKeys.value.length >= props.limit) break
      if (!selectedKeys.value.includes(key)) {
        selectedKeys.value.push(key)
        selected.value.push(resource)
      }
    }
  }

  function cancel(): void {
    emit('cancel')
  }

  function confirm(): void {
    const result = props.multiple ? selected.value : selected.value.slice(0, 1)
    emit('confirm', result)
  }

  function handleClick(resource: Resource): void {
    if (isSelected(resource)) {
      unSelect(resource)
    }
    else {
      select(resource)
    }
  }

  function handleDbClick(resource: Resource): void {
    clearSelected()
    select(resource)
    confirm()
  }

  function previewResource(resource: Resource): void {
    if (!resource?.url) {
      msg.warning(t('noUrl'))
      return
    }
    if (isAudio(resource)) {
      toggleAudio(resource)
      return
    }
    const formattedUrl = formatFileUrl(resource.url)
    if (isVideo(resource)) {
      useVideoViewer(formattedUrl, { title: resource?.origin_name || t('videoPreview') })
    }
    else if (isTextFile(resource)) {
      useTextViewer(formattedUrl, { title: resource?.origin_name || t('textPreview') })
    }
    else {
      useImageViewer([formattedUrl])
    }
  }

  function previewSelected(): void {
    const target = selected.value.find(r => canPreview(r))
    if (target) previewResource(target)
  }

  async function deleteResources(ids: number[], message: string): Promise<void> {
    if (!ids.length) return
    try {
      await confirmDelete(message)
      const results = await Promise.all(ids.map(id => deleteById(id)))
      const failed = results.filter(r => r.code !== ResultCode.SUCCESS)
      if (failed.length) {
        msg.error(failed[0].message || t('errorMessage'))
      }
      if (playingAudio.value?.id && ids.includes(playingAudio.value.id)) stopAudio()
      if (ids.length == 1) {
        selectedKeys.value = selectedKeys.value.filter(k => k !== ids[0])
        selected.value = selected.value.filter(r => r.id !== ids[0])
      }
      else {
        clearSelected()
      }
      await getResourceList(queryParams.value)
    }
    catch (error) {
      if (error != 'cancel') {
        msg.error(t('errorMessage'))
      }
    }
  }

  function onDel(id: number): void {
    deleteResources([id], t('tips'))
  }

  function batchDeleteSelected(): void {
    const ids = selected.value.map(r => r.id).filter(id => id != undefined) as number[]
    deleteResources(ids, t('batchDeleteTips', { count: ids.length }))
  }

  function resolveUploadBtn(file: File): Resources.Button | undefined {
    const mime = file.type || ''
    if (mime.startsWith('image/')) return resourceStore.getButton('local-image-upload')
    if (mime.startsWith('video/')) return resourceStore.getButton('local-video-upload')
    if (mime.startsWith('audio/')) return resourceStore.getButton('local-audio-upload') ?? resourceStore.getButton('local-file-upload')
    return resourceStore.getButton('local-file-upload')
  }

  function uploadFiles(files: FileList): void {
    const fileArray = Array.from(files)
    if (!fileArray.length) return

    const groups = new Map<string, File[]>()
    for (const file of fileArray) {
      const btn = resolveUploadBtn(file)
      const name = btn?.name || 'local-file-upload'
      const list = groups.get(name) || []
      list.push(file)
      groups.set(name, list)
    }

    const entries = [...groups.entries()]
    let index = 0

    const runNext = () => {
      if (index >= entries.length) {
        isUploading.value = false
        uploadProgress.value = 0
        uploadFileName.value = ''
        getResourceList(queryParams.value)
        msg.success(t('uploadSuccess'))
        return
      }
      const [btnName, groupFiles] = entries[index++]
      const btn = resourceStore.getButton(btnName)
      if (!btn?.upload) {
        runNext()
        return
      }
      const dt = new DataTransfer()
      groupFiles.forEach(f => dt.items.add(f))
      startUpload(dt.files, btn, runNext)
    }

    runNext()
  }

  function startUpload(files: FileList, btn: Resources.Button, onDone?: () => void): void {
    const fileCount = files.length
    uploadFileName.value = fileCount > 1
      ? `${files[0].name} (1/${fileCount})`
      : files[0].name
    isUploading.value = true
    uploadProgress.value = 0

    const enhancedArgs: EnhancedArgs = {
      btn,
      files,
      getResourceList: () => {
        if (onDone) {
          onDone()
        }
        else {
          getResourceList(queryParams.value)
          isUploading.value = false
          uploadProgress.value = 0
          uploadFileName.value = ''
          msg.success(t('uploadSuccess'))
        }
      },
      onProgress: (progress: number, currentIndex?: number, totalCount?: number) => {
        uploadProgress.value = progress
        if (totalCount && currentIndex != undefined && totalCount > 1) {
          const fileArray = Array.from(files)
          uploadFileName.value = `${fileArray[currentIndex]?.name || ''} (${currentIndex + 1}/${totalCount})`
        }
      },
      onError: (error: string) => {
        isUploading.value = false
        uploadProgress.value = 0
        uploadFileName.value = ''
        msg.error(error || t('uploadFailed'))
      },
    }

    const originalUpload = btn.upload
    if (!originalUpload) {
      enhancedArgs.onError(t('uploadNotConfigured'))
      return
    }
    try {
      const uploadResult = originalUpload(files, enhancedArgs)
      if (uploadResult != null && typeof uploadResult == 'object' && typeof (uploadResult as any).catch == 'function') {
        (uploadResult as Promise<any>).catch((error: any) => {
          enhancedArgs.onError?.(error?.message || String(error) || t('uploadFailed'))
        })
      }
    }
    catch (error: any) {
      enhancedArgs.onError?.(error?.message || String(error) || t('uploadFailed'))
    }
  }

  function handleFile(ev: Event, btn: Resources.Button): void {
    const target = ev.target as HTMLInputElement
    const files = target?.files as FileList | null
    if (!files || files.length == 0) return

    const fileLimit = btn?.uploadConfig?.limit
    if (fileLimit && files.length > fileLimit) {
      msg.warning(t('fileLimit', { limit: fileLimit }))
      target.value = ''
      return
    }

    startUpload(files, btn)
    target.value = ''
  }

  function handleDragEnter(e: DragEvent): void {
    e.preventDefault()
    dragCounter++
    isDragging.value = true
  }

  function handleDragOver(e: DragEvent): void {
    e.preventDefault()
  }

  function handleDragLeave(e: DragEvent): void {
    e.preventDefault()
    dragCounter--
    if (dragCounter <= 0) {
      dragCounter = 0
      isDragging.value = false
    }
  }

  function handleDrop(e: DragEvent): void {
    e.preventDefault()
    dragCounter = 0
    isDragging.value = false
    const files = e.dataTransfer?.files
    if (files?.length) uploadFiles(files)
  }

  onMounted(() => {
    getResourceList()
  })

  onUnmounted(() => {
    stopAudio()
  })

  return {
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
    t,
  }
}
