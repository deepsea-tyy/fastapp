import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../domain/entity/market/kline_data.dart';
import '../../../../domain/entity/market/depth_data.dart';
import '../../../../domain/entity/market/ticker_data.dart';
import '../../../../constants/app_config.dart';

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

/// 市场WebSocket连接
class MarketWebSocket {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  // 订阅的频道
  final Set<String> _subscribedChannels = {};

  // 消息流控制器
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();

  // 连接状态
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isAuthenticated = false;

  // JWT Token
  String? _token;

  // 操作 ID 计数器
  int _opIdCounter = 0;

  // WebSocket URL
  String? _wsUrl;

  // 重连配置
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 3);

  // 心跳配置
  DateTime? _lastHeartbeatResponse;
  final Duration _heartbeatTimeout = const Duration(seconds: 60);

  // 是否主动断开
  bool _manualDisconnect = false;

  /// 消息流
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 是否已认证
  bool get isAuthenticated => _isAuthenticated;

  /// 连接 WebSocket
  Future<void> connect({String? url, String? token}) async {
    if (_isConnecting || _isConnected) {
      return;
    }

    _manualDisconnect = false;
    _isConnecting = true;
    _token = token;
    _wsUrl = url ?? AppConfig.wsBaseUrl;

    try {
      // 使用真实 WebSocket（内部会设置 _isConnected = true）
      await _connectReal(_wsUrl!);
      _reconnectAttempts = 0; // 重置重连次数
    } catch (e) {
      _isConnected = false;
      _scheduleReconnect();
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  /// 真实 WebSocket 连接
  Future<void> _connectReal(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // 监听消息
      _channel!.stream.listen(
        (message) {
          _lastHeartbeatResponse = DateTime.now(); // 更新心跳时间
          _handleMessage(message);
        },
        onError: (error) {
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          _isConnected = false;
          _isAuthenticated = false;
          _scheduleReconnect();
        },
      );

      // 等待连接建立
      await Future.delayed(const Duration(milliseconds: 500));

      // 连接已建立，设置状态
      _isConnected = true;

      // 如果有 token，自动登录
      if (_token != null && _token!.isNotEmpty) {
        await login(_token!);
      }

      // 启动心跳
      _startHeartbeat();
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _isConnected = _isAuthenticated = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscribedChannels.clear();
    await _channel?.sink.close();
    _channel = null;
  }

  /// 登录认证
  Future<void> login(String token) async {
    if (!_isConnected) throw Exception('WebSocket未连接');
    _sendMessage('login', {'token': token});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 对已连接的 WebSocket 进行认证（用于用户登录后）
  Future<void> authenticate(String token) async {
    if (!_isConnected) throw Exception('WebSocket未连接，请先调用 connect()');
    if (_isAuthenticated) return;
    _token = token;
    await login(token);
  }

  /// 订阅热门币种（已登录用户使用）
  Future<void> subscribeHotTickers() async {
    if (!_isConnected) throw Exception('WebSocket未连接');
    if (!_isAuthenticated) return;
    _sendMessage('market.subscribe.hot', {});
    _subscribedChannels.add('market:hot');
  }

  /// 订阅频道
  void subscribe(String channel, {String? symbol}) {
    _subscribedChannels.add(symbol != null ? '$channel:$symbol' : channel);
  }

  /// 取消订阅
  void unsubscribe(String channel, {String? symbol}) {
    _subscribedChannels.remove(symbol != null ? '$channel:$symbol' : channel);
  }

  /// 发送消息
  void _sendMessage(String action, Map<String, dynamic> data) {
    if (_channel == null) {
      return;
    }

    final message = {
      'action': action,
      'data': data,
      'op_id': 'op_${++_opIdCounter}',
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// 处理接收到的消息
  void _handleMessage(dynamic rawMessage) {
    try {
      final message = jsonDecode(rawMessage as String) as Map<String, dynamic>;
      final msgText = message['message'] as String?;
      final success = message['success'] == true;

      // 处理特定的成功响应消息
      if (success && msgText != null) {
        if (msgText == 'connected successfully') {
          // 游客模式：自动绑定连接
          if (_token == null || _token!.isEmpty) {
            final bindKey = message['data']?['bind_key'];
            if (bindKey is String) {
              _sendMessage('visitor.bind_fd', {'bind_key': bindKey});
            }
          }
          return;
        } else if (msgText.contains('Auth successfully')) {
          _isAuthenticated = true;
          return;
        } else if (msgText.contains('Bind key successfully')) {
          _sendMessage('visitor.market.subscribe.hot', {});
          return;
        }
        // 如果是 "push" 或其他消息，继续处理数据
      }

      // 处理心跳
      if (message['action'] == 'heartbeat' || msgText == 'pong') return;

      // 处理数据推送
      final data = message['data'];
      if (data is Map<String, dynamic>) {
        final event = data['event'] as String?;
        if (event == 'market.hot.tickers') {
          final tickerList = (data['tickers'] as List).map((t) => TickerData.fromJson(t)).toList();
          _emitTickerMessage(WebSocketMessageType.hotTickers, 'HOT', tickerList);
        } else if (event == 'market.ticker') {
          final ticker = TickerData.fromJson(data);
          _emitTickerMessage(WebSocketMessageType.ticker, ticker.symbol, ticker);
        }
      }
    } catch (_) {}
  }

  /// 发送 ticker 消息到流
  void _emitTickerMessage(WebSocketMessageType type, String symbol, dynamic data) {
    _messageController.add(WebSocketMessage(
      type: type,
      symbol: symbol,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
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

  /// 计划重连
  void _scheduleReconnect() {
    if (_manualDisconnect ||
        _reconnectAttempts >= _maxReconnectAttempts ||
        _reconnectTimer?.isActive == true) {
      return;
    }

    _reconnectAttempts++;
    _reconnectTimer = Timer(_reconnectDelay, () async {
      if (_manualDisconnect || _isConnected || _isConnecting) return;

      try {
        _heartbeatTimer?.cancel();
        await _channel?.sink.close();
        _channel = null;

        await connect(url: _wsUrl, token: _token);

        // 重新订阅热门币种
        if (_isConnected && _subscribedChannels.contains('market:hot')) {
          await subscribeHotTickers();
        }
      } catch (_) {}
    });
  }

  /// 发送消息（对外接口，兼容旧代码）
  void send(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
  }
}

