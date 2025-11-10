import '../style/index.scss';
import type { PropType } from 'vue';
import { MaSearchOptions } from "../types/search-options";
import { MaSearchItem } from "../types";
import type { MaFormOptions } from '@/components/ma-form';
declare const _default: import("vue").DefineComponent<{
    options: {
        type: PropType<MaSearchOptions>;
        default: () => {};
    };
    formOptions: {
        type: PropType<MaFormOptions>;
        default: () => {};
    };
    searchItems: {
        type: PropType<MaSearchItem[]>;
        default: () => any[];
    };
}, () => any, unknown, {}, {}, import("vue").ComponentOptionsMixin, import("vue").ComponentOptionsMixin, ("search" | "reset" | "fold")[], "search" | "reset" | "fold", import("vue").PublicProps, Readonly<import("vue").ExtractPropTypes<{
    options: {
        type: PropType<MaSearchOptions>;
        default: () => {};
    };
    formOptions: {
        type: PropType<MaFormOptions>;
        default: () => {};
    };
    searchItems: {
        type: PropType<MaSearchItem[]>;
        default: () => any[];
    };
}>> & {
    onReset?: (...args: any[]) => any;
    onSearch?: (...args: any[]) => any;
    onFold?: (...args: any[]) => any;
}, {
    options: {};
    formOptions: {};
    searchItems: MaSearchItem[];
}, {}>;
export default _default;
