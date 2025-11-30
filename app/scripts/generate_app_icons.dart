import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

/// 应用图标生成脚本
/// 从 app_config.json 读取 logo 路径，生成 Android 和 iOS 所需的各种尺寸图标
/// 使用方法: dart run scripts/generate_app_icons.dart
/// 注意: 必须在 app/ 目录下运行

void main() async {
  // 确保在正确的目录下运行（app/ 目录）
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final appDir = scriptDir.parent;
  Directory.current = appDir;

  print('🚀 开始生成应用图标...\n');
  print('📁 工作目录: ${Directory.current.path}\n');

  // 加载配置
  final configFile = File('app_config.json');
  if (!await configFile.exists()) {
    print('❌ 错误: 找不到 app_config.json 文件');
    exit(1);
  }

  final config = jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final assets = config['assets'] as Map<String, dynamic>? ?? {};
  final logoPath = assets['appLogo'] as String? ?? 'assets/images/launch/logo.png';

  // 检查源图片是否存在
  final sourceFile = File(logoPath);
  if (!await sourceFile.exists()) {
    print('❌ 错误: 找不到源图片文件 $logoPath');
    exit(1);
  }

  print('📸 源图片: $logoPath\n');

  // 读取源图片
  final sourceBytes = await sourceFile.readAsBytes();
  final sourceImage = img.decodeImage(sourceBytes);
  if (sourceImage == null) {
    print('❌ 错误: 无法解码图片文件');
    exit(1);
  }

  print('✅ 成功加载源图片 (${sourceImage.width}x${sourceImage.height})\n');

  // 生成 Android 图标
  print('📱 生成 Android 图标...');
  await _generateAndroidIcons(sourceImage);
  print('✅ Android 图标生成完成\n');

  // 生成 iOS 图标
  print('🍎 生成 iOS 图标...');
  await _generateIOSIcons(sourceImage);
  print('✅ iOS 图标生成完成\n');

  print('🎉 所有图标生成完成！');
}

/// 生成 Android 图标
Future<void> _generateAndroidIcons(img.Image sourceImage) async {
  // Android 图标尺寸配置（像素）
  final androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in androidSizes.entries) {
    final dir = Directory('android/app/src/main/res/${entry.key}');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final size = entry.value;
    final resized = img.copyResize(
      sourceImage,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );

    final outputFile = File('${dir.path}/ic_launcher.png');
    await outputFile.writeAsBytes(img.encodePng(resized));
    print('  ✅ ${entry.key}/ic_launcher.png (${size}x${size})');
  }
}

/// 生成 iOS 图标
Future<void> _generateIOSIcons(img.Image sourceImage) async {
  // 读取 iOS Contents.json 配置
  final contentsFile = File('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json');
  if (!await contentsFile.exists()) {
    print('  ⚠️  警告: 找不到 iOS Contents.json 文件');
    return;
  }

  final contents = jsonDecode(await contentsFile.readAsString()) as Map<String, dynamic>;
  final images = contents['images'] as List<dynamic>;

  final iconDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  if (!await iconDir.exists()) {
    await iconDir.create(recursive: true);
  }

  for (final imageConfig in images) {
    final config = imageConfig as Map<String, dynamic>;
    final sizeStr = config['size'] as String;
    final scale = config['scale'] as String? ?? '1x';
    final filename = config['filename'] as String?;

    if (filename == null) continue;

    // 解析尺寸 (例如 "20x20" -> 20, "83.5x83.5" -> 83.5)
    final sizeParts = sizeStr.split('x');
    final size = double.parse(sizeParts[0]);
    // 解析缩放比例 (例如 "2x" -> 2)
    final scaleFactor = int.parse(scale.replaceAll('x', ''));
    // 计算实际像素尺寸（向上取整）
    final pixelSize = (size * scaleFactor).round();

    // 生成图标
    final resized = img.copyResize(
      sourceImage,
      width: pixelSize,
      height: pixelSize,
      interpolation: img.Interpolation.cubic,
    );

    final outputFile = File('${iconDir.path}/$filename');
    await outputFile.writeAsBytes(img.encodePng(resized));
    print('  ✅ $filename (${pixelSize}x${pixelSize})');
  }
}
