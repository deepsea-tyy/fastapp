import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../../../domain/entity/market/ticker_data.dart';
import '../../../../constants/app_config.dart';
import '../../../../core/services/message_service.dart';

/// WebSocket消息类型
enum WebSocketMessageType {
  kline,
  depth,
  ticker,
  hotTickers,
  orderStatus,
}

/// WebSocket消息
class WebSocketMessage {
  final WebSocketMessageType type;
  final String symbol;
  final dynamic data;
  final int timestamp;

  WebSocketMessage({
    required this.type,
    required this.symbol,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'symbol': symbol,
      'data': data,
      'timestamp': timestamp,
    };
  }
}

/// 市场 WebSocket 客户端
///
/// 特性：
/// - 统一错误处理，所有异常通过 errorStream 暴露
/// - 自动重连，指数退避策略（3s -> 6s -> 12s -> 24s -> 60s）
/// - 智能重置，连接稳定2分钟后重置重连计数器
/// - 用户提示，重连失败5次后显示一次"网络连接失败"提示
/// - 心跳保活，60秒超时自动重连
/// - 支持游客模式和登录模式
class MarketWebSocket {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  final Set<String> _subscribedChannels = {};
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<Exception> _errorController =
      StreamController<Exception>.broadcast();

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isAuthenticated = false;
  bool _manualDisconnect = false;
  bool _hasShownConnectionError = false;

  String? _token;
  String? _wsUrl;
  int _opIdCounter = 0;
  int _reconnectAttempts = 0;

  DateTime? _lastSuccessfulConnection;
  DateTime? _lastHeartbeatResponse;

  static const int _maxAttemptsBeforeNotify = 5;
  final Duration _minReconnectDelay = const Duration(seconds: 3);
  final Duration _maxReconnectDelay = const Duration(seconds: 60);
  final Duration _stableConnectionThreshold = const Duration(minutes: 2);
  final Duration _heartbeatTimeout = const Duration(seconds: 60);

  /// 消息流
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// 错误流
  Stream<Exception> get errorStream => _errorController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 是否已认证
  bool get isAuthenticated => _isAuthenticated;

