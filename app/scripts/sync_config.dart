import 'dart:io';
import 'dart:convert';

/// 配置同步脚本
/// 从 app_config.json 读取配置并同步到各个平台配置文件
/// 
/// 使用方法: dart run scripts/sync_config.dart

void main() async {
  final config = await _loadConfig();

  await Future.wait([
    syncAppConfig(config),
    syncAndroidManifest(config['android'] as Map<String, dynamic>),
    syncAndroidBuildGradle(config['android'] as Map<String, dynamic>),
    syncAndroidStyles(config),
    syncAndroidLaunchBackgroundXml(),
    syncMacosBundleId(config['ios'] as Map<String, dynamic>),
    syncInfoPlist(config['ios'] as Map<String, dynamic>),
    syncWebIndexHtml(config['web'] as Map<String, dynamic>),
    syncWebManifest(config),
    syncLaunchScreenAndIcons(),
  ]);

  print('✅ 配置同步完成！');
}

Future<Map<String, dynamic>> _loadConfig() async {
  final file = File('app_config.json');
  if (!await file.exists()) {
    print('❌ 错误: 找不到 app_config.json 文件');
    exit(1);
  }
  return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
}

T? _get<T>(Map<String, dynamic> config, List<String> path, [T? defaultValue]) {
  dynamic value = config;
  for (final key in path) {
    if (value is Map) {
      value = (value as Map)[key];
      if (value == null) return defaultValue;
    } else {
      return defaultValue;
    }
  }
  return value is T ? value : defaultValue;
}

Map<String, dynamic> _getMap(Map<String, dynamic> config, List<String> path, [Map<String, dynamic>? defaultValue]) {
  final value = _get<dynamic>(config, path, defaultValue);
  if (value is Map) {
    return Map<String, dynamic>.from(value.cast<String, dynamic>());
  }
  return defaultValue ?? <String, dynamic>{};
}

Future<void> _updateFile(String path, String Function(String) updater) async {
  final file = File(path);
  if (!await file.exists()) {
    print('⚠️  警告: 找不到 $path');
    return;
  }
  await file.writeAsString(updater(await file.readAsString()));
  print('✅ 已更新 $path');
}

Future<void> _ensureFile(String filePath, String content) async {
  final file = File(filePath);
  await file.parent.create(recursive: true);
  if (!await file.exists() || await file.readAsString() != content) {
    await file.writeAsString(content);
  }
}

