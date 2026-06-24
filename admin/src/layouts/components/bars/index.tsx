
import MineTabbar from './tabbar'
import MineToolbar from './toolbar'

export default defineComponent({
  name: 'Bars',
  setup() {
    const settingStore = useSettingStore()
    return () => (
      settingStore.getSettings('app').showBars && (
        <div class="mine-bars">
          <MineToolbar />
          {settingStore.getSettings('tabbar').enable && <MineTabbar />}
        </div>
      )
    )
  },
})
