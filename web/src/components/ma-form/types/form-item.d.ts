import type { MaModel } from './index';
import type { Component, VNode } from 'vue';
import type { FormItemRule } from 'element-plus';
import { Arrayable } from 'element-plus/es/utils';
export type ComponentName = 'Radio' | 'RadioButton' | 'Checkbox' | 'CheckboxButton' | 'Input' | 'Autocomplete' | 'InputNumber' | 'Select' | 'Cascader' | 'Switch' | 'Slider' | 'TimePicker' | 'DatePicker' | 'Rate' | 'ColorPicker' | 'Mention' | 'Transfer' | 'TimeSelect' | 'SelectV2' | 'TreeSelect' | 'Upload';
export type state = (item: MaFormItem, model: MaModel) => boolean;
/**
 * @description `element-plus` 的 `form-item` 属性，去掉了 `label` 和 `prop` 属性，移到了 `MaFormItem` 中这里的属性在 `MaFormItem` 中的 `itemProps` 里传入
 * @see {@link https://element-plus.org/zh-CN/component/form.html#formitem-attributes}
 */
export interface FormItem {
    labelPosition?: 'left' | 'right' | 'top';
    labelWidth?: string | number;
    required?: boolean;
    rules?: Arrayable<FormItemRule>;
    error?: string;
    showMessage?: boolean;
    inlineMessage?: string | boolean;
    size?: '' | 'large' | 'default' | 'small';
    for?: string;
    validateStatus?: '' | 'error' | 'validating' | 'success';
    [key: string]: any;
}
export type renderArgs = {
    item: MaFormItem;
    formData: any;
};
export type renderCustomer = (data: renderArgs) => VNode | Component;
export type renderType = renderCustomer | string | ComponentName | Component | VNode;
export type itemSlotType = (arg: {
    [key: string]: any;
}) => any;
export type renderSlotType = (...args: any[]) => any;
export interface colsAttr {
    span?: number;
    offset?: number;
    pull?: number;
    push?: number;
}
/**
 * @description `MaFormItem` 的属性列表
 */
export interface MaFormItem {
    label?: string | (() => string);
    prop?: string | (() => string);
    hide?: boolean | state;
    show?: boolean | state;
    cols?: {
        span?: number;
        offset?: number;
        push?: number;
        pull?: number;
        xs?: number | colsAttr;
        sm?: number | colsAttr;
        md?: number | colsAttr;
        lg?: number | colsAttr;
        xl?: number | colsAttr;
        tag?: string;
    };
    itemProps?: FormItem;
    itemSlots?: {
        default?: () => any;
        error?: itemSlotType;
        label?: itemSlotType;
    };
    /**
     * 设置要渲染的组件，可设置 `element plus` 的所有 `form` 组件，例如：`input`, `datePicker`
     * 也可以传入 `tsx`, `jsx` 语法的虚拟dom
     * 也可以传入一个组件，函数式，例如：() => ElInput,
     *
     * [ tsx, jsx 自定义组件，请手动绑定v-model]
     */
    render?: renderType;
    renderProps?: Record<string, any>;
    renderSlots?: Record<string, renderSlotType>;
    children?: MaFormItem[];
}
