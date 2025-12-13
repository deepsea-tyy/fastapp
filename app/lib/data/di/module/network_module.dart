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
import 'package:fastapp/data/network/websocket/market_websocket.dart';
import 'package:fastapp/data/network/websocket/websocket_service.dart';
import 'package:fastapp/core/services/page_content_service.dart';
import 'package:fastapp/core/services/language_service.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';
import 'package:fastapp/data/network/interceptors/error_interceptor.dart';
import 'package:fastapp/data/network/rest_client.dart';
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
    getIt.registerSingleton(MarketApi());
    getIt.registerSingleton(OrderApi());
    getIt.registerSingleton(WalletApi());
    getIt.registerSingleton(TradeApi());
    getIt.registerSingleton(FuturesApi());
    getIt.registerSingleton(UserApi(dio));
    getIt.registerSingleton(PageContentApi(dio));

    // websocket:---------------------------------------------------------------
    getIt.registerSingleton(MarketWebSocket());
    getIt.registerSingleton<WebSocketService>(
      WebSocketService(getIt<MarketWebSocket>()),
    );

    getIt.registerSingleton<PageContentService>(
      PageContentService(getIt<PageContentApi>()),
    );
  }
}
