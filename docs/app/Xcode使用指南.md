# Xcode 使用指南

> 当 `flutter run` 不可用时，使用 Xcode 进行 iOS 开发的完整指南

## 快速开始

### 1. 打开项目

```bash
cd app/ios
open Runner.xcworkspace
```

⚠️ **重要**：必须打开 `.xcworkspace` 文件，不是 `.xcodeproj` 文件！

### 2. 运行应用

1. **选择设备**：顶部工具栏选择 "iPhone 15" 或其他模拟器
2. **运行**：点击运行按钮（▶️）或按 `Cmd + R`
3. **等待构建**：底部面板显示进度，看到 "Build Succeeded" 即成功

### 3. 连接热重载（重要）

**推荐方法：启动前连接**

```bash
# 1. 先运行 flutter attach（等待连接）
cd app
flutter attach

# 2. 然后在 Xcode 中启动应用（▶️）
#    应用启动后会自动连接
```

**如果连接失败**：
- 停止应用，使用上面的"启动前连接"方法（最稳定）
- 或查看 Xcode 控制台的 `Observatory listening on http://127.0.0.1:xxxxx/xxxxx/` URL
- 使用：`flutter attach --debug-url=http://127.0.0.1:53018/buM_w0CwCuQ=`（去掉末尾斜杠）

**热重载快捷键**：
- `r`：热重载（快速更新）
- `R`：热重启（完全重启）
- `q`：断开连接（应用继续运行）

## 开发工作流程

### 推荐流程

```bash
# 1. 终端中先运行 flutter attach（等待连接）
cd app
flutter attach

# 2. Xcode 中启动应用
#    - 选择设备 → 点击运行（▶️）
#    - 应用启动后会自动连接到 flutter attach

# 3. 开发循环
#    - 修改 Dart 代码（IDE 中）
#    - 保存文件
#    - 终端按 'r' 热重载
#    - 查看效果，继续开发
```

### 常用操作

| 操作 | 快捷键 | 说明 |
|------|--------|------|
| 运行 | `Cmd + R` | 编译并运行 |
| 停止 | `Cmd + .` | 停止应用 |
| 构建 | `Cmd + B` | 仅编译 |
| 清理 | `Shift + Cmd + K` | 清理构建缓存 |

## 常见场景

### 修改 Dart 代码
1. IDE 中修改并保存
2. 终端运行 `flutter attach`（如未连接）
3. 按 `r` 键热重载

### 修改原生代码（Swift/Objective-C）
1. Xcode 中修改代码
2. 在 Xcode 中重新运行（▶️）

### 添加 Flutter 依赖
```bash
# 1. 修改 pubspec.yaml
# 2. 运行
flutter pub get
# 3. Xcode 中重新运行
```

### 添加 iOS 原生依赖
```bash
# 1. 修改 ios/Podfile
# 2. 运行
cd ios && pod install
# 3. Xcode 中重新运行
```

## 常见问题

### Xcode 相关问题

**Q: "Command PhaseScriptExecution failed" 错误？**
- 运行重建脚本：`./scripts/rebuild_ios.sh`
- 或在 Xcode 中：`Product` → `Clean Build Folder`

**Q: "Update to recommended settings" 提示？**
- 点击 "Update"，Xcode 会自动更新设置（通常是安全的）

**Q: 找不到设备选择器？**
- 设备选择器在顶部工具栏，运行按钮右侧

**Q: 构建失败？**
- 查看底部面板的错误信息
- 尝试清理构建：`Product` → `Clean Build Folder` (Shift + Cmd + K)

**Q: `flutter attach` 连接失败？**

**最佳解决方案**：
1. 在 Xcode 中停止应用（⏹️）
2. 在终端运行：`cd app && flutter attach`（等待连接）
3. 在 Xcode 中重新启动应用（▶️）
4. 应用启动后会自动连接到 `flutter attach`

**为什么 `--debug-url` 方法会失败？**
- 应用重启后 URL 会变化
- URL 有时效性，过期后无法连接
- 应用状态变化会导致连接失败

**Q: 如何查看日志？**
- Xcode 底部面板显示构建日志和运行日志
- 错误用红色显示，警告用黄色显示
- Dart VM Service URL 也会显示在控制台中

### iOS 构建问题

**Q: CocoaPods 相关错误？**

```bash
# 1. 清理 Pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 2. 清理 Flutter 构建
flutter clean

# 3. 重新构建
flutter build ios
```

**Q: "No such file or directory: app_localizations.dart"？**
- 运行 `flutter gen-l10n` 生成本地化文件

### 代码相关问题

**Q: 代码生成失败？**

```bash
# 1. 清理构建缓存
flutter clean

# 2. 删除生成的文件
find . -name "*.g.dart" -delete

# 3. 重新获取依赖
flutter pub get

# 4. 重新生成代码
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Q: Store 代码未生成？**

```bash
# 强制重新生成
flutter packages pub run build_runner build --delete-conflicting-outputs

# 或使用 watch 模式
flutter packages pub run build_runner watch
```

**检查点**：
- 确保 Store 类使用了 `@observable`、`@action`、`@computed` 注解
- 确保有 `part 'xxx_store.g.dart';` 声明
- 确保类名格式正确：`class XxxStore = _XxxStore with _$XxxStore;`

**Q: 依赖冲突？**

1. 检查 `pubspec.yaml` 中的依赖版本
2. 运行 `flutter pub upgrade` 更新依赖
3. 如果仍有冲突，手动调整版本号

**Q: 依赖注入错误？**

1. 检查 `main.dart` 中是否调用了 `ServiceLocator.configureDependencies()`
2. 检查依赖注册顺序（Data → Domain → Presentation）
3. 确保所有依赖都已注册

**Q: 网络请求失败？**

**检查点**：
- 检查 `data/network/constants/endpoints.dart` 中的 API 地址
- 检查拦截器配置（认证、错误处理）
- 查看日志输出（LoggingInterceptor）

**Q: 路由跳转失败？**

1. 检查 `utils/routes/routes.dart` 中是否注册了路由
2. 检查路由名称是否正确
3. 确保在 `app.dart` 中配置了路由

### Android 构建问题

**Q: Gradle 构建错误？**

```bash
# 1. 清理构建
flutter clean

# 2. 删除 Android 构建缓存
cd android
./gradlew clean
cd ..

# 3. 重新构建
flutter build apk
```

### 性能问题

**Q: 应用启动慢？**

**检查点**：
- 检查 `main.dart` 中的初始化逻辑
- 优化依赖注入的注册顺序
- 延迟加载非关键资源

**Q: UI 卡顿？**

**检查点**：
- 检查是否有大量计算在 UI 线程
- 使用 `Observer` 包裹需要响应式更新的 Widget
- 避免在 `build` 方法中执行耗时操作

## 调试技巧

### 查看日志

**在代码中添加日志**：
```dart
// 使用 print
print('Debug: $variable');

// 或使用 debugPrint（推荐）
debugPrint('Debug: $variable');
```

**在 Xcode 中查看**：
- Xcode 底部面板显示构建日志和运行日志
- 错误用红色显示，警告用黄色显示
- Dart VM Service URL 也会显示在控制台中

### 使用 Flutter DevTools

```bash
# 启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 设置断点

- **Swift/Objective-C**：在 Xcode 中设置断点
- **Dart**：在 IDE（VS Code/Android Studio）中设置断点

### 性能分析

- 在 Xcode 中：`Product` → `Profile` (Cmd + I)
- 可以分析内存、CPU 使用等
