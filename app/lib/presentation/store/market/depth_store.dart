import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart' as depth_usecase;
import 'package:fastapp/data/network/websocket/market_websocket.dart';
import 'package:mobx/mobx.dart';

part 'depth_store.g.dart';

class DepthStore = _DepthStore with _$DepthStore;

abstract class _DepthStore with Store {
  final GetDepthUseCase _getDepthUseCase;
  final ErrorStore _errorStore;
  final MarketWebSocket _webSocket;

  _DepthStore(
    this._getDepthUseCase,
    this._errorStore,
    this._webSocket,
  );

  // 深度图数据
  @observable
  DepthChartData? depthData;

  // 当前交易对
  @observable
  String currentSymbol = 'BTC/USDT';

  // 是否正在加载
  @observable
  bool isLoading = false;

  // 错误消息
  @observable
  String? errorMessage;

  // 当前订阅的主题（用于取消订阅）
  String? _currentDepthTopic;

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    currentSymbol = symbol;
    // 切换交易对时，更新WebSocket订阅
    _subscribeDepth(symbol);
  }

  /// 订阅深度图实时数据
  void _subscribeDepth(String symbol) {
    // 取消之前的订阅
    if (_currentDepthTopic != null) {
      _webSocket.unsubscribe(_currentDepthTopic!);
    }

    // 检查 WebSocket 是否已连接
    if (!_webSocket.isConnected) {
      print('DepthStore: WebSocket 未连接，跳过订阅 $symbol');
      return;
    }

    // 订阅新的深度图频道
    final topic = 'depth:$symbol';
    _currentDepthTopic = topic;

    _webSocket.subscribe(topic, symbol: symbol);
  }

  /// 更新深度图数据
  @action
  void _updateDepthData(DepthChartData newDepthData) {
    depthData = newDepthData;
  }

  @action
  Future<void> loadDepthData({int? limit}) async {
    isLoading = true;
    errorMessage = null;

    try {
      final data = await _getDepthUseCase.call(
        params: depth_usecase.GetDepthParams(
          symbol: currentSymbol,
          limit: limit,
        ),
      );
      depthData = data;
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refreshDepthData() async {
    await loadDepthData();
  }

  void dispose() {
    // 取消WebSocket订阅
    if (_currentDepthTopic != null) {
      _webSocket.unsubscribe(_currentDepthTopic!);
      _currentDepthTopic = null;
    }
  }
}

