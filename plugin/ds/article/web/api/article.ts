import type { ResponseStruct } from '#/global'

export interface ArticleVo {
  id: number
  // 标题
  title: string
  // 副标题
  subtitle: string
  // 作者
  author: string
  // 封面
  cover: string
  // 视频
  video: string
  // 发布日期
  release_at: string
  // 摘要
  brief: string
  // 内容
  content: string
  // 备注
  remark: string
  // 排序
  sort: number
  // 评论数
  comment: number
  // 浏览数
  views: number
  // 点赞数
  like: number
  // 1显示
  status: number
  // 调用代码
  code: string
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 文章表查询
export function page(params: ArticleVo): Promise<ResponseStruct<ArticleVo[]>> {
  return useHttp().get('/admin/article/article/list', { params })
}

// 文章表新增
export function create(data: ArticleVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/article/article/create', data)
}

// 文章表编辑
export function save(id: number, data: ArticleVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/article/article/save/${id}`, data)
}

// 文章表删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/article/article/delete', { data: ids })
}