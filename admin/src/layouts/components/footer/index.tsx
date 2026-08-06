
import '@/layouts/style/footer.scss'
import useFooterStore from '@/store/modules/useFooterStore'

export default defineComponent({
  name: 'Footer',
  setup() {
    const footerStore = useFooterStore()
    return () => (
      <footer>
        <div class="mine-footer">
          {footerStore.segments.length > 0 && (
            <nav class="mine-footer__breadcrumb" aria-label="当前位置">
              {footerStore.segments.map((seg, i) => (
                <span key={i} class="mine-footer__breadcrumb-group">
                  {i > 0 && <span class="mine-footer__sep"> > </span>}
                  <span
                    class="mine-footer__crumb"
                    class:mine-footer__crumb--current={!!seg.current}
                  >
                    {seg.label}
                  </span>
                </span>
              ))}
            </nav>
          )}
        </div>
      </footer>
    )
  },
})
