
import { Transition } from 'vue'
import Logo from '../logo'
import '@/layouts/style/sub-aside.scss'
import MineMenu from '@/layouts/components/menu'
import MineToolbar from '@/layouts/components/bars/toolbar'

export default defineComponent ({
  name: 'SubAside',
  setup() {
    const shadowTop = ref<boolean>(false)
    const shadowBottom = ref<boolean>(false)
    const subAsideRef = ref<HTMLElement | null>()
    const menuStore = useMenuStore()
    const route = useRoute()
    const {
      getSettings,
      getMenuCollapseState,
      showMineSubAside,
      getMobileState,
      setMobileSubmenuState,
      getMobileSubmenuState,
    } = useSettingStore()

    function onSubAsideScroll() {
      const scrollTop = subAsideRef.value?.scrollTop ?? 0
      shadowTop.value = scrollTop > 0
      const clientHeight = subAsideRef.value?.clientHeight ?? 0
      const scrollHeight = subAsideRef.value?.scrollHeight ?? 0
      shadowBottom.value = Math.ceil(scrollTop + clientHeight) < scrollHeight
    }
    const asideListClass = computed(() => {
      return {
        'mine-sub-aside-list': true,
        'shadow-top': shadowTop.value,
        'shadow-bottom': shadowBottom.value,
      }
    })
    return () => {
      return (
        <Transition name="mine-sub-aside-container">
          <div
            class={{
              'mine-sub-aside': true,
              '!absolute shadow-md': getMobileState(),
              '!w-0': getMobileState() && !getMobileSubmenuState(),
              '!w-[var(--mine-g-sub-aside-width)]': getMobileState() && getMobileSubmenuState(),
            }}
          >
            {
              showMineSubAside() || getMobileState()
              && (
                <Logo
                  showLogo={showMineSubAside() || getMenuCollapseState()}
                  showTitle={!getMenuCollapseState()}
                />
              )
            }
            <div ref={subAsideRef} class={asideListClass.value} onScroll={onSubAsideScroll}>
              <MineMenu
                menu={menuStore.allMenu}
                value={route.meta.activeName || route.path}
                default-opens={['/']}
                collapse={getMenuCollapseState()}
              />
            </div>
            {getSettings('app').showBars && (
              <div class="mine-sub-aside-bars">
                <MineToolbar />
              </div>
            )}
            {getMobileState() && (
              <div class="flex items-center h-13 justify-end px-3">
                <div
                  class="mine-sub-aside-close-button relative px-4"
                  onClick={() => setMobileSubmenuState(false)}
                >
                  <ma-svg-icon name="material-symbols:close-rounded" />
                </div>
              </div>
            )}
          </div>
        </Transition>
      )
    }
  },
})
