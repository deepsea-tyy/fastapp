
const useIframeKeepAliveStore = defineStore(
  'useIframeKeepAliveStore',
  () => {
    const iframeList = ref<string[]>([])

    function add(name: string | string[]) {
      if (typeof name === 'string') {
        !iframeList.value.includes(name) && iframeList.value.push(name)
      }
      else {
        name.forEach((v) => {
          v && !iframeList.value.includes(v) && iframeList.value.push(v)
        })
      }
    }

    function remove(name: string | string[]) {
      if (typeof name === 'string') {
        iframeList.value = iframeList.value.filter((v) => {
          return v !== name
        })
      }
      else {
        iframeList.value = iframeList.value.filter((v) => {
          return !name.includes(v)
        })
      }
    }

    function clean() {
      iframeList.value = []
    }

    return {
      iframeList,
      add,
      remove,
      clean,
    }
  },
)

export default useIframeKeepAliveStore
