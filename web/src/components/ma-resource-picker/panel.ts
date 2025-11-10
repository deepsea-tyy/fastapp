import { nextTick, type Ref } from 'vue'
import ContextMenu from '@imengyu/vue3-context-menu'

import type { Resources } from '#/global'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import type { FileType, Resource, ResourcePanelProps } from './type.ts'

import { deleteById } from '~/base/api/attachment.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import { formatImagePath } from '@/utils/common.ts'
import { useImageViewer } from '@/hooks/useImageViewer.ts'
import { useVideoViewer } from '@/hooks/useVideoViewer.ts'
import { useTextViewer } from '@/hooks/useTextViewer.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import useParentNode from '@/hooks/useParentNode.ts'

/**
 * 组件常量
 */
const RETURN_TYPE = 'url' as const
const SELECTED_KEY_TYPE = 'id' as const
const CONTEXT_MENU_RESET_DELAY = 300
const DEFAULT_SKELETON_NUM = 30

/**
 * 事件监听器引用接口
 */
interface EventListenerRef {
  element: HTMLElement
  event: string
  handler: EventListener
}

/**
 * 上传增强参数接口
 */
interface EnhancedArgs {
  btn: Resources.Button
  getResourceList: () => void
  onProgress: (progress: number, currentIndex?: number, totalCount?: number) => void
  onError: (error: string) => void
  files?: FileList
}

/**
 * useResourcePanel Composables
 * @param props - 组件属性
 * @param emit - 事件发射器
 * @param modelValue - 双向绑定值
 * @returns 资源面板相关的响应式数据和方法
 */
