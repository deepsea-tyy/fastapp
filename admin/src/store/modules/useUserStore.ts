import useCache from '@/hooks/useCache.ts'
import type { ResponseStruct } from '#/global'
import useHttp from '@/hooks/auto-imports/useHttp.ts'
import * as PermissionApi from '~/base/api/permission.ts'
import type { MenuVo, RoleVo } from '~/base/api/permission.ts'
import { recursionGetKey } from '@/utils/recursionGetKey.ts'
import useWebSocketStore from './useWebSocketStore'

export interface LoginParams {
  username: string
  password: string
}

export interface LoginResult {
  access_token: string
  expire_at: number
  refresh_token: string
}

export interface UserInfo {
  username: string
  nickname: string
  avatar: string
  phone: string
  email: string
  signed: string
  lang?: string
  dashboard: string
}

function getInfo(): Promise<ResponseStruct<UserInfo>> {
  return useHttp().get('/admin/passport/getInfo')
}

function logoutApi(): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/passport/logout')
}

/**
 * Passport login
 * @param data
 */
function loginApi(data: LoginParams): Promise<ResponseStruct<LoginResult>> {
  return useHttp().post('/admin/passport/login', data)
}

const useUserStore = defineStore(
  'useUserStore',
  () => {
    const cache = useCache()
    const router = useRouter()
    const token = ref<string | null>(cache.get('token', null))
    const locales = ref<any[]>([])
    const language = ref(cache.get('language', 'zh_CN'))
    const isLogin = computed(() => !!token.value)
    const userInfo = ref<any | null>(null)
    const menu = ref<MenuVo[]>([])
    const permissions = ref<string[]>([])
    const roles = ref<string[]>([])
    const dropdownMenuState = ref<{
      shortcuts: boolean
      systemInfo: boolean
    }>({
      shortcuts: false,
      systemInfo: false,
    })

    function getDropdownMenu() {
      return dropdownMenuState.value
    }

    function setDropdownMenuState(key: string, state: boolean) {
      if (dropdownMenuState.value[key] !== undefined) {
        dropdownMenuState.value[key] = state
      }
    }

    function getMenu() {
      return menu.value
    }

    function setMenu(list: MenuVo[]) {
      menu.value = list
    }

    function getDropdownMenuState(key: string) {
      return dropdownMenuState.value[key] !== undefined ? dropdownMenuState.value[key] : undefined
    }

    async function refreshRole() {
      const res = await PermissionApi.getRoles()
      setRoles(res.data)
    }

    async function refreshMenu() {
      const res = await PermissionApi.getMenus()
      setMenu(res.data)
    }

    async function login(data: { username: string, password: string, code: string, [key: string]: any }) {
      await usePluginStore().callHooks('loginBefore', data)
      return new Promise((resolve, reject) => {
        loginApi(data).then(async (res) => {
          token.value = res.data.access_token
          cache.set('token', res.data.access_token)
          cache.set('expire', useDayjs().unix() + res.data.expire_at, { exp: res.data.expire_at })
          cache.set('refresh_token', res.data.refresh_token)
          await usePluginStore().callHooks('login', { username: data.username, ...res.data })
          // WebSocket 会通过 token watch 自动初始化
          resolve(res.data)
        }).catch((error) => {
          reject(error)
        })
      })
    }
    async function requestUserInfo(): Promise<void> {
      try {
        const routeStore = useRouteStore()
        const { data } = await getInfo()
        setUserInfo(data)
        if (data?.lang) {
          setLanguage(data.lang)
        }
        await refreshMenu()
        await refreshRole()
        await routeStore.initRoutes(router, getMenu())
        const codes: string[] = recursionGetKey(getMenu(), 'name')
        getRoles().includes('SuperAdmin') && codes.unshift('*')
        setPermissions(codes)
        await usePluginStore().callHooks('getUserInfo', data)
      }
      // eslint-disable-next-line unused-imports/no-unused-vars
      catch (e) {
        await logout()
      }
    }

    async function logout(redirect = router.currentRoute.value.fullPath) {
      await usePluginStore().callHooks('logout')

      // 调用退出登录接口
      try {
        await logoutApi()
      } catch (error) {
        // 即使接口失败也继续执行本地清理
      }

      useTabStore().clearTab()
      // 退出登录时关闭 WebSocket 连接
      const wsStore = useWebSocketStore()
      wsStore.closeWebSocket()
      clearInfo()
      await router.push({
        name: 'login',
        query: {
          ...(router.currentRoute.value.name !== 'login' && { redirect }),
        },
      })
    }

    function setLanguage(langName: string) {
      if (!langName || typeof langName !== 'string' || !langName.trim()) return false
      language.value = langName.trim()
      cache.set('language', language.value)
      return true
    }

    function getLanguage() {
      return language.value
    }

    function getLocales(): any[] {
      return locales.value
    }

    function setLocales(localeArray: any[]): boolean {
      locales.value = localeArray
      return true
    }

    function getUserInfo(): any {
      return userInfo.value
    }

    function setUserInfo(data: any): boolean {
      userInfo.value = data
      return true
    }

    function getPermissions(): string[] {
      return permissions.value
    }

    function setPermissions(permissionArray: string[]): boolean {
      permissions.value = permissionArray
      return true
    }

    function getRoles(): string[] {
      return roles.value
    }

    function setRoles(roleArray: RoleVo[]): boolean {
      roles.value = roleArray.map(item => item.code) as string[]
      return true
    }

    async function clearCache() {
      await useHttp().get('/admin/user/clearCache')
    }

    function clearInfo() {
      cache.remove('token')
      cache.remove('refresh_token')
      cache.remove('language')
      cache.remove('expire')
      token.value = null
      language.value = ''
      userInfo.value = null
      permissions.value = []
      roles.value = []
    }

    return {
      token,
      isLogin,
      login,
      logout,
      getDropdownMenu,
      getDropdownMenuState,
      setDropdownMenuState,
      clearCache,
      setLanguage,
      getLanguage,
      requestUserInfo,
      getUserInfo,
      setPermissions,
      getPermissions,
      getRoles,
      getLocales,
      setLocales,
      getMenu,
    }
  },
)

export default useUserStore
