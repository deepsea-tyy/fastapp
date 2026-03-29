import type { ResponseStruct } from '#/global'
/**
 * systemConfigConfigGroup API JS
 */

export interface ConfigGroupVo {
  id?: number// 主键ID
  name: string// 配置组名称
  code: string// 配置组标识
  icon?: string// 配置组图标 (可选)
  remark?: string
}

export interface ConfigGroupListVo {
  id?: number// 主键ID
  name: string// 配置组名称
  code: string// 配置组标识
  icon?: string// 配置组图标 (可选)
  remark?: string
  info: Array<ConfigVo>
  updated_at?: string
  created_at?: string
}

export interface ConfigVo {
  group_code?: string// 组code
  key?: string// 配置键名
  value?: string// 配置值
  name?: string// 配置名称
  input_type?: string // 输入类型
  config_select_data?: Array<any> // 配置选项
  remark?: string
}

/**
 * 获取systemConfigConfigGroup分页列表
 * @returns
 */
export function page(data: any): Promise<ResponseStruct<any>> {
  return useHttp().get('/system/ConfigGroup/list', { params: data })
}

/**
 * 添加systemConfigConfigGroup
 * @returns
 */
export function create(data: any): Promise<ResponseStruct<any>> {
  return useHttp().post('/system/ConfigGroup', data)
}
/**
 * 更新systemConfigConfigGroup数据
 * @returns
 */
export function save(id: number, data: any): Promise<ResponseStruct<any>> {
  return useHttp().put(`/system/ConfigGroup/${id}`, data)
}

/**
 * 将systemConfigConfigGroup删除，有软删除则移动到回收站
 * @returns
 */
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/system/ConfigGroup', { data: ids })
}
