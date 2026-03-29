import type { App } from 'vue';
import useForm from './components/useForm';
import type { MaFormInstallOptions } from './types';
export declare const MaForm: {
    install(app: App, options?: MaFormInstallOptions): void;
};
export default MaForm;
export { useForm };
export type { MaFormInstallOptions, MaFormOptions, MaFormItem, MaFormExpose, MaModel, renderType, LoadingConfig, ComponentName, FormItem, state, } from './types';
