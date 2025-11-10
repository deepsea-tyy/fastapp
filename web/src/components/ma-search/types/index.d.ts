import { MaSearchOptions } from './search-options';
import type { MaFormOptions, MaFormItem } from '@/components/ma-form';
import MaForm from '@/components/ma-form';
interface MaSearchItem extends MaFormItem {
    hide?: boolean | (() => boolean);
    span?: number;
    offset?: number;
}
type MaSearchInstallOptions = {
    ssr?: boolean;
};
interface MaSearchExpose {
    getMaFormRef: () => typeof MaForm;
    foldToggle: () => void;
    getFold: () => boolean;
    setSearchForm: (form: null | Record<string, any>) => void;
    getSearchForm: () => Record<string, any>;
    setShowState: (state: boolean) => void;
    getShowState: () => boolean;
    setOptions: (opts: MaSearchOptions) => void;
    getOptions: () => MaSearchOptions;
    setFormOptions: (opts: MaFormOptions) => void;
    getFormOptions: () => MaFormOptions;
    setItems: (items: MaSearchItem[]) => void;
    getItems: () => MaSearchItem[];
    appendItem: (item: MaSearchItem) => void;
    removeItem: (prop: string) => void;
    getItemByProp: (prop: string) => void;
    setSearchBtnProps: (p: Record<string, any>) => void;
    setResetBtnProps: (p: Record<string, any>) => void;
}
export type { MaSearchInstallOptions, MaSearchOptions, MaSearchExpose, MaSearchItem, };
