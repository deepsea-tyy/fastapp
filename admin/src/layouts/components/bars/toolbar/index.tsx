
import type { MineTabbar } from '#/global'
import Logo from '@/layouts/components/logo'
import MineRightBar from './components/right-bar.tsx'
import '@/layouts/style/toolbar.scss'

export default defineComponent({
  name: 'Toolbar',
  setup() {
    const settingStore = useSettingStore()
    return () => (
      <div class="mine-toolbar overflow-hidden">
        <div class="flex items-center gap-x-3 lg:hidden">
          <Logo showTitle={false} />
          <ma-svg-icon name="material-symbols:menu-rounded" size={20} class="cursor-pointer" onClick={() => settingStore.setMobileSubmenuState(true)} />
        </div>
        <MineRightBar />
      </div>
    )
  },
})
