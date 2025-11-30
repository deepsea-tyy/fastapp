import 'dart:io';
import 'dart:convert';

/// 配置同步脚本
/// 从 app_config.json 读取配置并同步到各个平台文件
/// 使用方法: dart run scripts/sync_config.dart

void main() async {
  final config = await _loadConfig();
  if (config == null) return;

  final results = await Future.wait([
    syncAppConfig(config),
    syncAndroidManifest(config['android'] as Map<String, dynamic>),
    syncAndroidBuildGradle(config['android'] as Map<String, dynamic>),
    syncMacosBundleId(config['ios'] as Map<String, dynamic>),
    syncInfoPlist(config['ios'] as Map<String, dynamic>),
    syncWebIndexHtml(config['web'] as Map<String, dynamic>),
    syncWebManifest(config),
    syncSplashScreen(config['splash'] as Map<String, dynamic>? ?? {}),
  ]);

  if (results.every((r) => r)) {
    print('✅ 配置同步完成！');
  }
}

Future<Map<String, dynamic>?> _loadConfig() async {
  final file = File('app_config.json');
  if (!await file.exists()) {
    print('❌ 错误: 找不到 app_config.json 文件');
    exit(1);
  }
  return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
}

Future<bool> _updateFile(String path, String Function(String) updater) async {
  final file = File(path);
  if (!await file.exists()) {
    print('⚠️  警告: 找不到 $path');
    return false;
  }
  await file.writeAsString(updater(await file.readAsString()));
  print('✅ 已更新 $path');
  return true;
}

