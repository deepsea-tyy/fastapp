import 'dart:async';

import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/domain/repository/setting/setting_repository.dart';
import 'package:fastapp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:fastapp/domain/usecase/user/login_usecase.dart';
import 'package:fastapp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:fastapp/domain/usecase/user/get_user_info_usecase.dart';
import 'package:fastapp/domain/usecase/user/logout_usecase.dart';
import 'package:fastapp/domain/usecase/user/refresh_token_usecase.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
import 'package:fastapp/data/network/websocket/websocket_service.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/store/futures/futures_trade_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/store/orders/order_store.dart';
import 'package:fastapp/presentation/store/kyc/ex_kyc_store.dart';
import 'package:fastapp/domain/usecase/kyc/get_kyc_detail_usecase.dart';
import 'package:fastapp/domain/usecase/kyc/submit_kyc_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_ticker_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/download_market_data_usecase.dart';
import 'package:fastapp/domain/repository/market_repository.dart';
import 'package:fastapp/domain/usecase/trade/place_order_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_transactions_usecase.dart';
import 'package:fastapp/domain/usecase/order/get_orders_usecase.dart';
import 'package:fastapp/domain/usecase/trade/cancel_order_usecase.dart';
import 'package:fastapp/domain/repository/futures_repository.dart';
import 'package:fastapp/domain/usecase/setting/get_theme_usecase.dart';
import 'package:fastapp/domain/usecase/setting/set_theme_usecase.dart';
import 'package:fastapp/domain/usecase/setting/get_language_usecase.dart';
import 'package:fastapp/domain/usecase/setting/set_language_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_positions_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_funding_rate_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_mark_price_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_leverage_usecase.dart';
import 'package:fastapp/domain/usecase/futures/set_leverage_usecase.dart';

import 'package:fastapp/di/service_locator.dart';

class StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    // factories:---------------------------------------------------------------
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );

    // stores:------------------------------------------------------------------
    getIt.registerSingleton<UserStore>(
      UserStore(
        getIt<IsLoggedInUseCase>(),
        getIt<SaveLoginStatusUseCase>(),
        getIt<LoginUseCase>(),
        getIt<GetUserInfoUseCase>(),
        getIt<LogoutUseCase>(),
        getIt<RefreshTokenUseCase>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ThemeStore>(
      ThemeStore(
        getIt<GetThemeUseCase>(),
        getIt<SetThemeUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<LanguageStore>(
      LanguageStore(
        getIt<GetLanguageUseCase>(),
        getIt<SetLanguageUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<HomeStore>(
      HomeStore()..initData(),
    );

    getIt.registerSingleton<MarketDataStore>(
      MarketDataStore(
        getIt<DownloadMarketDataUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<MarketStore>(
      MarketStore(
        getIt<GetTickerUseCase>(),
        getIt<GetAllTickerUseCase>(),
        getIt<ErrorStore>(),
        getIt<WebSocketService>(),
        getIt<MarketDataStore>(),
      ),
    );

    getIt.registerSingleton<KlineStore>(
      KlineStore(
        getIt<GetKlineUseCase>(),
        getIt<ErrorStore>(),
        getIt<WebSocketService>(),
      ),
    );

    getIt.registerSingleton<DepthStore>(
      DepthStore(
        getIt<GetDepthUseCase>(),
        getIt<ErrorStore>(),
        getIt<WebSocketService>(),
      ),
    );

    getIt.registerSingleton<SpotTradeStore>(
      SpotTradeStore(
        getIt<PlaceOrderUseCase>(),
        getIt<GetDepthUseCase>(),
        getIt<GetBalanceUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<FuturesTradeStore>(
      FuturesTradeStore(
        getIt<PlaceOrderUseCase>(),
        getIt<GetDepthUseCase>(),
        getIt<GetBalanceUseCase>(),
        getIt<GetPositionsUseCase>(),
        getIt<GetFundingRateUseCase>(),
        getIt<GetMarkPriceUseCase>(),
        getIt<GetLeverageUseCase>(),
        getIt<SetLeverageUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<WalletStore>(
      WalletStore(
        getIt<GetAssetUseCase>(),
        getIt<GetBalanceUseCase>(),
        getIt<GetTransactionsUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<OrderStore>(
      OrderStore(
        getIt<GetOrdersUseCase>(),
        getIt<CancelOrderUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ExKycStore>(
      ExKycStore(
        getIt<GetKycDetailUseCase>(),
        getIt<SubmitKycUseCase>(),
        getIt<ErrorStore>(),
      ),
    );
  }
}
