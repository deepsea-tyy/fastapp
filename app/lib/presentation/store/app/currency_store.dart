import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/usecase/setting/get_currency_usecase.dart';
import 'package:fastapp/domain/usecase/setting/set_currency_usecase.dart';
import 'package:mobx/mobx.dart';

part 'currency_store.g.dart';

class CurrencyStore = _CurrencyStore with _$CurrencyStore;

abstract class _CurrencyStore with Store {
  final GetCurrencyUseCase _getCurrencyUseCase;
  final SetCurrencyUseCase _setCurrencyUseCase;
  final ErrorStore errorStore;

  /// 支持的币种列表（基于 ExchangeRateResponse）
  static const List<Map<String, String>> _currencyData = [
    {'code': 'USD', 'name': '美元', 'symbol': '\$'},
    {'code': 'CNY', 'name': '人民币', 'symbol': '¥'},
    {'code': 'EUR', 'name': '欧元', 'symbol': '€'},
    {'code': 'JPY', 'name': '日元', 'symbol': '¥'},
    {'code': 'KRW', 'name': '韩元', 'symbol': '₩'},
  ];

  _CurrencyStore(
    this._getCurrencyUseCase,
    this._setCurrencyUseCase,
    this.errorStore,
  ) {
    _init();
  }

  /// 异步初始化币种
  void _init() async {
    final savedCurrency = await _getCurrencyUseCase.call(params: null);
    if (savedCurrency != null) {
      _currency = savedCurrency;
    }
  }

  @observable
  String _currency = "CNY";

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
    _setCurrencyUseCase.call(params: SetCurrencyParams(currency: value));
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
