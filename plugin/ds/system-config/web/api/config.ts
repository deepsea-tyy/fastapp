import type { ResponseStruct } from '#/global'

interface ConfigSelectData {
  label: string // 显示的标签
  value: string | number // 值，可以是字符串或数字
}

export interface ConfigVo {
  group_code?: string
  key?: string
  value?: string
  name?: string
  input_type?: string
  config_select_data?: Array<ConfigSelectData>
  sort?: number
  remark?: string
}

// System/Config查询
export function page(params: ConfigVo): Promise<ResponseStruct<ConfigVo[]>> {
  return useHttp().get('/system/Config/list', { params })
}

// System/Config新增
export function create(data: ConfigVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/system/Config', data)
}

// System/Config编辑
export function save(id: number, data: ConfigVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/system/Config/${id}`, data)
}

// System/Config删除
export function deleteByKey(key: string): Promise<ResponseStruct<null>> {
  return useHttp().delete('/system/Config', { data: { key } })
}

// System/Config详情
export function details(code: string): Promise<ResponseStruct<ConfigVo>> {
  return useHttp().get(`/system/Config/Details/${code}`)
}

// 批量更新
export function batchUpdate(data: ConfigVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/system/Config/batchUpdate', data)
}
