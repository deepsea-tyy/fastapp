
import '@/layouts/style/logo.scss'

const appLogo = import.meta.env.VITE_APP_LOGO ?? '/logo.svg'

export default defineComponent({
  name: 'Logo',
  props: {
    showLogo: { type: Boolean, default: true },
    showTitle: { type: Boolean, default: true },
    title: { type: String, default: null },
  },
  setup(props) {
    const title = props.title ?? import.meta.env.VITE_APP_TITLE
    return () => {
      return (
        <router-link to="/" class={['mine-main-logo', 'cursor-pointer']} title={title}>
          {props.showLogo && (
            <img src={appLogo} alt={title} class="mine-logo-img" />
          )}
          {props.showTitle && (
            <span class="mine-logo-title">{title}</span>
          )}
        </router-link>
      )
    }
  },
})
