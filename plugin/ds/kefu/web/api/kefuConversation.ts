

/**
 * KefuConversation API JS
 */

import type { ResponseStruct, PageList } from '#/global'

/**
* 获取KefuConversation分页列表
* @returns
*/
export function page(data: any): Promise<ResponseStruct<any>> {
    return useHttp().get('/admin/kefu/kefuConversation/list', { params: data })
}
export function chatTree(): Promise<ResponseStruct<any>> {
    return useHttp().get('/admin/kefu/kefuConversation/chatTree')
}

export function chatVisitorTree(): Promise<ResponseStruct<any>> {
    return useHttp().get('/admin/kefu/kefuConversation/chatVisitorTree')
}

/**
* 将KefuConversation删除，有软删除则移动到回收站
* @returns
*/
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/kefu/kefuConversation', { data: ids })
}

/**
* 获取会话消息列表
* @returns
*/
export function getMessages(data: {
  conversation_id: number
  page?: number
  page_size?: number
}): Promise<ResponseStruct<PageList<any>>> {
  return useHttp().get('/admin/kefu/kefuConversation/message', { params: data })
}

export function getMessageVisitor(data: {
  visitor_id: string
  kefu_id: string
  page?: number
  page_size?: number
}): Promise<ResponseStruct<PageList<any>>> {
  return useHttp().get('/admin/kefu/kefuConversation/messageVisitor', { params: data })
}

/**
* 发送消息
* @returns
*/
export function sendMessage(data: {
  conversation_id: number
  admin_id?: number
  content: string
  message_type?: number
  file_url?: string
}): Promise<ResponseStruct<any>> {
  return useHttp().post('/admin/kefu/kefuConversation/send', data)
}

/**
* 消息已读状态
* @returns
*/
export function batchRead(data: {
  conversation_id: number
  sender_type: number
  message_ids: number[]
}): Promise<ResponseStruct<any>> {
  return useHttp().put('/admin/kefu/kefuConversation/batchRead', data)
}
