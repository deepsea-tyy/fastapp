
import type {MaFormItem} from '@/components/ma-form'
import type {ConfigGroupVo} from '$/ds/system-config/api/configGroup.ts'
import MaIconPicker from '@/components/ma-icon-picker/index.vue'
import MaChildrenForm from '@/components/ma-children-form/index.vue'
import {lang} from "@/utils/common.ts";

export default function getSysGroupFormItems(formType: 'add' | 'edit' = 'add', t: any, model: ConfigGroupVo): MaFormItem[] {
    return [
        {
            label: () => t('systemMenu.systemConfig.field.groupName'),
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
            },
            itemProps: {
                rules: [{required: true, message: t('form.requiredInput', {msg: t('systemMenu.systemConfig.field.groupName')})}],
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.groupIdentifier'),
            prop: 'code',
            render: 'input',
            renderProps: {
                disabled: formType === 'edit',
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.groupIdentifier')}),
            },
            itemProps: {
                rules: [{required: true, message: t('form.requiredInput', {msg: t('systemMenu.systemConfig.field.groupIdentifier')})}],
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.groupIcon'),
            prop: 'icon',
            render: () => MaIconPicker,
            renderProps: {
                class: 'w-full',
            },
        },
        {
            label: () => t('systemMenu.systemConfig.field.itemRemark'),
            prop: 'remark',
            render: 'input',
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('systemMenu.systemConfig.field.itemRemark')}),
                type: 'textarea',
            },
        },
    ]
}
