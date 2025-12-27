import 'dart:async';

import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/domain/repository/market_repository.dart';
import 'package:fastapp/domain/repository/order_repository.dart';
import 'package:fastapp/domain/repository/wallet_repository.dart';
import 'package:fastapp/domain/repository/trade_repository.dart';
import 'package:fastapp/domain/repository/futures_repository.dart';
import 'package:fastapp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:fastapp/domain/usecase/user/login_usecase.dart';
import 'package:fastapp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:fastapp/domain/usecase/user/get_user_info_usecase.dart';
import 'package:fastapp/domain/usecase/user/logout_usecase.dart';
import 'package:fastapp/domain/usecase/user/refresh_token_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_ticker_usecase.dart';
import 'package:fastapp/domain/usecase/market/download_market_data_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_currency_detail_usecase.dart';
import 'package:fastapp/domain/usecase/order/get_orders_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_account_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_transactions_usecase.dart';
import 'package:fastapp/domain/usecase/trade/place_order_usecase.dart';
import 'package:fastapp/domain/usecase/trade/cancel_order_usecase.dart';
import 'package:fastapp/domain/usecase/setting/get_theme_usecase.dart';
import 'package:fastapp/domain/usecase/setting/set_theme_usecase.dart';
import 'package:fastapp/domain/usecase/setting/get_language_usecase.dart';
import 'package:fastapp/domain/usecase/setting/set_language_usecase.dart';
import 'package:fastapp/domain/repository/setting/setting_repository.dart';
import 'package:fastapp/domain/usecase/futures/get_positions_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_funding_rate_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_mark_price_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_leverage_usecase.dart';
import 'package:fastapp/domain/usecase/futures/set_leverage_usecase.dart';
import 'package:fastapp/domain/repository/kyc/kyc_repository.dart';
import 'package:fastapp/domain/usecase/kyc/get_kyc_detail_usecase.dart';
import 'package:fastapp/domain/usecase/kyc/submit_kyc_usecase.dart';

import 'package:fastapp/di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // user:--------------------------------------------------------------------
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<GetUserInfoUseCase>(
      GetUserInfoUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LogoutUseCase>(
      LogoutUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<RefreshTokenUseCase>(
      RefreshTokenUseCase(getIt<UserRepository>()),
    );

    // market:------------------------------------------------------------------
    getIt.registerSingleton<GetKlineUseCase>(
      GetKlineUseCase(getIt<MarketRepository>()),
    );
    getIt.registerSingleton<GetDepthUseCase>(
      GetDepthUseCase(getIt<MarketRepository>()),
    );
    getIt.registerSingleton<GetTickerUseCase>(
      GetTickerUseCase(getIt<MarketRepository>()),
    );
    getIt.registerSingleton<GetAllTickerUseCase>(
      GetAllTickerUseCase(getIt<MarketRepository>()),
    );
    getIt.registerSingleton<DownloadMarketDataUseCase>(
      DownloadMarketDataUseCase(getIt<MarketRepository>()),
    );
    getIt.registerSingleton<GetCurrencyDetailUseCase>(
      GetCurrencyDetailUseCase(getIt<MarketRepository>()),
    );

    // order:-------------------------------------------------------------------
    getIt.registerSingleton<GetOrdersUseCase>(
      GetOrdersUseCase(getIt<OrderRepository>()),
    );
    getIt.registerSingleton<GetOrderDetailUseCase>(
      GetOrderDetailUseCase(getIt<OrderRepository>()),
    );
    getIt.registerSingleton<CancelOrderUseCase>(
      CancelOrderUseCase(getIt<OrderRepository>()),
    );

    // wallet:------------------------------------------------------------------
    getIt.registerSingleton<GetAccountBalanceUseCase>(
      GetAccountBalanceUseCase(getIt<WalletRepository>()),
    );
    getIt.registerSingleton<GetAssetUseCase>(
      GetAssetUseCase(getIt<WalletRepository>()),
    );
    getIt.registerSingleton<GetBalanceUseCase>(
      GetBalanceUseCase(getIt<WalletRepository>()),
    );
    getIt.registerSingleton<GetTransactionsUseCase>(
      GetTransactionsUseCase(getIt<WalletRepository>()),
    );

    // trade:-------------------------------------------------------------------
    getIt.registerSingleton<PlaceOrderUseCase>(
      PlaceOrderUseCase(getIt<TradeRepository>()),
    );

    // setting:-----------------------------------------------------------------
    getIt.registerSingleton<GetThemeUseCase>(
      GetThemeUseCase(getIt<SettingRepository>()),
    );
    getIt.registerSingleton<SetThemeUseCase>(
      SetThemeUseCase(getIt<SettingRepository>()),
    );
    getIt.registerSingleton<GetLanguageUseCase>(
      GetLanguageUseCase(getIt<SettingRepository>()),
    );
    getIt.registerSingleton<SetLanguageUseCase>(
      SetLanguageUseCase(getIt<SettingRepository>()),
    );

    // futures:-----------------------------------------------------------------
    getIt.registerSingleton<GetPositionsUseCase>(
      GetPositionsUseCase(getIt<FuturesRepository>()),
    );
    getIt.registerSingleton<GetFundingRateUseCase>(
      GetFundingRateUseCase(getIt<FuturesRepository>()),
    );
    getIt.registerSingleton<GetMarkPriceUseCase>(
      GetMarkPriceUseCase(getIt<FuturesRepository>()),
    );
    getIt.registerSingleton<GetLeverageUseCase>(
      GetLeverageUseCase(getIt<FuturesRepository>()),
    );
    getIt.registerSingleton<SetLeverageUseCase>(
      SetLeverageUseCase(getIt<FuturesRepository>()),
    );

    // kyc:---------------------------------------------------------------------
    getIt.registerSingleton<GetKycDetailUseCase>(
      GetKycDetailUseCase(getIt<KycRepository>()),
    );
    getIt.registerSingleton<SubmitKycUseCase>(
      SubmitKycUseCase(getIt<KycRepository>()),
    );
  }
}
