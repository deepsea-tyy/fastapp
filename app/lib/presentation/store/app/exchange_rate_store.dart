import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/exchange_rate_response.dart';
import 'package:fastapp/domain/usecase/market/get_exchange_rate_usecase.dart';
import 'package:mobx/mobx.dart';

part 'exchange_rate_store.g.dart';

class ExchangeRateStore = _ExchangeRateStore with _$ExchangeRateStore;

abstract class _ExchangeRateStore with Store {
  final GetExchangeRateUseCase _getExchangeRateUseCase;
  final ErrorStore _errorStore;

  _ExchangeRateStore(
    this._getExchangeRateUseCase,
    this._errorStore,
  );

  @observable
  ExchangeRateResponse? exchangeRate;

  @observable
  bool isLoading = false;

  @observable
  bool isInitialized = false;

  @action
  Future<void> loadExchangeRate() async {
    if (isLoading) return;

    isLoading = true;

    try {
      exchangeRate = await _getExchangeRateUseCase.call(params: null);
      isInitialized = true;
    } catch (e) {
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
  }

  @computed
  double get cny => exchangeRate?.cny ?? 7.0;

  @computed
  double get krw => exchangeRate?.krw ?? 1441.55;

  @computed
  double get eur => exchangeRate?.eur ?? 0.848939;

  @computed
  double get jpy => exchangeRate?.jpy ?? 156.5;
}
