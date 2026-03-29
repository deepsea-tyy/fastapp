
import MaDrawer from '@/components/ma-drawer/index.vue'
import type { Component } from 'vue'
import { useResizeObserver } from '@vueuse/core'

export interface UseDrawerExpose {
  on: {
    ok?: (...args: any[]) => void
    cancel?: (...args: any[]) => void
  }
  Drawer: Component
  open: (...args: any[]) => void
  close: () => void
  setTitle: (title: string) => void
  setAttr: (attr: Record<string, any>) => void
}

export default function useDrawer(drawerProps: Record<string, any> | null = null): UseDrawerExpose {
  const isOpen = ref<boolean>(false)
  const title = ref<string>('unknown')
  const drawerWidth = ref<string>((drawerProps?.size as string) ?? '50%')

  const openArgs = ref<any[]>([])
  const closeArgs = ref<any[]>([])

  // 根据屏幕宽度计算抽屉宽度
  const calculateWidth = (width: number): string => {
    if (width < 768) {
      return (drawerProps?.xsSize as string) ?? '90%'
    }
    if (width < 992) {
      return (drawerProps?.smSize as string) ?? '75%'
    }
    if (width < 1200) {
      return (drawerProps?.mdSize as string) ?? '65%'
    }
    if (width < 1920) {
      return (drawerProps?.lgSize as string) ?? (drawerProps?.size as string) ?? '50%'
    }
    return (drawerProps?.xlSize as string) ?? (drawerProps?.size as string) ?? '50%'
  }

  // 响应式宽度处理
  onMounted(() => {
    if (typeof window !== 'undefined') {
      // 初始化时设置一次
      drawerWidth.value = calculateWidth(window.innerWidth)

      // 监听窗口大小变化
      useResizeObserver(document.body, (entries) => {
        const [entry] = entries
        drawerWidth.value = calculateWidth(entry.contentRect.width)
      })
    }
  })

  const open = (...args: any[]) => {
    openArgs.value = args
    closeArgs.value = args
    isOpen.value = true
  }

  const close = () => {
    isOpen.value = false
  }

  const setTitle = (string: string) => title.value = string
  const setAttr = (attr: Record<string, any>) => Object.assign(drawerProps ?? {}, attr)

  const on = ref<{
    ok: (...args: any[]) => any
    cancel: (...args: any[]) => any
  }>({ ok: () => {}, cancel: () => {} })

  const Drawer = (props: Record<string, any> = {}) => {
    const slots = useSlots()
    const args: Record<string, any> = {
      appendToBody: true,
      closeOnClickModal: false,
      ...drawerProps,
      ...props,
    }

    return h(
      MaDrawer,
      {
        'modelValue': isOpen.value,
        'onUpdate:modelValue': (v: boolean) => isOpen.value = v,
        'title': props?.title ?? title.value,
        'footer': true,
        'destroyOnClose': true,
        'size': drawerWidth.value,
        ...args,
        'onOk': ({ okLoadingState }) => {
          openArgs.value.push(okLoadingState)
          return args?.ok?.(...openArgs.value) ?? on.value?.ok?.(...openArgs.value)
        },
        'onCancel': ({ cancelLoadingState }) => {
          closeArgs.value.push(cancelLoadingState)
          return (args?.cancel?.(...closeArgs.value) ?? on.value?.cancel?.(...closeArgs.value) ?? true)
            ? (cancelLoadingState(false) || close())
            : null
        },
      },
      {
        ...slots,
        default: () => slots.default?.(...openArgs.value),
      },
    )
  }

  return {
    on: on.value,
    Drawer,
    open,
    close,
    setTitle,
    setAttr,
  }
}
