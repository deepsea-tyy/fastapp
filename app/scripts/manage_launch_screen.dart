import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

/// 应用资源管理脚本
/// 统一管理 iOS、Android 和 Web 的应用图标和启动图
/// 
/// 使用方法: dart run scripts/manage_launch_screen.dart [command]
/// 命令: icons, launch/sync, all (默认)
/// 
/// 功能：
/// - icons: 生成应用图标（Android mipmap + drawable, iOS AppIcon）
/// - launch/sync: 同步启动图（Android、iOS、Web）
/// - all: 生成图标并同步启动图

// 路径常量
const _configFile = 'app_config.json';
const _defaultSplashImage = 'assets/images/launch/light-background.png';
const _defaultLogoPath = 'assets/images/launch/logo.png';

// Android 路径
const _androidDrawable = 'android/app/src/main/res/drawable';
const _androidLaunchImage = '$_androidDrawable/launch_background_image.png';

// iOS 路径
const _iosLaunchImageDir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
const _iosAppIconDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const _iosContentsJson = '$_iosAppIconDir/Contents.json';

// Web 路径
const _webIndexHtml = 'web/index.html';

// iOS 启动图尺寸
const _iosLaunchSizes = {
  'LaunchImage.png': {'width': 375, 'height': 812},
  'LaunchImage@2x.png': {'width': 750, 'height': 1624},
  'LaunchImage@3x.png': {'width': 1125, 'height': 2436},
};

// Android 图标尺寸
const _androidIconSizes = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

void main(List<String> args) async {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  Directory.current = scriptDir.parent;

  final command = args.isNotEmpty ? args[0] : 'all';
  
  switch (command) {
    case 'icons':
      await generateAppIcons();
      break;
    case 'launch':
    case 'sync':
      await syncLaunchScreen();
      break;
    case 'all':
      await generateAppIcons();
      await syncLaunchScreen();
      break;
    default:
      print('❌ 未知命令: $command');
      print('可用命令: icons, launch, sync, all');
      exit(1);
  }
}

// 辅助函数
Future<Map<String, dynamic>> _loadConfig() async {
  final file = File(_configFile);
  if (!await file.exists()) {
    print('❌ 错误: 找不到 $_configFile 文件');
    exit(1);
  }
  return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
}

T? _getConfigValue<T>(Map<String, dynamic> config, List<String> path, [T? defaultValue]) {
  dynamic value = config;
  for (final key in path) {
    if (value is Map<String, dynamic>) {
      value = value[key];
      if (value == null) return defaultValue;
    } else {
      return defaultValue;
    }
  }
  return value is T ? value : defaultValue;
}

Future<img.Image> _loadImage(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    print('❌ 错误: 找不到图片文件: $path');
    exit(1);
  }
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('❌ 错误: 无法解码图片文件: $path');
    exit(1);
  }
  return image;
}

Future<void> _saveResizedImage(img.Image source, String path, int width, int height) async {
  final resized = img.copyResize(
    source,
    width: width,
    height: height,
    interpolation: img.Interpolation.cubic,
  );
  await File(path).writeAsBytes(img.encodePng(resized));
}

/// 生成应用图标
Future<void> generateAppIcons() async {
  print('🎨 生成应用图标...');

  try {
    final config = await _loadConfig();
    final logoPath = _getConfigValue<String>(config, ['assets', 'appLogo']) ?? _defaultLogoPath;
    final sourceImage = await _loadImage(logoPath);

    // Android 图标
    for (final entry in _androidIconSizes.entries) {
      final dir = Directory('android/app/src/main/res/${entry.key}');
      await dir.create(recursive: true);
      await _saveResizedImage(sourceImage, '${dir.path}/ic_launcher.png', entry.value, entry.value);
    }
    
    // Android drawable 图标
    final drawableDir = Directory(_androidDrawable);
    await drawableDir.create(recursive: true);
    await _saveResizedImage(sourceImage, '${drawableDir.path}/ic_launcher.png', 192, 192);

    // iOS 图标
    final contentsFile = File(_iosContentsJson);
    if (await contentsFile.exists()) {
      final contents = jsonDecode(await contentsFile.readAsString()) as Map<String, dynamic>;
      final images = contents['images'] as List<dynamic>;
      final iconDir = Directory(_iosAppIconDir);
      await iconDir.create(recursive: true);

      for (final imageConfig in images) {
        final config = imageConfig as Map<String, dynamic>;
        final filename = config['filename'] as String?;
        if (filename == null) continue;

        final sizeStr = config['size'] as String;
        final scale = (config['scale'] as String? ?? '1x').replaceAll('x', '');
        final pixelSize = (double.parse(sizeStr.split('x')[0]) * int.parse(scale)).round();

        await _saveResizedImage(sourceImage, '${iconDir.path}/$filename', pixelSize, pixelSize);
      }
    }

    print('✅ 图标生成完成');
  } catch (e) {
    print('❌ 错误: 生成图标失败: $e');
    exit(1);
  }
}

