import type { ResponseStruct } from '#/global'

export interface CategoryVo {
  id: number
  // 名称
  name: string
  // icon
  icon: string
  // 排序
  sort: number
  // 上级
  parent_id: number
  // 1显示
  status: number
  // 备注
  remark: string
  // 调用代码
  code: string
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 分类表查询
export function page(params: CategoryVo): Promise<ResponseStruct<CategoryVo[]>> {
  return useHttp().get('/admin/article/category/list', { params })
}

// 分类表新增
export function create(data: CategoryVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/article/category/create', data)
}

// 分类表编辑
export function save(id: number, data: CategoryVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/article/category/save/${id}`, data)
}

// 分类表删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/article/category/delete', { data: ids })
}

// 分类表删除
export function selectCategory(params:any): Promise<ResponseStruct<null>> {
  return useHttp().get('/admin/article/category/selectCategory', { params })
}