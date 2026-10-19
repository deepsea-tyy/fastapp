
import { useSorted } from '@vueuse/core'
import type { MineTabbar } from '#/global'
import useCache from '@/hooks/useCache.ts'
import { NOT_FOUND_PATH, type HomeRoute } from '@/router/routes.ts'

const useTabStore = defineStore(
  'useTabStore',
  () => {
    const { set, get } = useCache()
    const route = useRoute()
    const router = useRouter()
    const settingStore = useSettingStore()
    const keepAliveStore = useKeepAliveStore()
    const iframeKeepLiveStore = useIframeKeepAliveStore()
    const tabList = ref<MineTabbar[]>([])
    const defaultTab = ref<MineTabbar>({
      name: '',
      path: '/',
      fullPath: '/',
      title: '',
      affix: true,
    })

    function ensureHomeTab(home: HomeRoute | null) {
      defaultTab.value = home
        ? {
            name: home.name,
            path: home.path,
            fullPath: home.path,
            title: home.title,
            icon: home.icon,
            i18n: home.i18n,
            affix: true,
          }
        : {
            name: 'MineSystemError',
            path: NOT_FOUND_PATH,
            fullPath: NOT_FOUND_PATH,
            title: '',
            i18n: 'menu.pageError',
            affix: true,
          }
      if (home && tabList.value.length === 0) {
        addTab(defaultTab.value)
      }
    }

    function initTab() {
      tabList.value = get('tabList', [])
      watch(() => tabList.value, () => storage(), { immediate: true, deep: true })
    }

    function affixTab(tab: MineTabbar) {
      tab.affix = true
      useSorted(tabList.value,
        (a: MineTabbar, b: MineTabbar) => Number(b.affix) - Number(a.affix),
        { dirty: true },
      )
    }

    function cancelAffixTab(tab: MineTabbar) {
      tab.affix = false
    }

    function addTab(route: MineTabbar) {
      if (route.name === 'MineSystemError') {
        return
      }
      if (!tabList.value?.find(item => item.fullPath === route.fullPath)
        && !settingStore.getSettings('app').whiteRoute.includes(route.name)
      ) {
        tabList.value?.push({
          name: route.name,
          path: route.path,
          fullPath: route?.fullPath ?? route.path,
          i18n: route?.i18n,
          affix: route?.affix === true,
          icon: route?.icon,
          title: route?.title,
        } as MineTabbar)
      }
    }

    async function maxSizeTab(tab: MineTabbar) {
      await go(tab)
      document.querySelector('#app')?.classList.add('mine-max-size')
    }

    function exitMaxSizeTab() {
      document.querySelector('#app')?.classList.remove('mine-max-size')
    }

    async function refreshTab(tab: MineTabbar | null = null) {
      if (tab === null) {
        tab = getCurrentTab() as MineTabbar
      }
      keepAliveStore.hidden()
      await new Promise(resolve => resolve(setTimeout(() => {
      }, 200)))
      if (tab.path.indexOf('MineIframe') > 0) {
        iframeKeepLiveStore.remove(tab.name)
      }
      keepAliveStore.remove(tab.name)
      await nextTick(async () => {
        iframeKeepLiveStore.add(tab.name)
        keepAliveStore.add(tab.name)
        keepAliveStore.display()
        await go(tab)
      })
    }

    function closeTab(tab: MineTabbar) {
      if (tab.affix) {
        return
      }
      tabList.value?.map(async (item: MineTabbar, idx: number) => {
        if (item.fullPath === tab.fullPath) {
          if (route.fullPath === tab.fullPath) {
            if (tabList.value[idx + 1]) {
              await router.push(tabList.value[idx + 1].fullPath)
            }
            else if (idx > 0) {
              await router.push(tabList.value[idx - 1].fullPath)
            }
          }
          if (tab.path.indexOf('MineIframe') > 0) {
            iframeKeepLiveStore.remove(tab.name)
          }
          tabList.value.splice(idx, 1)
          keepAliveStore.remove(item.name)
        }
      })
    }

    async function closeOtherTab(tab: MineTabbar) {
      tabList.value = tabList.value?.filter((item: any) => {
        if (item.fullPath === tab.fullPath || item.affix === true) {
          return true
        }
        else {
          if (item.path.indexOf('MineIframe') > 0) {
            iframeKeepLiveStore.remove(item.name)
          }
          keepAliveStore.remove(item.name)
          return false
        }
      })
      await go(tab)
    }
    async function closeLeftTab(tab: MineTabbar) {
      let index: number = -1
      tabList.value?.find((item: MineTabbar, idx: number) => {
        if (item.fullPath === tab.fullPath) {
          index = idx
        }
      })

      if (index !== -1) {
        tabList.value = tabList.value.filter((item: MineTabbar, idx: number) => {
          if (idx >= index || item.affix === true) {
            return true
          }
          else {
            if (item.path.indexOf('MineIframe') > 0) {
              iframeKeepLiveStore.remove(item.name)
            }
            keepAliveStore.remove(item.name)
            return false
          }
        })
        await go(tab)
      }
    }
    async function closeRightTab(tab: MineTabbar) {
      let index: number = -1
      tabList.value?.find((item: MineTabbar, idx: number) => {
        if (item.fullPath === tab.fullPath) {
          index = idx
        }
      })

      if (index !== -1) {
        tabList.value = tabList.value.filter((item: MineTabbar, idx: number) => {
          if (idx <= index || item.affix === true) {
            return true
          }
          else {
            if (item.path.indexOf('MineIframe') > 0) {
              iframeKeepLiveStore.remove(item.name)
            }
            keepAliveStore.remove(item.name)
            return false
          }
        })
        await go(tab)
      }
    }

    function closeCurrentTab() {
      closeTab(getCurrentTab() as MineTabbar)
    }

    function getCurrentTab() {
      return tabList.value.find(item => item.fullPath === route.fullPath)
    }

    function changeTabTitle(title: string, tab: MineTabbar | null = null) {
      const t = (tab ?? getCurrentTab())
      t!.title = title
      delete t?.i18n
      useSettingStore().setTitle(title)
      storage()
    }

    function clearTab() {
      tabList.value = []
      keepAliveStore.clean()
      iframeKeepLiveStore.clean()
    }

    function storage() {
      set('tabList', tabList.value)
    }

    async function go(item: any) {
      await router.replace(item?.fullPath ?? item.path)
    }

    return {
      tabList,
      defaultTab,
      go,
      initTab,
      ensureHomeTab,
      changeTabTitle,
      affixTab,
      cancelAffixTab,
      maxSizeTab,
      exitMaxSizeTab,
      refreshTab,
      addTab,
      closeTab,
      closeOtherTab,
      closeLeftTab,
      closeRightTab,
      getCurrentTab,
      closeCurrentTab,
      clearTab,
    }
  },
)

export default useTabStore
