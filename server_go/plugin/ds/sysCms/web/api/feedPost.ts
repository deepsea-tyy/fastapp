import type { ResponseStruct } from '#/global'

export interface FeedPostVo {
  id: number
  // 发布用户ID
  user_id: number
  // 内容类型：1纯文本 2图文 3视频 4链接
  content_type: number
  // 标题（可选）
  title: string
  // 内容
  content: string
  // 图片列表（JSON数组）
  images: string
  // 视频列表（JSON数组）
  videos: string
  // 外链地址
  link_url: string
  // 链接元数据（标题、描述、封面等）
  link_meta: string
  // 引用类型：1帖子 2文章
  quoted_type: number
  // 引用的内容ID
  quoted_id: number
  // 审核状态：0待审核 1已通过 2已拒绝
  audit_status: number
  // 审核时间
  audited_at: string
  // 是否置顶：0否 1是
  is_top: number
  // 是否热门：0否 1是
  is_hot: number
  // 状态：1显示 0隐藏
  status: number
  // 浏览次数
  view_count: number
  // 点赞数
  like_count: number
  // 评论数
  comment_count: number
  // 分享数
  share_count: number
  // 收藏数
  collect_count: number
  // 引用数
  quote_count: number
  // 发布IP
  ip: string
  // 设备类型：ios, android, web
  device_type: string
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
  // 软删除
  deleted_at: string
}

// 用户帖子（UGC）查询
export function page(params: FeedPostVo): Promise<ResponseStruct<FeedPostVo[]>> {
  return useHttp().get('/admin/ds/syscms/feed_post/list', { params })
}

// 用户帖子（UGC）新增
export function create(data: FeedPostVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/syscms/feed_post/create', data)
}

// 用户帖子（UGC）编辑
export function save(id: number, data: FeedPostVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/syscms/feed_post/save/${id}`, data)
}

// 用户帖子（UGC）删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/syscms/feed_post/delete', { data: ids })
}
