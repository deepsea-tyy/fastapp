# 问题排查指南

## 代码相关问题

### 代码生成失败

**问题**：运行 `build_runner` 时出错

**解决方案**：

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

### 依赖冲突

**问题**：`flutter pub get` 时出现版本冲突

**解决方案**：

1. 检查 `pubspec.yaml` 中的依赖版本
2. 运行 `flutter pub upgrade` 更新依赖
3. 如果仍有冲突，手动调整版本号

### Store 代码未生成

**问题**：修改 Store 后，`.g.dart` 文件未更新

**解决方案**：

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

### 依赖注入错误

**问题**：运行时出现 `GetIt` 未注册错误

**解决方案**：

1. 检查 `main.dart` 中是否调用了 `ServiceLocator.configureDependencies()`
2. 检查依赖注册顺序（Data → Domain → Presentation）
3. 确保所有依赖都已注册

### 网络请求失败

**问题**：API 请求返回错误

**检查点**：
- 检查 `data/network/constants/endpoints.dart` 中的 API 地址
- 检查拦截器配置（认证、错误处理）
- 查看日志输出（LoggingInterceptor）

### 路由跳转失败

**问题**：使用路由名称跳转时找不到路由

**解决方案**：

1. 检查 `utils/routes/routes.dart` 中是否注册了路由
2. 检查路由名称是否正确
3. 确保在 `app.dart` 中配置了路由

## 构建问题

### Android 构建失败

**问题**：Gradle 构建错误

**解决方案**：

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

### iOS 构建失败

**问题**：CocoaPods 相关错误

**解决方案**：

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

## 性能问题

### 应用启动慢

**检查点**：
- 检查 `main.dart` 中的初始化逻辑
- 优化依赖注入的注册顺序
- 延迟加载非关键资源

### UI 卡顿

**检查点**：
- 检查是否有大量计算在 UI 线程
- 使用 `Observer` 包裹需要响应式更新的 Widget
- 避免在 `build` 方法中执行耗时操作

## 调试技巧

### 查看日志

```dart
// 在代码中添加日志
print('Debug: $variable');

// 或使用 debugPrint（推荐）
debugPrint('Debug: $variable');
```

### 使用 Flutter DevTools

```bash
# 启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 热重载

- 按 `r` 键进行热重载
- 按 `R` 键进行热重启
- 按 `q` 键退出