Future<bool> syncAppConfig(Map<String, dynamic> config) async {
  final app = config['app'] as Map<String, dynamic>;
  final android = config['android'] as Map<String, dynamic>? ?? {};
  final ios = config['ios'] as Map<String, dynamic>? ?? {};
  final network = config['network'] as Map<String, dynamic>? ?? {};
  final theme = config['theme'] as Map<String, dynamic>? ?? {};
  final resources = config['resources'] as Map<String, dynamic>? ?? {};
  final ui = config['ui'] as Map<String, dynamic>? ?? {};
  final assets = config['assets'] as Map<String, dynamic>? ?? {};
  final fonts = config['fonts'] as Map<String, dynamic>? ?? {};
  final splash = config['splash'] as Map<String, dynamic>? ?? {};
  final splashWeb = splash['web'] as Map<String, dynamic>? ?? {};

  final endpoints = network['endpoints'] as Map<String, dynamic>? ?? {};
  final marketEndpoints = endpoints['market'] as Map<String, dynamic>? ?? {};
  final tradeEndpoints = endpoints['trade'] as Map<String, dynamic>? ?? {};
  final orderEndpoints = endpoints['order'] as Map<String, dynamic>? ?? {};
  final walletEndpoints = endpoints['wallet'] as Map<String, dynamic>? ?? {};
  final futuresEndpoints = endpoints['futures'] as Map<String, dynamic>? ?? {};

  final replacements = {
    r"static const String appName = '[^']*';": "static const String appName = '${app['name']}';",
    r"static const String appVersion = '[^']*';": "static const String appVersion = '${app['version']}';",
    r"static const int buildNumber = \d+;": "static const int buildNumber = ${app['buildNumber']};",
    r"static const String appDescription = '[^']*';": "static const String appDescription = '${app['description']}';",
    r"static const String apiBaseUrl = '[^']*';": "static const String apiBaseUrl = '${network['apiBaseUrl'] ?? 'http://jsonplaceholder.typicode.com'}';",
    r"static const String wsBaseUrl = '[^']*';": "static const String wsBaseUrl = '${network['wsBaseUrl'] ?? 'ws://127.0.0.1:9502/ws'}';",
    r"static const int connectionTimeout = \d+;": "static const int connectionTimeout = ${network['connectionTimeout'] ?? 30000};",
    r"static const int receiveTimeout = \d+;": "static const int receiveTimeout = ${network['receiveTimeout'] ?? 15000};",
    r"static const String marketTicker = '[^']*';": "static const String marketTicker = '${marketEndpoints['ticker'] ?? '/api/v1/market/ticker'}';",
    r"static const String marketKline = '[^']*';": "static const String marketKline = '${marketEndpoints['kline'] ?? '/api/v1/market/kline'}';",
    r"static const String marketDepth = '[^']*';": "static const String marketDepth = '${marketEndpoints['depth'] ?? '/api/v1/market/depth'}';",
    r"static const String tradePlaceOrder = '[^']*';": "static const String tradePlaceOrder = '${tradeEndpoints['placeOrder'] ?? '/api/v1/trade/order'}';",
    r"static const String tradeCancelOrder = '[^']*';": "static const String tradeCancelOrder = '${tradeEndpoints['cancelOrder'] ?? '/api/v1/trade/order/cancel'}';",
    r"static const String orderList = '[^']*';": "static const String orderList = '${orderEndpoints['list'] ?? '/api/v1/order/list'}';",
    r"static const String orderDetail = '[^']*';": "static const String orderDetail = '${orderEndpoints['detail'] ?? '/api/v1/order/detail'}';",
    r"static const String walletBalance = '[^']*';": "static const String walletBalance = '${walletEndpoints['balance'] ?? '/api/v1/wallet/balance'}';",
    r"static const String walletTransactions = '[^']*';": "static const String walletTransactions = '${walletEndpoints['transactions'] ?? '/api/v1/wallet/transactions'}';",
    r"static const String futuresPosition = '[^']*';": "static const String futuresPosition = '${futuresEndpoints['position'] ?? '/api/v1/futures/position'}';",
    r"static const String futuresLeverage = '[^']*';": "static const String futuresLeverage = '${futuresEndpoints['leverage'] ?? '/api/v1/futures/leverage'}';",
    r"static const String futuresFundingRate = '[^']*';": "static const String futuresFundingRate = '${futuresEndpoints['fundingRate'] ?? '/api/v1/futures/funding-rate'}';",
    r"static const String seedColor = '[^']*';": "static const String seedColor = '${theme['seedColor'] ?? '#2196F3'}';",
    r"static const String imageCdnBaseUrl = '[^']*';": "static const String imageCdnBaseUrl = '${resources['imageCdnBaseUrl'] ?? ''}';",
    r"static const double defaultHorizontalPadding = [\d.]+;": "static const double defaultHorizontalPadding = ${ui['defaultHorizontalPadding'] ?? 12.0};",
    r"static const double defaultVerticalPadding = [\d.]+;": "static const double defaultVerticalPadding = ${ui['defaultVerticalPadding'] ?? 12.0};",
    r"static const double defaultBorderRadius = [\d.]+;": "static const double defaultBorderRadius = ${ui['defaultBorderRadius'] ?? 8.0};",
    r"static const String appLogo = '[^']*';": "static const String appLogo = '${assets['appLogo'] ?? 'assets/icons/ic_appicon.png'}';",
    r"static const String carBackground = '[^']*';": "static const String carBackground = '${assets['carBackground'] ?? 'assets/images/img_login.jpg'}';",
    r"static const String productSans = '[^']*';": "static const String productSans = '${fonts['productSans'] ?? 'ProductSans'}';",
    r"static const String roboto = '[^']*';": "static const String roboto = '${fonts['roboto'] ?? 'Roboto'}';",
    r"static const String androidPackageName = '[^']*';": "static const String androidPackageName = '${android['packageName'] ?? 'com.iotecksolutions.todoapp'}';",
    r"static const String iosBundleId = '[^']*';": "static const String iosBundleId = '${ios['bundleId'] ?? 'com.iotecksolutions.todoapp'}';",
    r"static const String splashImage = '[^']*';": "static const String splashImage = '${splash['image'] ?? 'assets/images/launch/light-background.png'}';",
    r"static const String splashBackgroundColor = '[^']*';": "static const String splashBackgroundColor = '${splash['backgroundColor'] ?? '#ffffff'}';",
    r"static const String splashWebBackgroundSize = '[^']*';": "static const String splashWebBackgroundSize = '${splashWeb['backgroundSize'] ?? 'cover'}';",
    r"static const int splashWebFadeOutTime = \d+;": "static const int splashWebFadeOutTime = ${splashWeb['fadeOutTime'] ?? 400};",
    r"static const int splashWebHideDelay = \d+;": "static const int splashWebHideDelay = ${splashWeb['hideDelay'] ?? 500};",
  };

  return await _updateFile('lib/constants/app_config.dart', (content) {
    replacements.forEach((pattern, replacement) {
      content = content.replaceAll(RegExp(pattern), replacement);
    });
    return content;
  });
}

Future<bool> syncAndroidManifest(Map<String, dynamic> config) async {
  return await _updateFile('android/app/src/main/AndroidManifest.xml', (content) {
    return content
        .replaceAll(
          RegExp(r'android:label="[^"]*"'),
          'android:label="${config['label']}"',
        )
        .replaceAll(
          RegExp(r'package="[^"]*"'),
          'package="${config['packageName']}"',
        );
  });
}

Future<bool> syncAndroidBuildGradle(Map<String, dynamic> config) async {
  final packageName = config['packageName'] as String? ?? 'com.iotecksolutions.todoapp';
  return await _updateFile('android/app/build.gradle', (content) {
    return content
        .replaceAll(
          RegExp(r'namespace\s+"[^"]*"'),
          'namespace "$packageName"',
        )
        .replaceAll(
          RegExp(r'applicationId\s+"[^"]*"'),
          'applicationId "$packageName"',
        );
  });
}

Future<bool> syncMacosBundleId(Map<String, dynamic> config) async {
  final bundleId = config['bundleId'] as String? ?? 'com.iotecksolutions.todoapp';
  
  // 更新 AppInfo.xcconfig
  return await _updateFile('macos/Runner/Configs/AppInfo.xcconfig', (content) {
    return content.replaceAll(
      RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^\n]*'),
      'PRODUCT_BUNDLE_IDENTIFIER = $bundleId',
    );
  });
}

