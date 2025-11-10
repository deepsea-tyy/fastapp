# FastApp 开发框架

> 🚀 **FastApp** - 基于 Hyperf 3.1 + Vue3 + TypeScript 构建的企业级全栈应用框架 | 🤖 **AI 模板开发** - 智能代码生成，让开发更高效

**FastApp** 是一个高性能的企业级应用开发框架，基于 Hyperf 3.1 和 Swoole 协程技术，集成完整的权限管理、JWT认证、代码生成器、WebSocket、插件系统等核心功能。**最大亮点是 AI 模板开发**，通过 AI 辅助生成代码模板，大幅提升开发效率，帮助开发者快速构建后台管理系统和 API 服务。

## ✨ 核心亮点

### 🤖 AI 模板开发
- **AI 辅助代码生成**：基于 AI 的智能代码模板生成，支持 CRUD、API、前端页面等
- **模板定制化**：AI 根据项目需求自动生成和优化代码模板
- **开发效率提升**：通过 AI 模板开发，减少 70% 的重复编码工作
- **智能提示**：AI 提供开发建议和最佳实践

> 📖 详细使用指南：[AI辅助开发流程指南](docs/AI辅助开发流程指南.md)

## 🔍 搜索关键词

**技术栈**：Hyperf | Swoole | PHP 8.1+ | Vue3 | TypeScript | Element Plus | RBAC | JWT | WebSocket | Code Generator

**AI 相关**：AI 模板开发 | AI 代码生成 | AI 辅助开发 | AI 开发工具 | 智能代码生成 | AI 编程助手

**应用场景**：后台管理系统 | 企业级应用 | API 服务 | 权限管理 | 代码生成 | 插件开发 | AI 开发框架

## 📚 文档导航

> 📖 **完整文档索引**：请查看 [文档导航](docs/README.md)

**快速链接**：
- 🚀 [快速开始](docs/快速开始.md) | 📖 [开发规范](docs/开发规范.md) | ⚙️ [核心功能](docs/核心功能.md)
- 🔧 [代码生成器](docs/代码生成器.md) | 🔌 [插件系统](docs/插件系统使用指南.md) | 🌐 [WebSocket](docs/WebSocket开发文档.md)
- 🔐 [权限系统](docs/权限系统使用文档.md) | 🤖 [AI辅助开发](docs/AI辅助开发流程指南.md)

## 主要特性

| 特性 | 说明 |
|------|------|
| 🤖 **AI 模板开发** | **核心亮点**：AI 辅助代码生成，智能模板定制，减少 70% 重复编码工作 |
| 🚀 **高性能** | 基于 Swoole 和 Hyperf，协程并发处理 |
| 🔐 **安全认证** | JWT 认证系统，支持 AccessToken 和 RefreshToken |
| 📊 **权限管理** | 基于 RBAC，支持功能权限和数据权限 |
| 🔧 **代码生成** | 自动化 CRUD 代码生成器，支持前后端代码生成，配合 AI 模板开发更高效 |
| 📄 **Excel处理** | 强大的导入导出功能，支持大数据量分片处理 |
| 🔌 **插件系统** | 完整的插件开发和管理系统 |
| 🌐 **WebSocket** | 完整的 WebSocket 服务器解决方案，支持多设备在线 |

## 快速开始

**环境要求**：PHP >= 8.1 | Swoole >= 5.0 | MySQL >= 5.7 | Redis >= 3.0

```bash
# 安装依赖
composer install

# 配置环境
cp .env.example .env

# 启动服务
php bin/hyperf.php start
```

**访问地址**：
- **API 接口**：`http://127.0.0.1:9501`（默认端口，可通过 `.env` 中的 `APP_PORT` 配置）
- **Swagger 文档**：`http://127.0.0.1:9503/swagger`（默认与 API 同端口，可通过 `.env` 中的 `APP_DOC_PORT` 配置独立端口）
- **WebSocket**：`ws://127.0.0.1:9502`（默认端口，可通过 `.env` 中的 `WS_PORT` 配置）

**核心命令**：
```bash
# 代码生成（完整CRUD）
php bin/hyperf.php ds:generate-crud --table=users --module=admin

# 代码生成（API模式）
php bin/hyperf.php ds:generate-crud --table=users --module=api --target=api

# 数据库迁移
php bin/hyperf.php migrate
```

## 项目结构

```
fastapp/
├── app/          # 应用代码
├── config/       # 配置文件
├── databases/    # 数据库迁移和种子文件
├── plugin/       # 插件目录
├── runtime/      # 运行时文件（日志、缓存）
├── storage/      # 存储目录（上传文件、多语言、Swagger）
├── web/          # 前端代码
└── docs/         # 文档目录
```

> 💡 详细结构说明请查看 [项目结构文档](docs/项目结构.md)

## 技术支持

- **作者**：deepsea
- **联系方式**：https://t.me/deepsea159
- **框架版本**：Hyperf 3.1

## ☕ 给我一杯咖啡

如果这个项目对你有帮助，欢迎请我喝一杯咖啡！

<div align="center">
  <img src="docs/pay.jpg" alt="给我一杯咖啡" width="300" />
</div>