import type { ResponseStruct } from '#/global'

export interface PlacementPositionVo {
  id: number
  // 调用代码（唯一标识符，如：home_banner）
  code: string
  // 位置名称
  name: string
  // 状态：1启用 0禁用
  status: number
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 投放位置查询
export function page(params: PlacementPositionVo): Promise<ResponseStruct<PlacementPositionVo[]>> {
  return useHttp().get('/admin/ds/sysCms/placement_position/list', { params })
}
export function selectPlacementPosition(): Promise<ResponseStruct<PlacementPositionVo[]>> {
  return useHttp().get('/admin/ds/sysCms/placement_position/selectPlacementPosition')
}

// 投放位置新增
export function create(data: PlacementPositionVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/sysCms/placement_position/create', data)
}

// 投放位置编辑
export function save(id: number, data: PlacementPositionVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/sysCms/placement_position/save/${id}`, data)
}

// 投放位置删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/sysCms/placement_position/delete', { data: ids })
}
