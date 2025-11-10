// 导入组件（使用 ES 模块）
// @ts-ignore - 编译后的 JS 文件，类型可能不完整
import * as MaEchartsModule from './index.es.js'

// 导出组件
export const useEcharts = (MaEchartsModule as any).default || (MaEchartsModule as any).useEcharts
export default useEcharts

// 导出类型
export type {
  Theme,
  ElementEventType,
  ElementEventName,
  MaEchartsExpose,
  Fn,
  RefValue,
  ComputedRefValue,
  MaEChartOptions,
  OptionsParams,
  AppendDataOpts,
  LoadingOpts,
} from './types/index'

