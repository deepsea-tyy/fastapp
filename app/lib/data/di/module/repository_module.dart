import 'dart:async';

import 'package:fastapp/data/network/apis/market/market_api.dart';
import 'package:fastapp/data/network/apis/order/order_api.dart';
import 'package:fastapp/data/network/apis/wallet/wallet_api.dart';
import 'package:fastapp/data/network/apis/trade/trade_api.dart';
import 'package:fastapp/data/network/apis/futures/futures_api.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/data/network/apis/feed/feed_api.dart';
import 'package:fastapp/data/repository/setting/setting_repository_impl.dart';
import 'package:fastapp/data/repository/user/user_repository_impl.dart';
import 'package:fastapp/data/repository/feed/feed_repository_impl.dart';
import 'package:fastapp/data/repository/market/market_repository_impl.dart';
import 'package:fastapp/data/repository/order/order_repository_impl.dart';
import 'package:fastapp/data/repository/wallet/wallet_repository_impl.dart';
import 'package:fastapp/data/repository/trade/trade_repository_impl.dart';
import 'package:fastapp/data/repository/futures/futures_repository_impl.dart';
import 'package:fastapp/core/services/market_data_service.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/domain/repository/setting/setting_repository.dart';
import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/domain/repository/market_repository.dart';
import 'package:fastapp/domain/repository/order_repository.dart';
import 'package:fastapp/domain/repository/wallet_repository.dart';
import 'package:fastapp/domain/repository/trade_repository.dart';
import 'package:fastapp/domain/repository/futures_repository.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/repository/kyc/kyc_repository.dart';
import 'package:fastapp/data/repository/kyc/kyc_repository_impl.dart';
import 'package:fastapp/data/network/apis/kyc/ex_kyc_api.dart';

import 'package:fastapp/di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
      getIt<UserApi>(),
    ));

    getIt.registerSingleton<MarketRepository>(MarketRepositoryImpl(
      getIt<MarketApi>(),
      getIt<MarketDataService>(),
    ));

    getIt.registerSingleton<OrderRepository>(OrderRepositoryImpl(
      getIt<OrderApi>(),
    ));

    getIt.registerSingleton<WalletRepository>(WalletRepositoryImpl(
      getIt<WalletApi>(),
    ));

    getIt.registerSingleton<TradeRepository>(TradeRepositoryImpl(
      getIt<TradeApi>(),
    ));

    getIt.registerSingleton<FuturesRepository>(FuturesRepositoryImpl(
      getIt<FuturesApi>(),
    ));

    getIt.registerSingleton<FeedRepository>(FeedRepositoryImpl(
      getIt<FeedApi>(),
    ));

    getIt.registerSingleton<KycRepository>(KycRepositoryImpl(
      getIt<ExKycApi>(),
    ));
  }
}
