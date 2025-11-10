
import type { ProviderService, RecursiveRequired, SystemSettings } from '#/global'
import type { App } from 'vue'
import globalConfigSettings from '@/provider/settings/settings.config.ts'
import { defaultsDeep } from 'lodash-es'

const defaultGlobalConfigSettings: RecursiveRequired<SystemSettings.all> = {
  app: {
    colorMode: 'autoMode',
    useLocale: 'zh_CN',
    whiteRoute: ['login'],
    layout: 'classic',
    pageAnimate: 'ma-slide-down',
    enableWatermark: false,
    primaryColor: '#2563EB',
    asideDark: false,
    showBreadcrumb: true,
    loadUserSetting: true,
    watermarkText: import.meta.env.VITE_APP_TITLE,
  },
  welcomePage: {
    name: 'welcome',
    path: '/welcome',
    title: '欢迎页',
    icon: 'icon-park-outline:jewelry',
  },
  mainAside: {
    showIcon: true,
    showTitle: true,
    enableOpenFirstRoute: false,
  },
  subAside: {
    showIcon: true,
    showTitle: true,
    fixedAsideState: false,
    showCollapseButton: true,
  },
  tabbar: {
    enable: true,
    mode: 'rectangle',
  },
  copyright: {
    enable: true,
    dates: useDayjs().format('YYYY'),
    company: import.meta.env.VITE_APP_TITLE,
    website: '',
    putOnRecord: '豫ICP备00000000号-1',
  },
}

const systemSetting = defaultsDeep(globalConfigSettings, defaultGlobalConfigSettings) as RecursiveRequired<SystemSettings.all>

const provider: ProviderService.Provider = {
  name: 'defaultSetting',
  setProvider(app: App): void {
    app.provide('defaultSetting', systemSetting)
  },
  getProvider() {
    return inject('defaultSetting') as SystemSettings.all
  },
}

export default provider as ProviderService.Provider
