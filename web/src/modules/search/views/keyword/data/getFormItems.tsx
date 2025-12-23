import type { MaFormItem } from '@/components/ma-form'
import type { KeywordVo } from '~/search/api/keyword.ts'
import MaDictSelect from '@/components/ma-dict-picker/ma-dict-select.vue'
import MaSvgIcon from '@/components/ma-svg-icon/index.vue'

export default function getFormItems(formType: 'add' | 'edit' = 'add', t: any, model: KeywordVo): MaFormItem[] {
  // 新增默认值
  if (formType === 'add') {
    model.hit_count = 1
    model.source = 1
    model.sort = 0
  }

  // 编辑默认值
  if (formType === 'edit') {
    // todo...
  }

  return [
    {
      label: () => t('search.KeywordFields.keyword'), // '搜索关键词'
      prop: 'keyword',
      render: () => <el-input />,
      renderProps: {
placeholder: t('search.KeywordFields.keyword'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.KeywordFields.hit_count'), // '命中次数'
      prop: 'hit_count',
      render: () => <el-input-number />,
      renderProps: {
        placeholder: t('search.KeywordFields.hit_count'),
        min: 0,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.KeywordFields.icon'), // '图标'
      prop: 'icon',
      render: () => MaDictSelect,
      renderProps: {
        placeholder: t('search.KeywordFields.icon'),
        dictName: 'search-keyword-icon',
        filterable: true,
        onChange: (value: string) => {
          // 当选择图标时，如果颜色为空，自动填充字典中的默认颜色
          if (!model.color && value) {
            const dictStore = useDictStore()
            const iconDict = dictStore.find('search-keyword-icon')
            const iconItem = iconDict?.find((item: any) => item.value === value)
            if (iconItem?.color) {
              model.color = iconItem.color
            }
          }
        },
      },
      renderSlots: {
        prefix: () => {
          const dictStore = useDictStore()
          const iconDict = dictStore.find('search-keyword-icon')
          const iconItem = iconDict?.find((item: any) => item.value === model.icon)
          const displayColor = model.color || iconItem?.color
          return model.icon ? (
            <MaSvgIcon name={model.icon} size={20} style={{ color: displayColor }} />
          ) : null
        },
        optionDefault: ({ option }: any) => (
          <div class="flex items-center gap-2">
            <MaSvgIcon name={option.value} size={20} style={{ color: option.color }} />
            <span>{option.i18n ? t(option.i18n) : option.label}</span>
          </div>
        ),
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.KeywordFields.color'), // '图标颜色'
      prop: 'color',
      render: () => <el-color-picker show-alpha={false} />,
      renderProps: {
        placeholder: t('search.KeywordFields.color'),
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.KeywordFields.source'), // '来源'
      prop: 'source',
      render: () =>  <ma-dict-select
        dictName="search-keyword-source"
        filterable={true}  // 支持搜索
      />,
      renderProps: {
placeholder: t('search.KeywordFields.source'),
            },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.KeywordFields.sort'), // '排序'
      prop: 'sort',
      render: () => <el-input-number />,
      renderProps: {
        placeholder: t('search.KeywordFields.sort'),
        min: 0,
        max: 9999,
      },
      cols: { lg: 12, md: 24 },
    },
    {
      label: () => t('search.KeywordFields.last_searched_at'), // '最后搜索时间'
      prop: 'last_searched_at',
      render: () => <el-date-picker />,
      renderProps: {
        placeholder: t('search.KeywordFields.last_searched_at'),
      },
      cols: { lg: 12, md: 24 },
    },
  ]
}
