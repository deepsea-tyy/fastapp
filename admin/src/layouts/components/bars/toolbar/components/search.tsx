
export default defineComponent({
  name: 'search',
  setup() {
    const openSearchPanel = async () => {
      useSettingStore().setSearchPanelEnable(true)
      await nextTick()
      const dom = document.querySelector('.mine-search-input') as HTMLElement
      dom?.focus()
    }
    return () => (
      <ma-svg-icon
        class="tool-icon animate-ease-in"
        name="heroicons:magnifying-glass-20-solid"
        size={20}
        onClick={() => openSearchPanel()}
      />
    )
  },
})
