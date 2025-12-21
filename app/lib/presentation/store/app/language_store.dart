import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/language/Language.dart';
import 'package:fastapp/domain/usecase/setting/get_language_usecase.dart';
import 'package:fastapp/domain/usecase/setting/set_language_usecase.dart';
import 'package:mobx/mobx.dart';

part 'language_store.g.dart';

class LanguageStore = _LanguageStore with _$LanguageStore;

abstract class _LanguageStore with Store {
  final GetLanguageUseCase _getLanguageUseCase;
  final SetLanguageUseCase _setLanguageUseCase;
  final ErrorStore errorStore;

  static const List<Map<String, String>> _languageData = [
    {'code': 'CN', 'locale': 'zh_CN'},
    {'code': 'TW', 'locale': 'zh_TW'},
    {'code': 'US', 'locale': 'en'},
    {'code': 'JP', 'locale': 'ja'},
    {'code': 'KR', 'locale': 'ko'},
    {'code': 'DE', 'locale': 'gm'},
    {'code': 'RU', 'locale': 'ru'},
    {'code': 'TH', 'locale': 'th'},
    {'code': 'AT', 'locale': 'au'},
  ];

  /// 语言名称的多语言映射表
  /// key: locale, value: 该语言在不同语言下的显示名称
  static const Map<String, Map<String, String>> _languageLabels = {
    'zh_CN': {
      'zh_CN': '中文简体',
      'zh_TW': '中文簡體',
      'en': 'Simplified Chinese',
      'ja': '簡体中国語',
      'ko': '중국어 간체',
      'gm': 'Vereinfachtes Chinesisch',
      'ru': 'Упрощённый китайский',
      'th': 'จีนตัวย่อ',
      'au': 'Vereinfachtes Chinesisch',
    },
    'zh_TW': {
      'zh_CN': '中文繁体',
      'zh_TW': '中文繁體',
      'en': 'Traditional Chinese',
      'ja': '繁体中国語',
      'ko': '중국어 번체',
      'gm': 'Traditionelles Chinesisch',
      'ru': 'Традиционный китайский',
      'th': 'จีนตัวเต็ม',
      'au': 'Traditionelles Chinesisch',
    },
    'en': {
      'zh_CN': '英文',
      'zh_TW': '英文',
      'en': 'English',
      'ja': '英語',
      'ko': '영어',
      'gm': 'Englisch',
      'ru': 'Английский',
      'th': 'อังกฤษ',
      'au': 'Englisch',
    },
    'ja': {
      'zh_CN': '日语',
      'zh_TW': '日語',
      'en': 'Japanese',
      'ja': '日本語',
      'ko': '일본어',
      'gm': 'Japanisch',
      'ru': 'Японский',
      'th': 'ญี่ปุ่น',
      'au': 'Japanisch',
    },
    'ko': {
      'zh_CN': '韩语',
      'zh_TW': '韓語',
      'en': 'Korean',
      'ja': '韓国語',
      'ko': '한국어',
      'gm': 'Koreanisch',
      'ru': 'Корейский',
      'th': 'เกาหลี',
      'au': 'Koreanisch',
    },
    'gm': {
      'zh_CN': '德语',
      'zh_TW': '德語',
      'en': 'German',
      'ja': 'ドイツ語',
      'ko': '독일어',
      'gm': 'Deutsch',
      'ru': 'Немецкий',
      'th': 'เยอรมัน',
      'au': 'Deutsch',
    },
    'ru': {
      'zh_CN': '俄语',
      'zh_TW': '俄語',
      'en': 'Russian',
      'ja': 'ロシア語',
      'ko': '러시아어',
      'gm': 'Russisch',
      'ru': 'Русский',
      'th': 'รัสเซีย',
      'au': 'Russisch',
    },
    'th': {
      'zh_CN': '泰语',
      'zh_TW': '泰語',
      'en': 'Thai',
      'ja': 'タイ語',
      'ko': '태국어',
      'gm': 'Thailändisch',
      'ru': 'Тайский',
      'th': 'ไทย',
      'au': 'Thailändisch',
    },
    'au': {
      'zh_CN': '奥语',
      'zh_TW': '奧語',
      'en': 'Austrian',
      'ja': 'オーストリア語',
      'ko': '오스트리아어',
      'gm': 'Österreichisch',
      'ru': 'Австрийский',
      'th': 'ออสเตรีย',
      'au': 'Österreichisch',
    },
  };

  static const Map<String, String> _localeToCode = {
    'zh_CN': 'CN',
    'zh_TW': 'TW',
    'en': 'US',
    'ja': 'JP',
    'ko': 'KR',
    'gm': 'DE',
    'ru': 'RU',
    'th': 'TH',
    'au': 'AT',
  };

  _LanguageStore(
    this._getLanguageUseCase,
    this._setLanguageUseCase,
    this.errorStore,
  ) {
    _init();
  }

  /// 异步初始化语言
  void _init() async {
    final savedLanguage = await _getLanguageUseCase.call(params: null);
    if (savedLanguage != null) {
      _locale = savedLanguage;
    }
  }

  @observable
  String _locale = "zh_CN";

  @computed
  String get locale => _locale;

  /// 获取当前语言下的支持语言列表（动态显示名称）
  @computed
  List<Language> get supportedLanguages {
    return _languageData.map((data) {
      final locale = data['locale']!;
      final code = data['code']!;
      return Language(
        code: code,
        locale: locale,
        language: _getLanguageLabel(locale),
      );
    }).toList();
  }

  /// 获取语言标签（根据当前选择的语言）
  /// 回退顺序：当前语言 -> zh_CN -> en -> locale本身
  String _getLanguageLabel(String locale) {
    final labels = _languageLabels[locale];
    return labels?[_locale] ?? 
           labels?['zh_CN'] ?? 
           labels?['en'] ?? 
           locale;
  }

  @action
  void changeLanguage(String value) {
    _locale = value;
    _setLanguageUseCase.call(params: SetLanguageParams(language: value));
  }

  @action
  String getCode() => _localeToCode[_locale] ?? 'CN';

  @action
  String? getLanguage() {
    return supportedLanguages
        .firstWhere(
          (language) => language.locale == _locale,
          orElse: () => supportedLanguages.first,
        )
        .language;
  }

}
