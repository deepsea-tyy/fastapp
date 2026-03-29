import { FormItem, MaFormItem, ComponentName, state, renderType, colsAttr, renderSlotType, itemSlotType, renderCustomer } from './form-item';
import { MaFormOptions, alignmentType } from './form-options';
import { LoadingConfig } from './loading-config';
import { ElForm } from 'element-plus';
type MaFormInstallOptions = {
    ssr?: boolean;
};
interface MaFormExpose {
    setLoadingState: (loading: boolean) => void;
    setOptions: (opts: MaFormOptions) => void;
    getOptions: () => MaFormOptions;
    setItems: (items: MaFormItem[]) => void;
    getItems: () => MaFormItem[];
    appendItem: (item: MaFormItem) => void;
    getItemByProp: (prop: string) => MaFormItem;
    getElFormRef: () => typeof ElForm;
}
interface MaModel {
    [key: string]: any;
}
export type { MaFormInstallOptions, MaFormOptions, MaFormItem, MaFormExpose, MaModel, renderType, colsAttr, alignmentType, LoadingConfig, ComponentName, FormItem, renderSlotType, itemSlotType, renderCustomer, state, };
