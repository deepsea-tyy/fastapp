
import '@/layouts/style/logo.scss'
import type { SystemSettings } from '#/global'
import LogoSvg from '/logo.svg'

export default defineComponent({
  name: 'Logo',
  props: {
    showLogo: { type: Boolean, default: true },
    showTitle: { type: Boolean, default: true },
    title: { type: String, default: null },
  },
  setup(props) {
    const title = props.title ?? import.meta.env.VITE_APP_TITLE
    const settings: SystemSettings.welcomePage = useSettingStore().getSettings('welcomePage')
    return () => {
      return (
        <router-link to={settings.path} class={['mine-main-logo', 'cursor-pointer']} title={title}>
          {props.showLogo && (
            <img src={LogoSvg} alt={title} class="mine-logo-img" />
          )}
          {props.showTitle && (
            <span class="mine-logo-title">{title}</span>
          )}
        </router-link>
      )
    }
  },
})
