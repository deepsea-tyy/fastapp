import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';

/// 多语言服务
/// 统一处理语言相关的转换和映射
class LanguageService {
  final SharedPreferenceHelper _sharedPreferenceHelper;

  LanguageService(this._sharedPreferenceHelper);

  /// 语言代码到 Accept-Language 的映射表
  static const Map<String, String> _localeToAcceptLanguage = {
    'zh_CN': 'zh_CN',
    'zh_TW': 'zh_TW',
    'en': 'en_US',
    'ja': 'ja_JP',
    'ko': 'ko_KR',
    'gm': 'de_DE',
    'ru': 'ru_RU',
    'th': 'th_TH',
    'au': 'de_AT',
  };

  /// 获取当前语言的 Accept-Language 格式
  String getCurrentAcceptLanguage() {
    final locale = _sharedPreferenceHelper.currentLanguage;
    if (locale == null || locale.isEmpty) return 'zh_CN';
    return _localeToAcceptLanguage[locale] ?? locale;
  }
}

