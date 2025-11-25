# FastApp 后台管理系统

基于 Vue3 + TypeScript + Element Plus 构建的企业级后台管理系统前端应用。

## 技术栈

| 技术 | 说明 |
|------|------|
| Vue 3.5+ | Composition API |
| TypeScript | 类型安全 |
| Element Plus | UI 组件库 |
| Pinia | 状态管理 |
| Vite 7 | 构建工具 |
| ECharts | 图表库 |
| TinyMCE | 富文本编辑器 |

## 环境要求

- Node.js >= 20.0.0
- pnpm >= 10.4.1

## 快速开始

### 1. 安装依赖

```bash
pnpm install
```

### 2. 配置环境变量

创建 `.env` 文件，配置关键变量：

```env
VITE_APP_PORT=3000
VITE_APP_API_URL=http://127.0.0.1:9501
VITE_APP_ROUTE_MODE=hash
```

### 3. 启动开发

```bash
pnpm dev
```

访问：`http://localhost:3000`

### 4. 构建生产

```bash
pnpm build
```

## 项目结构

```
web/
├── src/
│   ├── components/    # 组件（ma-* 业务组件，m-* 基础组件）
│   ├── hooks/         # Composition Hooks
│   ├── modules/       # 业务模块（api、views、locales）
│   ├── store/         # Pinia 状态管理
│   └── utils/         # 工具函数
├── docs/              # 开发文档
└── public/            # 静态资源
```

## 核心功能

### 权限管理
- 路由权限、功能权限（`v-auth`）、角色权限（`v-role`）、用户权限（`v-user`）

### 组件库
- **业务组件**：`ma-pro-table`、`ma-form`、`ma-search`、`ma-echarts`、`ma-upload-*`、`ma-dict-*` 等
- **基础组件**：`m-button`、`m-input`、`m-drawer` 等

### 状态管理
- `useUserStore`、`useSettingStore`、`useTabStore`、`useRouteStore`、`useDictStore`

### 国际化
- 支持中文（简体/繁体）、英文，模块级别配置

## 开发指南

### 添加新模块

```bash
# 使用后端代码生成器自动生成（推荐）
php bin/hyperf.php ds:crud --table=users --module=admin

# 或手动创建
src/modules/user/
├── api/index.ts        # API 接口
├── views/index.vue     # 页面组件
└── locales/            # 国际化文件
```

### 使用示例

**表格组件**
```vue
<template>
  <ma-pro-table ref="tableRef" :api="getUserList" :columns="columns" />
</template>
```

**表单组件**
```vue
<template>
  <ma-form ref="formRef" :form-items="formItems" :form-data="formData" />
</template>
```

**Hooks**
```typescript
import { useTable, useForm, useMessage } from '@/hooks'

const { tableRef } = useTable()
const { formRef, validate } = useForm()
const { success, error } = useMessage()
```

## 常用命令

```bash
pnpm dev          # 开发
pnpm build        # 构建
pnpm lint         # 代码检查
pnpm lint:tsc     # 类型检查
pnpm gen:icons    # 生成图标
```

## 开发文档

- **[📖 文档导航](README.md)** - 完整文档索引
- **[前端功能使用指南](前端功能使用指南.md)** - 组件使用、表格、表单、搜索等
- **[图标使用指南](图标使用指南.md)** - 图标组件和选择器
- **[图表使用指南](图表使用指南.md)** - ECharts 图表使用

## 相关链接

- [Vue 3](https://cn.vuejs.org/) | [Element Plus](https://element-plus.org/zh-CN/) | [Vite](https://cn.vitejs.dev/)
- [后端文档](../server/server.md) | [项目根目录](../../README.md)

## 注意事项

1. 使用 `pnpm` 作为包管理器
2. 遵循 ESLint 和 Stylelint 规范
3. 充分利用 TypeScript 类型系统
4. 优先使用现有组件，避免重复造轮子

---

*FastApp 前端项目 - 基于 Vue3 + TypeScript + Element Plus*
