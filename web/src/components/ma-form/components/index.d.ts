import type { PropType } from 'vue';
import type { MaFormItem, MaFormOptions, MaModel } from '../types';
declare const _default: import("vue").DefineComponent<{
    modelValue: {
        type: PropType<MaModel>;
        default: () => {};
    };
    options: {
        type: PropType<MaFormOptions>;
        default: () => {};
    };
    items: {
        type: PropType<MaFormItem[]>;
        default: () => any[];
    };
}, () => any, unknown, {}, {}, import("vue").ComponentOptionsMixin, import("vue").ComponentOptionsMixin, {}, string, import("vue").PublicProps, Readonly<import("vue").ExtractPropTypes<{
    modelValue: {
        type: PropType<MaModel>;
        default: () => {};
    };
    options: {
        type: PropType<MaFormOptions>;
        default: () => {};
    };
    items: {
        type: PropType<MaFormItem[]>;
        default: () => any[];
    };
}>>, {
    modelValue: {};
    options: {};
    items: MaFormItem[];
}, {}>;
export default _default;