  void _handleError(dynamic error, {bool shouldReconnect = true}) {
    final exception = error is Exception ? error : Exception('WebSocket错误: $error');
    _errorController.add(exception);

    if (shouldReconnect && !_manualDisconnect) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  Future<T?> _safeExecute<T>(Future<T> Function() operation, {bool shouldReconnect = true}) async {
    try {
      return await operation();
    } catch (e) {
      _handleError(e, shouldReconnect: shouldReconnect);
      return null;
    }
  }

  Future<void> connect({String? url, String? token}) async {
    if (_isConnecting || _isConnected) return;

    _manualDisconnect = false;
    _isConnecting = true;
    _token = token;
    _wsUrl = url ?? AppConfig.wsBaseUrl;

    await _safeExecute(() async {
      await _connectReal(_wsUrl!);
      _reconnectAttempts = 0;
      _hasShownConnectionError = false;
    });

    _isConnecting = false;
  }

  /// 真实 WebSocket 连接
  ///
  /// 使用 WebSocket.connect + IOWebSocketChannel 而不是 WebSocketChannel.connect
  /// 原因：WebSocketChannel.connect 内部异步创建 Socket 连接，连接失败时错误会逃逸到
  /// Flutter 根 Zone，导致 Unhandled Exception。使用 WebSocket.connect 可以让
  /// 异常在 await 处同步抛出，确保被外层的 _safeExecute 正确捕获
  Future<void> _connectReal(String url) async {
    final webSocket = await WebSocket.connect(url);
    _channel = IOWebSocketChannel(webSocket);

    _channel!.stream.listen(
      (message) {
        _lastHeartbeatResponse = DateTime.now();
        _handleMessage(message);
      },
      onError: (error) => _handleError(error),
      onDone: () {
        if (!_manualDisconnect) {
          _isConnected = false;
          _isAuthenticated = false;
          _scheduleReconnect();
        }
      },
      cancelOnError: false,
    );

    _isConnected = true;
    _lastSuccessfulConnection = DateTime.now();

    if (_token != null && _token!.isNotEmpty) {
      await login(_token!);
    }

    _startHeartbeat();
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _isConnected = _isAuthenticated = false;
    _hasShownConnectionError = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscribedChannels.clear();
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> login(String token) async {
    if (!_isConnected) throw Exception('WebSocket未连接');
    _sendMessage('login', {'token': token});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> authenticate(String token) async {
    if (!_isConnected) throw Exception('WebSocket未连接，请先调用 connect()');
    if (_isAuthenticated) return;
    _token = token;
    await login(token);
  }

  Future<void> subscribeHotTickers() async {
    if (!_isConnected) throw Exception('WebSocket未连接');
    if (!_isAuthenticated) return;
    _sendMessage('market.subscribe.hot', {});
    _subscribedChannels.add('market:hot');
  }

  void subscribe(String channel, {String? symbol}) {
    _subscribedChannels.add(symbol != null ? '$channel:$symbol' : channel);
  }

  void unsubscribe(String channel, {String? symbol}) {
    _subscribedChannels.remove(symbol != null ? '$channel:$symbol' : channel);
  }

  void _sendMessage(String action, Map<String, dynamic> data) {
    if (_channel == null) return;

    _channel!.sink.add(jsonEncode({
      'action': action,
      'data': data,
      'op_id': 'op_${++_opIdCounter}',
    }));
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final message = jsonDecode(rawMessage as String) as Map<String, dynamic>;
      final msgText = message['message'] as String?;
      final success = message['success'] == true;

      if (success && msgText != null) {
        if (msgText == 'connected successfully') {
          if (_token == null || _token!.isEmpty) {
            final bindKey = message['data']?['bind_key'];
            if (bindKey is String) {
              _sendMessage('visitor.bind_fd', {'bind_key': bindKey});
            }
          }
          return;
        } else if (msgText.contains('Auth successfully')) {
          _isAuthenticated = true;
          if (_subscribedChannels.contains('market:hot')) {
            _sendMessage('market.subscribe.hot', {});
          }
          return;
        } else if (msgText.contains('Bind key successfully')) {
          _sendMessage('visitor.market.subscribe.hot', {});
          return;
        }
      }

      if (message['action'] == 'heartbeat' || msgText == 'pong') return;

      final data = message['data'];
      if (data is Map<String, dynamic>) {
        final event = data['event'] as String?;
        if (event == 'market.hot.tickers') {
          final tickerList = (data['tickers'] as List)
              .map((t) => TickerData.fromJson(t))
              .toList();
          _emitMessage(WebSocketMessageType.hotTickers, 'HOT', tickerList);
        } else if (event == 'market.ticker') {
          final ticker = TickerData.fromJson(data);
          _emitMessage(WebSocketMessageType.ticker, ticker.symbol, ticker);
        }
      }
    } catch (_) {}
  }

  void _emitMessage(WebSocketMessageType type, String symbol, dynamic data) {
    _messageController.add(WebSocketMessage(
      type: type,
      symbol: symbol,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// 计算指数退避延迟
  ///
  /// 延迟策略：3秒 -> 6秒 -> 12秒 -> 24秒 -> 60秒（封顶）
  /// 避免频繁重连造成服务器压力，同时保证快速恢复
  Duration _calculateBackoffDelay() {
    final delaySeconds = _minReconnectDelay.inSeconds * (1 << _reconnectAttempts);
    final cappedSeconds = delaySeconds.clamp(
      _minReconnectDelay.inSeconds,
      _maxReconnectDelay.inSeconds,
    );
    return Duration(seconds: cappedSeconds);
  }

  /// 智能重置重连计数器
  ///
  /// 如果连接稳定超过2分钟，重置计数器为0
  /// 确保下次断线时从3秒开始重连，而不是累积的高延迟
  void _maybeResetReconnectAttempts() {
    if (_lastSuccessfulConnection != null) {
      final stableDuration = DateTime.now().difference(_lastSuccessfulConnection!);
      if (stableDuration > _stableConnectionThreshold) {
        _reconnectAttempts = 0;
        _hasShownConnectionError = false;
      }
    }
  }

  /// 启动心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _lastHeartbeatResponse = DateTime.now();

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isConnected) return timer.cancel();

      final timeSinceLastResponse = DateTime.now().difference(_lastHeartbeatResponse!);
      if (timeSinceLastResponse > _heartbeatTimeout) {
        timer.cancel();
        _isConnected = false;
        _scheduleReconnect();
      } else {
        _sendMessage('heartbeat', {});
      }
    });
  }

  /// 自动重连
  ///
  /// 特性：
  /// - 无限重连，直到成功或用户主动断开
  /// - 指数退避策略，避免服务器压力
  /// - 智能重置计数器，确保稳定连接后快速恢复
  /// - 重连失败5次后显示一次"网络连接失败"提示
  void _scheduleReconnect() {
    if (_manualDisconnect || _reconnectTimer?.isActive == true) {
      return;
    }

    _maybeResetReconnectAttempts();
    final delay = _calculateBackoffDelay();
    _reconnectAttempts++;

    if (_reconnectAttempts >= _maxAttemptsBeforeNotify && !_hasShownConnectionError) {
      _hasShownConnectionError = true;
      MessageService.error('网络连接失败，正在重试...');
    }

    _reconnectTimer = Timer(delay, () {
      if (_manualDisconnect || _isConnected || _isConnecting) return;

      _safeExecute(() async {
        _heartbeatTimer?.cancel();
        await _channel?.sink.close();
        _channel = null;

        await connect(url: _wsUrl, token: _token);
      }, shouldReconnect: false);
    });
  }

  void send(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _errorController.close();
  }
}

