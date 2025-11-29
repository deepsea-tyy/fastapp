import 'package:fastapp/core/data/network/dio/configs/dio_configs.dart';
import 'package:fastapp/core/data/network/dio/dio_client.dart';
import 'package:fastapp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:fastapp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:fastapp/data/network/apis/market/market_api.dart';
import 'package:fastapp/data/network/apis/order/order_api.dart';
import 'package:fastapp/data/network/apis/wallet/wallet_api.dart';
import 'package:fastapp/data/network/apis/trade/trade_api.dart';
import 'package:fastapp/data/network/apis/futures/futures_api.dart';
import 'package:fastapp/data/network/websocket/market_websocket.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';
import 'package:fastapp/data/network/interceptors/error_interceptor.dart';
import 'package:fastapp/data/network/rest_client.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';

import 'package:fastapp/di/service_locator.dart';

class NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    // event bus:---------------------------------------------------------------
    getIt.registerSingleton<EventBus>(EventBus());

    // interceptors:------------------------------------------------------------
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(
        accessToken: () async => await getIt<SharedPreferenceHelper>().authToken,
      ),
    );

    // rest client:-------------------------------------------------------------
    getIt.registerSingleton(RestClient());

    // dio:---------------------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.baseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout:Endpoints.receiveTimeout,
      ),
    );
    getIt.registerSingleton<DioClient>(
      DioClient(dioConfigs: getIt())
        ..addInterceptors(
          [
            getIt<AuthInterceptor>(),
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
    );

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(MarketApi());
    getIt.registerSingleton(OrderApi());
    getIt.registerSingleton(WalletApi());
    getIt.registerSingleton(TradeApi());
    getIt.registerSingleton(FuturesApi());

    // websocket:---------------------------------------------------------------
    getIt.registerSingleton(MarketWebSocket());
  }
}
