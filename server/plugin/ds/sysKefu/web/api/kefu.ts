

/**
 * Kefu API JS
 */

/**
* 获取Kefu分页列表
* @returns
*/
export function page(data: any): Promise<ResponseStruct<any>> {
    return useHttp().get('/admin/ds/sysKefu/kefu/list', { params: data })
}
export function selectAdmin(): Promise<ResponseStruct<any>> {
    return useHttp().get('/admin/ds/sysKefu/kefu/selectAdmin' )
}

/**
* 添加Kefu
* @returns
*/
export function create(data: any): Promise<ResponseStruct<any>> {
  return useHttp().post('/admin/ds/sysKefu/kefu/create', data)
}
/**
* 更新Kefu数据
* @returns
*/
export function save(id: number, data: any): Promise<ResponseStruct<any>> {
    return useHttp().put(`/admin/ds/sysKefu/kefu/save/${id}`, data)
}

/**
* 将Kefu删除，有软删除则移动到回收站
* @returns
*/
export function deleteByIds(ids: number[]): Promise<ResponseStruct<null>> {
  return useHttp().delete('/admin/ds/sysKefu/kefu/delete', { data: ids })
}
