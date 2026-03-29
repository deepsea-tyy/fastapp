import type { ResponseStruct } from '#/global'

export interface PlacementContentVo {
  id: number
  // 调用代码
  code: string
  // 内容名称
  name: string
  // 数据类型：1链接 2视频 3分享 4文章 5路径
  object_type: number
  // 关联数据ID（根据object_type关联不同表，object_type=4时关联article表）
  object_id: number
  // 链接地址（object_type=1）
  url: string
  // 链接打开方式：1当前窗口 2新窗口
  target: number
  // 标题（多语言，用于覆盖关联数据的标题）
  title: string
  // 封面图片（多语言，用于覆盖关联数据的封面）
  cover: string
  // 描述（多语言，用于覆盖关联数据的描述）
  desc: string
  // 分享内容（多语言，object_type=3分享时使用）
  content: string
  // 开始时间（时间戳）
  start_at: number
  // 结束时间（时间戳）
  end_at: number
  // 永久有效：1是 0否
  fixed: number
  // 状态：1显示 0隐藏
  status: number
  // 排序
  sort: number
  // 备注
  remark: string
  // 展示次数
  views: number
  // 点击次数
  clicks: number
  // 创建者
  created_by: number
  // 更新者
  updated_by: number
  // 创建时间
  created_at: string
  // 更新时间
  updated_at: string
}

// 投放内容查询
export function page(params: PlacementContentVo): Promise<ResponseStruct<PlacementContentVo[]>> {
  return useHttp().get('/admin/ds/sysCms/placement_content/list', { params })
}

// 投放内容新增
export function create(data: PlacementContentVo): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/ds/sysCms/placement_content/create', data)
}

// 投放内容编辑
export function save(id: number, data: PlacementContentVo): Promise<ResponseStruct<null>> {
  return useHttp().put(`/admin/ds/sysCms/placement_content/save/${id}`, data)
}

// 投放内容删除
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/sysCms/placement_content/delete', { data: ids })
}
