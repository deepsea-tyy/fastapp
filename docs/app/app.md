# Flutter 应用

> 本目录为 FastApp 项目的 Flutter 移动端应用目录

一个使用 MobX 和 Provider 创建的 Flutter 样板项目，采用分层架构设计。

## 📚 文档导航

- [项目架构说明](ARCHITECTURE.md) - 架构设计、目录结构
- [开发指南](DEVELOPMENT.md) - 快速开始、添加功能、常用操作
- [环境配置指南](SETUP.md) - 环境要求、安装步骤
- [问题排查指南](TROUBLESHOOTING.md) - 常见问题解决方案

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. 运行项目

```bash
flutter run
```

## 项目功能

- ✅ 登录/首页/路由
- ✅ 主题切换（深色/浅色）
- ✅ 多语言支持
- ✅ 网络请求（Dio）
- ✅ 本地数据库（Sembast）
- ✅ 状态管理（MobX + Provider）
- ✅ 依赖注入（GetIt）
- ✅ 数据加密（XXTEA）
- ✅ 表单验证
- ✅ 用户通知

## 技术栈

- **状态管理**：MobX、Provider
- **网络请求**：Dio
- **本地存储**：Sembast、SharedPreferences
- **依赖注入**：GetIt
- **代码生成**：build_runner、mobx_codegen
- **其他**：XXTEA 加密、Validators 验证、Flushbar 通知

## 项目结构

项目采用**分层架构（Clean Architecture）**设计：

```
lib/
├── presentation/    # 🎨 界面代码层（主要开发区域）
│   └── store/app/   # 全局 Store（用户、主题、语言状态）
├── domain/          # 💼 业务逻辑层（接口定义）
├── data/            # 💾 数据层（网络/本地存储实现）
├── core/            # 🔧 核心功能模块（可复用组件）
├── constants/       # 📋 应用常量
└── utils/           # 🛠️ 工具类
```

详细说明请查看 [项目架构说明](ARCHITECTURE.md)

## 总结

这是一个 Flutter 样板项目，展示了如何在 Flutter 中组织代码结构，采用分层架构和依赖注入，便于扩展和维护。
