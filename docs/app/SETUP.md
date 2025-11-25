# 环境配置指南

## 系统要求

- **macOS**：macOS 10.14 或更高版本
- **Windows**：Windows 10 或更高版本
- **Linux**：Ubuntu 18.04 或更高版本

## 版本要求

- **Dart SDK**：`>=3.0.6 <4.0.0`
- **Flutter SDK**：建议使用 Flutter 3.0.6 或更高版本

## 安装步骤

### 1. 安装 Flutter SDK

- 访问 [Flutter 官网](https://flutter.dev/docs/get-started/install) 下载最新稳定版本
- 或使用包管理器：
  ```bash
  # macOS
  brew install --cask flutter
  
  # Linux
  snap install flutter --classic
  ```

### 2. 配置环境变量

将 Flutter 的 `bin` 目录添加到 PATH：

```bash
# macOS/Linux
export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"

# Windows
# 在系统环境变量中添加 Flutter\bin 目录
```

### 3. 安装开发工具

- **Android Studio**：用于 Android 开发
- **Xcode**（仅 macOS）：用于 iOS 开发
- **VS Code**：推荐安装 Flutter 和 Dart 插件

### 4. 检查环境

```bash
flutter doctor
flutter --version
```

## 项目设置

### 1. 克隆项目

```bash
git clone <repository-url>
cd flutter_boilerplate_project
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 生成代码

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. 运行项目

```bash
flutter run
```

## 平台特定配置

### Android

1. 打开 Android Studio
2. 安装 Android SDK（API 36 或更高）
3. 安装 Android SDK Build-Tools
4. 接受许可证：
   ```bash
   flutter doctor --android-licenses
   ```

### iOS (macOS)

1. 安装 Xcode
2. 安装 CocoaPods：
   ```bash
   sudo gem install cocoapods
   ```
3. 安装依赖：
   ```bash
   cd ios
   pod install
   cd ..
   ```
