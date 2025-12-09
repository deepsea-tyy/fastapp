import 'package:dio/dio.dart';
import 'package:fastapp/core/services/language_service.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';

/// 请求头拦截器
/// 用于添加固定的请求头，如 Accept-Language、Token 等
class HeaderInterceptor extends Interceptor {
  final LanguageService _languageService;
  final SharedPreferenceHelper _sharedPreferenceHelper;

  HeaderInterceptor({
    required LanguageService languageService,
    required SharedPreferenceHelper sharedPreferenceHelper,
  })  : _languageService = languageService,
        _sharedPreferenceHelper = sharedPreferenceHelper;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent(
      'Accept-Language',
      () => _languageService.getCurrentAcceptLanguage(),
    );

    final accessToken = await _sharedPreferenceHelper.authToken;
    if (accessToken?.isNotEmpty ?? false) {
      options.headers.putIfAbsent('Token', () => accessToken!);
    }

    handler.next(options);
  }
}

