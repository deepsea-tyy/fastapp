
import { useFullscreen } from '@vueuse/core'

export default defineComponent({
  name: 'fullscreen',
  setup() {
    const { isFullscreen, toggle } = useFullscreen(document.body, { autoExit: true })
    return () => (
      <div class="hidden items-center lg:flex">
        <ma-svg-icon
          class="tool-icon"
          name={isFullscreen.value ? 'mingcute:fullscreen-exit-line' : 'mingcute:fullscreen-line'}
          size={20}
          onClick={() => toggle()}
        />
      </div>
    )
  },
})
