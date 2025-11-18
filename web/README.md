# FastApp 后台管理系统

基于 Vue3 + TypeScript + Element Plus 构建的企业级后台管理系统前端应用。

## 技术栈

- **框架**: Vue 3.5+ (Composition API)
- **语言**: TypeScript
- **UI 组件库**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **构建工具**: Vite 7
- **样式**: SCSS + UnoCSS
- **国际化**: Vue I18n
- **HTTP 客户端**: Axios
- **图表**: ECharts
- **富文本编辑器**: TinyMCE
- **其他**: VueUse、Day.js、Lodash-es 等

## 环境要求

- Node.js >= 20.0.0 或 >= 21.1.0
- pnpm >= 10.4.1 (推荐使用 pnpm 作为包管理器)

## 快速开始

### 1. 安装依赖

```bash
pnpm install
```

### 2. 配置环境变量

创建 `.env` 文件（可参考 `.env.example`），配置以下关键变量：

```env
# 应用端口
VITE_APP_PORT=3000

# API 基础地址
VITE_APP_API_URL=http://127.0.0.1:9501

# 路由模式 (hash/history)
VITE_APP_ROUTE_MODE=hash

# 是否开启 vConsole
VITE_OPEN_vCONSOLE=false
```

### 3. 启动开发服务器

```bash
pnpm dev
```

访问地址：`http://localhost:3000`（端口根据配置而定）

### 4. 构建生产版本

```bash
pnpm build
```

构建产物将输出到 `dist` 目录。

## 项目结构

```
web/
├── src/
│   ├── assets/          # 静态资源（样式、图片等）
│   ├── components/      # 公共组件
│   │   ├── ma-*        # 业务组件（表格、表单、搜索等）
│   │   └── m-basic-ui/ # 基础 UI 组件
│   ├── directives/      # Vue 指令（权限、复制等）
│   ├── hooks/           # Composition API Hooks
│   ├── layouts/         # 布局组件
│   ├── locales/         # 国际化文件
│   ├── modules/         # 业务模块
│   │   ├── base/        # 基础模块
│   │   └── test/        # 测试模块
│   ├── plugins/         # 插件目录
│   ├── provider/        # 全局提供者（字典、设置等）
│   ├── router/          # 路由配置
│   ├── store/           # Pinia 状态管理
│   ├── utils/           # 工具函数
│   ├── App.vue          # 根组件
│   ├── bootstrap.ts     # 应用启动引导
│   └── main.ts          # 入口文件
├── public/              # 公共静态资源
├── vite/                # Vite 插件配置
├── vite.config.ts       # Vite 配置文件
└── package.json         # 项目配置
```

## 核心功能

### 1. 权限管理
- 基于路由的权限控制
- 功能权限（v-auth）
- 角色权限（v-role）
- 用户权限（v-user）

### 2. 布局系统
- 多种布局模式（经典、混合、横幅等）
- 响应式设计，支持移动端
- 可配置的主题和样式

### 3. 组件库
- **ma-pro-table**: 高级表格组件
- **ma-form**: 动态表单组件
- **ma-search**: 搜索组件
- **ma-echarts**: 图表组件
- **ma-editor**: 富文本编辑器
- 更多组件请查看 `src/components/ma-*`

### 4. 状态管理
使用 Pinia 进行状态管理，主要 Store 模块：
- `useUserStore`: 用户信息
- `useSettingStore`: 系统设置
- `useTabStore`: 标签页管理
- `useRouteStore`: 路由管理
- `useDictStore`: 字典数据

### 5. 国际化
支持多语言切换，默认语言文件：
- 简体中文 (zh_CN)
- 繁体中文 (zh_TW)
- English (en)

## 开发指南

### 添加新模块

1. 在 `src/modules/` 下创建模块目录
2. 创建模块的 API、视图、国际化文件
3. 在路由中注册模块路由

### 使用组件

```vue
<template>
  <ma-pro-table
    ref="tableRef"
    :api="getUserList"
    :columns="columns"
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { getUserList } from '@/api/user'

const tableRef = ref()
const columns = [
  { prop: 'name', label: '姓名' },
  { prop: 'email', label: '邮箱' },
]
</script>
```

### 使用 Hooks

```typescript
import { useTable } from '@/hooks/useTable'
import { useForm } from '@/hooks/useForm'
import { useMessage } from '@/hooks/useMessage'

const { tableRef, getTableList } = useTable()
const { formRef, validate } = useForm()
const { success, error } = useMessage()
```

## 常用命令

```bash
# 开发
pnpm dev

# 构建
pnpm build

# 预览构建结果
pnpm serve

# 代码检查
pnpm lint

# 类型检查
pnpm lint:tsc

# E2E 测试
pnpm test:e2e

# 生成图标
pnpm gen:icons
```

## 注意事项

1. **包管理器**: 推荐使用 `pnpm`，项目已锁定包管理器版本
2. **代码规范**: 项目配置了 ESLint 和 Stylelint，提交前请确保代码通过检查
3. **类型安全**: 使用 TypeScript，请确保类型定义正确
4. **环境变量**: 不同环境使用不同的 `.env` 文件（`.env.development`、`.env.production`）

## 相关文档

- [Vue 3 文档](https://cn.vuejs.org/)
- [Element Plus 文档](https://element-plus.org/zh-CN/)
- [Vite 文档](https://cn.vitejs.dev/)
- [Pinia 文档](https://pinia.vuejs.org/zh/)

## 技术支持

如有问题，请查看项目文档或联系开发团队。

