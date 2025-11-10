import type { Ref } from 'vue';
import type { ElTable } from 'element-plus';
import type { MaTableColumns, TableColumn, TableColumnFilterPlacement, TableColumnFixed, TableColumnRenderer, TableColumnScope, TableColumnSortOrders, TableColumnSortable, TableColumnType } from './table-column';
import type { MaTableOptions, MaTableSetting } from './table-options';
import type { LoadingConfig } from './loading-config';
import type { PaginationProps } from './pagination';
interface MaTableInstallOptions {
    ssr?: boolean;
}
interface MaTableExpose {
    setData: (data: any[]) => void;
    setPagination: (pagination: PaginationProps) => void;
    setCurrentPage: (pager: number) => void;
    setLoadingState: (loading: boolean) => void;
    setOptions: (opts: MaTableOptions) => void;
    getOptions: () => MaTableOptions;
    setColumns: (cols: MaTableColumns[]) => void;
    getColumns: () => MaTableColumns[];
    appendColumn: (column: MaTableColumns) => void;
    removeColumn: (prop: string) => void;
    getColumnByProp: (prop: string) => MaTableColumns;
    getElTableRef: () => Ref<typeof ElTable>;
}
export type { MaTableInstallOptions, MaTableSetting, MaTableColumns, MaTableExpose, MaTableOptions, TableColumnFilterPlacement, TableColumnSortOrders, TableColumnSortable, TableColumnRenderer, TableColumnScope, TableColumnFixed, TableColumnType, PaginationProps, LoadingConfig, TableColumn, };
