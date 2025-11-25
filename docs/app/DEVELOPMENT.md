# 开发指南

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

```bash
# 生成代码文件
flutter packages pub run build_runner build --delete-conflicting-outputs

# 或使用 watch 模式（自动同步）
flutter packages pub run build_runner watch
```

### 3. 运行项目

```bash
# 查看可用设备
flutter devices

# 运行在连接的设备上
flutter run

# 运行在特定平台
flutter run -d android    # Android
flutter run -d ios        # iOS (macOS)
flutter run -d chrome     # Web
flutter run -d macos      # macOS
```

### 4. 构建应用

```bash
flutter build apk         # Android APK
flutter build appbundle   # Android App Bundle
flutter build ios         # iOS (macOS)
flutter build web         # Web
```

## 添加新功能

### 1. 添加新界面

**步骤**：

1. 在 `presentation/views/` 下创建新目录：
   ```
   lib/presentation/views/new_feature/
   ├── new_feature.dart        # UI 界面
   └── store/
       └── new_feature_store.dart  # 状态管理
   ```

2. 创建 UI 文件（参考 `login.dart`）：
   ```dart
   class NewFeatureScreen extends StatefulWidget {
     @override
     _NewFeatureScreenState createState() => _NewFeatureScreenState();
   }
   ```

3. 创建 Store（使用 MobX）：
   ```dart
   import 'package:mobx/mobx.dart';
   
   part 'new_feature_store.g.dart';
   
   class NewFeatureStore = _NewFeatureStore with _$NewFeatureStore;
   
   abstract class _NewFeatureStore with Store {
     @observable
     bool isLoading = false;
     
     @action
     void loadData() {
       isLoading = true;
       // 业务逻辑
       isLoading = false;
     }
   }
   ```

4. 注册路由（在 `utils/routes/routes.dart`）：
   ```dart
   static const String newFeature = '/new-feature';
   
   static final routes = <String, WidgetBuilder>{
     newFeature: (context) => NewFeatureScreen(),
   };
   ```

5. 注册 Store（在 `presentation/di/module/store_module.dart`）：
   ```dart
   getIt.registerSingleton<NewFeatureStore>(
     NewFeatureStore(
       // 依赖注入
     ),
   );
   ```

6. 生成代码：
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

### 2. 添加新业务功能

**完整示例：添加"设置"功能**

#### 步骤 1：创建实体（`domain/entity/setting/setting.dart`）

```dart
class Setting {
  final String key;
  final String value;
  
  Setting({required this.key, required this.value});
}
```

#### 步骤 2：定义仓库接口（`domain/repository/setting/setting_repository.dart`）

```dart
abstract class SettingRepository {
  Future<Setting?> getSetting(String key);
  Future<void> saveSetting(Setting setting);
}
```

#### 步骤 3：实现仓库（`data/repository/setting/setting_repository_impl.dart`）

```dart
class SettingRepositoryImpl implements SettingRepository {
  final SharedPreferenceHelper _prefHelper;
  
  SettingRepositoryImpl(this._prefHelper);
  
  @override
  Future<Setting?> getSetting(String key) async {
    final value = await _prefHelper.getString(key);
    return value != null ? Setting(key: key, value: value) : null;
  }
  
  @override
  Future<void> saveSetting(Setting setting) async {
    await _prefHelper.setString(setting.key, setting.value);
  }
}
```

#### 步骤 4：创建用例（`domain/usecase/setting/get_setting_usecase.dart`）

```dart
class GetSettingUseCase {
  final SettingRepository repository;
  
  GetSettingUseCase(this.repository);
  
  Future<Setting?> call(String key) {
    return repository.getSetting(key);
  }
}
```

#### 步骤 5：注册依赖

- 在 `data/di/module/repository_module.dart` 注册 Repository
- 在 `domain/di/module/usecase_module.dart` 注册 UseCase
- 在 `presentation/di/module/store_module.dart` 注册 Store

#### 步骤 6：创建界面和 Store

参考步骤 1 的界面创建流程。

## 状态管理

### MobX Store 使用

**定义 Store**：

```dart
import 'package:mobx/mobx.dart';

part 'example_store.g.dart';

class ExampleStore = _ExampleStore with _$ExampleStore;

abstract class _ExampleStore with Store {
  // 可观察变量
  @observable
  bool isLoading = false;
  
  @observable
  String? data;
  
  // 操作
  @action
  Future<void> loadData() async {
    isLoading = true;
    try {
      // 业务逻辑
      data = await someAsyncOperation();
    } finally {
      isLoading = false;
    }
  }
  
  // 计算属性
  @computed
  String get displayText => isLoading ? '加载中...' : (data ?? '无数据');
}
```

**在 UI 中使用**：

```dart
import 'package:flutter_mobx/flutter_mobx.dart';

Observer(
  builder: (_) => Text(_store.displayText),
)
```

### Store 分类

- **全局 Store**：放在 `presentation/store/app/`，如 UserStore、ThemeStore、LanguageStore
- **功能级 Store**：放在 `presentation/store/{feature}/`，如 PostStore（`store/post/`）、BitgetHomeStore（`store/bitget/`）
- **页面级 Store**：如果只在一个页面使用，可放在页面目录下

## 网络请求

### 添加新的 API

1. **定义 API**（`data/network/apis/example/example_api.dart`）：
   ```dart
   class ExampleApi {
     final DioClient _dioClient;
     
     ExampleApi(this._dioClient);
     
     Future<ExampleData> getExample() async {
       final res = await _dioClient.dio.get('/api/example');
       return ExampleData.fromJson(res.data);
     }
   }
   ```

2. **注册 API**（`data/di/module/network_module.dart`）：
   ```dart
   getIt.registerSingleton(ExampleApi(getIt<DioClient>()));
   ```

3. **在 Repository 中使用**：
   ```dart
   class ExampleRepositoryImpl implements ExampleRepository {
     final ExampleApi _api;
     
     ExampleRepositoryImpl(this._api);
     
     @override
     Future<ExampleData> getExample() {
       return _api.getExample();
     }
   }
   ```

## 样式配置

- **主题**：`constants/app_theme.dart`
- **颜色**：`constants/colors.dart`
- **尺寸**：`constants/dimens.dart`
- **字体**：`constants/font_family.dart`

## 代码生成

```bash
# 生成所有代码
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch 模式（自动生成）
flutter packages pub run build_runner watch

# 清理后重新生成
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## IDE 配置

### 隐藏生成的文件

**Android Studio**：
`Preferences` -> `Editor` -> `File Types` -> 添加 `*.g.dart`

**VS Code**：
`Settings` -> 搜索 `Files:Exclude` -> 添加：
```
**/*.g.dart
```
