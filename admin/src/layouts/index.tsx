
import { KeepAlive, Transition } from 'vue'
import { RouterView } from 'vue-router'
import MineSearchPanel from './components/search-panel'
import MineSubAside from './components/sub-aside'
import MineFooter from './components/footer'
import MineBackTop from './components/back-top'
import MineIframe from './components/iframe'
import '@/layouts/style/index.scss'
import type { SystemSettings } from '#/global'
import handleResize from '@/utils/handleResize'

export default defineComponent({
  name: 'MineContainer',
  setup() {
    const {
      getSettings,
      openGlobalWatermark,
      clearGlobalWatermark,
      getSearchPanelEnable,
      getMobileState,
    } = useSettingStore()

    const subAsideEl = ref()
    const keepAliveStore = useKeepAliveStore()
    const appSetting = getSettings('app') as SystemSettings.app
    const menuStore = useMenuStore()
    const route = useRoute()

    watch(() => appSetting.enableWatermark, (v: boolean | undefined) => {
      v && openGlobalWatermark()
      v || clearGlobalWatermark()
    }, { immediate: true })

    onMounted(() => {
      menuStore.setSubAsideWidthByDefault()
      handleResize(subAsideEl)
    })

    return () => (
      <div class="app-container">
        <div class={{
          'mine-wrapper': true,
          'mine-wrapper-full': getMobileState(),
          'mine-wrapper-not-full': !getMobileState(),
        }}
        >
          <Transition name="mine-aside-animate">
            <div class={{ 'group mine-aside': true, 'w-0': getMobileState() }}>
              <MineSubAside ref={subAsideEl} />
            </div>
          </Transition>
          <div class="mine-main">
            <div class={{
              'mine-worker-area': true,
              'mine-worker-area--full': route.meta?.fullPage,
            }}>
              <RouterView class="router-view">
                {({ Component }) => (
                  <Transition name={appSetting.pageAnimate} mode="out-in">
                    <KeepAlive include={keepAliveStore.list}>
                      {(keepAliveStore.getShowState() && route.meta.type !== 'I') && <Component key={route.fullPath} />}
                    </KeepAlive>
                  </Transition>
                )}

              </RouterView>
            </div>
            <div class="mine-iframe-area" v-show={route.meta?.type === 'I'}>
              <MineIframe />
            </div>
            <MineFooter />
            <MineBackTop />
          </div>

        </div>
        <div class="mine-max-size-exit" onClick={() => useTabStore().exitMaxSizeTab()}>
          <ma-svg-icon name="i-material-symbols:close" size={50} />
        </div>

        <MineSearchPanel v-show={getSearchPanelEnable()} />
      </div>
    )
  },
})
