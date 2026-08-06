
import { useColorMode } from '@vueuse/core'
import type { Ref } from 'vue'
import type { SystemSettings } from '#/global'
import useWatermark from '@/hooks/useWatermark'
import useThemeColor from '@/hooks/useThemeColor.ts'
import { cloneDeep } from 'lodash-es'

const useSettingStore = defineStore(
  'useSettingStore',
  () => {
    type settingType = SystemSettings.settingType | null
    const title = ref<string>('')
    const defaultSetting = ref<SystemSettings.all>(cloneDeep(useDefaultSetting()))
    const colorMode: Ref<string> = useColorMode()
    const searchPanelEnable = ref<boolean>(false)
    const menuCollapseState = ref<boolean>(true)
    const { setWatermark, clear } = useWatermark()
    const isMobile = ref<boolean>(false)
    const mobileMenuState = ref<boolean>(false)
    const userBarState = ref<boolean>(false)

    function showMineSubAside() {
      return true
    }

    function setUserBarState(state: boolean) {
      userBarState.value = state
    }

    function getUserBarState() {
      return userBarState.value
    }

    function setMobileState(state: boolean) {
      isMobile.value = state
    }

    function getMobileState() {
      return isMobile.value
    }

    function setMobileSubmenuState(state: boolean) {
      mobileMenuState.value = state
    }

    function getMobileSubmenuState() {
      return mobileMenuState.value
    }

    function getFixedAsideState() {
      return defaultSetting.value.subAside?.fixedAsideState
    }

    function setFixedAsideState(state: boolean) {
      return defaultSetting.value.subAside.fixedAsideState = state
    }

    function setToolBar(name: string, show: boolean) {
      defaultSetting.value.toolBars = defaultSetting.value.toolBars || [] // 初始化为空数组

      const existingToolBar = defaultSetting.value.toolBars.find(item => item.name === name)

      if (existingToolBar) {
        existingToolBar.show = show // 更新 show 值
      }
      else {
        defaultSetting.value.toolBars.push({ name, show }) // 添加新的工具栏项
      }
    }

    function syncToolBars(toolbars: MineToolbar[]) {
      defaultSetting.value.toolBars = toolbars.map(item => ({ name: item.name, show: item.show }))
    }

    function getMenuCollapseState() {
      return menuCollapseState.value
    }
    function setMenuCollapseState(state: boolean) {
      return menuCollapseState.value = state
    }

    function setSubAsideWidth(width: string) {
      const mineSubAsideDom: HTMLElement | null = document.querySelector('.mine-sub-aside')
      if (mineSubAsideDom) {
        mineSubAsideDom.style.width = width
      }
    }

    function getSettings(type: settingType = null): any {
      if (defaultSetting.value) {
        return type === null ? defaultSetting.value : defaultSetting.value[type]
      }
      else {
        return null
      }
    }

    function setSettings(setting: any, type: settingType = null) {
      if (type === null) {
        defaultSetting.value = setting
      }
      else {
        defaultSetting.value[type as string] = setting
      }
    }

    function initColorMode() {
      colorMode.value = defaultSetting.value?.app?.colorMode ?? 'light'
      useThemeColor().setThemeColor(defaultSetting.value.app.primaryColor)
    }

    async function toggleColorMode(modeText: 'light' | 'dark' | null = null) {
      if (modeText === null) {
        colorMode.value = colorMode.value === 'light' ? 'dark' : 'light'
      }
      else {
        colorMode.value = modeText
      }

      defaultSetting.value.app.colorMode = colorMode.value as 'light' | 'dark'
      await nextTick(() => {
        useThemeColor().initThemeColor()
        defaultSetting.value.app.enableWatermark && openGlobalWatermark()
      })
    }

    function openGlobalWatermark(str: string | string[] | null = null) {
      setWatermark((str ?? defaultSetting.value?.app?.watermarkText) as string | string[])
    }

    function clearGlobalWatermark() {
      clear()
    }

    function setSearchPanelEnable(state: boolean) {
      searchPanelEnable.value = state
    }

    function getSearchPanelEnable() {
      return searchPanelEnable.value
    }

    // 设置网页标题
    function setTitle(routeTitle: string) {
      title.value = `${import.meta.env.VITE_APP_TITLE} - ${routeTitle}`
      document.title = title.value
    }

    return {
      title,
      colorMode,
      initColorMode,
      setUserBarState,
      getUserBarState,
      setMobileState,
      getMobileState,
      setMobileSubmenuState,
      getMobileSubmenuState,
      setSearchPanelEnable,
      getSearchPanelEnable,
      showMineSubAside,
      getFixedAsideState,
      setFixedAsideState,
      setToolBar,
      syncToolBars,
      getMenuCollapseState,
      setMenuCollapseState,
      setTitle,
      setSubAsideWidth,
      toggleColorMode,
      getSettings,
      setSettings,
      openGlobalWatermark,
      clearGlobalWatermark,
    }
  },
)

export default useSettingStore
