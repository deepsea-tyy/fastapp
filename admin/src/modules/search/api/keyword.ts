import type { ResponseStruct } from '#/global'

export interface KeywordVo {
  id: number
  // 搜索关键词
  keyword: string
  // 命中次数
  hit_count: number
  // 图标名称
  icon: string
  // 图标颜色(十六进制)
  color: string
  // 来源:1=用户搜索,2=热门推荐,3=系统推荐
  source: number
  // 排序(数字越大越靠前)
  sort: number
  // 最后搜索时间
  last_searched_at: string
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 搜索关键词记录查询
export function page(params: KeywordVo): Promise<ResponseStruct<KeywordVo[]>> {
  return useHttp().get('/admin/search/keyword/list', { params })
}

// 搜索关键词记录新增
export function create(data: KeywordVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/search/keyword/create', data)
}

// 搜索关键词记录编辑
export function save(id: number, data: KeywordVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/search/keyword/save/${id}`, data)
}

// 搜索关键词记录删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/search/keyword/delete', { data: ids })
}
