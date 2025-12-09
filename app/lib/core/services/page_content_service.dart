import 'dart:io';
import 'dart:convert';
import 'package:fastapp/data/network/apis/page_content/page_content_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 页面内容服务
/// 负责下载和缓存页面配置
class PageContentService {
  final PageContentApi _pageContentApi;
  static const int _defaultPlatform = 2; // 默认App平台
  
  bool _isDownloading = false;
  Future<Map<String, dynamic>?>? _downloadFuture;
  final Map<int, File> _cachedFiles = {}; // 按平台缓存文件路径

  PageContentService(this._pageContentApi);

  /// 获取文件名
  String _getFileName(int platform) {
    return platform == 1 ? 'app-init-web.json' : 'app-init-app.json';
  }

  /// 获取页面内容配置
  /// [platform] 平台：1Web 2App，默认为2（App）
  /// 优先从服务器下载，失败则使用本地缓存
  Future<Map<String, dynamic>?> getPageContent({int platform = _defaultPlatform}) async {
    try {
      final content = await downloadAndSave(platform: platform);
      if (content != null) return content;
    } catch (_) {}
    return _loadFromLocal(platform: platform);
  }

  /// 下载并保存页面内容配置
  /// [platform] 平台：1Web 2App，默认为2（App）
  Future<Map<String, dynamic>?> downloadAndSave({int platform = _defaultPlatform}) async {
    if (_isDownloading && _downloadFuture != null) {
      return _downloadFuture;
    }

    _isDownloading = true;
    _downloadFuture = _performDownload(platform: platform);

    try {
      return await _downloadFuture!;
    } finally {
      _isDownloading = false;
      _downloadFuture = null;
    }
  }

  /// 执行下载操作
  Future<Map<String, dynamic>?> _performDownload({int platform = _defaultPlatform}) async {
    try {
      final fileContent = await _pageContentApi.downloadPageContent(platform: platform);
      await _saveFileContent(fileContent, platform: platform);
      return jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 从本地文件加载配置
  Future<Map<String, dynamic>?> _loadFromLocal({int platform = _defaultPlatform}) async {
    try {
      final file = await _getLocalFile(platform: platform);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 保存文件内容到本地
  Future<void> _saveFileContent(String content, {int platform = _defaultPlatform}) async {
    try {
      final file = await _getLocalFile(platform: platform);
      await file.create(recursive: true);
      await file.writeAsString(content, flush: true);
    } catch (_) {}
  }

  /// 获取本地文件路径
  Future<File> _getLocalFile({int platform = _defaultPlatform}) async {
    if (_cachedFiles.containsKey(platform)) {
      return _cachedFiles[platform]!;
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final configDir = Directory(path.join(directory.path, 'config'));
    await configDir.create(recursive: true);
    final fileName = _getFileName(platform);
    final file = File(path.join(configDir.path, fileName));
    _cachedFiles[platform] = file;
    return file;
  }

  /// 清除本地缓存
  /// [platform] 平台：1Web 2App，null表示清除所有平台
  Future<void> clearCache({int? platform}) async {
    try {
      if (platform != null) {
        final file = await _getLocalFile(platform: platform);
        if (await file.exists()) await file.delete();
        _cachedFiles.remove(platform);
      } else {
        // 清除所有平台
        for (final platformKey in _cachedFiles.keys) {
          final file = _cachedFiles[platformKey]!;
          if (await file.exists()) await file.delete();
        }
        _cachedFiles.clear();
      }
    } catch (_) {}
  }

  /// 获取本地文件路径
  /// [platform] 平台：1Web 2App，默认为2（App）
  Future<String?> getLocalFilePath({int platform = _defaultPlatform}) async {
    try {
      final file = await _getLocalFile(platform: platform);
      return await file.exists() ? file.path : null;
    } catch (_) {
      return null;
    }
  }
}