Future<void> syncAppConfig(Map<String, dynamic> config) async {
  final app = _getMap(config, ['app']);
  final android = _getMap(config, ['android']);
  final ios = _getMap(config, ['ios']);
  final network = _getMap(config, ['network']);
  final theme = _getMap(config, ['theme']);
  final themeLight = _getMap(config, ['theme', 'light']);
  final themeDark = _getMap(config, ['theme', 'dark']);
  final resources = _getMap(config, ['resources']);
  final ui = _getMap(config, ['ui']);
  final assets = _getMap(config, ['assets']);
  final fonts = _getMap(config, ['fonts']);
  final splash = _getMap(config, ['splash']);
  final splashAndroid = _getMap(splash, ['android']);
  final splashIos = _getMap(splash, ['ios']);
  final splashWeb = _getMap(splash, ['web']);
  final endpoints = _getMap(network, ['endpoints']);

  final replacements = {
    r"static const String appName = '[^']*';": "static const String appName = '${app['name'] ?? 'fastapp'}';",
    r"static const String appVersion = '[^']*';": "static const String appVersion = '${app['version'] ?? '1.0.0'}';",
    r"static const int buildNumber = \d+;": "static const int buildNumber = ${app['buildNumber'] ?? 1};",
    r"static const String appDescription = '[^']*';": "static const String appDescription = '${app['description'] ?? 'A flutter boilerplate project'}';",
    r"static const String apiBaseUrl = '[^']*';": "static const String apiBaseUrl = '${network['apiBaseUrl'] ?? 'http://jsonplaceholder.typicode.com'}';",
    r"static const String wsBaseUrl = '[^']*';": "static const String wsBaseUrl = '${network['wsBaseUrl'] ?? 'ws://127.0.0.1:9502/ws'}';",
    r"static const int connectionTimeout = \d+;": "static const int connectionTimeout = ${network['connectionTimeout'] ?? 5000};",
    r"static const int receiveTimeout = \d+;": "static const int receiveTimeout = ${network['receiveTimeout'] ?? 5000};",
    r"static const int sendTimeout = \d+;": "static const int sendTimeout = ${network['sendTimeout'] ?? 5000};",
    r"static const String marketTicker = '[^']*';": "static const String marketTicker = '${_getMap(endpoints, ['market'])['ticker'] ?? '/api/v1/market/ticker'}';",
    r"static const String marketKline = '[^']*';": "static const String marketKline = '${_getMap(endpoints, ['market'])['kline'] ?? '/api/v1/market/kline'}';",
    r"static const String marketDepth = '[^']*';": "static const String marketDepth = '${_getMap(endpoints, ['market'])['depth'] ?? '/api/v1/market/depth'}';",
    r"static const String tradePlaceOrder = '[^']*';": "static const String tradePlaceOrder = '${_getMap(endpoints, ['trade'])['placeOrder'] ?? '/api/v1/trade/order'}';",
    r"static const String tradeCancelOrder = '[^']*';": "static const String tradeCancelOrder = '${_getMap(endpoints, ['trade'])['cancelOrder'] ?? '/api/v1/trade/order/cancel'}';",
    r"static const String orderList = '[^']*';": "static const String orderList = '${_getMap(endpoints, ['order'])['list'] ?? '/api/v1/order/list'}';",
    r"static const String orderDetail = '[^']*';": "static const String orderDetail = '${_getMap(endpoints, ['order'])['detail'] ?? '/api/v1/order/detail'}';",
    r"static const String walletBalance = '[^']*';": "static const String walletBalance = '${_getMap(endpoints, ['wallet'])['balance'] ?? '/api/v1/wallet/balance'}';",
    r"static const String walletTransactions = '[^']*';": "static const String walletTransactions = '${_getMap(endpoints, ['wallet'])['transactions'] ?? '/api/v1/wallet/transactions'}';",
    r"static const String futuresPosition = '[^']*';": "static const String futuresPosition = '${_getMap(endpoints, ['futures'])['position'] ?? '/api/v1/futures/position'}';",
    r"static const String futuresLeverage = '[^']*';": "static const String futuresLeverage = '${_getMap(endpoints, ['futures'])['leverage'] ?? '/api/v1/futures/leverage'}';",
    r"static const String futuresFundingRate = '[^']*';": "static const String futuresFundingRate = '${_getMap(endpoints, ['futures'])['fundingRate'] ?? '/api/v1/futures/funding-rate'}';",
    r"static const String seedColorLight = '[^']*';": "static const String seedColorLight = '${themeLight['seedColor'] ?? '#2196F3'}';",
    r"static const String seedColorDark = '[^']*';": "static const String seedColorDark = '${themeDark['seedColor'] ?? '#2196F3'}';",
    r"static const String scaffoldBackgroundColorLight = '[^']*';": "static const String scaffoldBackgroundColorLight = '${themeLight['scaffoldBackgroundColor'] ?? '#FFFFFF'}';",
    r"static const String scaffoldBackgroundColorDark = '[^']*';": "static const String scaffoldBackgroundColorDark = '${themeDark['scaffoldBackgroundColor'] ?? ''}';",
    r"static const String buttonBackgroundColorLight = '[^']*';": "static const String buttonBackgroundColorLight = '${themeLight['buttonBackgroundColor'] ?? '#424242'}';",
    r"static const String buttonBackgroundColorDark = '[^']*';": "static const String buttonBackgroundColorDark = '${themeDark['buttonBackgroundColor'] ?? '#757575'}';",
    r"static const String buttonForegroundColorLight = '[^']*';": "static const String buttonForegroundColorLight = '${themeLight['buttonForegroundColor'] ?? '#FFFFFF'}';",
    r"static const String buttonForegroundColorDark = '[^']*';": "static const String buttonForegroundColorDark = '${themeDark['buttonForegroundColor'] ?? '#FFFFFF'}';",
    r"static const String buttonDisabledBackgroundColorLight = '[^']*';": "static const String buttonDisabledBackgroundColorLight = '${themeLight['buttonDisabledBackgroundColor'] ?? '#BDBDBD'}';",
    r"static const String buttonDisabledBackgroundColorDark = '[^']*';": "static const String buttonDisabledBackgroundColorDark = '${themeDark['buttonDisabledBackgroundColor'] ?? '#616161'}';",
    r"static const String buttonDisabledForegroundColorLight = '[^']*';": "static const String buttonDisabledForegroundColorLight = '${themeLight['buttonDisabledForegroundColor'] ?? '#B3FFFFFF'}';",
    r"static const String buttonDisabledForegroundColorDark = '[^']*';": "static const String buttonDisabledForegroundColorDark = '${themeDark['buttonDisabledForegroundColor'] ?? '#B3FFFFFF'}';",
    r"static const String imageCdnBaseUrl = '[^']*';": "static const String imageCdnBaseUrl = '${resources['imageCdnBaseUrl'] ?? ''}';",
    r"static const double defaultHorizontalPadding = [\d.]+;": "static const double defaultHorizontalPadding = ${ui['defaultHorizontalPadding'] ?? 12.0};",
    r"static const double defaultVerticalPadding = [\d.]+;": "static const double defaultVerticalPadding = ${ui['defaultVerticalPadding'] ?? 12.0};",
    r"static const double defaultBorderRadius = [\d.]+;": "static const double defaultBorderRadius = ${ui['defaultBorderRadius'] ?? 8.0};",
    r"static const String appLogo = '[^']*';": "static const String appLogo = '${_get<String>(config, ['assets', 'appLogo', 'android']) ?? _get<String>(config, ['assets', 'appLogo', 'ios']) ?? 'assets/icons/ic_appicon.png'}';",
    r"static const String carBackground = '[^']*';": "static const String carBackground = '${assets['carBackground'] ?? 'assets/images/img_login.jpg'}';",
    r"static const String productSans = '[^']*';": "static const String productSans = '${fonts['productSans'] ?? 'ProductSans'}';",
    r"static const String roboto = '[^']*';": "static const String roboto = '${fonts['roboto'] ?? 'Roboto'}';",
    r"static const String androidPackageName = '[^']*';": "static const String androidPackageName = '${android['packageName'] ?? 'com.iotecksolutions.todoapp'}';",
    r"static const String iosBundleId = '[^']*';": "static const String iosBundleId = '${ios['bundleId'] ?? 'com.iotecksolutions.todoapp'}';",
    r"static const String splashImage = '[^']*';": "static const String splashImage = '${_get<String>(config, ['splash', 'android', 'image']) ?? _get<String>(config, ['splash', 'ios', 'image']) ?? _get<String>(config, ['splash', 'web', 'image']) ?? 'assets/images/launch/light-background.png'}';",
    r"static const String splashBackgroundColorAndroid = '[^']*';": "static const String splashBackgroundColorAndroid = '${splashAndroid['backgroundColor'] ?? '#ffffff'}';",
    r"static const String splashBackgroundColorIos = '[^']*';": "static const String splashBackgroundColorIos = '${splashIos['backgroundColor'] ?? '#ffffff'}';",
    r"static const String splashBackgroundColorWeb = '[^']*';": "static const String splashBackgroundColorWeb = '${splashWeb['backgroundColor'] ?? '#ffffff'}';",
    r"static const String splashWebBackgroundSize = '[^']*';": "static const String splashWebBackgroundSize = '${splashWeb['backgroundSize'] ?? 'cover'}';",
    r"static const int splashWebFadeOutTime = \d+;": "static const int splashWebFadeOutTime = ${splashWeb['fadeOutTime'] ?? 400};",
    r"static const int splashWebHideDelay = \d+;": "static const int splashWebHideDelay = ${splashWeb['hideDelay'] ?? 500};",
  };

  await _updateFile('lib/constants/app_config.dart', (content) {
    replacements.forEach((pattern, replacement) {
      content = content.replaceAll(RegExp(pattern), replacement);
    });
    return content;
  });
}

