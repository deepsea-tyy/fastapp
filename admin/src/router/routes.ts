import type { RouteRecordRaw } from 'vue-router'

export interface HomeRoute {
    name: string
    path: string
    title: string
    icon?: string
    i18n?: string
}

export const NOT_FOUND_PATH = '/404'

const moduleViews = import.meta.glob('../modules/**/views/**/**.{vue,jsx,tsx}')
const pluginViews = import.meta.glob('../plugins/*/**/views/**/**.{vue,jsx,tsx}')

function errorPage() {
    return import('@/layouts/[...all].tsx')
}

function resolveView(component: string, suffix: string, title: string) {
    const moduleKey = `../modules/${component}${suffix}`
    const pluginKey = `../plugins/${component}${suffix}`
    if (moduleViews[moduleKey]) {
        return moduleViews[moduleKey]
    }
    if (pluginViews[pluginKey]) {
        return pluginViews[pluginKey]
    }
    console.warn(`路由 [${title}] 找不到 ${component}${suffix} 页面`)
    return errorPage
}

export function menuToRoutes(routerMap: any[] = []): RouteRecordRaw[] {
    const routes: RouteRecordRaw[] = []
    routerMap.forEach((item: any) => {
        if (item.meta?.type === 'B') {
            return
        }

        const meta = item.meta ?? {}
        const route: RouteRecordRaw = {
            path: meta.type === 'I' ? `/MineIframe/${item.name}` : item.path,
            name: item.name,
            meta,
        }
        if (meta.type === 'I') {
            route.component = () => import('@/layouts/components/iframe/index.tsx')
        }
        else if (item.component) {
            const suffix: string = meta.componentSuffix ?? '.vue'
            route.component = resolveView(item.component, suffix, meta.title)
        }
        if (item.children?.length) {
            route.children = menuToRoutes(item.children)
        }
        routes.push(route)
    })
    return routes
}

export function firstMenuRoute(routes: RouteRecordRaw[] = []): HomeRoute | null {
    for (const route of routes) {
        const meta = route.meta ?? {}
        if (meta.type === 'L' || meta.hidden) {
            continue
        }
        if ((meta.type === 'I' || route.component) && route.path && route.name) {
            return {
                name: String(route.name),
                path: route.path,
                title: (meta.title as string) ?? '',
                icon: meta.icon as string | undefined,
                i18n: meta.i18n as string | undefined,
            }
        }
        if (route.children?.length) {
            const child = firstMenuRoute(route.children)
            if (child) {
                return child
            }
        }
    }
    return null
}

export function rootLayout(redirect: string): RouteRecordRaw {
    return {
        name: 'MineRootLayoutRoute',
        path: '/',
        component: () => import('@/layouts'),
        redirect,
        children: [
            {
                name: 'uc:index',
                path: '/uc/index',
                component: () => import('~/base/views/uc/index.vue'),
                meta: {
                    title: '个人中心',
                    icon: 'heroicons:user-circle',
                    type: 'M',
                    hidden: true,
                },
            },
            {
                name: 'uc:google2fa',
                path: '/uc/google2fa',
                component: () => import('~/base/views/uc/google2fa.vue'),
                meta: {
                    title: 'Google 2FA 设置',
                    icon: 'heroicons:shield-check',
                    type: 'M',
                    hidden: true,
                },
            },
            {
                path: '/:pathMatch(.*)*',
                name: 'MineSystemError',
                component: errorPage,
                meta: {
                    hidden: true,
                    i18n: 'menu.pageError',
                },
            },
        ],
    }
}

export function flattenRoutes(routes: any[] = [], breadcrumb: any[] = []) {
    const res: any[] = []
    routes.forEach((route) => {
        const tmp = { ...route }
        if (tmp.children) {
            const childrenBreadcrumb = [...breadcrumb, route]
            const tmpRoute = { ...route }
            tmpRoute.meta = tmpRoute.meta ?? {}
            tmpRoute.meta.breadcrumb = childrenBreadcrumb
            delete tmpRoute.children
            res.push(tmpRoute)
            flattenRoutes(tmp.children, childrenBreadcrumb).forEach(item => res.push(item))
        }
        else {
            const tmpBreadcrumb = [...breadcrumb, tmp]
            tmp.meta = tmp.meta ?? {}
            tmp.meta.breadcrumb = tmpBreadcrumb
            res.push(tmp)
        }
    })
    return res
}

export function normalizeRoute(route: any) {
    return flattenRoutes([route])[0].meta.breadcrumb[0]
}
