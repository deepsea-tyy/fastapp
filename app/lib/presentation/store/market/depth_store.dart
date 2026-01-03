import 'dart:async';
import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart' as depth_usecase;
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:mobx/mobx.dart';

part 'depth_store.g.dart';

class DepthStore = _DepthStore with _$DepthStore;

abstract class _DepthStore with Store {
  final GetDepthUseCase _getDepthUseCase;
  final ErrorStore _errorStore;
  final AppWebSocket _webSocket;

  _DepthStore(
    this._getDepthUseCase,
    this._errorStore,
    this._webSocket,
  ) {
    _initWebSocket();
  }

  StreamSubscription? _websocketSubscription;

  /// 初始化 WebSocket 监听
  void _initWebSocket() {
    _websocketSubscription?.cancel();
    _websocketSubscription = _webSocket.messageStream.listen((message) {
      if (message.type == WebSocketMessageType.depth && isSubscribed) {
        try {
          final depthData = DepthChartData.fromJson(message.data as Map<String, dynamic>);
          _updateDepthData(depthData);
        } catch (e) {
          // 忽略解析错误
        }
      }
    });
  }

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

  // 是否已订阅
  @observable
  bool isSubscribed = false;

  // 是否正在订阅/切换中
  @observable
  bool isSubscribing = false;

  // 当前订阅的主题（用于取消订阅）
  String? _currentDepthTopic;

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    // 如果 symbol 相同且已订阅，不需要重新订阅
    if (currentSymbol == symbol && isSubscribed) return;
    
    currentSymbol = symbol;
    _subscribeDepth(symbol);
    loadDepthData();
  }

  /// 订阅深度图实时数据
  @action
  Future<void> _subscribeDepth(String symbol) async {
    if (isSubscribing) return;
    
    isSubscribing = true;
    isSubscribed = false;

    try {
      // 取消之前的订阅
      if (_currentDepthTopic != null) {
        _webSocket.unsubscribe('depth', symbol: _currentDepthTopic!);
      }

      // 设置新的订阅主题（去掉斜杠）
      _currentDepthTopic = symbol.replaceAll('/', '');

      // 确保 WebSocket 已连接
      if (!_webSocket.isConnected) {
        await _webSocket.connect();
      }

      // 订阅新的深度图频道
      _webSocket.subscribe('depth', symbol: _currentDepthTopic!);
      isSubscribed = true;
    } catch (e) {
      isSubscribed = false;
      errorMessage = '订阅失败: $e';
    } finally {
      isSubscribing = false;
    }
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
    _websocketSubscription?.cancel();
    if (_currentDepthTopic != null) {
      _webSocket.unsubscribe('depth', symbol: _currentDepthTopic!);
    }
    isSubscribed = false;
    isSubscribing = false;
  }
}

