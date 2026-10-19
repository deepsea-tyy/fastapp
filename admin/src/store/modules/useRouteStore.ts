import type { Plugin } from '#/global'
import type { Router, RouteRecordRaw } from 'vue-router'
import usePluginStore from '@/store/modules/usePluginStore.ts'
import useTabStore from '@/store/modules/useTabStore.ts'
import { firstMenuRoute, flattenRoutes, menuToRoutes, normalizeRoute, NOT_FOUND_PATH, rootLayout } from '@/router/routes.ts'

const useRouteStore = defineStore(
    'useRouteStore',
    () => {
        const routesRaw = ref<RouteRecordRaw[]>([])

        async function initRoutes(router: Router, menus: any[]) {
            const menuRoutes = menuToRoutes(menus)
            const home = firstMenuRoute(menuRoutes)
            const layout = rootLayout(home?.path ?? NOT_FOUND_PATH)

            if (router.hasRoute('MineRootLayoutRoute')) {
                router.removeRoute('MineRootLayoutRoute')
            }
            router.addRoute(layout)
            routesRaw.value = router.getRoutes()
            routesRaw.value.find(route => route.name === 'MineRootLayoutRoute')?.children?.push(...menuRoutes)

            flattenRoutes(menuRoutes).forEach((route) => {
                router.addRoute('MineRootLayoutRoute', route)
            })

            const plugins = usePluginStore().getPluginConfig() as Record<string, Plugin.PluginConfig>
            Object.keys(plugins).forEach((name) => {
                const plugin = plugins[name]
                if (plugin.config?.enable !== true || !plugin.views) {
                    return
                }
                plugin.views.forEach((item: Plugin.Views) => {
                    const route = normalizeRoute(item)
                    layout.children?.push(route)
                    router.addRoute('MineRootLayoutRoute', route)
                })
            })

            await usePluginStore().callHooks('registerRoute', router, routesRaw.value)
            useTabStore().ensureHomeTab(home)
        }

        return {
            initRoutes,
            routesRaw,
        }
    },
)

export default useRouteStore
