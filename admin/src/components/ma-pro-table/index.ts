// 导入组件（使用 ES 模块）
// @ts-ignore - 编译后的 JS 文件，类型可能不完整
import * as MaProTableModule from './index.es.js'

// 导入样式
import './style.css'

// 导出组件（直接重新导出，确保组件能正确注册）
export const MaProTable = (MaProTableModule as any).MaProTable || (MaProTableModule as any).default
export const useProTableRenderPlugin = (MaProTableModule as any).useProTableRenderPlugin
export const useProTableToolbar = (MaProTableModule as any).useProTableToolbar

// 确保 default 导出是组件对象
export default (MaProTableModule as any).MaProTable || (MaProTableModule as any).default

// 导出类型
export type {
  MaProTableInstallOptions,
  MaProTableOptions,
  MaProTableColumns,
  MaProTableSchema,
  MaProTableExpose,
  MaProTableToolbar,
  MaProTableRenderPlugin,
  ContextMenuItem,
  OperationAction,
  Options,
} from './types'

// 重新导出 MaSearchItem（从本地组件导入）
export type { MaSearchItem } from '@/components/ma-search'

