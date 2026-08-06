
export interface FooterSegment {
  label: string
  current?: boolean
}

const useFooterStore = defineStore('useFooterStore', () => {
  const segments = ref<FooterSegment[]>([])

  function setSegments(value: FooterSegment[]) {
    segments.value = value
  }

  function clear() {
    segments.value = []
  }

  return { segments, setSegments, clear }
})

export default useFooterStore
