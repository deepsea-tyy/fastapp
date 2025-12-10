import 'package:dio/dio.dart';
import 'package:fastapp/core/services/language_service.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';

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

  /// 检查是否是无需添加token的请求
  bool _shouldSkipToken(String path) {
    return path == Endpoints.userRefreshToken || 
           path == Endpoints.userLogout ||
           path == Endpoints.userLogin;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent(
      'Accept-Language',
      () => _languageService.getCurrentAcceptLanguage(),
    );

    // 跳过refresh token、logout和login请求的token添加
    if (!_shouldSkipToken(options.path)) {
      final accessToken = await _sharedPreferenceHelper.authToken;
      if (accessToken?.isNotEmpty ?? false) {
        options.headers.putIfAbsent('Token', () => accessToken!);
      }
    }

    handler.next(options);
  }
}

