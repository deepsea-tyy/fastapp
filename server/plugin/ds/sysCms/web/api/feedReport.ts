import type { ResponseStruct } from '#/global'

export interface FeedReportVo {
  id: number
  // 举报用户ID
  user_id: number
  // 目标类型：1帖子 2文章 3评论
  target_type: number
  // 目标ID
  target_id: number
  // 举报原因：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他
  report_type: number
  // 举报说明
  content: string
  // 处理状态：0待处理 1已处理 2已忽略
  handle_status: number
  // 处理时间
  handled_at: string
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 举报（通用）查询
export function page(params: FeedReportVo): Promise<ResponseStruct<FeedReportVo[]>> {
  return useHttp().get('/admin/ds/syscms/feed_report/list', { params })
}

// 举报（通用）新增
export function create(data: FeedReportVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/syscms/feed_report/create', data)
}

// 举报（通用）编辑
export function save(id: number, data: FeedReportVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/syscms/feed_report/save/${id}`, data)
}

// 举报（通用）删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/syscms/feed_report/delete', { data: ids })
}
