import type { CellCls, CellStyle, ColumnCls, ColumnStyle, Sort, SummaryMethod, TableColumnCtx, TreeNode } from 'element-plus';
import type { TableOverflowTooltipOptions } from 'element-plus/es/components/table/src/util';
import type { MaTableColumns } from './table-column';
import type { LoadingConfig, PaginationProps } from './index';
export interface ExtraOptions {
    containerHeight?: string;
    loading?: boolean;
    loadingConfig?: LoadingConfig;
    columnAlign?: 'left' | 'center' | 'right';
    headerAlign?: 'left' | 'center' | 'right';
    showOverflowTooltip?: boolean;
    pagination?: PaginationProps;
    adaption?: boolean;
    adaptionOffsetBottom?: number;
    showPagination?: boolean;
}
/**
 * @description `element-plus` 的 `table` 属性，未拓展
 * @see {@link https://element-plus.org/zh-CN/component/table.html#table-%E5%B1%9E%E6%80%A7}
 */
export interface MaTableOptions extends ExtraOptions {
    data?: Array<any>;
    height?: string | number;
    maxHeight?: string | number;
    stripe?: boolean;
    border?: boolean;
    size?: '' | 'large' | 'default' | 'small';
    fit?: boolean;
    showHeader?: boolean;
    highlightCurrentRow?: boolean;
    currentRowKey?: string | number;
    rowClassName?: ColumnCls<any>;
    rowStyle?: ColumnStyle<any>;
    cellClassName?: CellCls<any>;
    cellStyle?: CellStyle<any>;
    headerRowClassName?: ColumnCls<any>;
    headerRowStyle?: ColumnStyle<any>;
    headerCellClassName?: CellCls<any>;
    headerCellStyle?: CellStyle<any>;
    rowKey?: string | ((row: any) => string);
    emptyText?: string;
    defaultExpandAll?: boolean;
    expandRowKeys?: any[];
    defaultSort?: Sort;
    tooltipEffect?: 'dark' | 'light';
    tooltipOptions?: TableOverflowTooltipOptions;
    showSummary?: boolean;
    sumText?: string;
    summaryMethod?: SummaryMethod<any>;
    spanMethod?: (data: {
        row: any;
        rowIndex: number;
        column: TableColumnCtx<any>;
        columnIndex: number;
    }) => number[] | {
        rowspan: number;
        colspan: number;
    } | undefined;
    selectOnIndeterminate?: boolean;
    indent?: number;
    lazy?: boolean;
    load?: (row: any, treeNode: TreeNode, resolve: (data: any[]) => void) => void;
    treeProps?: {
        hasChildren?: string;
        children?: string;
    };
    tableLayout?: 'fixed' | 'auto';
    scrollbarAlwaysOn?: boolean;
    flexible?: boolean;
    on?: {
        [key: string]: (...args: any[]) => any | void;
    };
}
export interface MaTableSetting {
    columns?: MaTableColumns[];
    /**
     * @description 拓展 `element-plus` 的 `table` 属性
     * @see {@link https://element-plus.org/zh-CN/component/table.html#table-%E5%B1%9E%E6%80%A7}
     */
    options?: MaTableOptions;
}
