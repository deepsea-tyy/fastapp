import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/kline_data.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart' as kline_usecase;
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:mobx/mobx.dart';

part 'kline_store.g.dart';

class KlineStore = _KlineStore with _$KlineStore;

abstract class _KlineStore with Store {
  final GetKlineUseCase _getKlineUseCase;
  final ErrorStore _errorStore;
  final AppWebSocket _webSocket;

  _KlineStore(
    this._getKlineUseCase,
    this._errorStore,
    this._webSocket,
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

  // 选中的副图指标列表
  @observable
  ObservableList<String> selectedSecondaryIndicators = ObservableList<String>();

  // 是否正在加载
  @observable
  bool isLoading = false;

  // 错误消息
  @observable
  String? errorMessage;

  // 时间周期列表
  final List<String> intervals = ['1m', '5m', '15m', '1h', '4h', '1d'];

  // 当前订阅的主题（用于取消订阅）
  String? _currentKlineTopic;

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    currentSymbol = symbol;
    // 切换交易对时，更新WebSocket订阅
    _subscribeKline(symbol, currentInterval);
  }

  @action
  void setCurrentInterval(String interval) {
    currentInterval = interval;
    // 切换时间周期时，更新WebSocket订阅
    _subscribeKline(currentSymbol, interval);
  }

  /// 订阅K线实时数据
  void _subscribeKline(String symbol, String interval) {
    // 取消之前的订阅
    if (_currentKlineTopic != null) {
      _webSocket.unsubscribe(_currentKlineTopic!);
    }

    // 检查 WebSocket 是否已连接
    if (!_webSocket.isConnected) {
      print('KlineStore: WebSocket 未连接，跳过订阅 $symbol:$interval');
      return;
    }

    // 订阅新的K线频道
    final topic = 'kline:$symbol:$interval';
    _currentKlineTopic = topic;

    _webSocket.subscribe(topic, symbol: symbol);
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
  void setSelectedSecondaryIndicators(List<String> indicators) {
    selectedSecondaryIndicators.clear();
    selectedSecondaryIndicators.addAll(indicators);
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

  /// 更新最新的K线数据（用于实时数据推送）
  /// 如果新数据的时间戳与最后一条数据相同，则更新最后一条
  /// 如果时间戳不同，则添加新的K线数据
  @action
  void updateLatestKline(KlineData newKline) {
    if (klineData.isEmpty) {
      klineData.add(newKline);
      return;
    }

    final lastKline = klineData.last;
    // 如果是同一根K线（相同时间戳），更新最后一条
    if (lastKline.timestamp == newKline.timestamp) {
      klineData[klineData.length - 1] = newKline;
    } else {
      // 如果是新的K线，添加到最后
      klineData.add(newKline);
    }
  }

  void dispose() {
    // 取消WebSocket订阅
    if (_currentKlineTopic != null) {
      _webSocket.unsubscribe(_currentKlineTopic!);
      _currentKlineTopic = null;
    }
  }
}

