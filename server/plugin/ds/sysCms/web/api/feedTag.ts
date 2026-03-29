import type { ResponseStruct } from '#/global'

export interface FeedTagVo {
  id: number
  // 标签名称（多语言）
  name: string
  // 标签图标
  icon: string
  // 标签颜色
  color: string
  // 内容数量
  post_count: number
  // 关注数
  follow_count: number
  // 是否热门
  is_hot: number
  // 状态：1启用 0禁用
  status: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 标签查询
export function page(params: FeedTagVo): Promise<ResponseStruct<FeedTagVo[]>> {
  return useHttp().get('/admin/ds/syscms/feed_tag/list', { params })
}

// 标签新增
export function create(data: FeedTagVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/syscms/feed_tag/create', data)
}

// 标签编辑
export function save(id: number, data: FeedTagVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/syscms/feed_tag/save/${id}`, data)
}

// 标签删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/syscms/feed_tag/delete', { data: ids })
}
