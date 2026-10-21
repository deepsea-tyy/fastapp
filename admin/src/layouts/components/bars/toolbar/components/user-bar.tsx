
import { useI18n } from 'vue-i18n'
import Message from 'vue-m-message'
import MineSystemInfo from './dropdownMenuComponents/system-info.tsx'
import {formatFileUrl} from "@/utils/common.ts";

export default defineComponent({
  name: 'UserBar',
  setup() {
    const userStore = useUserStore()
    const router = useRouter()
    const userInfo = userStore.getUserInfo()
    const { t } = useI18n()

    const links: any[] = [
      {
        label: 'base.userBar.uc',
        icon: 'material-symbols:account-circle-outline',
        handle: () => router.push({ path: '/uc' }),
      },
      {
        label: 'base.userBar.clearCache',
        icon: 'mingcute:broom-line',
        handle: async () => {
          await userStore.clearCache()
          Message.success(t('base.common.clearCache'))
        },
      },
      { label: 'divider' },
      {
        label: 'base.userBar.systemInfo',
        icon: 'i-bi:info-circle',
        handle: () => userStore.setDropdownMenuState('systemInfo', true),
      },
      { label: 'divider' },
      {
        label: 'base.userBar.logout',
        icon: 'hugeicons:logout-04',
        handle: () => userStore.logout(),
      },
    ]

    return () => (
      <div class="mine-user-bar">
        <m-dropdown
          class="min-w-[6rem] p-1"
          v-slots={{
            default: () => (
              <div class="mine-userinfo">
                {userInfo.avatar && <img src={formatFileUrl(userInfo.avatar)} alt={userInfo.username} class="mine-img-avatar" />}
                {!userInfo.avatar && <div class="mine-text-avatar">{userInfo.username[0].toUpperCase()}</div>}
                <a class="username hidden lg:flex">
                  {userInfo.username}
                  <ma-svg-icon name="material-symbols:keyboard-arrow-down-rounded" className="icon" size={20} />
                </a>
              </div>
            ),
            popper: () => (
              <div>
                {links.map((item: any) => (
                  <div>
                    {item.label !== 'divider' && (
                      <m-dropdown-item
                        type="default"
                        handle={item.handle}
                        v-slots={{
                          'default': () => <span>{ t(item.label) }</span>,
                          'prefix-icon': () => <ma-svg-icon name={item.icon} size={18} />,
                        }}
                      />
                    )}
                    {item.label === 'divider' && <m-dropdown-divider />}
                  </div>
                ),
                )}
              </div>
            ),
          }}
        />

        <MineSystemInfo />
      </div>
    )
  },
})
