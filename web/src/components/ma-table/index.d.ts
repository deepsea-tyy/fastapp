import type { App } from 'vue';
import useTable from './components/useTable';
import type { MaTableInstallOptions } from './types';
export declare const MaTable: {
    install(app: App, options?: MaTableInstallOptions): void;
};
export default MaTable;
export { useTable };
export type { MaTableInstallOptions, MaTableSetting, MaTableOptions, MaTableExpose, MaTableColumns, PaginationProps, LoadingConfig, TableColumnFilterPlacement, TableColumnSortOrders, TableColumnSortable, TableColumnRenderer, TableColumnScope, TableColumnFixed, TableColumnType, TableColumn, } from './types';
