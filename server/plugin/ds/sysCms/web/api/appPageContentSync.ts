import type { ResponseStruct } from '#/global'

export interface AppPageContentSyncVo {
  id: number
  // 版本号（时间戳）
  version: string
  // 平台：1Web 2App
  platform: number
  // 文件路径
  file_path: string
  // 文件大小（字节）
  file_size: number
  // 记录数量
  record_count: number
  // 生成时间
  generated_at: string
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 同步版本查询
export function page(params: AppPageContentSyncVo): Promise<ResponseStruct<AppPageContentSyncVo[]>> {
  return useHttp().get('/admin/ds/sysCms/app_page_content_sync/list', { params })
}

// 生成文件
export function generate(): Promise<ResponseStruct<any>> {
  return useHttp().post('/admin/ds/sysCms/app_page_content_sync/generate')
}

// 删除文件记录
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/sysCms/app_page_content_sync/delete', { data: ids })
}

