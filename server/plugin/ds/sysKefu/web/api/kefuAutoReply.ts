import type { ResponseStruct } from '#/global'

export interface KefuAutoReplyVo {
  id: number
  // 规则名称
  title: string
  // 触发类型：1=关键词精确匹配，2=关键词模糊匹配，3=正则匹配
  trigger_type: number
  // 关键词列表（JSON数组，如：）
  keywords: string
  // 回复类型：1=纯文本，2=图片，3=文件，4=多条消息
  reply_type: number
  // 回复内容（JSON格式，支持多语言）
  reply_content: string
  // 语言：zh_CN=简体中文，en=英文
  lang: string
  // 优先级（数值越大优先级越高，相同优先级按ID排序）
  priority: number
  // 状态：0=禁用，1=启用
  status: number
  // 命中次数（统计用）
  hit_count: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
}

// 客服自动回复规则查询
export function page(params: KefuAutoReplyVo): Promise<ResponseStruct<KefuAutoReplyVo[]>> {
  return useHttp().get('/admin/ds/syskefu/kefu_auto_reply/list', { params })
}

// 客服自动回复规则新增
export function create(data: KefuAutoReplyVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/syskefu/kefu_auto_reply/create', data)
}

// 客服自动回复规则编辑
export function save(id: number, data: KefuAutoReplyVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/syskefu/kefu_auto_reply/save/${id}`, data)
}

// 客服自动回复规则删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/syskefu/kefu_auto_reply/delete', { data: ids })
}
