
const useKeepAliveStore = defineStore(
  'useKeepAliveStore',
  () => {
    const list = ref<string[]>([])
    const show = ref<boolean>(true)

    function add(name: string | string[]) {
      if (typeof name === 'string') {
        !list.value.includes(name) && list.value.push(name)
      }
      else {
        name.forEach((v) => {
          v && !list.value.includes(v) && list.value.push(v)
        })
      }
    }

    function remove(name: string | string[]) {
      if (typeof name === 'string') {
        list.value = list.value.filter((v) => {
          return v !== name
        })
      }
      else {
        list.value = list.value.filter((v) => {
          return !name.includes(v)
        })
      }
    }

    function clean() {
      list.value = []
    }

    function display() {
      show.value = true
    }

    function hidden() {
      show.value = false
    }

    function getShowState() {
      return show.value
    }

    return {
      list,
      add,
      remove,
      clean,
      getShowState,
      display,
      hidden,
    }
  },
)

export default useKeepAliveStore
