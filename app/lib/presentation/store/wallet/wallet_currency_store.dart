import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/usecase/wallet/get_wallet_currency_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/set_wallet_currency_usecase.dart';
import 'package:mobx/mobx.dart';

part 'wallet_currency_store.g.dart';

class WalletCurrencyStore = _WalletCurrencyStore with _$WalletCurrencyStore;

abstract class _WalletCurrencyStore with Store {
  final GetWalletCurrencyUseCase _getWalletCurrencyUseCase;
  final SetWalletCurrencyUseCase _setWalletCurrencyUseCase;
  final ErrorStore errorStore;

  /// 钱包支持的币种列表
  static const List<Map<String, String>> _currencyData = [
    {'code': 'USDT', 'name': 'USDT', 'symbol': 'USDT'},
    {'code': 'BNB', 'name': 'BNB', 'symbol': 'BNB'},
    {'code': 'ETH', 'name': 'ETH', 'symbol': 'ETH'},
    {'code': 'BTC', 'name': 'BTC', 'symbol': 'BTC'},
  ];

  _WalletCurrencyStore(
    this._getWalletCurrencyUseCase,
    this._setWalletCurrencyUseCase,
    this.errorStore,
  ) {
    _init();
  }

  /// 异步初始化币种
  void _init() async {
    final savedCurrency = await _getWalletCurrencyUseCase.call(params: null);
    if (savedCurrency != null) {
      _currency = savedCurrency;
    }
  }

  @observable
  String _currency = "USDT";

  @computed
  String get currency => _currency;

  /// 获取当前币种符号
  @computed
  String get currencySymbol {
    final data = _currencyData.firstWhere(
      (item) => item['code'] == _currency,
      orElse: () => _currencyData.first,
    );
    return data['symbol']!;
  }

  /// 获取当前币种名称
  @computed
  String get currencyName {
    final data = _currencyData.firstWhere(
      (item) => item['code'] == _currency,
      orElse: () => _currencyData.first,
    );
    return data['name']!;
  }

  /// 获取所有支持的币种列表
  List<Map<String, String>> get supportedCurrencies => _currencyData;

  @action
  void changeCurrency(String value) {
    _currency = value;
    _setWalletCurrencyUseCase.call(params: SetWalletCurrencyParams(currency: value));
  }

  /// 根据币种代码获取币种信息
  Map<String, String>? getCurrencyByCode(String code) {
    try {
      return _currencyData.firstWhere((item) => item['code'] == code);
    } catch (e) {
      return null;
    }
  }
}
