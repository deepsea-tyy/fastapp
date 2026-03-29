import '../style/index.scss';
import type { PropType } from 'vue';
import { MaProTableSchema, MaProTableOptions } from "../types";
declare const _default: import("vue").DefineComponent<import("vue").ExtractPropTypes<{
    options: {
        type: PropType<MaProTableOptions>;
        default: () => {
            tableOptions: {};
            searchOptions: {};
            searchFormOptions: {};
        };
    };
    schema: {
        type: PropType<MaProTableSchema>;
        default: () => {
            searchItems: any[];
            tableColumns: any[];
        };
    };
}>, () => any, {}, {}, {}, import("vue").ComponentOptionsMixin, import("vue").ComponentOptionsMixin, ("row-drag-sort" | "search-submit" | "search-reset")[], "row-drag-sort" | "search-submit" | "search-reset", import("vue").PublicProps, Readonly<import("vue").ExtractPropTypes<{
    options: {
        type: PropType<MaProTableOptions>;
        default: () => {
            tableOptions: {};
            searchOptions: {};
            searchFormOptions: {};
        };
    };
    schema: {
        type: PropType<MaProTableSchema>;
        default: () => {
            searchItems: any[];
            tableColumns: any[];
        };
    };
}>> & Readonly<{
    "onRow-drag-sort"?: (...args: any[]) => any;
    "onSearch-submit"?: (...args: any[]) => any;
    "onSearch-reset"?: (...args: any[]) => any;
}>, {
    options: MaProTableOptions;
    schema: MaProTableSchema;
}, {}, {}, {}, string, import("vue").ComponentProvideOptions, true, {}, any>;
export default _default;