/// 同步启动图
Future<void> syncLaunchScreen() async {
  print('🔄 同步启动图配置...');

  try {
    final config = await _loadConfig();
    final imagePath = _getConfigValue<String>(config, ['splash', 'image']) ?? _defaultSplashImage;
    final sourceImage = await _loadImage(imagePath);

    // Android 启动图
    final targetDir = Directory(_androidDrawable);
    await targetDir.create(recursive: true);
    final targetFile = File(_androidLaunchImage);
    if (await targetFile.exists()) await targetFile.delete();
    await File(imagePath).copy(_androidLaunchImage);
    
    // 创建透明图标用于 Android 12+ SplashScreen API
    // windowSplashScreenAnimatedIcon 需要实际的PNG图标，不能使用shape
    // 使用较大的尺寸（512x512）来覆盖默认图标区域，避免显示黑色圆形
    // 确保创建完全透明的 RGBA 格式图片
    final emptyIconPng = File('$_androidDrawable/empty_icon.png');
    final transparentImage = img.Image(width: 512, height: 512, numChannels: 4);
    // 确保所有像素都是完全透明的（RGBA: 0, 0, 0, 0）
    // numChannels: 4 创建 RGBA 格式，默认所有像素都是透明的
    await emptyIconPng.writeAsBytes(img.encodePng(transparentImage));
    print('   ✅ 已创建透明图标: empty_icon.png (512x512, RGBA)');

    // iOS 启动图
    final launchImageDir = Directory(_iosLaunchImageDir);
    if (await launchImageDir.exists()) {
      for (final entry in _iosLaunchSizes.entries) {
        await _saveResizedImage(
          sourceImage,
          '${launchImageDir.path}/${entry.key}',
          entry.value['width']!,
          entry.value['height']!,
        );
      }
    }

    // Web 启动图
    await _syncWebLaunchScreen(config);

    print('✅ 启动图同步完成');
  } catch (e) {
    print('❌ 错误: 同步启动图失败: $e');
    exit(1);
  }
}

/// 同步 Web 启动图配置
Future<void> _syncWebLaunchScreen(Map<String, dynamic> config) async {
  final webIndexFile = File(_webIndexHtml);
  if (!await webIndexFile.exists()) return;

  final splash = config['splash'] as Map<String, dynamic>? ?? {};
  final image = _getConfigValue<String>(config, ['splash', 'image']) ?? _defaultSplashImage;
  final backgroundColor = _getConfigValue<String>(config, ['splash', 'backgroundColor']) ?? '#ffffff';
  final web = splash['web'] as Map<String, dynamic>? ?? {};
  final webBackgroundSize = web['backgroundSize'] as String? ?? 'cover';
  final webFadeOutTime = web['fadeOutTime'] as int? ?? 400;
  final webHideDelay = web['hideDelay'] as int? ?? 500;
  
  var content = await webIndexFile.readAsString();
  
  content = content.replaceAll(RegExp(r'background-image:\s*url\("[^"]*"\)'), 'background-image: url("$image")');
  content = content.replaceAll(RegExp(r'background-color:\s*#[0-9a-fA-F]{6}'), 'background-color: $backgroundColor');
  content = content.replaceAll(RegExp(r'background-size:\s*[^;]+'), 'background-size: $webBackgroundSize');
  content = content.replaceAll(RegExp(r'const FADE_OUT_TIME = \d+'), 'const FADE_OUT_TIME = $webFadeOutTime');
  content = content.replaceAll(RegExp(r'setTimeout\(hideSplash, \d+\)'), 'setTimeout(hideSplash, $webHideDelay)');
  
  await webIndexFile.writeAsString(content);
}
