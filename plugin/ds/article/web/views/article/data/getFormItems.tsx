import type {MaFormItem} from '@/components/ma-form'
import MaChildrenForm from '@/components/ma-children-form/index.vue'
import type {ArticleVo} from '$/ds/article/api/article.ts'
import {lang} from "@/utils/common.ts";
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectCategory} from "$/ds/article/api/category.ts";

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: ArticleVo): MaFormItem[] {
    return [
        {
            label: () => t('crud.category'),
            prop: 'category_id',
            render: () => MaRemoteSelect,
            renderProps: {
                api: selectCategory,
                multiple:true,
                placeholder: t('form.pleaseSelect', {msg: t('crud.category')}),
            },
        },
        {
            label: () => t('crud.status'), // '1显示'
            prop: 'status',
            render: () => <ma-dict-select/>,
            renderProps: {
                placeholder: t('crud.status'),
                clearable: true,
                dictName: 'system-display',
            },
        },
        {
            label: () => t('article.ArticleFields.code'), // '调用代码'
            prop: 'code',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.code')}),
            },
        },
        {
            label: () => t('crud.sort'), // '排序'
            prop: 'sort',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('crud.sort'),
            },
        },
        {
            label: () => t('article.ArticleFields.comment'), // '评论数'
            prop: 'comment',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.comment')}),
            },
        },
        {
            label: () => t('article.ArticleFields.views'), // '浏览数'
            prop: 'views',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.views')}),
            },
        },
        {
            label: () => t('article.ArticleFields.like'), // '点赞数'
            prop: 'like',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.like')}),
            },
        },
        {
            label: () => t('article.ArticleFields.author'), // '作者'
            prop: 'author',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.author')}),
            },
        },
        {
            label: () => t('article.ArticleFields.release_at'), // '发布日期'
            prop: 'release_at',
            render: () => <el-date-picker/>,
            renderProps: {
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.release_at')}),
            },
        },
        {
            label: () => t('crud.remark'), // '备注'
            prop: 'remark',
            render: () => <el-input/>,
            renderProps: {placeholder: t('crud.remark')},
        },
        {
            label: () => t('article.ArticleFields.cover'), // '封面'
            prop: 'cover',
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
                        formType: 'upload',
                    }
                ],
                defaultItemValue: {lang: 'zh-CN', text: ''},
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.cover')}),
            },
        },
        {
            label: () => t('article.ArticleFields.video'), // '视频'
            prop: 'video',
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
                        formType: 'uploadVideo',
                    }
                ],
                defaultItemValue: {lang: 'zh-CN', text: ''},
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.video')}),
            },
        },
        {
            label: () => t('article.ArticleFields.title'), // '标题'
            prop: 'title',
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
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.title')}),
            },
        },
        {
            label: () => t('article.ArticleFields.subtitle'), // '副标题'
            prop: 'subtitle',
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
                defaultItemValue: {lang: 'zh-CN'},
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.subtitle')}),
            },
        },
        {
            label: () => t('article.ArticleFields.brief'), // '摘要'
            prop: 'brief',
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
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.brief')}),
            },
        },
        {
            label: () => t('article.ArticleFields.content'), // '内容'
            prop: 'content',
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
                        formType: 'editor',
                    }
                ],
                defaultItemValue: {lang: 'zh-CN', text: ''},
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.content')}),
            },
        },
    ]
}
