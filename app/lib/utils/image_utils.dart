import '../constants/app_config.dart';

/// 图片工具类
class ImageUtils {
  ImageUtils._();

  /// 默认图片
  static const String defaultImage = '/404.png';

  /// 检查是否是完整 URL
  static bool _isFullUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// 格式化单个图片路径
  /// [path] 图片路径
  /// [baseUrl] 基础 URL（可选，默认使用配置的 imageCdnBaseUrl）
  /// 返回: 完整的图片 URL，如果路径为空则返回默认图片
  static String formatSingleImagePath(
    String? path, {
    String? baseUrl,
  }) {
    // 如果路径为空或为空字符串，返回默认图片
    if (path == null || path.trim().isEmpty) {
      return defaultImage;
    }

    // 如果已经是完整 URL，直接返回
    if (_isFullUrl(path)) {
      return path;
    }

    // 使用提供的 baseUrl 或配置的 imageCdnBaseUrl
    final urlPrefix = baseUrl ?? AppConfig.imageCdnBaseUrl;
    return urlPrefix + path;
  }

  /// 格式化图片路径
  /// [obj] 可以是字符串、字符串数组
  /// [baseUrl] 基础 URL（可选，默认使用配置的 imageCdnBaseUrl）
  /// 返回: 格式化后的图片路径或路径数组，如果为空则返回默认图片
  static dynamic formatImagePath(
    dynamic obj, {
    String? baseUrl,
  }) {
    if (obj == null) {
      return defaultImage;
    }

    if (obj is String) {
      return _isFullUrl(obj)
          ? obj
          : formatSingleImagePath(obj, baseUrl: baseUrl);
    }

    if (obj is List<String>) {
      if (obj.isEmpty) {
        return [defaultImage];
      }
      return obj
          .map((item) => _isFullUrl(item)
              ? item
              : formatSingleImagePath(item, baseUrl: baseUrl))
          .toList();
    }

    return defaultImage;
  }

  /// 处理 URL - 从完整 URL 中提取路径部分
  /// [url] 完整的 URL
  /// 返回: 处理后的路径，移除 baseUrl 前缀
  static String processUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return '';
    }

    final baseUrl = AppConfig.imageCdnBaseUrl;
    if (baseUrl.isEmpty) {
      return url.trim();
    }

    // 如果 URL 以 baseUrl 开头，移除前缀
    if (url.startsWith(baseUrl)) {
      return url.replaceFirst(baseUrl, '');
    }

    // 如果是完整 URL，直接返回
    if (_isFullUrl(url)) {
      return url;
    }

    return url.trim();
  }

  /// 验证图片路径是否有效
  /// [path] 图片路径
  /// 返回: true 如果路径有效
  static bool isValidImagePath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return false;
    }

    // 完整 URL 视为有效
    if (_isFullUrl(path)) {
      return true;
    }

    // 本地路径视为有效
    return path.isNotEmpty;
  }
}
