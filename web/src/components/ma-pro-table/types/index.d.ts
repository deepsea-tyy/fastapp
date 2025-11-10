import { MaSearchExpose, type MaSearchItem, type MaSearchOptions } from "@/components/ma-search";
import { type MaFormOptions } from "@/components/ma-form";
import type { TableColumnType, TableColumnRenderer, MaTableColumns, MaTableOptions, MaTableExpose } from '@/components/ma-table';
import type { LinkProps } from "element-plus/lib/components";
import type { Component, VNode } from "vue";
interface MaProTableColumns extends Omit<MaTableColumns, 'children' | 'type'> {
    type?: TableColumnType | 'operation' | 'sort';
    cellRenderTo?: {
        name: string;
        props?: any | any[];
    };
    children?: MaProTableColumns[];
    operationConfigure?: {
        type?: 'auto' | 'dropdown' | 'tile';
        fold?: number;
        actions?: OperationAction[];
    };
    [key: string]: any;
}
interface MaProTableSchema {
    searchItems?: MaSearchItem[];
    tableColumns?: MaProTableColumns[];
}
interface ContextMenuItem {
    label?: string | (() => string);
    icon?: string | (() => string);
    disabled?: boolean;
    divided?: boolean;
    onMenuClick?: (data: {
        row: any;
        column: any;
        proxy: MaProTableExpose;
    }, event: Event) => void;
}
interface OperationAction {
    name?: string;
    icon?: string | ((data: TableColumnRenderer) => string);
    text?: string | ((data: TableColumnRenderer) => string);
    order?: number;
    disabled?: (data: TableColumnRenderer) => boolean;
    show?: (data: TableColumnRenderer) => boolean;
    onClick?: (data: TableColumnRenderer, proxy: MaProTableExpose, e?: MouseEvent | undefined) => void;
    linkProps?: LinkProps | any;
}
interface MaProTableToolbar {
    name?: string;
    render?: () => Component | VNode | string;
    show?: boolean | (() => boolean);
    order?: number;
}
interface Options {
    id?: string;
    adaptionOffsetBottom?: number;
    actionBtnPosition?: 'auto' | 'header' | 'table';
    header?: {
        show?: boolean | (() => boolean);
        mainTitle?: string | (() => string);
        subTitle?: string | (() => string);
    };
    selection?: {
        crossPage?: boolean;
        selectedText?: string | (() => string);
        clearText?: string | (() => string);
    };
    toolbar?: boolean | (() => boolean);
    toolStates?: {
        [key: string]: boolean | (() => boolean);
    };
    rowContextMenu?: {
        enabled?: boolean;
        items?: ContextMenuItem[];
    };
    requestOptions?: {
        api: (...args: any[]) => any;
        autoRequest?: boolean;
        response?: {
            totalKey?: string;
            dataKey?: string;
        };
        requestPage?: {
            pageName?: string;
            sizeName?: string;
            size?: number;
        };
        requestParams?: Record<string, any>;
        responseDataHandler?: (response: Record<string, any>) => any[];
    };
    onSearchSubmit?: (form: Record<string, any>) => Record<string, any> | void;
    onSearchReset?: (form: Record<string, any>) => Record<string, any> | void;
    on?: {
        [key: string]: (...args: any[]) => any | void;
    };
}
interface MaProTableOptions extends Options {
    tableOptions?: MaTableOptions;
    searchOptions?: MaSearchOptions;
    searchFormOptions?: MaFormOptions;
}
interface MaProTableRenderPlugin {
    name: string;
    render: (data: TableColumnRenderer, proxy: MaProTableExpose, ...args: any[] | any) => any;
}
type MaProTableInstallOptions = {
    ssr?: boolean;
    provider?: {
        app: any;
        icon?: any;
        contextMenu?: any;
        renderPlugins?: MaProTableRenderPlugin[];
        toolbars?: MaProTableToolbar[];
    };
};
interface MaProTableExpose {
    getSearchRef: () => MaSearchExpose;
    getTableRef: () => MaTableExpose;
    getElTableStates: () => any;
    refresh: () => Promise<void>;
    requestData: () => Promise<void>;
    changeApi: (api: () => any, isRequestNow: boolean) => void;
    setRequestParams: (params: Record<string, any>, isRequestNow: boolean) => void;
    setTableColumns: (cols: MaProTableColumns[]) => void;
    getTableColumns: () => MaProTableColumns[];
    setSearchForm: (form: null | Record<string, any>) => void;
    getSearchForm: () => Record<string, any>;
    search: (params?: Record<string, any>) => void;
    setProTableOptions: (opts: MaProTableOptions) => void;
    getProTableOptions: () => MaProTableOptions;
    resizeHeight: () => Promise<void>;
    getCurrentId: () => string;
}
export type { MaProTableInstallOptions, MaProTableOptions, MaProTableColumns, MaProTableSchema, MaProTableExpose, MaProTableToolbar, MaProTableRenderPlugin, MaSearchItem, ContextMenuItem, OperationAction, Options, };
