import { type App } from 'vue';
import type { MaProTableInstallOptions } from './types';
import useProTableRenderPlugin from "./components/useProTableRenderPlugin";
import useProTableToolbar from "./components/useProTableToolbar";
export declare const MaProTable: {
    install(app: App, options?: MaProTableInstallOptions): void;
};
export { useProTableRenderPlugin, useProTableToolbar, };
export default MaProTable;
export type { MaProTableInstallOptions, MaProTableOptions, MaProTableColumns, MaProTableSchema, MaProTableExpose, MaProTableToolbar, MaProTableRenderPlugin, MaSearchItem, ContextMenuItem, OperationAction, Options, } from './types';