Future<bool> syncInfoPlist(Map<String, dynamic> config) async {
  return await _updateFile('ios/Runner/Info.plist', (content) {
    return content
        .replaceAll(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleDisplayName</key>\n\t<string>${config['displayName']}</string>',
        )
        .replaceAll(
          RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleName</key>\n\t<string>${config['bundleName']}</string>',
        );
  });
}

Future<bool> syncWebIndexHtml(Map<String, dynamic> config) async {
  final icon = config['icon'] as String?;
  return await _updateFile('web/index.html', (content) {
    content = content
        .replaceAll(RegExp(r'<title>[^<]*</title>'), '<title>${config['title']}</title>')
        .replaceAll(
          RegExp(r'<meta name="apple-mobile-web-app-title" content="[^"]*">'),
          '<meta name="apple-mobile-web-app-title" content="${config['title']}">',
        );
    
    // 更新 apple-touch-icon 和 favicon（如果配置了图标）
    if (icon != null) {
      // 更新 apple-touch-icon
      content = content.replaceAll(
        RegExp(r'<link rel="apple-touch-icon" href="[^"]*"'),
        '<link rel="apple-touch-icon" href="$icon"',
      );
      // 更新 favicon
      content = content.replaceAll(
        RegExp(r'<link rel="icon" type="image/png" href="[^"]*"'),
        '<link rel="icon" type="image/png" href="$icon"',
      );
    }
    
    return content;
  });
}

Future<bool> syncWebManifest(Map<String, dynamic> config) async {
  final file = File('web/manifest.json');
  if (!await file.exists()) {
    print('⚠️  警告: 找不到 web/manifest.json');
    return false;
  }

  final manifest = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final web = config['web'] as Map<String, dynamic>;
  final app = config['app'] as Map<String, dynamic>;
  
  manifest['name'] = web['title'];
  manifest['short_name'] = web['shortName'];
  manifest['description'] = app['description'];
  
  // 更新图标路径（如果配置了）
  final icon = web['icon'] as String?;
  if (icon != null && manifest['icons'] is List) {
    final icons = manifest['icons'] as List;
    for (var i = 0; i < icons.length; i++) {
      if (icons[i] is Map) {
        final iconMap = icons[i] as Map<String, dynamic>;
        iconMap['src'] = icon;
      }
    }
  }

  await file.writeAsString(const JsonEncoder.withIndent('    ').convert(manifest));
  print('✅ 已更新 web/manifest.json');
  return true;
}

Future<bool> syncSplashScreen(Map<String, dynamic> config) async {
  final image = config['image'] as String? ?? 'assets/images/launch/light-background.png';
  final backgroundColor = config['backgroundColor'] as String? ?? '#ffffff';
  final web = config['web'] as Map<String, dynamic>? ?? {};
  final webBackgroundSize = web['backgroundSize'] as String? ?? 'cover';
  final webFadeOutTime = web['fadeOutTime'] as int? ?? 400;
  final webHideDelay = web['hideDelay'] as int? ?? 500;
  
  // 同步 Android 启动图资源
  final androidImageCopied = await _copyAndroidSplashImage(image);
  
  final results = await Future.wait([
    // 同步 Web 启动图
    _updateFile('web/index.html', (content) {
      // 更新背景图片路径
      content = content.replaceAll(
        RegExp(r'background-image:\s*url\("[^"]*"\)'),
        'background-image: url("$image")',
      );
      // 更新背景颜色
      content = content.replaceAll(
        RegExp(r'background-color:\s*#[0-9a-fA-F]{6}'),
        'background-color: $backgroundColor',
      );
      // 更新背景尺寸
      content = content.replaceAll(
        RegExp(r'background-size:\s*[^;]+'),
        'background-size: $webBackgroundSize',
      );
      // 更新淡出时间
      content = content.replaceAll(
        RegExp(r'const FADE_OUT_TIME = \d+'),
        'const FADE_OUT_TIME = $webFadeOutTime',
      );
      // 更新隐藏延迟
      content = content.replaceAll(
        RegExp(r'setTimeout\(hideSplash, \d+\)'),
        'setTimeout(hideSplash, $webHideDelay)',
      );
      return content;
    }),
  ]);
  
  return results.every((r) => r) && androidImageCopied;
}

Future<bool> _copyAndroidSplashImage(String imagePath) async {
  final sourceFile = File(imagePath);
  if (!await sourceFile.exists()) {
    print('⚠️  警告: 找不到启动图文件 $imagePath');
    return false;
  }
  
  final targetDir = Directory('android/app/src/main/res/drawable');
  if (!await targetDir.exists()) {
    print('⚠️  警告: 找不到 Android drawable 目录');
    return false;
  }
  
  final targetFile = File('${targetDir.path}/launch_background_image.png');
  await sourceFile.copy(targetFile.path);
  print('✅ 已同步 Android 启动图资源: ${targetFile.path}');
  return true;
}

