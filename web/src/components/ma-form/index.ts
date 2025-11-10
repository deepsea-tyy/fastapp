// 导入组件（使用 ES 模块）
// @ts-ignore - 编译后的 JS 文件，类型可能不完整
import * as MaFormModule from './index.es.js'

// 导出组件（直接重新导出，确保组件能正确注册）
export const MaForm = (MaFormModule as any).MaForm || (MaFormModule as any).default
export const useForm = (MaFormModule as any).useForm
export default (MaFormModule as any).MaForm || (MaFormModule as any).default

// 导出类型
export type {
  MaFormInstallOptions,
  MaFormOptions,
  MaFormItem,
  MaFormExpose,
  MaModel,
  renderType,
  LoadingConfig,
  ComponentName,
  FormItem,
  state,
} from './types'

