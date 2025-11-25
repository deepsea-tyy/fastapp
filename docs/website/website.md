# FastApp 企业官网

基于 Nuxt.js 4.2 构建的企业官网，支持 SSR/SSG、SEO 优化、国际化等功能。

## 技术栈

- **框架**: Nuxt.js 4.2
- **语言**: TypeScript
- **UI 框架**: Vue 3
- **样式**: Tailwind CSS
- **构建工具**: Vite

## 功能特性

- ✅ 服务端渲染 (SSR)
- ✅ 静态站点生成 (SSG)
- ✅ SEO 优化
- ✅ 响应式设计
- ✅ TypeScript 支持
- ✅ 现代化 UI 设计

## 快速开始

### 安装依赖

```bash
pnpm install
```

### 开发模式

```bash
pnpm dev
```

访问 http://localhost:3000

### 构建生产版本

```bash
pnpm build
```

### 生成静态站点

```bash
pnpm generate
```

### 预览生产版本

```bash
pnpm preview
```

## 项目结构

```
website/
├── assets/          # 静态资源（CSS、图片等）
├── components/      # Vue 组件
├── layouts/         # 布局文件
├── pages/           # 页面文件（自动路由）
├── public/          # 公共静态文件
├── nuxt.config.ts   # Nuxt 配置文件
├── package.json     # 项目依赖
└── tsconfig.json    # TypeScript 配置
```

## 页面说明

- `/` - 首页
- `/about` - 关于我们
- `/products` - 产品与服务
- `/contact` - 联系我们

## 开发说明

### 添加新页面

在 `pages/` 目录下创建新的 `.vue` 文件，Nuxt 会自动生成路由。

### 添加新组件

在 `components/` 目录下创建组件，可以在任何地方直接使用，无需导入。

### 修改布局

编辑 `layouts/default.vue` 文件来修改默认布局。

## 部署

### 静态部署

使用 `pnpm generate` 生成静态文件，然后部署到任何静态托管服务。

### 服务端渲染部署

使用 `pnpm build` 构建应用，然后使用 Node.js 运行。

## 相关文档

- [Nuxt.js 官方文档](https://nuxt.com)
- [Vue 3 文档](https://vuejs.org)
- [Tailwind CSS 文档](https://tailwindcss.com)

