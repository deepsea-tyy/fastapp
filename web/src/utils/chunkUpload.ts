/**
 * 分片上传工具
 * 支持大文件分片上传和MD5校验
 */

import SparkMD5 from 'spark-md5'

export interface ChunkUploadOptions {
  file: File
  chunkSize?: number // 分片大小，默认 2MB
  onProgress?: (progress: number) => void // 进度回调
  onChunkProgress?: (chunkIndex: number, totalChunks: number) => void // 分片进度回调
}

export interface ChunkUploadResult {
  success: boolean
  url?: string
  message?: string
}

/**
 * 计算文件MD5值
 * 使用 spark-md5 库，支持大文件的流式处理
 */
export async function calculateFileMD5(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const blobSlice = File.prototype.slice || (File.prototype as any).mozSlice || (File.prototype as any).webkitSlice
    const chunkSize = 2 * 1024 * 1024 // 2MB 分块读取
    const chunks = Math.ceil(file.size / chunkSize)
    let currentChunk = 0
    const spark = new SparkMD5.ArrayBuffer()
    const fileReader = new FileReader()

    fileReader.onload = (e) => {
      const result = e.target?.result as ArrayBuffer
      spark.append(result)
      currentChunk++

      if (currentChunk < chunks) {
        loadNext()
      } else {
        const md5 = spark.end()
        resolve(md5)
      }
    }

    fileReader.onerror = () => {
      reject(new Error('文件读取失败'))
    }

    function loadNext() {
      const start = currentChunk * chunkSize
      const end = start + chunkSize >= file.size ? file.size : start + chunkSize
      fileReader.readAsArrayBuffer(blobSlice.call(file, start, end))
    }

    loadNext()
  })
}

/**
 * 创建文件分片
 */
export function createFileChunks(file: File, chunkSize: number = 2 * 1024 * 1024): Blob[] {
  const chunks: Blob[] = []
  let start = 0
  
  while (start < file.size) {
    const end = Math.min(start + chunkSize, file.size)
    chunks.push(file.slice(start, end))
    start = end
  }
  
  return chunks
}

/**
 * 上传分片
 */
async function uploadChunk(
  chunk: Blob,
  fileMD5: string,
  chunkIndex: number,
  totalChunks: number,
  filename: string,
  uploadUrl: string = '/attachment/chunk-upload'
): Promise<any> {
  const formData = new FormData()
  formData.append('file', chunk)
  formData.append('file_md5', fileMD5)
  formData.append('chunk_index', chunkIndex.toString())
  formData.append('total_chunks', totalChunks.toString())
  formData.append('filename', filename)

  return useHttp().post(uploadUrl, formData)
}

/**
 * 合并分片
 */
async function mergeChunks(
  fileMD5: string,
  totalChunks: number,
  filename: string,
  mergeUrl: string = '/attachment/chunk-merge'
): Promise<any> {
  return useHttp().post(mergeUrl, {
    file_md5: fileMD5,
    total_chunks: totalChunks,
    filename: filename
  })
}

/**
 * 分片上传主函数
 */
export async function chunkUpload(options: ChunkUploadOptions): Promise<ChunkUploadResult> {
  const { file, chunkSize = 2 * 1024 * 1024, onProgress, onChunkProgress } = options
  
  try {
    // 1. 计算MD5
    onProgress?.(5)
    const fileMD5 = await calculateFileMD5(file)
    
    // 2. 分片
    const chunks = createFileChunks(file, chunkSize)
    const totalChunks = chunks.length
    
    onProgress?.(10)
    
    // 3. 上传分片
    const uploadPromises = chunks.map(async (chunk, index) => {
      try {
        const result = await uploadChunk(chunk, fileMD5, index, totalChunks, file.name)
        onChunkProgress?.(index + 1, totalChunks)
        return result
      } catch (error) {
        throw new Error(`分片 ${index + 1} 上传失败: ${error}`)
      }
    })
    
    // 等待所有分片上传完成
    await Promise.all(uploadPromises)
    onProgress?.(90)
    
    // 4. 合并
    const mergeResult = await mergeChunks(fileMD5, totalChunks, file.name)
    onProgress?.(100)
    
    if (mergeResult.code === 200) {
      return {
        success: true,
        url: mergeResult.data.url,
        message: '上传成功'
      }
    } else {
      return {
        success: false,
        message: mergeResult.message || '上传失败'
      }
    }
    
  } catch (error) {
    return {
      success: false,
      message: error instanceof Error ? error.message : '上传失败'
    }
  }
}

/**
 * 判断是否应该使用分片上传
 * 文件大小超过阈值时使用分片上传
 */
export function shouldUseChunkUpload(file: File, threshold: number = 10 * 1024 * 1024): boolean {
  return file.size > threshold
}