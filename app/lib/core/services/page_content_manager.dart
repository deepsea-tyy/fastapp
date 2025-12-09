import 'package:fastapp/core/services/page_content_service.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';

/// 页面内容管理器
/// 提供便捷的方法来获取页面配置中的文本内容
class PageContentManager {
  final PageContentService _pageContentService;
  final LanguageStore _languageStore;
  
  // 缓存配置数据
  Map<String, dynamic>? _cachedContent;
  bool _isLoading = false;

  PageContentManager(
    this._pageContentService,
    this._languageStore,
  );

  /// 初始化并加载配置
  /// [preloadedContent] 如果提供了已下载的内容，直接使用它，避免重复下载
  /// [platform] 平台：1Web 2App，默认为2（App）
  Future<void> initialize({
    Map<String, dynamic>? preloadedContent,
    int platform = 2,
  }) async {
    if (_cachedContent != null || _isLoading) {
      return;
    }

    _isLoading = true;
    try {
      if (preloadedContent != null) {
        // 如果提供了已下载的内容，直接使用
        _cachedContent = preloadedContent;
      } else {
        // 否则从本地读取或下载
        _cachedContent = await _pageContentService.getPageContent(platform: platform);
      }
    } catch (e) {
      // 加载失败，使用空配置
      _cachedContent = {};
    } finally {
      _isLoading = false;
    }
  }

  /// 刷新配置（重新下载）
  /// [platform] 平台：1Web 2App，默认为2（App）
  Future<void> refresh({int platform = 2}) async {
    _isLoading = true;
    try {
      _cachedContent = await _pageContentService.downloadAndSave(platform: platform);
    } catch (e) {
      // 刷新失败，保持现有缓存
    } finally {
      _isLoading = false;
    }
  }

  /// 获取文本内容
  /// [key] 配置的key，如 'login.title'
  /// [defaultValue] 如果找不到配置，返回的默认值
  /// [params] 可选的参数，用于替换文本中的占位符，如 {count}
  String getText(
    String key, {
    String? defaultValue,
    Map<String, dynamic>? params,
  }) {
    final defaultResult = defaultValue ?? key;
    
    if (_cachedContent == null) return defaultResult;

    final content = _cachedContent![key];
    if (content is! Map<String, dynamic> || 
        (content['content_type'] as int?) != 1) {
      return defaultResult;
    }

    final data = content['data'];
    if (data is! Map<String, dynamic>) {
      return defaultResult;
    }

    final text = _getTextByLocale(data, defaultResult);
    return _replaceParams(text, params);
  }

  /// 根据语言获取文本
  String _getTextByLocale(Map<String, dynamic> data, String defaultValue) {
    final locale = _languageStore.locale;
    final localeKey = _getLocaleKey(locale, data);
    
    return data[localeKey] as String? ??
           data['zh_CN'] as String? ??
           data['en'] as String? ??
           defaultValue;
  }

  /// 获取语言key
  String _getLocaleKey(String locale, Map<String, dynamic> data) {
    if (locale == 'en') return 'en';
    if (locale == 'zh_TW') {
      return data.containsKey('zh_TW') ? 'zh_TW' : 'zh_CN';
    }
    return locale.startsWith('zh') ? 'zh_CN' : 'zh_CN';
  }

  /// 替换参数占位符
  String _replaceParams(String text, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return text;
    
    return params.entries.fold(
      text,
      (result, entry) => result.replaceAll('{${entry.key}}', entry.value.toString()),
    );
  }

  /// 批量获取文本
  Map<String, String> getTexts(List<String> keys, {Map<String, String>? defaultValues}) {
    final result = <String, String>{};
    for (final key in keys) {
      result[key] = getText(key, defaultValue: defaultValues?[key]);
    }
    return result;
  }

  /// 检查配置是否已加载
  bool get isInitialized => _cachedContent != null;

  /// 获取所有配置
  Map<String, dynamic>? get allContent => _cachedContent;
}

