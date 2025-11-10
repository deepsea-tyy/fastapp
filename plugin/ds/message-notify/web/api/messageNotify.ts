import type { ResponseStruct } from '#/global'

export interface MessageNotifyVo {
  id: number
  // 通知标题（多语言）
  title: string | Array<{ lang: string; text: string }>
  // 通知内容（多语言）
  content: string | Array<{ lang: string; text: string }>
  // 通知类型:1-全局,2-个人
  type: number
  // 用户ID全局通知为null
  user_id: number
  // 通知分类:1-系统通知,2-业务通知,3-其他
  notify_type: number
  // 跳转链接
  link: string
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 消息通知表查询
export function page(params: MessageNotifyVo): Promise<ResponseStruct<MessageNotifyVo[]>> {
  return useHttp().get('/admin/ds/message-notify/message_notify/list', { params })
}

// 消息通知表新增
export function create(data: MessageNotifyVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/message-notify/message_notify/create', data)
}

// 消息通知表编辑
export function save(id: number, data: MessageNotifyVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/message-notify/message_notify/save/${id}`, data)
}

// 消息通知表删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/message-notify/message_notify/delete', { data: ids })
}