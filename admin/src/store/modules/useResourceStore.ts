
import type { Resources } from '#/global'
import { uploadLocal } from '@/utils/uploadLocal.ts'
import { chunkUpload, shouldUseChunkUpload } from '@/utils/chunkUpload.ts'

const resourceDefaultButtons: Resources.Button[] = [
  {
    name: 'local-image-upload',
    label: 'imageUpload',
    icon: 'solar:upload-square-broken',
    upload: async (files: FileList, args: Resources.Args & { onProgress?: (progress: number, currentIndex?: number, totalCount?: number) => void }) => {
      const fileArray = Array.from(files)
      const totalCount = fileArray.length
      
      for (let i = 0; i < fileArray.length; i++) {
        const file = fileArray[i]
        const options = { file }
        
        try {
          await uploadLocal(options)
          // 更新进度：已完成 (i+1) 个文件
          const progress = ((i + 1) / totalCount) * 100
          args?.onProgress?.(progress, i, totalCount)
          
          // 如果是最后一个文件，刷新资源列表
          if (i === totalCount - 1) {
            args?.getResourceList?.()
          }
        } catch (e) {
          throw new Error(e)
        }
      }
    },
    uploadConfig: {
      accept: 'image/*',
    },
    order: 0,
  },
  {
    name: 'local-file-upload',
    label: 'fileUpload',
    icon: 'hugeicons:file-upload',
    upload: async (files: FileList, args: Resources.Args & { onProgress?: (progress: number, currentIndex?: number, totalCount?: number) => void }) => {
      const fileArray = Array.from(files)
      const totalCount = fileArray.length
      
      for (let i = 0; i < fileArray.length; i++) {
        const file = fileArray[i]
        const options = { file }
        
        try {
          await uploadLocal(options)
          // 更新进度：已完成 (i+1) 个文件
          const progress = ((i + 1) / totalCount) * 100
          args?.onProgress?.(progress, i, totalCount)
          
          // 如果是最后一个文件，刷新资源列表
          if (i === totalCount - 1) {
            args?.getResourceList?.()
          }
        } catch (e) {
          throw new Error(e)
        }
      }
    },
    uploadConfig: {
      accept: '.doc,.xls,.ppt,.txt,.pdf',
    },
    order: 1,
  },
  {
    name: 'local-video-upload',
    label: 'videoUpload',
    icon: 'ri:video-upload-line',
    upload: async (files: FileList, args: Resources.Args & { onProgress?: (progress: number, currentIndex?: number, totalCount?: number) => void; onError?: (error: string) => void }) => {
      const fileArray = Array.from(files)
      const totalCount = fileArray.length
      
      for (let i = 0; i < fileArray.length; i++) {
        const file = fileArray[i]
        let fileProgress = 0
        
        try {
          // 检查是否应该使用分片上传
          if (shouldUseChunkUpload(file, 10 * 1024 * 1024)) {
            // 使用分片上传
            const result = await chunkUpload({
              file,
              chunkSize: 2 * 1024 * 1024, // 2MB 分片
              onProgress: (progress) => {
                fileProgress = progress
                // 计算总体进度：(已完成文件数 + 当前文件进度) / 总文件数
                const overallProgress = ((i + progress / 100) / totalCount) * 100
                args?.onProgress?.(overallProgress, i, totalCount)
              },
              onChunkProgress: (chunkIndex, totalChunks) => {
              }
            })
            
            if (!result.success) {
              throw new Error(result.message || '视频上传失败')
            }
          } else {
            // 使用普通上传
            const options = { file }
            await uploadLocal(options)
            fileProgress = 100
          }
          
          // 更新进度：当前文件已完成
          const overallProgress = ((i + 1) / totalCount) * 100
          args?.onProgress?.(overallProgress, i, totalCount)
          
          // 如果是最后一个文件，刷新资源列表
          if (i === totalCount - 1) {
            args?.getResourceList?.()
          }
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : '视频上传失败'
          args?.onError?.(errorMessage)
          throw error
        }
      }
    },
    uploadConfig: {
      accept: 'video/*,.mp4,.avi,.mov,.wmv,.flv,.mkv,.webm',
    },
    order: 2,
  },
]

const useResourceStore = defineStore(
  'useResourceStore',
  () => {
    const resourceButtons = ref<Resources.Button[]>([])

    const getButton = (name: string): Resources.Button | undefined => {
      return resourceButtons.value.find(item => item.name === name)
    }

    const addButton = (button: Resources.Button): boolean => {
      if (getButton(button.name)) {
        return false
      }
      else {
        resourceButtons.value.push(button)
        return true
      }
    }

    const removeButton = (name: string) => {
      resourceButtons.value = resourceButtons.value.filter(item => item.name !== name)
    }

    const getAllButton = () => {
      return resourceButtons.value
    }

    resourceDefaultButtons.forEach(item => addButton(item))

    return {
      addButton,
      removeButton,
      getButton,
      getAllButton,
    }
  },
)

export default useResourceStore
