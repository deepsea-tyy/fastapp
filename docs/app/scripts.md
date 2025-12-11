# 脚本使用指南

> FastApp 项目脚本工具说明文档

## 快速参考

| 脚本 | 功能 | 命令 |
|------|------|------|
| `clean.sh` | 彻底清理项目缓存 | `./scripts/clean.sh` |
| `dev.sh` | 快速运行应用 | `./scripts/dev.sh [参数]` |
| `dev_rebuild_ios.sh` | 重建 iOS 项目 | `./scripts/dev_rebuild_ios.sh` |
| `launch_screen.dart` | 管理图标和启动图 | `dart run scripts/launch_screen.dart [命令]` |
| `sync_config.dart` | 同步配置到各平台 | `dart run scripts/sync_config.dart` |

---

## 脚本详情

### 1. `clean.sh` - 彻底清理缓存

彻底清理 Flutter 项目的所有构建缓存和残留文件，解决编译卡顿、依赖残留等问题。

```bash
cd app
./scripts/clean.sh
```

**清理内容**：

1. **Flutter 标准清理**：执行 `flutter clean`
2. **删除编译缓存**：删除 `.dart_tool` 目录（包含 `flutter_build` 编译缓存）
3. **删除构建产物**：删除 `build` 目录
4. **清理插件配置**：删除 `.flutter-plugins` 和 `.flutter-plugins-dependencies`
5. **平台特定清理**：
   - **Android**：清理 Gradle 缓存、`app/build`、`.gradle`
   - **iOS**：清理 Pods、Podfile.lock、DerivedData、ephemeral 文件
   - **macOS**：清理 Pods、ephemeral 文件
   - **Linux/Windows/Web**：清理 ephemeral 文件
6. **重新获取依赖**：执行 `flutter pub get`

**适用场景**：
- 编译卡顿或异常
- 卸载包后仍有残留引用
- 依赖冲突无法解决
- 构建缓存损坏
- 切换分支后构建异常

**注意事项**：
- 清理后首次编译会较慢（需要重新生成缓存）
- 如需清理全局 pub 缓存，可运行 `flutter pub cache repair`
- IDE 缓存需要手动清理或重启 IDE

---

### 2. `dev.sh` - 快速开发运行

快速运行 Flutter 应用，跳过自动 pub get 检查。

```bash
cd app
./scripts/dev.sh              # 默认运行
./scripts/dev.sh --release    # 发布模式
./scripts/dev.sh -d ios       # 指定设备
```

**工作原理**：检查依赖是否存在，首次运行自动获取，使用 `--no-pub` 跳过检查。

---

### 3. `dev_rebuild_ios.sh` - iOS 重建

完整清理并重新构建 iOS 项目，解决构建问题和依赖冲突。

```bash
cd app
./scripts/dev_rebuild_ios.sh
```

**执行步骤**：
1. 清理 Flutter 和 iOS 构建缓存
2. 删除 Pods、Podfile.lock 等 iOS 依赖文件
3. 重新获取 Flutter 依赖
4. 重新安装 CocoaPods 依赖

**适用场景**：首次设置、构建错误、依赖冲突、升级 SDK 后

**注意**：如遇 "Null check operator" 错误（Flutter 3.38.3 已知问题），可使用 Xcode 直接构建或 `flutter run -d <device_id>`

---

### 4. `launch_screen.dart` - 资源管理

统一管理 iOS、Android 和 Web 平台的应用图标和启动图。

```bash
cd app
dart run scripts/launch_screen.dart        # 生成图标并同步启动图（默认）
dart run scripts/launch_screen.dart icons  # 仅生成图标
dart run scripts/launch_screen.dart launch  # 仅同步启动图
```

**功能说明**：

- **生成图标**：
  - Android：生成多尺寸图标（mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi）
  - iOS：根据 `Contents.json` 生成所有尺寸图标
  - 源文件：`app_config.json` → `assets.appLogo.android/ios` 或默认 `assets/images/launch/logo.png`

- **同步启动图**：
  - Android：复制启动图，创建透明图标（Android 12+）
  - iOS：生成多尺寸启动图，同步 `LaunchScreen.storyboard` 背景色
  - Web：更新 `index.html` 中的启动图配置
  - 源文件：`app_config.json` → `splash.android/ios/web.image` 或默认 `assets/images/launch/light-background.png`

**配置示例**（`app_config.json`）：
```json
{
  "assets": {
    "appLogo": {
      "android": "assets/images/launch/logo.png",
      "ios": "assets/images/launch/logo.png"
    }
  },
  "splash": {
    "android": { "image": "...", "backgroundColor": "#ffffff" },
    "ios": { "image": "...", "backgroundColor": "#ffffff" },
    "web": { "image": "...", "backgroundColor": "#ffffff", "backgroundSize": "cover" }
  }
}
```

---

### 5. `sync_config.dart` - 配置同步

从 `app_config.json` 读取配置并同步到各平台配置文件。

```bash
cd app
dart run scripts/sync_config.dart
```

**同步内容**：

- **应用配置**（`lib/constants/app_config.dart`）：应用信息、网络配置、主题、资源、平台信息
- **Android**：`AndroidManifest.xml`、`build.gradle`、`styles.xml`、`launch_background.xml`
- **iOS**：`Info.plist`、`AppInfo.xcconfig`（macOS）
- **Web**：`index.html`、`manifest.json`
- **资源**：自动调用 `launch_screen.dart` 同步图标和启动图

**配置结构**（`app_config.json`）：
```json
{
  "app": { "name": "...", "version": "...", "buildNumber": 1 },
  "android": { "packageName": "...", "label": "..." },
  "ios": { "bundleId": "...", "displayName": "...", "bundleName": "..." },
  "web": { "title": "...", "themeColor": "...", "icon": "..." },
  "network": { "apiBaseUrl": "...", "wsBaseUrl": "...", "endpoints": {...} },
  "theme": { "light": { "seedColor": "..." }, "dark": { "seedColor": "..." } },
  "resources": { "imageCdnBaseUrl": "..." },
  "ui": { "defaultHorizontalPadding": 12.0, "defaultVerticalPadding": 12.0 },
  "assets": { "appLogo": { "android": "...", "ios": "..." } },
  "splash": { "android": {...}, "ios": {...}, "web": {...} }
}
```

**注意**：脚本会修改多个配置文件，提交前请检查更改。未设置的配置项将使用默认值。

---

## 常用工作流程

### 日常开发
```bash
./scripts/dev.sh                    # 快速启动
# 修改配置后
dart run scripts/sync_config.dart   # 同步配置
```

### 更换图标/启动图
```bash
# 1. 准备资源文件，更新 app_config.json
# 2. 同步配置和资源
dart run scripts/sync_config.dart
# 或仅同步资源
dart run scripts/launch_screen.dart all
```

### 编译卡顿或依赖问题
```bash
./scripts/clean.sh            # 彻底清理缓存
```

### iOS 构建问题
```bash
./scripts/dev_rebuild_ios.sh  # 完整重建
```

### 项目初始化
```bash
# 1. 配置 app_config.json
# 2. 同步配置
dart run scripts/sync_config.dart
# 3. 获取依赖并运行
flutter pub get
./scripts/dev.sh
```

---

## 相关文档

- [开发指南.md](开发指南.md) - 项目开发指南
- [全局配置.md](全局配置.md) - 应用配置管理说明
- [Xcode使用指南.md](Xcode使用指南.md) - iOS 开发指南
