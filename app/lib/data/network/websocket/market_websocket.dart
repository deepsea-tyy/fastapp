import 'dart:async';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../mock/mock_market_data.dart';
import '../../../../domain/entity/market/kline_data.dart';
import '../../../../domain/entity/market/depth_data.dart';
import '../../../../domain/entity/market/ticker_data.dart';

/// WebSocket消息类型
enum WebSocketMessageType {
  kline,
  depth,
  ticker,
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

/// 市场WebSocket连接（模拟）
class MarketWebSocket {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _dataTimer;
  final Random _random = Random();
  
  // 订阅的频道
  final Set<String> _subscribedChannels = {};
  
  // 消息流控制器
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  
  // 连接状态
  bool _isConnected = false;
  bool _isConnecting = false;

  /// 消息流
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 连接WebSocket（模拟）
  Future<void> connect({String? url}) async {
    if (_isConnecting || _isConnected) {
      return;
    }

    _isConnecting = true;
    
    // 模拟连接延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isConnected = true;
    _isConnecting = false;

    // 启动心跳
    _startHeartbeat();
    
    // 启动数据推送
    _startDataPush();
  }

  /// 断开连接
  Future<void> disconnect() async {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _dataTimer?.cancel();
    _subscribedChannels.clear();
    await _channel?.sink.close();
    _channel = null;
  }

  /// 订阅频道
  void subscribe(String channel, {String? symbol}) {
    final key = symbol != null ? '$channel:$symbol' : channel;
    _subscribedChannels.add(key);
  }

  /// 取消订阅
  void unsubscribe(String channel, {String? symbol}) {
    final key = symbol != null ? '$channel:$symbol' : channel;
    _subscribedChannels.remove(key);
  }

  /// 启动心跳
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      // 模拟心跳
    });
  }

  /// 启动数据推送
  void _startDataPush() {
    _dataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      // 推送Ticker数据
      for (final channel in _subscribedChannels) {
        if (channel.startsWith('ticker:')) {
          final symbol = channel.split(':')[1];
          final ticker = MockMarketData.generateTickerData(symbol);
          _messageController.add(WebSocketMessage(
            type: WebSocketMessageType.ticker,
            symbol: symbol,
            data: ticker.toJson(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
        } else if (channel.startsWith('depth:')) {
          final symbol = channel.split(':')[1];
          final depth = MockMarketData.generateDepthData(symbol: symbol);
          _messageController.add(WebSocketMessage(
            type: WebSocketMessageType.depth,
            symbol: symbol,
            data: depth.toJson(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
        } else if (channel.startsWith('kline:')) {
          // K线数据推送频率较低
          if (_random.nextDouble() < 0.1) { // 10%概率推送
            final parts = channel.split(':');
            final symbol = parts[1];
            final interval = parts.length > 2 ? parts[2] : '1m';
            final klines = MockMarketData.generateKlineData(
              symbol: symbol,
              interval: interval,
              limit: 1,
            );
            if (klines.isNotEmpty) {
              _messageController.add(WebSocketMessage(
                type: WebSocketMessageType.kline,
                symbol: symbol,
                data: klines.last.toJson(),
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ));
            }
          }
        }
      }
    });
  }

  /// 发送消息（模拟）
  void send(Map<String, dynamic> message) {
    if (!_isConnected) {
      return;
    }
    // 模拟发送消息
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
  }
}

