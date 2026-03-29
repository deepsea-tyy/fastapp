// 导入组件（使用 ES 模块）
// @ts-ignore - 编译后的 JS 文件，类型可能不完整
import * as MaTableModule from './index.es.js'

// 导入样式
import './style.css'

// 导出组件（直接重新导出，确保组件能正确注册）
export const MaTable = (MaTableModule as any).MaTable || (MaTableModule as any).default
export const useTable = (MaTableModule as any).useTable
export default (MaTableModule as any).MaTable || (MaTableModule as any).default

// 导出类型
export type {
  MaTableInstallOptions,
  MaTableSetting,
  MaTableColumns,
  MaTableExpose,
  MaTableOptions,
  TableColumnFilterPlacement,
  TableColumnSortOrders,
  TableColumnSortable,
  TableColumnRenderer,
  TableColumnScope,
  TableColumnFixed,
  TableColumnType,
  PaginationProps,
  LoadingConfig,
  TableColumn,
} from './types'