Future<void> syncAndroidManifest(Map<String, dynamic> config) async {
  final android = _getMap(config, ['android']);
  await _updateFile('android/app/src/main/AndroidManifest.xml', (content) {
    return content
        .replaceAll(RegExp(r'android:label="[^"]*"'), 'android:label="${android['label'] ?? 'fastapp'}"')
        .replaceAll(RegExp(r'package="[^"]*"'), 'package="${android['packageName'] ?? 'com.iotecksolutions.todoapp'}"');
  });
}

Future<void> syncAndroidBuildGradle(Map<String, dynamic> config) async {
  final android = _getMap(config, ['android']);
  final packageName = android['packageName'] as String? ?? 'com.iotecksolutions.todoapp';
  await _updateFile('android/app/build.gradle', (content) {
    return content
        .replaceAll(RegExp(r'namespace\s+"[^"]*"'), 'namespace "$packageName"')
        .replaceAll(RegExp(r'applicationId\s+"[^"]*"'), 'applicationId "$packageName"');
  });
}

Future<void> syncMacosBundleId(Map<String, dynamic> config) async {
  final ios = _getMap(config, ['ios']);
  final bundleId = ios['bundleId'] as String? ?? 'com.iotecksolutions.todoapp';
  await _updateFile('macos/Runner/Configs/AppInfo.xcconfig', (content) {
    return content.replaceAll(RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^\n]*'), 'PRODUCT_BUNDLE_IDENTIFIER = $bundleId');
  });
}

