import type {MaFormItem} from '@/components/ma-form'
import MaChildrenForm from '@/components/ma-children-form/index.vue'
import type {ArticleVo} from '$/ds/sysCms/api/article.ts'
import {lang} from "@/utils/common.ts";
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectCategory} from "$/ds/sysCms/api/category.ts";

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
            cols: { lg: 12, md: 24 },
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
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.code'), // '调用代码'
            prop: 'code',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.code')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('crud.sort'), // '排序'
            prop: 'sort',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('crud.sort'),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.view_count'), // '浏览数'
            prop: 'view_count',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.view_count')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.like_count'), // '点赞数'
            prop: 'like_count',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.like_count')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.comment_count'), // '评论数'
            prop: 'comment_count',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.comment_count')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.share_count'), // '分享数'
            prop: 'share_count',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.share_count')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.collect_count'), // '收藏数'
            prop: 'collect_count',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.collect_count')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.author'), // '作者'
            prop: 'author',
            render: () => <el-input/>,
            renderProps: {
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.author')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('article.ArticleFields.release_at'), // '发布日期'
            prop: 'release_at',
            render: () => <el-date-picker/>,
            renderProps: {
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.release_at')}),
            },
            cols: { lg: 12, md: 24 },
        },
        {
            label: () => t('crud.remark'), // '备注'
            prop: 'remark',
            render: () => <el-input/>,
            renderProps: {placeholder: t('crud.remark')},
            cols: { lg: 12, md: 24 },
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
                        addDefaultValue: 'zh_CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'upload',
                    }
                ],
                defaultItemValue: {lang: 'zh_CN', text: ''},
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.cover')}),
            },
            cols: { lg: 12, md: 24 },
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
                        addDefaultValue: 'zh_CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'uploadVideo',
                    }
                ],
                defaultItemValue: {lang: 'zh_CN', text: ''},
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.video')}),
            },
            cols: { lg: 12, md: 24 },
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
                        addDefaultValue: 'zh_CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'textarea',
                    }
                ],
                defaultItemValue: {lang: 'zh_CN', text: ''},
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.title')}),
            },
            cols: { lg: 12, md: 24 },
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
                        addDefaultValue: 'zh_CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'textarea',
                    }
                ],
                defaultItemValue: {lang: 'zh_CN'},
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.subtitle')}),
            },
            cols: { lg: 12, md: 24 },
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
                        addDefaultValue: 'zh_CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'textarea',
                    }
                ],
                defaultItemValue: {lang: 'zh_CN', text: ''},
                placeholder: t('form.pleaseInput', {msg: t('article.ArticleFields.brief')}),
            },
            cols: { lg: 12, md: 24 },
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
                        addDefaultValue: 'zh_CN',
                    },
                    {
                        title: t('common.content'),
                        dataIndex: 'text',
                        formType: 'editor',
                    }
                ],
                defaultItemValue: {lang: 'zh_CN', text: ''},
                placeholder: t('form.pleaseSelect', {msg: t('article.ArticleFields.content')}),
            },
        },
    ]
}
