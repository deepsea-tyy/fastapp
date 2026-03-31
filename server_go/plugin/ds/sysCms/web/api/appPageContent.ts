import type { ResponseStruct } from '#/global'

export interface AppPageContentVo {
  id: number
  // 内容标识（唯一，如：home.welcome.title）
  code: string
  // 页面标识（如：home, market, spot）
  page_code: string
  // 组件标识（如：top_bar, banner, quick_entrance）
  component_code: string
  // 内容类型：1固定文本 2列表数据 3富文本 4配置项
  content_type: number
  // 内容数据（JSON，根据content_type存储不同类型的数据：1=多语言文本{"zh_CN":"中文","en":"English"} 2=列表数据[] 3=富文本{} 4=配置项{}）
  data: Record<string, any> | any[]
  // 平台：1Web 2App 3Both
  platform: number
  // 开始时间（时间戳）
  start_at: number
  // 结束时间（时间戳）
  end_at: number
  // 永久有效：1是 0否
  fixed: number
  // 状态：1启用 0禁用
  status: number
  // 排序
  sort: number
  // 备注
  remark: string
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 页面内容查询
export function page(params: AppPageContentVo): Promise<ResponseStruct<AppPageContentVo[]>> {
  return useHttp().get('/admin/ds/sysCms/app_page_content/list', { params })
}

// 页面内容新增
export function create(data: AppPageContentVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/sysCms/app_page_content/create', data)
}

// 页面内容编辑
export function save(id: number, data: AppPageContentVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/sysCms/app_page_content/save/${id}`, data)
}

// 页面内容删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/sysCms/app_page_content/delete', { data: ids })
}

