import type { MaFormItem } from '@/components/ma-form'
import type { AppPageContentVo } from '$/ds/sysCms/api/appPageContent.ts'
import MaJsonEditor from '@/components/ma-json-editor/index.vue'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: AppPageContentVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.content_type = 1
    model.platform = 2
    model.fixed = 1
    model.status = 1
    model.sort = 100
    model.data = {}
  }
  
  // 根据 content_type 确定 data 字段的编辑器类型
  const getDataType = (contentType?: number) => {
    const type = contentType ?? model.content_type
    switch (type) {
      case 1: // 固定文本 - 多语言对象
        return 'object'
      case 2: // 列表数据 - 数组
        return 'array'
      case 3: // 富文本 - 对象
        return 'object'
      case 4: // 配置项 - 对象
        return 'object'
      default:
        return 'object'
    }
  }

  return [
    {
      label: () => t('admin.AppPageContentFields.code'),
      prop: 'code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.code'),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('admin.AppPageContentFields.code') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.page_code'),
      prop: 'page_code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.page_code'),
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseInput', { msg: t('admin.AppPageContentFields.page_code') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.component_code'),
      prop: 'component_code',
      render: () => <el-input />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.component_code'),
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.content_type'),
      prop: 'content_type',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.content_type'),
        dictName: 'app-page-content-type',
        clearable: true,
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseSelect', { msg: t('admin.AppPageContentFields.content_type') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.platform'),
      prop: 'platform',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.platform'),
        dictName: 'app-page-content-platform',
        clearable: true,
      },
      itemProps: {
        rules: [{ required: true, message: t('form.pleaseSelect', { msg: t('admin.AppPageContentFields.platform') }) }],
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.data'),
      prop: 'data',
      render: () => MaJsonEditor,
      renderProps: {
        type: () => getDataType(),
        height: '300px',
      },
      cols: { lg: 24, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.start_at'),
      prop: 'start_at',
      render: () => <el-date-picker />,
      renderProps: {
        type: 'datetime',
        placeholder: t('admin.AppPageContentFields.start_at'),
        valueFormat: 'X',
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.end_at'),
      prop: 'end_at',
      render: () => <el-date-picker />,
      renderProps: {
        type: 'datetime',
        placeholder: t('admin.AppPageContentFields.end_at'),
        valueFormat: 'X',
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('admin.AppPageContentFields.fixed'),
      prop: 'fixed',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('admin.AppPageContentFields.fixed'),
        dictName: 'system-yes-no',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.status'),
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
        placeholder: t('crud.status'),
        dictName: 'system-status',
        clearable: true,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.sort'),
      prop: 'sort',
      render: () => <el-input-number />,
      renderProps: {
        placeholder: t('crud.sort'),
        min: 0,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('crud.remark'),
      prop: 'remark',
      render: () => <el-input />,
      renderProps: {
        type: 'textarea',
        placeholder: t('crud.remark'),
        rows: 3,
      },
      cols: { lg: 24, md: 24 },
    },
  ]
}

