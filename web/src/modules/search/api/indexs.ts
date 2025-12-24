import type { ResponseStruct } from '#/global'

export interface IndexsVo {
  id: number
  // 内容类型: article|feed|activity|news
  target_type: string
  // 内容ID
  target_id: number
  // 标题
  title: string
  // 关键词数组
  keyword: string
  // 作者/发布者
  author: string
  // 标签数组
  tags: string
  // 扩展字段JSON
  extra: string
  // 权重: 1-100
  weight: number
  // 浏览量
  view_count: number
  // 点赞数
  like_count: number
  // 状态: 1=正常 0=禁用
  status: number
  // 发布时间
  published_at: string
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
  // 删除时间
  deleted_at: string
}

// 搜索索引 - 统一存储可搜索内容查询
export function page(params: IndexsVo): Promise<ResponseStruct<IndexsVo[]>> {
  return useHttp().get('/admin/search/indexs/list', { params })
}

// 搜索索引 - 统一存储可搜索内容新增
export function create(data: IndexsVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/search/indexs/create', data)
}

// 搜索索引 - 统一存储可搜索内容编辑
export function save(id: number, data: IndexsVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/search/indexs/save/${id}`, data)
}

// 搜索索引 - 统一存储可搜索内容删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/search/indexs/delete', { data: ids })
}
