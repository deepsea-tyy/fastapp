import 'dart:async';

import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/domain/repository/market_repository.dart';
import 'package:fastapp/domain/repository/order_repository.dart';
import 'package:fastapp/domain/repository/wallet_repository.dart';
import 'package:fastapp/domain/repository/trade_repository.dart';
import 'package:fastapp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:fastapp/domain/usecase/user/login_usecase.dart';
import 'package:fastapp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:fastapp/domain/usecase/user/get_user_info_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_ticker_usecase.dart';
import 'package:fastapp/domain/usecase/order/get_orders_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_transactions_usecase.dart';
import 'package:fastapp/domain/usecase/trade/place_order_usecase.dart';
import 'package:fastapp/domain/usecase/trade/cancel_order_usecase.dart';

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
  }
}
