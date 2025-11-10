// 导入组件（使用 ES 模块）
// @ts-ignore - 编译后的 JS 文件，类型可能不完整
import * as MaSearchModule from './index.es.js'

// 导入样式
import './style.css'

// 导出组件（直接重新导出，确保组件能正确注册）
export const MaSearch = (MaSearchModule as any).MaSearch || (MaSearchModule as any).default
export default (MaSearchModule as any).MaSearch || (MaSearchModule as any).default

// 导出类型
export type {
  MaSearchInstallOptions,
  MaSearchOptions,
  MaSearchExpose,
  MaSearchItem,
} from './types'

