import type { TableColumnCtx } from 'element-plus';
import type { VNode } from 'vue';
export type TableColumnSortOrders = 'ascending' | 'descending' | null;
export type TableColumnType = 'selection' | 'index' | 'expand';
export type TableColumnSortable = false | true | 'custom';
export type TableColumnFixed = true | 'left' | 'right';
export type TableColumnFilterPlacement = 'top-start' | 'top-end' | 'top' | 'bottom-start' | 'bottom-end' | 'bottom' | 'left-start' | 'left-end' | 'left' | 'right-start' | 'right-end' | 'right';
type FilterMethods = (value: any, row: any, column: TableColumnCtx<any>) => void;
export interface TableHeaderScope {
    column: TableColumnCtx<any>;
    $index: number;
}
export interface TableColumnScope {
    row?: any;
    column: TableColumn;
    $index: number;
}
export interface TableColumnRenderer extends TableColumnScope {
    options: TableColumn;
    attrs: any;
}
/**
 * @description `element-plus` 的 `table` 中 `Table-column` 属性，未拓展
 * @see {@link https://element-plus.org/zh-CN/component/table.html#table-column-%E5%B1%9E%E6%80%A7}
 */
export interface TableColumn {
    label?: string | (() => string);
    prop?: string | ((index: number) => string);
    type?: TableColumnType;
    index?: number | ((index: number) => number);
    columnKey?: string;
    width?: string | number;
    minWidth?: string | number;
    fixed?: TableColumnFixed;
    renderHeader?: (data: TableHeaderScope) => VNode | string;
    sortable?: TableColumnSortable;
    sortMethod?: (a: any, b: any) => number;
    sortBy?: string | ((row: any, index: number) => string) | string[];
    sortOrders?: Array<TableColumnSortOrders>;
    resizable?: boolean;
    formatter?: (row: any, column: TableColumnCtx<any>, cellValue: any, index: number) => VNode | string;
    showOverflowTooltip?: boolean;
    align?: 'left' | 'center' | 'right';
    headerAlign?: 'left' | 'center' | 'right';
    className?: string;
    labelClassName?: string;
    selectable?: (row: any, index: number) => boolean;
    reserveSelection?: boolean;
    filters?: {
        text: string;
        value: string;
    }[];
    filterPlacement?: TableColumnFilterPlacement;
    filterClassName?: string;
    filterMultiple?: boolean;
    filterMethod?: FilterMethods;
    filteredValue?: Array<any>;
}
/**
 * @description `element-plus` 的 `table` 中 `Table-column` 属性，已拓展，额外增加 `hide` 、`slot` 、`cellRender` 、`headerRender` 四个属性
 * @see {@link https://element-plus.org/zh-CN/component/table.html#table-column-%E5%B1%9E%E6%80%A7}
 */
export interface MaTableColumns extends TableColumn {
    hide?: boolean | CallableFunction;
    children?: MaTableColumns[];
    cellRender?: (data: TableColumnRenderer) => VNode | string;
    headerRender?: (data: TableColumnRenderer) => VNode | string;
}
export {};
