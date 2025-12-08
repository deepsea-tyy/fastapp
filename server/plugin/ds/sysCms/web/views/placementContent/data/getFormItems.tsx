import type { MaFormItem } from '@/components/ma-form'
import type { PlacementContentVo } from '$/ds/sysCms/api/placementContent.ts'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import MaChildrenForm from '@/components/ma-children-form/index.vue'
import {selectPlacementPosition} from "$/ds/sysCms/api/placementPosition.ts";
import {lang} from "@/utils/common.ts";

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: PlacementContentVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.object_type = 1

    model.object_id = 0

    model.target = 1

    model.fixed = 0

    model.status = 1

    model.sort = 0

    model.views = 0

    model.clicks = 0

  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('admin.PlacementContentFields.code'), // '调用代码'
      prop: 'code',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.code'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementPosition'),
      prop: 'position_id',
      render: () => MaRemoteSelect,
      renderProps: {
                api: selectPlacementPosition,
                multiple: true,
placeholder: t('admin.PlacementPosition'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.name'), // '内容名称'
      prop: 'name',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.name'),
            },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('admin.PlacementContentFields.name') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.object_type'), // '数据类型：1链接 2视频 3分享 4文章 5路径'
      prop: 'object_type',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.PlacementContentFields.object_type'),
        dictName: 'placement-object-type',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.url'), // '链接地址（object_type=1）'
      prop: 'url',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.url'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.target'), // '链接打开方式：1当前窗口 2新窗口'
      prop: 'target',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.PlacementContentFields.target'),
        dictName: 'placement-target',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.start_at'), // '开始时间（时间戳）'
      prop: 'start_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.start_at'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.end_at'), // '结束时间（时间戳）'
      prop: 'end_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.end_at'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.fixed'), // '永久有效：1是 0否'
      prop: 'fixed',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.PlacementContentFields.fixed'),
        dictName: 'system-yes-no',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('crud.status'),
        dictName: 'placement-status',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.sort'), // '排序'
      prop: 'sort',
      render: () => <el-input />,
      renderProps: {
placeholder: t('crud.sort'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.remark'), // '备注'
      prop: 'remark',
      render: () => <el-input />,
      renderProps: {
placeholder: t('crud.remark'),
        type: 'textarea',
        rows: 3,
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.views'), // '展示次数'
      prop: 'views',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.views'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.clicks'), // '点击次数'
      prop: 'clicks',
      render: () => <el-input />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.clicks'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.cover'), // '封面图片（多语言，用于覆盖关联数据的封面）'
      prop: 'cover',
      render: () => <ma-upload-image />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.cover'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.title'), // '标题（多语言，用于覆盖关联数据的标题）'
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
            formType: 'input',
          }
        ],
        defaultItemValue: {lang: 'zh_CN', text: ''},
        placeholder: t('form.pleaseInput', { msg: t('admin.PlacementContentFields.title') }),
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.desc'), // '描述（多语言，用于覆盖关联数据的描述）'
      prop: 'desc',
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
        placeholder: t('form.pleaseInput', { msg: t('admin.PlacementContentFields.desc') }),
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.PlacementContentFields.content'), // '分享内容（多语言，object_type=3分享时使用）'
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
            formType: 'textarea',
          }
        ],
        defaultItemValue: {lang: 'zh_CN', text: ''},
        placeholder: t('form.pleaseInput', { msg: t('admin.PlacementContentFields.content') }),
      },
      cols: { lg: 12, md: 24 },
    },
  ]
}
