
import type { PageList, ResponseStruct } from '#/global'

export interface DepartmentVo {
  id?: number
  name?: string
  code?: string
  parent_id?: number
  sort?: number
  status?: number
  remark?: string
  children?: DepartmentVo[]
  [key: string]: any
}

export interface DepartmentSearchVo {
  name?: string
  code?: string
  status?: number
  [key: string]: any
}

export function page(data: DepartmentSearchVo): Promise<ResponseStruct<PageList<DepartmentVo>>> {
  return useHttp().get('/admin/department/list', { params: data })
}

export function selectDept(data?: DepartmentSearchVo): Promise<ResponseStruct<DepartmentVo[]>> {
  return useHttp().get('/admin/department/selectDept', { params: data })
}

export function create(data: DepartmentVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/department', data)
}

export function save(id: number, data: DepartmentVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/department/${id}`, data)
}

export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/department', { data: ids })
}
