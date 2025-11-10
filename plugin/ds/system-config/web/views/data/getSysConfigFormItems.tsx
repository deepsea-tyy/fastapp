import type {MaFormItem} from '@/components/ma-form'
import type {ConfigGroupVo} from '$/ds/system-config/api/configGroup.ts'
import type {ConfigVo} from '$/ds/system-config/api/config.ts'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import MaKeyValue from '@/components/ma-key-value/index.vue'

import {page} from '$/ds/system-config/api/configGroup.ts'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'
import {formatLang, lang} from "@/utils/common.ts";
import MaChildrenForm from '@/components/ma-children-form/index.vue'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: ConfigVo): MaFormItem[] {
    const isDataSourceHidden = ref(true) // 控制数据源显示与否
    if (formType === 'add') {
        model.sort = 0
        model.input_type = 'input'
    }

    // 如果数据源显示
    if (formType === 'add' && isDataSourceHidden.value) {
        model.config_select_data = []
    }

    return [
        {
            label: () => t('systemMenu.systemConfig.field.belongingGroup'),
            prop: 'group_code',
            render: () => MaRemoteSelect,
            renderProps: {
                disabled: true,
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.belongingGroup')}),
                api: () => new Promise(resolve => resolve(page({page_size: 999}))),
                dataHandle: (response: any) => {
                    return response.data?.map((item: ConfigGroupVo) => {
                        return {label: formatLang(item.name), value: item.code}
                    })
                },
            },
            itemProps: {
                rules: [{required: true, message: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.belongingGroup')})}],
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.configTitle'),
            prop: 'name',
            render: () => MaChildrenForm,
            renderProps: {
                options: {
                    showAddButton: true,
                    showDeleteButton: true,
                    minItems: 1,
                    emptyRow: 1,
                    itemTitle: t('common.language'),
                    itemLabelWidth: '80px',
                    itemWidth: '100%'
                },
                formList: [
                    {
                        title: t('common.language'),
                        dataIndex: 'lang',
                        formType: 'select',
                        dict: {
                            data: lang(t),
                        },
                        addDefaultValue: 'zh-CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'textarea',
                    }
                ],
                defaultItemValue: {lang: 'zh-CN', text: ''},
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.configTitle')}),
            },
            itemProps: {
                rules: [{required: true, message: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.configTitle')})}],
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.configIdentifier'),
            prop: 'key',
            render: 'input',
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.configIdentifier')}),
            },
            itemProps: {
                rules: [{required: true, message: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.configIdentifier')})}],
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.configValue'),
            prop: 'value',
            render: 'input',
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.configValue')}),
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.sortOrder'),
            prop: 'sort',
            render: 'inputNumber',
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.sortOrder')}),
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.component'),
            prop: 'input_type',
            render: () => MaDictSelect,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.component')}),
                data: () => {
                    // 在 dataHandle 中定义一个数组
                    return [
                        {label: t('systemMenu.systemConfig.field.componentInfo.textBox'), value: 'input'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.textArea'), value: 'textarea'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.dropdown'), value: 'select'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.radio'), value: 'radio'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.checkbox'), value: 'checkbox'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.switch'), value: 'switch'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.imageUpload'), value: 'imageUpload'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.keyValuePair'), value: 'keyValuePair'},
                        {label: t('systemMenu.systemConfig.field.componentInfo.tinyMCE'), value: 'editor'},
                    ]
                },
                onChange: (value: string) => {
                    isDataSourceHidden.value = !['select', 'radio', 'checkbox', 'switch', 'keyValuePair'].includes(value)
                },
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.dataSource'),
            prop: 'config_select_data',
            hide: () => isDataSourceHidden.value,
            render: () => MaKeyValue,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.dataSource')}),
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.configDescription'),
            prop: 'remark',
            render: 'input',
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.configDescription')}),
            },
        },
    ]
}
