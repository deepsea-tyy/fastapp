import 'package:fastapp/core/data/network/dio/configs/dio_configs.dart';
import 'package:fastapp/core/data/network/dio/dio_client.dart';
import 'package:fastapp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:fastapp/core/data/network/dio/interceptors/header_interceptor.dart';
import 'package:fastapp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:fastapp/core/data/network/dio/interceptors/response_interceptor.dart';
import 'package:fastapp/core/data/network/dio/interceptors/token_refresh_interceptor.dart';
import 'package:fastapp/data/network/apis/market/market_api.dart';
import 'package:fastapp/data/network/apis/order/order_api.dart';
import 'package:fastapp/data/network/apis/wallet/wallet_api.dart';
import 'package:fastapp/data/network/apis/trade/trade_api.dart';
import 'package:fastapp/data/network/apis/futures/futures_api.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/data/network/apis/page_content/page_content_api.dart';
import 'package:fastapp/data/network/apis/kyc/ex_kyc_api.dart';
import 'package:fastapp/data/network/apis/attachment/attachment_api.dart';
import 'package:fastapp/data/network/apis/feed/feed_api.dart';
import 'package:fastapp/data/network/apis/message/message_notify_api.dart';
import 'package:fastapp/data/network/apis/customer_service/customer_service_api.dart';
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:fastapp/core/services/page_content_service.dart';
import 'package:fastapp/core/services/market_data_service.dart';
import 'package:fastapp/core/services/exchange_rate_service.dart';
import 'package:fastapp/core/services/quality_feedback_service.dart';
import 'package:fastapp/core/services/language_service.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';
import 'package:fastapp/data/network/interceptors/error_interceptor.dart';
import 'package:fastapp/data/network/rest_client.dart';
import 'package:fastapp/data/network/http_client_wrapper.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';
import 'package:fastapp/di/service_locator.dart';

class NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    getIt.registerSingleton<EventBus>(EventBus());
    
    final sharedPrefs = getIt<SharedPreferenceHelper>();
    final eventBus = getIt<EventBus>();

    getIt.registerSingleton<LanguageService>(LanguageService(sharedPrefs));
    getIt.registerSingleton(RestClient());

    getIt.registerSingleton<HeaderInterceptor>(
      HeaderInterceptor(
        languageService: getIt<LanguageService>(),
        sharedPreferenceHelper: sharedPrefs,
      ),
    );
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ResponseInterceptor>(ResponseInterceptor(eventBus));
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(eventBus));
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(accessToken: () async => await sharedPrefs.authToken),
    );

    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.baseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
        sendTimeout: Endpoints.sendTimeout,
      ),
    );
    final dioClient = DioClient(dioConfigs: getIt());
    getIt.registerSingleton<DioClient>(dioClient);

    getIt.registerSingleton<TokenRefreshInterceptor>(
      TokenRefreshInterceptor(
        sharedPrefsHelper: sharedPrefs,
        dio: dioClient.dio,
        eventBus: eventBus,
      ),
    );

    dioClient.addInterceptors([
      getIt<HeaderInterceptor>(),
      getIt<AuthInterceptor>(),
      getIt<TokenRefreshInterceptor>(),
      getIt<ResponseInterceptor>(),
      getIt<ErrorInterceptor>(),
      getIt<LoggingInterceptor>(),
    ]);

    final dio = getIt<DioClient>();
    final restClient = getIt<RestClient>();
    
    // 注册 HTTP 客户端包装器
    // 用于统一管理 DioClient 和 RestClient 的切换
    // 开发时默认使用 DioClient（有日志），生产时可配置部分接口使用 RestClient（性能优化）
    getIt.registerSingleton<HttpClientWrapper>(
      HttpClientWrapper(
        dioClient: dio,
        restClient: restClient,
      ),
    );
    
    // 注册 MarketApi（使用 HttpClientWrapper）
    getIt.registerSingleton(MarketApi(getIt<HttpClientWrapper>()));
    getIt.registerSingleton(OrderApi(getIt<HttpClientWrapper>()));
    getIt.registerSingleton(WalletApi(dio));
    getIt.registerSingleton(TradeApi(getIt<HttpClientWrapper>()));
    getIt.registerSingleton(FuturesApi(getIt<HttpClientWrapper>()));
    getIt.registerSingleton(UserApi(dio));
    getIt.registerSingleton(PageContentApi(dio));
    getIt.registerSingleton(ExKycApi(dio));
    getIt.registerSingleton(AttachmentApi(dio));
    getIt.registerSingleton(FeedApi(dio));
    getIt.registerSingleton(MessageNotifyApi(dio));
    getIt.registerSingleton(CustomerServiceApi(dio));

    // websocket:---------------------------------------------------------------
    getIt.registerSingleton(AppWebSocket());

    getIt.registerSingleton<PageContentService>(
      PageContentService(getIt<PageContentApi>()),
    );

    getIt.registerSingleton<MarketDataService>(
      MarketDataService(getIt<MarketApi>()),
    );

    getIt.registerSingleton<ExchangeRateService>(
      ExchangeRateService(getIt<MarketApi>()),
    );

    getIt.registerSingleton<QualityFeedbackService>(
      QualityFeedbackService(),
    );
  }
}
