import type { MaFormExpose } from '@/components/ma-form'
import { useResizeObserver } from '@vueuse/core'

// 响应式断点
const BREAKPOINTS = {
  xs: 768,
  sm: 992,
} as const

export interface FormResponsiveOptions {
  /** 小屏幕 (< 768px) 的标签位置 */
  xsLabelPosition?: 'left' | 'right' | 'top'
  /** 小屏幕的标签宽度 */
  xsLabelWidth?: string
  /** 中等屏幕 (768-992px) 的标签位置 */
  smLabelPosition?: 'left' | 'right' | 'top'
  /** 中等屏幕的标签宽度 */
  smLabelWidth?: string
  /** 大屏幕 (≥ 992px) 的标签位置 */
  lgLabelPosition?: 'left' | 'right' | 'top'
  /** 大屏幕的标签宽度 */
  lgLabelWidth?: string
}

/**
 * 表单响应式布局 Hook
 * 根据屏幕宽度动态调整表单的 labelPosition 和 labelWidth
 * 当 labelPosition 为 'top' 时，自动设置 labelWidth 为 '100%' 以确保标签占整行
 * 
 * @param formRef - 表单引用
 * @param options - 响应式配置选项
 * @returns 返回 labelPosition 和 labelWidth 的响应式引用
 */
export default function useFormResponsive(
  formRef: Ref<MaFormExpose | undefined>,
  options: FormResponsiveOptions = {}
): {
  labelPosition: Ref<'left' | 'right' | 'top'>
  labelWidth: Ref<string>
} {
  const {
    xsLabelPosition = 'top',
    xsLabelWidth = 'auto',
    smLabelPosition = 'right',
    smLabelWidth = '100px',
    lgLabelPosition = 'right',
    lgLabelWidth = '120px',
  } = options

  const labelPosition = ref<'left' | 'right' | 'top'>(lgLabelPosition)
  const labelWidth = ref<string>(lgLabelWidth)

  // 根据屏幕宽度计算布局配置
  const calculateLayout = (width: number) => {
    if (width < BREAKPOINTS.xs) {
      return { position: xsLabelPosition, width: xsLabelWidth }
    }
    if (width < BREAKPOINTS.sm) {
      return { position: smLabelPosition, width: smLabelWidth }
    }
    return { position: lgLabelPosition, width: lgLabelWidth }
  }

  // 更新表单选项
  const updateFormOptions = () => {
    if (!formRef.value) return

    // 当 labelPosition 为 'top' 时，labelWidth 应该是 '100%'
    // 当 labelPosition 为 'left' 或 'right' 时，使用计算出的宽度，如果为空或 'auto' 则使用默认值
    let finalLabelWidth: string
    if (labelPosition.value === 'top') {
      finalLabelWidth = '100%'
    } else {
      finalLabelWidth = labelWidth.value && labelWidth.value !== 'auto' 
        ? labelWidth.value 
        : '120px'
    }

    formRef.value.setOptions({
      labelPosition: labelPosition.value,
      labelWidth: finalLabelWidth,
    })
  }

  // 应用布局配置
  const applyLayout = (width: number) => {
    const layout = calculateLayout(width)
    
    // 只在值真正变化时才更新
    if (labelPosition.value !== layout.position || labelWidth.value !== layout.width) {
      labelPosition.value = layout.position
      labelWidth.value = layout.width
      updateFormOptions()
    }
  }

  // 响应式处理
  onMounted(() => {
    if (typeof window === 'undefined') return

    // 初始化时设置一次
    applyLayout(window.innerWidth)

    // 使用 useResizeObserver 监听 document.body 的尺寸变化
    // 这样可以更准确地捕获尺寸变化，包括抽屉打开时的变化
    useResizeObserver(document.body, (entries) => {
      const [entry] = entries
      if (formRef.value) {
        applyLayout(entry.contentRect.width)
      }
    })
  })

  // 监听 formRef 的变化，当表单准备好时初始化布局
  watch(
    formRef,
    (newRef) => {
      if (newRef && typeof window !== 'undefined') {
        // 立即设置默认值，确保表单有初始宽度
        const defaultLayout = calculateLayout(window.innerWidth)
        const defaultWidth = defaultLayout.position === 'top' 
          ? '100%' 
          : (defaultLayout.width && defaultLayout.width !== 'auto' ? defaultLayout.width : '120px')
        
        // 先设置默认值，确保表单有初始宽度
        newRef.setOptions({
          labelPosition: defaultLayout.position,
          labelWidth: defaultWidth,
        })
        
        // 然后使用 nextTick 确保 DOM 已更新后再应用完整布局
        nextTick(() => {
          applyLayout(window.innerWidth)
        })
      }
    },
    { immediate: true }
  )

  // 监听 labelPosition 和 labelWidth 的变化
  watch([labelPosition, labelWidth], () => {
    if (formRef.value) {
      updateFormOptions()
    }
  })

  return {
    labelPosition,
    labelWidth,
  }
}

