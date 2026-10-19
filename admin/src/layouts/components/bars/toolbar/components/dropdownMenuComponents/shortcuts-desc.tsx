import { useI18n } from 'vue-i18n'

export default defineComponent({
  name: 'shortcutsDesc',
  setup() {
    const { t } = useI18n()
    const { getDropdownMenu } = useUserStore()
    const dropdownMenuState = getDropdownMenu()

    return () => (
      <>
        <m-modal
          contentClass="w-[380px] lg:w-450px justify-start"
          v-model={dropdownMenuState.shortcuts}
          title={t('base.userBar.shortcuts')}
        >
          <div class="mine-shortcuts-block">
            <div class="title">{t('base.shortcuts.searchBar')}</div>
            <div class="short-list">
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Alt</span>
                  +
                  <span>s</span>
                </div>
                <div>{t('base.shortcuts.searchOpen')}</div>
              </div>
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Esc</span>
                </div>
                <div>{t('base.shortcuts.close')}</div>
              </div>
            </div>
          </div>
          <div class="mine-shortcuts-block mt-10">
            <div class="title">{t('base.shortcuts.tabs')}</div>
            <div class="short-list">
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Alt</span>
                  +
                  <span>1 ~ 9</span>
                </div>
                <div>{t('base.shortcuts.switchN')}</div>
              </div>
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Alt</span>
                  +
                  <span>0</span>
                </div>
                <div>{t('base.shortcuts.switchLast')}</div>
              </div>
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Alt</span>
                  +
                  <span>↑</span>
                </div>
                <div>{t('base.shortcuts.toMax')}</div>
              </div>
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Alt</span>
                  +
                  <span>↓</span>
                </div>
                <div>{t('base.shortcuts.exitMax')}</div>
              </div>
              <div class="flex items-center text-sm">
                <div class="short-key">
                  <span>Alt</span>
                  +
                  <span>c</span>
                </div>
                <div>{t('base.shortcuts.close')}</div>
              </div>
            </div>
          </div>
        </m-modal>
      </>
    )
  },
})