export function useResourcePanel(
  props: Readonly<ResourcePanelProps>,
  emit: {
    (e: 'cancel'): void
    (e: 'confirm', value: Resource[]): void
  },
  modelValue: Ref<string | string[] | undefined>,
) {
  const i18n = useTrans() as TransType
  const t = i18n.globalTrans
  const msg = useMessage()
  const resourceStore = useResourceStore()

  /**
   * 上传状态管理
   */
  const isUploading = ref<boolean>(false)
  const uploadProgress = ref<number>(0)
  const uploadFileName = ref<string>('')

  /**
   * 文件类型选择
   */
  const fileTypeSelected = ref<string>(props.defaultFileType ?? '')

  /**
   * 文件类型列表
   */
  const fileTypes = ref<FileType[]>([
    { label: () => t('all'), value: '', icon: 'ri:gallery-view-2', suffix: '' },
    { label: () => t('image'), value: 'image', icon: 'ri:image-line', suffix: 'png,jpg,jpeg,gif,bmp' },
    { label: () => t('video'), value: 'video', icon: 'ri:folder-video-line', suffix: 'mp4,avi,wmv,mov,flv,mkv,webm' },
    { label: () => t('audio'), value: 'audio', icon: 'ri:file-music-line', suffix: 'mp3,wav,ogg,wma,aac,flac,ape,wavpack' },
    { label: () => t('document'), value: 'document', icon: 'ri:file-text-line', suffix: 'doc,docx,xls,xlsx,ppt,pptx,pdf' },
  ])

  /**
   * 加载状态
   */
  const loading = ref<boolean>(false)

  /**
   * 当前资源列表
   */
  const resources = ref<Resource[]>([])

  /**
   * 资源总数
   */
  const total = ref<number>(0)

  /**
   * 选中资源的key列表,该数据可用做直接返回
   */
  const selectedKeys = ref<Array<string | number>>([])

  /**
   * 选中资源的完整数据列表
   */
  const selected = ref<Resource[]>([])

  /**
   * 记录右键菜单是否刚刚显示过，用于防止右键后点击触发选择
   */
  const contextMenuJustShown = ref<boolean>(false)

  /**
   * 右键菜单定时器
   */
  let contextMenuTimer: ReturnType<typeof setTimeout> | null = null

  /**
   * 保存事件监听器的引用，用于清理
   */
  const eventListeners = ref<EventListenerRef[]>([])

  /**
   * 查询参数
   */
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

  /**
   * 获取资源列表
   * @param params - 查询参数
   */
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

  /**
   * 监听v-model变化，更新selectedKeys
   */
  watch(() => modelValue.value, (newValue) => {
    selectedKeys.value = Array.isArray(newValue) ? newValue : newValue ? [newValue] : []
  }, { deep: true })

  /**
   * 监听selectedKeys变化，更新v-model
   */
  watch(() => selectedKeys.value, (newKeys) => {
    const newValue = props.multiple ? newKeys : newKeys[0]
    // 同样，只有在modelValue真正改变时才更新
    if (modelValue.value && modelValue.value !== newValue) {
      modelValue.value = newValue as string | string[]
    }
  }, { deep: true })

  /**
   * 加载占位符数量
   */
  const skeletonNum = computed<number>(() => {
    return loading.value ? queryParams.value.page_size : DEFAULT_SKELETON_NUM
  })

  /**
   * 文件类型切换处理
   * @param value - 选中的文件类型值
   */
  function onfileTypesChange(value: string): void {
    fileTypeSelected.value = value
    const selectedType = fileTypes.value.find(i => i.value === value)
    queryParams.value.suffix = selectedType?.suffix ? selectedType.suffix.split(',') : []
    getResourceList(queryParams.value)
  }

  /**
   * 获取资源的唯一标识键
   * @param resource - 资源对象
   * @returns 资源的唯一标识键
   */
  function getResourceKey(resource: Resource): string | number | undefined {
    return resource.id ?? resource[SELECTED_KEY_TYPE as keyof Resource] ?? resource[RETURN_TYPE as keyof Resource]
  }

  /**
   * 获取封面
   * @param resource - 资源对象
   * @returns 封面URL或undefined
   */
  function getCover(resource: Resource): string | undefined {
    if (resource?.mime_type?.startsWith('image')) {
      return formatImagePath(resource.url ?? '')
    }
    return undefined
  }

  /**
   * 判断是否被选中
   * @param resource - 资源对象
   * @returns 是否选中
   */
  function isSelected(resource: Resource): boolean {
    const key = getResourceKey(resource)
    if (key === undefined) return false
    return selectedKeys.value.includes(key)
  }

  /**
   * 可预览的文件类型配置
   */
  const previewableTypes = {
    // 通过 mime_type 前缀判断的类型
    mimeTypePrefixes: ['image', 'video'],
    // 通过 suffix 判断的类型
    suffixes: ['xls', 'xlsx', 'doc', 'docx', 'txt', 'pdf'],
    // 通过完整的 mime_type 判断的类型
    mimeTypes: [
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
      'application/pdf',
    ],
  }

  /**
   * 判断是否能预览
   * @param resource - 资源对象
   * @returns 是否能预览
   */
  function canPreview(resource: Resource): boolean {
    if (!resource) return false

    const mimeType = resource.mime_type || ''
    const suffix = resource.suffix?.toLowerCase() || ''

    // 检查 mime_type 前缀
    if (previewableTypes.mimeTypePrefixes.some(prefix => mimeType.startsWith(prefix))) {
      return true
    }

    // 检查完整的 mime_type
    if (previewableTypes.mimeTypes.includes(mimeType.toLowerCase())) {
      return true
    }

    // 检查文件后缀
    return !!(suffix && previewableTypes.suffixes.includes(suffix));


  }

  /**
   * 判断是否为视频
   * @param resource - 资源对象
   * @returns 是否为视频
   */
  function isVideo(resource: Resource): boolean {
    return !!(resource?.mime_type?.startsWith('video'))
  }

  /**
   * 判断是否为文本文件
   * @param resource - 资源对象
   * @returns 是否为文本文件
   */
  function isTextFile(resource: Resource): boolean {
    const mimeType = resource?.mime_type?.toLowerCase() || ''
    const suffix = resource?.suffix?.toLowerCase() || ''
    return mimeType === 'text/plain' || suffix === 'txt'
  }

  /**
   * 获取资源图标
   * @param resource - 资源对象
   * @returns 图标名称或undefined
   */
  function getResourceIcon(resource: Resource): string | undefined {
    // 如果是图片，不显示图标（直接显示图片）
    if (resource?.mime_type?.startsWith('image')) {
      return undefined
    }
    
    // 如果是视频，显示视频图标
    if (isVideo(resource)) {
      return 'ri:file-video-line'
    }
    
    // 如果是Excel文件，显示Excel图标
    const suffix = resource?.suffix?.toLowerCase()
    if (suffix === 'xls' || suffix === 'xlsx') {
      return 'mdi:microsoft-excel'
    }
    
    // 其他文件显示默认文档图标
    return 'mdi:file-document-multiple-outline'
  }

  /**
   * 选中资源
   * @param resource - 资源对象
   */
  function select(resource: Resource): void {
    const key = getResourceKey(resource)
    if (key === undefined) return

    // 单选
    if (props.multiple) {
      // 判断是否上限
      if (props.limit && selectedKeys.value.length >= props.limit) {
        msg.warning(t('maxSelect', { limit: props.limit }))
        return
      }
      // 检查是否已经选中，避免重复添加
      if (!selectedKeys.value.includes(key)) {
        selectedKeys.value.push(key)
      }
      if (!selected.value.find(i => getResourceKey(i) === key)) {
        selected.value.push(resource)
      }
    }
    else {
      selected.value = [resource]
      selectedKeys.value = [key]
    }
  }

  /**
   * 取消选中
   * @param resource - 资源对象
   */
  function unSelect(resource: Resource): void {
    const key = getResourceKey(resource)
    if (key === undefined) return

    selectedKeys.value = selectedKeys.value.filter(i => i !== key)
    selected.value = selected.value.filter(i => getResourceKey(i) !== key)
  }

  /**
   * 清空选中
   */
  function clearSelected(): void {
    selectedKeys.value = []
    selected.value = []
  }

  /**
   * 取消操作
   */
  function cancel(): void {
    emit('cancel')
  }

  /**
   * 确认操作
   */
  function confirm(): void {
    emit('confirm', selected.value)
  }

  /**
   * 处理点击资源事件
   * @param resource - 资源对象
   * @param event - 鼠标事件
   */
  function handleClick(resource: Resource, event?: MouseEvent): void {
    // 如果是右键点击，不处理
    if (event && event.button === 2) {
      return
    }
    // 如果右键菜单刚刚显示过，忽略这次点击
    if (contextMenuJustShown.value) {
      contextMenuJustShown.value = false
      if (contextMenuTimer) {
        clearTimeout(contextMenuTimer)
        contextMenuTimer = null
      }
      return
    }
    if (isSelected(resource)) {
      unSelect(resource)
    }
    else {
      select(resource)
    }
  }

  /**
   * 处理双击资源事件
   * @param resource - 资源对象
   */
  function handleDbClick(resource: Resource): void {
    // 双击确认选中单个元素
    clearSelected()
    select(resource)
    confirm()
  }

  /**
   * 删除资源
   * @param id - 资源ID
   */
  async function onDel(id: number): Promise<void> {
    try {
      // 弹出删除确认框
      const confirmed = await msg.confirm(t('tips'))

      if (confirmed) {
        // 如果用户确认删除，进行删除操作
        const res = await deleteById(id)
        if (res.code !== ResultCode.SUCCESS) {
          msg.error(res.message)
          return
        }
        msg.success(res.message)
        await getResourceList()
      }
      else {
        // 用户取消删除操作
        msg.info(t('cancelMessage'))
      }
    }
    catch (error) {
      // 异常处理，捕获任何错误
      if (error === 'cancel') {
        msg.info(t('cancelMessage'))
      }
      else {
        msg.error(t('errorMessage'))
      }
    }
  }

  /**
   * 右键菜单
   * @param e - 鼠标事件
   * @param resource - 资源对象
   */
  function executeContextmenu(e: MouseEvent, resource: Resource): void {
    e.preventDefault()
    e.stopPropagation()

    // 标记右键菜单已显示，防止后续点击触发选择
    contextMenuJustShown.value = true
    if (contextMenuTimer) {
      clearTimeout(contextMenuTimer)
    }
    // 延迟后重置标志
    contextMenuTimer = setTimeout(() => {
      contextMenuJustShown.value = false
      contextMenuTimer = null
    }, CONTEXT_MENU_RESET_DELAY)

    ContextMenu.showContextMenu({
      x: e.x,
      y: e.y,
      zIndex: 9999,
      iconFontClass: '',
      customClass: 'mine-contextmenu',
      items: [
        // 选中当前类型
        {
          label: t('select'),
          hidden: isSelected(resource),
          icon: 'i-ri:check-fill',
          onClick: () => {
            setTimeout(() => {
              try {
                // 获取当前资源的类型
                const currentType = resource?.mime_type?.split('/')[0] || ''
                if (!currentType) return

                // 清空当前选中
                clearSelected()

                // 选择此类型的所有项
                const sameTypeResources = resources.value.filter(item =>
                  item?.mime_type?.startsWith(currentType),
                )

                // 直接更新选中状态，避免通过select函数逐个选择
                sameTypeResources.forEach((item) => {
                  const key = getResourceKey(item)
                  if (key !== undefined && !selectedKeys.value.includes(key)) {
                    selectedKeys.value.push(key)
                    selected.value.push(item)
                  }
                })
              }
              catch (error) {
                console.error('选中当前类型时出错:', error)
              }
            }, 0)
          },
        },
        {
          label: t('deselect'),
          hidden: !isSelected(resource),
          icon: 'i-ri:close-fill',
          onClick: () => {
            setTimeout(() => {
              try {
                unSelect(resource)
              }
              catch (error) {
                console.error('取消选中资源时出错:', error)
              }
            }, 0)
          },
        },
        {
          label: t('view'),
          icon: 'i-ri:search-eye-line',
          disabled: !canPreview(resource),
          onClick: () => {
            // 使用 setTimeout 延迟执行，避免浏览器扩展的消息通道问题
            setTimeout(() => {
              try {
                if (!resource?.url) {
                  msg.warning('资源地址不存在')
                  return
                }
                const formattedUrl = formatImagePath(resource.url)
                if (isVideo(resource)) {
                  useVideoViewer(formattedUrl, { title: resource?.origin_name || '视频预览' })
                }
                else if (isTextFile(resource)) {
                  useTextViewer(formattedUrl, { title: resource?.origin_name || '文本预览' })
                }
                else {
                  useImageViewer([formattedUrl])
                }
              }
              catch (error) {
                console.error('预览资源失败:', error)
                msg.error('预览资源失败，请稍后重试')
              }
            }, 0)
          },
        },
        {
          label: t('delete'),
          icon: 'i-material-symbols:delete-outline',
          onClick: () => {
            // 使用 setTimeout 延迟执行，避免浏览器扩展的消息通道问题
            setTimeout(() => {
              try {
                if (resource?.id !== undefined) {
                  onDel(resource.id)
                }
              }
              catch (error) {
                console.error('删除资源时出错:', error)
                msg.error('删除操作失败，请稍后重试')
              }
            }, 0)
          },
        },
      ],
    })
  }

  /**
   * 处理文件上传
   * @param ev - 文件选择事件
   * @param btn - 上传按钮配置
   */
  function handleFile(ev: Event, btn: Resources.Button): void {

    const target = ev.target as HTMLInputElement
    const files = target?.files as FileList | null
    if (!files || files.length === 0) return

    // 检查文件数量限制
    const fileLimit = btn?.uploadConfig?.limit
    if (fileLimit && files.length > fileLimit) {
      msg.warning(`最多只能选择 ${fileLimit} 个文件`)
      target.value = '' // 清空选择
      return
    }

    // 多文件上传：显示文件信息
    const fileCount = files.length
    uploadFileName.value = fileCount > 1
      ? `${files[0].name} (1/${fileCount})`
      : files[0].name
    isUploading.value = true
    uploadProgress.value = 0

    try {
      // 创建增强的 args 对象，包含进度回调
      const enhancedArgs: EnhancedArgs = {
        btn,
        files,
        getResourceList: () => {
          getResourceList()
          isUploading.value = false
          uploadProgress.value = 0
          uploadFileName.value = ''
          msg.success(t('uploadSuccess'))
        },
        onProgress: (progress: number, currentIndex?: number, totalCount?: number) => {
          uploadProgress.value = progress
          // 如果有多个文件，更新文件名显示
          if (totalCount && currentIndex !== undefined && totalCount > 1 && files) {
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

      // 包装上传函数以处理错误
      const originalUpload = btn.upload
      if (originalUpload) {
        try {
          const uploadResult = originalUpload(files, enhancedArgs)
          // 如果返回 Promise，添加错误处理
          if (uploadResult != null && typeof uploadResult === 'object' && typeof (uploadResult as any).catch === 'function') {
            (uploadResult as Promise<any>).catch((error: any) => {
              enhancedArgs.onError?.(error?.message || String(error) || t('uploadFailed'))
            })
          }
        }
        catch (error: any) {
          enhancedArgs.onError?.(error?.message || String(error) || t('uploadFailed'))
        }
      }
      else {
        enhancedArgs.onError?.(t('uploadNotConfigured'))
      }
    } catch (error) {
      console.error('处理文件上传时出错:', error)
      isUploading.value = false
      uploadProgress.value = 0
      uploadFileName.value = ''
      msg.error(t('uploadProcessingError'))
    }
  }

  /**
   * 组件挂载时的初始化操作
   */
  onMounted(async () => {
    await getResourceList()
    await nextTick()

    const apps = document.getElementsByClassName('res-app') as HTMLCollectionOf<HTMLDivElement>

    for (let i = 0; i < apps.length; i++) {
      const app = apps[i] as HTMLDivElement
      const parentElement = app?.parentElement

      /**
       * 创建点击事件处理器
       */
      const clickHandler = (e: Event) => {
        const mouseEvent = e as MouseEvent
        mouseEvent.stopPropagation()
        try {
          const node = useParentNode(mouseEvent, 'div')
          const fileInput = node.children[0] as HTMLInputElement
          const btn = resourceStore.getAllButton()?.find(item => item.name === fileInput.getAttribute('name'))
          if (btn?.click) {
            btn.click(btn, selected.value as any)
          }
          if (btn?.upload) {
            fileInput?.click?.()
          }
        }
        catch (error) {
          console.error('处理点击事件时出错:', error)
        }
      }

      /**
       * 创建鼠标悬停事件处理器
       */
      const mouseoverHandler = () => {
        const index = i
        app.className = 'res-app main-effect'

        if (index === 0) {
          if (apps[1]) {
            apps[1].className = 'res-app second-effect'
          }
          if (apps[2]) {
            apps[2].className = 'res-app third-effect'
          }
        }
        else if (index === apps.length - 1) {
          if (apps[index - 1]) {
            apps[index - 1].className = 'res-app second-effect'
          }
          if (apps[index - 2]) {
            apps[index - 2].className = 'res-app third-effect'
          }
        }
        else {
          if (apps[index - 1]) {
            apps[index - 1].className = 'res-app second-effect'
          }
          if (apps[index + 1]) {
            apps[index + 1].className = 'res-app second-effect'
          }

          if (index - 2 > -1 && apps[index - 2]) {
            apps[index - 2].className = 'res-app third-effect'
          }

          if (index + 2 < apps.length && apps[index + 2]) {
            apps[index + 2].className = 'res-app third-effect'
          }
        }
      }

      /**
       * 创建鼠标移出事件处理器
       */
      const mouseoutHandler = () => {
        for (const app of apps) {
          app.className = 'res-app'
        }
      }

      // 添加事件监听器并保存引用
      app.addEventListener('click', clickHandler)
      eventListeners.value.push({ element: app, event: 'click', handler: clickHandler })

      if (parentElement) {
        parentElement.addEventListener('mouseover', mouseoverHandler)
        eventListeners.value.push({ element: parentElement, event: 'mouseover', handler: mouseoverHandler })

        parentElement.addEventListener('mouseout', mouseoutHandler)
        eventListeners.value.push({ element: parentElement, event: 'mouseout', handler: mouseoutHandler })
      }
    }
  })

  /**
   * 组件卸载时的清理操作
   */
  onUnmounted(() => {
    // 清理所有事件监听器
    eventListeners.value.forEach(({ element, event, handler }) => {
      try {
        element.removeEventListener(event, handler)
      }
      catch (error) {
        console.error('移除事件监听器时出错:', error)
      }
    })
    eventListeners.value = []

    // 清理定时器
    if (contextMenuTimer) {
      clearTimeout(contextMenuTimer)
      contextMenuTimer = null
    }
  })

  // 返回所有需要在模板中使用的响应式数据和方法
  return {
    // 状态
    loading,
    resources,
    total,
    selectedKeys,
    selected,
    fileTypeSelected,
    fileTypes,
    queryParams,
    skeletonNum,
    isUploading,
    uploadProgress,
    uploadFileName,
    resourceStore,
    // 方法
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
  }
}
