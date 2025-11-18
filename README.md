# FastApp 项目说明

FastApp 是一个企业级全栈应用框架，包含移动端、Web端、后台管理系统和后端服务。

## 目录结构

### app
Flutter 移动端应用目录

基于 Flutter 开发的跨平台移动应用，采用 MobX + Provider 状态管理，支持 Android、iOS、Web、Windows、macOS、Linux 等多平台。

详细文档请查看：[app/README.md](app/README.md)

### appweb
Web 端应用目录

Web 端应用（当前目录为空）

### web
后台管理系统目录

基于 Vue3 + TypeScript + Element Plus 构建的企业级后台管理系统前端应用。

详细文档请查看：[web/README.md](web/README.md)

### server
后端服务目录

基于 Hyperf 3.1 + Swoole 构建的高性能后端服务，提供 API 接口、WebSocket 服务、权限管理、代码生成等功能。

详细文档请查看：[server/README.md](server/README.md)

### website
官网目录

项目官网（当前目录为空）

## 技术栈概览

- **移动端**: Flutter + Dart + MobX + Provider
- **后台管理**: Vue3 + TypeScript + Element Plus + Pinia
- **后端服务**: Hyperf 3.1 + Swoole + PHP 8.1+
- **数据库**: MySQL + Redis

## 快速开始

### 后端服务

```bash
cd server
composer install
cp .env.example .env
php bin/hyperf.php start
```

### 后台管理系统

```bash
cd web
pnpm install
pnpm dev
```

### 移动端应用

```bash
cd app
flutter pub get
flutter run
```

## 项目特点

- 🚀 **高性能**: 基于 Swoole 协程，支持高并发
- 🔐 **权限管理**: 完整的 RBAC 权限系统
- 🤖 **AI 辅助**: AI 模板开发，智能代码生成
- 📱 **跨平台**: Flutter 支持多平台部署
- 🎨 **现代化 UI**: Vue3 + Element Plus 构建美观的管理界面
- 🔌 **插件系统**: 灵活的插件扩展机制

## 相关文档

- [后端服务文档](server/README.md)
- [后台管理系统文档](web/README.md)
- [移动端应用文档](app/README.md)

## 技术支持

- **作者**：deepsea
- **联系方式**：https://t.me/deepsea159
- **框架版本**：Hyperf 3.1

## ☕ 给我一杯咖啡

如果这个项目对你有帮助，欢迎请我喝一杯咖啡！

<div align="center">
  <img src="server/docs/assets/wechat_qr.png" alt="微信收款码" width="300" />
</div>

