# FastApp 项目说明

[![GitHub](https://img.shields.io/badge/GitHub-fastapp-blue?logo=github)](https://github.com/deepsea-tyy/fastapp)

FastApp 是一个企业级全栈应用框架，包含移动端、Web端、后台管理系统、企业官网和后端服务。

## 项目结构

```
fastapp/
├── server/          # 后端服务（Hyperf 3.1 + Swoole）
├── web/             # 后台管理系统（Vue3 + TypeScript + Element Plus）
├── app/             # 移动端应用（Flutter + Dart）
├── website/         # 企业官网（Nuxt.js 4.2）
└── docs/            # 项目文档
```

## 各模块说明

### app
Flutter 移动端应用，采用 MobX + Provider 状态管理，支持多平台部署。

详细文档：[app 文档](docs/app/开发指南.md)

### web
后台管理系统前端应用，基于 Vue3 + TypeScript + Element Plus 构建。

详细文档：[web 文档](docs/web/开发指南.md)

### server
后端服务目录

基于 Hyperf 3.1 + Swoole 构建的高性能后端服务，提供 API 接口、WebSocket 服务、权限管理、代码生成等功能。

详细文档请查看：[server 文档](docs/server/getting-started/开发指南.md)

#### 项目结构

```
fastapp/
├── server/          # 后端服务
│   ├── app/         # 应用代码（Controller、Service、Repository、Model）
│   ├── config/      # 配置文件
│   ├── databases/   # 数据库迁移和种子文件
│   ├── plugin/      # 插件目录
│   ├── runtime/     # 运行时文件（日志、缓存）
│   └── storage/     # 存储目录（上传文件、多语言、Swagger）
├── web/             # 前端代码
├── app/             # Flutter移动端应用
└── website/         # 企业官网
```

#### 代码架构

采用分层架构设计：

```
Controller → Service → Repository → Model
   HTTP      业务逻辑    数据操作   数据模型
```

**命名规范**：
- 文件：`UserController.php`、`UserService.php`、`UserRepository.php`
- 目录：使用 PascalCase，按业务模块划分

### website
企业官网，基于 Nuxt.js 4.2 构建，支持 SSR/SSG、SEO 优化、国际化等功能。

详细文档：[website 文档](docs/website/企业官网.md)

## 技术栈

- **后端**: Hyperf 3.1 + Swoole + PHP 8.1+
- **前端**: Vue3 + TypeScript + Element Plus + Pinia
- **移动端**: Flutter + Dart + MobX + Provider
- **官网**: Nuxt.js 4.2 + Vue3 + TypeScript
- **数据库**: MySQL + Redis

## 快速开始

### 后端服务
```bash
cd server && composer install && cp .env.example .env && php bin/hyperf.php start
```

### 后台管理系统
```bash
cd web && pnpm install && pnpm dev
```

### 移动端应用
```bash
cd app && flutter pub get && flutter run
```

### 企业官网
```bash
cd website && pnpm install && pnpm dev
```

## 项目特点

- 🚀 **高性能**: 基于 Swoole 协程，支持高并发
- 🔐 **权限管理**: 完整的 RBAC 权限系统
- 🤖 **AI 辅助**: AI 模板开发，智能代码生成
- 📱 **跨平台**: Flutter 支持多平台部署
- 🎨 **现代化 UI**: Vue3 + Element Plus 构建美观的管理界面
- 🔌 **插件系统**: 灵活的插件扩展机制

## 相关文档

- [后端服务文档](docs/server/getting-started/开发指南.md)
- [后台管理系统文档](docs/web/开发指南.md)
- [移动端应用文档](docs/app/开发指南.md)
- [企业官网文档](docs/website/企业官网.md)

## 技术支持

- **作者**：deepsea
- **联系方式**：https://t.me/deepsea159
- **框架版本**：Hyperf 3.1

## ☕ 给我一杯咖啡

如果这个项目对你有帮助，欢迎请我喝一杯咖啡！

<div align="center">
  <img src="docs/assets/wechat_qr.png" alt="微信收款码" width="300" />
</div>