Future<void> syncInfoPlist(Map<String, dynamic> config) async {
  final ios = _getMap(config, ['ios']);
  await _updateFile('ios/Runner/Info.plist', (content) {
    return content
        .replaceAll(RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'), '<key>CFBundleDisplayName</key>\n\t<string>${ios['displayName'] ?? 'fastapp'}</string>')
        .replaceAll(RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'), '<key>CFBundleName</key>\n\t<string>${ios['bundleName'] ?? 'fastapp'}</string>');
  });
}

Future<void> syncWebIndexHtml(Map<String, dynamic> config) async {
  final web = _getMap(config, ['web']);
  await _updateFile('web/index.html', (content) {
    final title = web['title'] as String? ?? 'fastapp';
    final themeColor = web['themeColor'] as String? ?? '#0175C2';
    content = content
        .replaceAll(RegExp(r'<title>[^<]*</title>'), '<title>$title</title>')
        .replaceAll(RegExp(r'<meta name="apple-mobile-web-app-title" content="[^"]*">'), '<meta name="apple-mobile-web-app-title" content="$title">')
        .replaceAll(RegExp(r'<meta name="theme-color" content="[^"]*">'), '<meta name="theme-color" content="$themeColor">');
    
    // 读取 web icon
    final icon = _get<String>(config, ['web', 'icon']);
    if (icon != null) {
      content = content
          .replaceAll(RegExp(r'<link rel="apple-touch-icon" href="[^"]*"'), '<link rel="apple-touch-icon" href="$icon"')
          .replaceAll(RegExp(r'<link rel="icon" type="image/png" href="[^"]*"'), '<link rel="icon" type="image/png" href="$icon"');
    }
    return content;
  });
}

Future<void> syncWebManifest(Map<String, dynamic> config) async {
  final file = File('web/manifest.json');
  if (!await file.exists()) {
    print('⚠️  警告: 找不到 web/manifest.json');
    return;
  }

  final manifest = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final web = _getMap(config, ['web']);
  final app = _getMap(config, ['app']);
  
  manifest['name'] = web['title'] ?? 'fastapp';
  manifest['short_name'] = web['shortName'] ?? 'fastapp';
  manifest['description'] = app['description'] ?? 'A flutter boilerplate project';
  manifest['theme_color'] = web['themeColor'] ?? '#0175C2';
  manifest['background_color'] = web['backgroundColor'] ?? '#0175C2';
  
  // 读取 web icon
  final icon = _get<String>(config, ['web', 'icon']);
  if (icon != null && manifest['icons'] is List) {
    for (final iconMap in (manifest['icons'] as List).whereType<Map<String, dynamic>>()) {
      iconMap['src'] = icon;
    }
  }

  await file.writeAsString(const JsonEncoder.withIndent('    ').convert(manifest));
  print('✅ 已更新 web/manifest.json');
}

Future<void> syncAndroidStyles(Map<String, dynamic> config) async {
  final android = _getMap(config, ['android']);
  final styles = _getMap(android, ['styles']);
  final normalThemeBackground = styles['normalThemeBackground'] as String? ?? '@drawable/ic_launcher';
  final launchThemeBackground = styles['launchThemeBackground'] as String? ?? '@drawable/launch_background';
  final nightNormalThemeBackground = styles['nightNormalThemeBackground'] as String? ?? '?android:colorBackground';
  
  await _syncAndroidStylesXml('android/app/src/main/res/values/styles.xml', normalThemeBackground, launchThemeBackground);
  await _syncAndroidStylesXml('android/app/src/main/res/values-night/styles.xml', nightNormalThemeBackground, launchThemeBackground);
  // Android 12+ (API 31+) 特殊配置，使用空图标避免显示应用logo
  await _syncAndroidV31StylesXml('android/app/src/main/res/values-v31/styles.xml', launchThemeBackground);
}

Future<void> _syncAndroidStylesXml(String xmlPath, String normalThemeBackground, String launchThemeBackground) async {
  // 使用黑色主题，适配全屏背景图片
  final xmlContent = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- LaunchTheme: 启动时显示的主题，使用全屏背景图片 -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             Flutter draws its first frame -->
        <item name="android:windowBackground">$launchThemeBackground</item>
    </style>
    <!-- NormalTheme: Flutter 渲染后使用的主题 -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">$normalThemeBackground</item>
    </style>
</resources>
''';
  await _ensureFile(xmlPath, xmlContent);
}

Future<void> _syncAndroidV31StylesXml(String xmlPath, String launchThemeBackground) async {
  // Android 12+ SplashScreen API 配置
  // 使用黑色主题，适配全屏背景图片
  // 不设置 windowSplashScreenBackground，让系统使用默认背景色
  // 使用启动图作为图标，在图标区域显示启动图
  final xmlContent = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- windowBackground 在 Android 12+ 仍然有效，支持 drawable，用于显示全屏启动图片 -->
        <item name="android:windowBackground">$launchThemeBackground</item>
        <!-- 图标区域显示启动图 -->
        <!-- windowSplashScreenAnimatedIcon 使用启动图，在图标区域显示 -->
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/launch_background_image</item>
        <!-- 图标背景色设置为透明 -->
        <item name="android:windowSplashScreenIconBackgroundColor">@android:color/transparent</item>
    </style>
</resources>
''';
  await _ensureFile(xmlPath, xmlContent);
}

Future<void> syncAndroidLaunchBackgroundXml() async {
  const xmlContent = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 启动图片层 - 使用 fill 填充整个屏幕 -->
    <item>
        <bitmap
            android:gravity="fill"
            android:src="@drawable/launch_background_image" />
    </item>
</layer-list>
''';
  await _ensureFile('android/app/src/main/res/drawable/launch_background.xml', xmlContent);
  await _ensureFile('android/app/src/main/res/drawable-v21/launch_background.xml', xmlContent);
  
  // 删除旧的 empty_icon.xml，因为 Android 12+ 需要使用 PNG 图标
  // empty_icon.png 由 manage_launch_screen.dart 创建
  final emptyIconXml = File('android/app/src/main/res/drawable/empty_icon.xml');
  if (await emptyIconXml.exists()) {
    await emptyIconXml.delete();
    print('✅ 已删除 empty_icon.xml（使用 empty_icon.png 替代）');
  }
}

Future<void> syncLaunchScreenAndIcons() async {
  print('🎨 同步启动图和图标...');
  final result = await Process.run('dart', ['run', 'scripts/launch_screen.dart', 'all'], runInShell: true);
  if (result.exitCode != 0) {
    print('   ⚠️  同步启动图和图标失败: ${result.stderr}');
  }
}
