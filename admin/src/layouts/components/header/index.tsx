
import { Transition } from 'vue'
import '@/layouts/style/header.scss'
import Logo from '@/layouts/components/logo'
import MainAside from '@/layouts/components/main-aside'

export default defineComponent({
  name: 'Header',
  setup() {
    const settingStore = useSettingStore()
    return () => {
      return (
        <Transition name="mine-header">
          {settingStore.showMineHeader() && (
            <div class="mine-header-main hidden lg:flex">
              <Logo class="ml-2 overflow-hidden !w-[var(--mine-g-sub-aside-width)]" />
              <div class="w-[calc(100%-var(--mine-g-sub-aside-width))]">
                { settingStore.getSettings('app').layout === 'mixed' && <MainAside /> }
              </div>
            </div>
          )}
        </Transition>
      )
    }
  },
})
