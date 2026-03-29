import type { PropType } from 'vue';
import type { PaginationProps } from 'element-plus/es/components/pagination/src/pagination';
import { MaTableColumns } from '../types';
declare const _default: {
    options: {
        data: {
            type: PropType<any[]>;
            default: () => never[];
        };
        size: {
            readonly type: PropType<import("element-plus/es/utils/index.mjs").EpPropMergeType<StringConstructor, "" | "small" | "default" | "large", never>>;
            readonly required: false;
            readonly validator: ((val: unknown) => boolean) | undefined;
            __epPropKey: true;
        };
        width: (NumberConstructor | StringConstructor)[];
        height: (NumberConstructor | StringConstructor)[];
        maxHeight: (NumberConstructor | StringConstructor)[];
        fit: {
            type: BooleanConstructor;
            default: boolean;
        };
        stripe: BooleanConstructor;
        border: BooleanConstructor;
        rowKey: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["rowKey"]>;
        showHeader: {
            type: BooleanConstructor;
            default: boolean;
        };
        showSummary: BooleanConstructor;
        sumText: StringConstructor;
        summaryMethod: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["summaryMethod"]>;
        rowClassName: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["rowClassName"]>;
        rowStyle: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["rowStyle"]>;
        cellClassName: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["cellClassName"]>;
        cellStyle: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["cellStyle"]>;
        headerRowClassName: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["headerRowClassName"]>;
        headerRowStyle: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["headerRowStyle"]>;
        headerCellClassName: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["headerCellClassName"]>;
        headerCellStyle: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["headerCellStyle"]>;
        highlightCurrentRow: BooleanConstructor;
        currentRowKey: (NumberConstructor | StringConstructor)[];
        emptyText: StringConstructor;
        expandRowKeys: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["expandRowKeys"]>;
        defaultExpandAll: BooleanConstructor;
        defaultSort: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["defaultSort"]>;
        tooltipEffect: StringConstructor;
        tooltipOptions: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["tooltipOptions"]>;
        spanMethod: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["spanMethod"]>;
        selectOnIndeterminate: {
            type: BooleanConstructor;
            default: boolean;
        };
        indent: {
            type: NumberConstructor;
            default: number;
        };
        treeProps: {
            type: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["treeProps"]>;
            default: () => {
                hasChildren: string;
                children: string;
                checkStrictly: boolean;
            };
        };
        lazy: BooleanConstructor;
        load: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["load"]>;
        style: {
            type: PropType<import("vue").CSSProperties>;
            default: () => {};
        };
        className: {
            type: StringConstructor;
            default: string;
        };
        tableLayout: {
            type: PropType<"fixed" | "auto">;
            default: string;
        };
        scrollbarAlwaysOn: BooleanConstructor;
        flexible: BooleanConstructor;
        showOverflowTooltip: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["showOverflowTooltip"]>;
        tooltipFormatter: PropType<import("element-plus/es/components/table/src/table/defaults.mjs").TableProps<any>["tooltipFormatter"]>;
        appendFilterPanelTo: StringConstructor;
        scrollbarTabindex: {
            type: (NumberConstructor | StringConstructor)[];
            default: undefined;
        };
        allowDragLastColumn: {
            type: BooleanConstructor;
            default: boolean;
        };
        preserveExpandedContent: BooleanConstructor;
        nativeScrollbar: BooleanConstructor;
        loading: {
            type: BooleanConstructor;
            default: boolean;
        };
        columnAlign: {
            type: StringConstructor;
            default: string;
        };
        headerAlign: {
            type: StringConstructor;
            default: string;
        };
        pagination: {
            type: PropType<PaginationProps>;
            default: PaginationProps;
        };
    };
    columns: {
        type: PropType<MaTableColumns[]>;
        default: any[];
    };
};
export default _default;
