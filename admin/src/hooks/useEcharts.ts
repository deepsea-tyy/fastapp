import type {
  ECharts,
  EChartsCoreOption,
  EChartsInitOpts,
} from 'echarts/core'
import type { Ref } from 'vue'
import {
  getCurrentInstance,
  nextTick,
  onActivated,
  onBeforeUnmount,
  onMounted,
  shallowRef,
  unref,
} from 'vue'
import { useColorMode, useDebounceFn } from '@vueuse/core'

type EchartsNs = typeof import('echarts/core')

export type Theme = 'default' | 'light' | 'mineDark' | string

export interface MaEChartOptions extends EChartsInitOpts {
  theme?: Theme | Ref<Theme>
}

type ElementEventType = 'echarts' | 'zrender'

export interface OptionsParams {
  name: string
  callback: (...args: any[]) => void
  type?: ElementEventType
  query?: string | object
}

export interface AppendDataOpts {
  seriesIndex: number
  data: any
}

export interface LoadingOpts {
  type?: string
  opts?: Record<string, any>
}

export interface UseEchartsExpose {
  echarts: EchartsNs
  getInstance: () => ECharts | null
  setOption: (options: EChartsCoreOption, params?: OptionsParams[]) => void
  showLoading: (loadingOpts?: LoadingOpts) => void
  hideLoading: () => void
  clear: () => void
  resize: () => void
  appendData: (opts: AppendDataOpts) => void
  getDom: () => HTMLElement | undefined
  getWidth: () => number | undefined
  getHeight: () => number | undefined
  getOption: () => EChartsCoreOption
}

const colorMode = useColorMode()

export function themeMode(): Theme {
  return colorMode.value === 'dark' ? 'mineDark' : 'default'
}

function pickInitThemeAndOpts(
  options?: MaEChartOptions,
): [string, EChartsInitOpts | undefined] {
  if (!options) {
    return ['default', undefined]
  }
  const { theme, ...rest } = options
  const themeStr = (unref(theme) as string | undefined) ?? 'default'
  const keys = Object.keys(rest)
  const initOpts = keys.length > 0 ? (rest as EChartsInitOpts) : undefined
  return [themeStr, initOpts]
}

export function useEcharts(
  el: Ref<HTMLElement | null | undefined>,
  options?: MaEChartOptions,
): UseEchartsExpose | null {
  const instance = getCurrentInstance()
  const echartsNs = instance?.appContext.config.globalProperties
    .$echarts as EchartsNs | undefined
  if (!echartsNs) {
    return null
  }

  const chartRef = shallowRef<ECharts | null>(null)

  const resize = () => {
    chartRef.value?.resize()
  }

  const debouncedResize = useDebounceFn(resize, 100)

  const teardown = () => {
    window.removeEventListener('resize', debouncedResize)
    chartRef.value?.dispose()
    chartRef.value = null
  }

  onMounted(async () => {
    await nextTick()
    if (!el.value) {
      return
    }
    const [theme, initOpts] = pickInitThemeAndOpts(options)
    chartRef.value = echartsNs.init(el.value, theme, initOpts)
    window.addEventListener('resize', debouncedResize)
    await debouncedResize()
  })

  onActivated(async () => {
    await debouncedResize()
  })

  onBeforeUnmount(() => {
    teardown()
  })

  return {
    echarts: echartsNs,
    getInstance: () => chartRef.value,
    setOption: (opt: EChartsCoreOption, eventParams?: OptionsParams[]) => {
      const c = chartRef.value
      if (!c) {
        return
      }
      c.setOption(opt)
      eventParams?.forEach((p) => {
        if (p.type === 'zrender' && typeof p.callback === 'function') {
          c.getZr().on(p.name, (ev: any) => {
            if (!ev.target) {
              p.callback(ev)
            }
          })
        }
        else if (typeof p.callback === 'function') {
          if (p.query !== undefined) {
            c.on(p.name as any, p.query as any, p.callback as any)
          }
          else {
            c.on(p.name as any, p.callback as any)
          }
        }
      })
    },
    showLoading: (loadingOpts?: LoadingOpts) => {
      const c = chartRef.value
      if (!c) {
        return
      }
      c.showLoading(loadingOpts?.type ?? 'default', loadingOpts?.opts ?? {})
    },
    hideLoading: () => chartRef.value?.hideLoading(),
    clear: () => {
      teardown()
    },
    resize,
    appendData: (opts: AppendDataOpts) => {
      chartRef.value?.appendData(opts as Parameters<ECharts['appendData']>[0])
    },
    getDom: () => chartRef.value?.getDom() ?? undefined,
    getWidth: () => chartRef.value?.getWidth(),
    getHeight: () => chartRef.value?.getHeight(),
    getOption: () =>
      (chartRef.value?.getOption() ?? {}) as EChartsCoreOption,
  }
}
