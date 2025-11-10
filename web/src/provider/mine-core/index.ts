
import type { ProviderService } from '#/global'
import type { MaFormItem, MaFormOptions } from '@/components/ma-form'
import type { MaSearchItem, MaSearchOptions } from '@/components/ma-search'
import type { MaTableColumns, MaTableOptions, PaginationProps } from '@/components/ma-table'
import type { App } from 'vue'
import MaSvgIcon from '@/components/ma-svg-icon/index.vue'
import ContextMenu from '@imengyu/vue3-context-menu'
import MaForm from '@/components/ma-form'
import MaProTable from '@/components/ma-pro-table'
import MaSearch from '@/components/ma-search'
import FloatingVue from 'floating-vue'

import MaTable from '@/components/ma-table'

// MaTable样式（已包含在组件中）
// MaSearch样式（已包含在组件中）
// MaProTable样式（已包含在组件中）
// FloatingVue样式 (tooltip 需要)
import 'floating-vue/dist/style.css'

interface MineCoreCommonConfig {
  table?: {
    commonOptions: MaTableOptions
    commonColumns: MaTableColumns[]
    commonPagination: PaginationProps | null
  }
  form?: {
    commonOptions: MaFormOptions
    commonItems: MaFormItem[]
  }
  search?: {
    commonOptions: MaSearchOptions
    commonItems: MaSearchItem[]
  }
}

function commonConfig(): MineCoreCommonConfig {
  return {
    table: {
      commonOptions: {},
      commonColumns: [],
      commonPagination: null,
    },
    form: {
      commonOptions: {},
      commonItems: [],
    },
    search: {
      commonOptions: {},
      commonItems: [],
    },
  }
}

// 注册 basic-ui 组件
async function registerBasicUIComponents(app: App) {
  // 注册 FloatingVue (tooltip 需要)
  app.use(FloatingVue, { distance: 12 })
  
  // 动态导入并注册所有 basic-ui 组件（包括 index.vue 和其他 .vue 文件）
  const components = import.meta.glob('@/components/m-basic-ui/components/**/*.vue', { eager: true })
  for (const path in components) {
    const component: any = components[path]
    if (component.default && component.default.name) {
      app.component(component.default.name, component.default)
    }
  }
}

const provider: ProviderService.Provider = {
  name: 'mine-core',
  async setProvider(app: App) {
    // 先注册 basic-ui 组件，确保全局可用
    await registerBasicUIComponents(app)
    
    app.use(MaTable)
    app.use(MaForm)
    app.use(MaSearch)
    app.use(MaProTable, {
      ssr: false,
      provider: {
        app,
        icon: markRaw(MaSvgIcon),
        contextMenu: ContextMenu.showContextMenu,
      },
    })
    app.config.globalProperties.$mineCore = commonConfig()
  },
  getProvider(): any {
    return useGlobal().$mineCore
  },
}

export default provider as ProviderService.Provider
