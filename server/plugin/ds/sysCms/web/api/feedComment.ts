import type { ResponseStruct } from '#/global'

export interface FeedCommentVo {
  id: number
  // 目标类型：1帖子 2文章
  target_type: number
  // 目标ID
  target_id: number
  // 评论用户ID
  user_id: number
  // 父评论ID（0为顶级评论）
  parent_id: number
  // 根评论ID（用于楼中楼）
  root_id: number
  // 回复的用户ID
  reply_to_user_id: number
  // 评论内容
  content: string
  // 图片列表（JSON数组）
  images: string
  // 点赞数
  like_count: number
  // 回复数
  reply_count: number
  // 状态：1显示 0隐藏
  status: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
  // 软删除
  deleted_at: string
}

// 评论（通用）查询
export function page(params: FeedCommentVo): Promise<ResponseStruct<FeedCommentVo[]>> {
  return useHttp().get('/admin/ds/syscms/feed_comment/list', { params })
}

// 评论（通用）新增
export function create(data: FeedCommentVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/syscms/feed_comment/create', data)
}

// 评论（通用）编辑
export function save(id: number, data: FeedCommentVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/syscms/feed_comment/save/${id}`, data)
}

// 评论（通用）删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/syscms/feed_comment/delete', { data: ids })
}
