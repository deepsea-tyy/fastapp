import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/kline_data.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart' as kline_usecase;
import 'package:mobx/mobx.dart';

part 'kline_store.g.dart';

class KlineStore = _KlineStore with _$KlineStore;

abstract class _KlineStore with Store {
  final GetKlineUseCase _getKlineUseCase;
  final ErrorStore _errorStore;

  _KlineStore(
    this._getKlineUseCase,
    this._errorStore,
  );

  // K线数据列表
  @observable
  ObservableList<KlineData> klineData = ObservableList<KlineData>();

  // 当前交易对
  @observable
  String currentSymbol = 'BTC/USDT';

  // 当前时间周期
  @observable
  String currentInterval = '1h';

  // 主图指标（MA、BOLL等）
  @observable
  String mainIndicator = 'MA';

  // 副图指标（MACD、RSI、KDJ等）
  @observable
  String secondaryIndicator = 'MACD';

  // 是否正在加载
  @observable
  bool isLoading = false;

  // 错误消息
  @observable
  String? errorMessage;

  // 时间周期列表
  final List<String> intervals = ['1m', '5m', '15m', '1h', '4h', '1d'];

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    currentSymbol = symbol;
  }

  @action
  void setCurrentInterval(String interval) {
    currentInterval = interval;
  }

  @action
  void setMainIndicator(String indicator) {
    mainIndicator = indicator;
  }

  @action
  void setSecondaryIndicator(String indicator) {
    secondaryIndicator = indicator;
  }

  @action
  Future<void> loadKlineData({
    int? startTime,
    int? endTime,
    int? limit = 100,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      final data = await _getKlineUseCase.call(
        params: kline_usecase.GetKlineParams(
          symbol: currentSymbol,
          interval: currentInterval,
          startTime: startTime,
          endTime: endTime,
          limit: limit,
        ),
      );
      klineData.clear();
      klineData.addAll(data);
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refreshKlineData() async {
    await loadKlineData();
  }

  void dispose() {}
}

