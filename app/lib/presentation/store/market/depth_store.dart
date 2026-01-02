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
    // 取消旧的订阅（如果存在）
    _websocketSubscription?.cancel();

    // 监听 WebSocket 消息
    _websocketSubscription = _webSocket.messageStream.listen((message) {
      if (message.type == WebSocketMessageType.depth) {
        // 检查 symbol 是否匹配（支持带斜杠和不带斜杠的格式）
        final messageSymbol = message.symbol;
        final normalizedMessageSymbol = messageSymbol.replaceAll('/', '');
        final normalizedCurrentSymbol = currentSymbol.replaceAll('/', '');

        // 调试日志
        // print('DepthStore 接收深度消息: symbol=$messageSymbol, currentSymbol=$currentSymbol');

        // 检查 symbol 是否匹配
        if (normalizedMessageSymbol == normalizedCurrentSymbol) {
          // 解析深度数据
          try {
            final depthData = DepthChartData.fromJson(message.data as Map<String, dynamic>);
            // 更新深度数据
            // print('DepthStore 更新深度数据: bids=${depthData.bids.length}, asks=${depthData.asks.length}');
            _updateDepthData(depthData);
          } catch (e) {
            // 忽略解析错误
            // print('DepthStore: 解析深度数据失败: $e');
          }
        } else {
          // print('DepthStore: symbol 不匹配，跳过更新');
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

  // 当前订阅的主题（用于取消订阅）
  String? _currentDepthTopic;

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    final oldSymbol = currentSymbol;
    currentSymbol = symbol;
    // 切换交易对时，更新WebSocket订阅并重新加载数据
    if (oldSymbol != symbol) {
      _subscribeDepth(symbol);
      // 重新加载新交易对的深度数据
      loadDepthData();
    }
  }

  /// 订阅深度图实时数据
  void _subscribeDepth(String symbol) {
    // 取消之前的订阅
    if (_currentDepthTopic != null) {
      _webSocket.unsubscribe('depth', symbol: _currentDepthTopic!);
    }

    // 设置新的订阅主题
    _currentDepthTopic = symbol;

    // 检查 WebSocket 是否已连接
    if (!_webSocket.isConnected) {
      // 如果未连接，尝试连接
      _webSocket.connect().then((_) {
        // 连接成功后订阅
        if (_currentDepthTopic != null) {
          _webSocket.subscribe('depth', symbol: _currentDepthTopic!);
        }
      }).catchError((e) {
        print('DepthStore: WebSocket 连接失败: $e');
      });
      return;
    }

    // 订阅新的深度图频道
    _webSocket.subscribe('depth', symbol: _currentDepthTopic!);
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
      // 先通过 HTTP API 获取初始数据
      final data = await _getDepthUseCase.call(
        params: depth_usecase.GetDepthParams(
          symbol: currentSymbol,
          limit: limit,
        ),
      );
      depthData = data;
      
      // 数据加载成功后，WebSocket 会持续推送更新
      // WebSocket 推送由 MarketDepthProcess.php 提供，通过 _initWebSocket() 监听
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      // 不再使用模拟数据，完全依赖 WebSocket 推送
      // 如果 WebSocket 连接正常，会通过推送更新数据
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
    _websocketSubscription?.cancel();
    _websocketSubscription = null;
    if (_currentDepthTopic != null) {
      _webSocket.unsubscribe('depth', symbol: _currentDepthTopic!);
      _currentDepthTopic = null;
    }
  }
}

