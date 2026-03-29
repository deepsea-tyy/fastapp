import { LoadingConfig } from './index';
import type { FormRules, FormItemProp } from 'element-plus';
import type { VNode, CSSProperties } from "vue";
export type alignmentType = 'normal' | 'stretch' | 'center' | 'start' | 'end' | 'flex-start' | 'flex-end' | 'self-start' | 'self-end' | 'anchor-center' | 'baseline' | 'first baseline' | 'last baseline' | 'safe center' | 'unsafe center' | 'inherit' | 'initial' | 'revert' | 'revert-layer' | 'unset';
export interface ExtraFormOptions {
    loading?: boolean;
    loadingConfig?: LoadingConfig;
    containerClass?: string;
    layout?: 'flex' | 'grid';
    grid?: {
        alignment?: alignmentType;
        class?: string | {
            [key: string]: any;
        } | [];
        direction?: 'vertical' | 'horizontal';
        prefixCls?: string;
        style?: string | CSSProperties | CSSProperties[] | string[];
        spacer?: string | number | VNode;
        size?: 'default' | 'small' | 'large' | number | [];
        wrap?: boolean;
        fill?: boolean;
        fillRatio?: number;
    };
    flex?: {
        gutter?: number;
        justify?: 'start' | 'end' | 'center' | 'space-around' | 'space-between' | 'space-evenly';
        align: 'top' | 'middle' | 'bottom';
        tag?: string;
    };
    footerSlot?: () => any;
}
/**
 * @description `element-plus` 的 `form` 属性，不含 model 属性, 单独在ma-form v-model上，未拓展
 * @see {@link https://element-plus.org/zh-CN/component/form.html#form-attributes}
 */
export interface MaFormOptions extends ExtraFormOptions {
    rules?: FormRules;
    inline?: boolean;
    labelPosition?: 'left' | 'right' | 'top';
    labelWidth?: string | number;
    labelSuffix?: string;
    hideRequiredAsterisk?: boolean;
    showMessage?: boolean;
    inlineMessage?: boolean;
    statusIcon?: boolean;
    validateOnRuleChange?: boolean;
    size?: '' | 'large' | 'default' | 'small';
    disabled?: boolean;
    scrollToError?: boolean;
    /**
     * 当校验有失败结果时，滚动到第一个失败的表单项目 可通过 `scrollIntoView` 配置
     * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollIntoView}
     */
    scrollIntoViewOptions?: Record<string, any> | boolean;
    onValidate?: (prop: FormItemProp, isValid: boolean, message: string) => void;
}
