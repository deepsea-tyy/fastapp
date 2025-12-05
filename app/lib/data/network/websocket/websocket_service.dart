import 'dart:async';
import 'package:fastapp/data/network/websocket/market_websocket.dart';

/// WebSocket订阅回调类型
typedef WebSocketCallback = void Function(WebSocketMessage message);

/// WebSocket服务管理器
/// 统一管理WebSocket订阅和消息分发，避免重复订阅
class WebSocketService {
  final MarketWebSocket _marketWebSocket;
  
  // 主题订阅者映射：topic -> [callback1, callback2, ...]
  final Map<String, Set<WebSocketCallback>> _subscribers = {};
  
  // WebSocket消息流订阅
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  
  // 是否已初始化
  bool _initialized = false;

  WebSocketService(this._marketWebSocket) {
    _initialize();
  }

  /// 初始化消息监听
  void _initialize() {
    if (_initialized) return;
    
    _messageSubscription = _marketWebSocket.messageStream.listen(
      _dispatchMessage,
      onError: (error) {
        // 错误处理
      },
    );
    
    _initialized = true;
  }

  /// 订阅主题
  /// [topic] 主题格式：'{type}:{symbol}' 或 '{type}:{symbol}:{interval}'
  /// 例如：'ticker:BTC/USDT', 'kline:BTC/USDT:1m', 'depth:BTC/USDT'
  /// [callback] 消息回调函数
  /// 
  /// 返回订阅ID，用于取消订阅
  String subscribe(String topic, WebSocketCallback callback) {
    // 添加到订阅者列表
    _subscribers.putIfAbsent(topic, () => {}).add(callback);
    
    // 解析主题，订阅WebSocket频道
    _subscribeWebSocketChannel(topic);
    
    // 返回订阅ID（使用topic和callback的hashCode）
    return '${topic}_${callback.hashCode}';
  }

  /// 取消订阅
  /// [topic] 主题
  /// [callback] 回调函数，如果为null则取消该主题的所有订阅
  void unsubscribe(String topic, [WebSocketCallback? callback]) {
    if (callback != null) {
      // 取消特定回调的订阅
      _subscribers[topic]?.remove(callback);
      
      // 如果该主题没有订阅者了，取消WebSocket订阅
      if (_subscribers[topic]?.isEmpty ?? false) {
        _subscribers.remove(topic);
        _unsubscribeWebSocketChannel(topic);
      }
    } else {
      // 取消该主题的所有订阅
      _subscribers.remove(topic);
      _unsubscribeWebSocketChannel(topic);
    }
  }

  /// 取消所有订阅
  void unsubscribeAll() {
    final topics = _subscribers.keys.toList();
    for (final topic in topics) {
      _unsubscribeWebSocketChannel(topic);
    }
    _subscribers.clear();
  }

  /// 构建主题字符串
  String _buildTopic(WebSocketMessage message) {
    switch (message.type) {
      case WebSocketMessageType.ticker:
        return 'ticker:${message.symbol}';
      case WebSocketMessageType.depth:
        return 'depth:${message.symbol}';
      case WebSocketMessageType.kline:
        // K线消息的symbol只包含交易对，不包含interval
        // 返回基础格式，分发时会匹配所有相关订阅
        return 'kline:${message.symbol}';
      case WebSocketMessageType.orderStatus:
        return 'order:${message.symbol}';
    }
  }

  /// 分发消息到订阅者（支持K线的多订阅匹配）
  void _dispatchMessage(WebSocketMessage message) {
    final baseTopic = _buildTopic(message);
    
    // 对于K线消息，需要匹配所有相关的订阅（不同interval）
    if (message.type == WebSocketMessageType.kline) {
      final symbol = message.symbol;
      // 查找所有匹配的K线订阅
      for (final topic in _subscribers.keys) {
        if (topic.startsWith('kline:$symbol:')) {
          final callbacks = _subscribers[topic];
          if (callbacks != null && callbacks.isNotEmpty) {
            for (final callback in callbacks) {
              try {
                callback(message);
              } catch (e) {
                // 单个回调错误不影响其他订阅者
              }
            }
          }
        }
      }
    } else {
      // 其他类型的消息，直接分发
      final callbacks = _subscribers[baseTopic];
      if (callbacks != null && callbacks.isNotEmpty) {
        for (final callback in callbacks) {
          try {
            callback(message);
          } catch (e) {
            // 单个回调错误不影响其他订阅者
          }
        }
      }
    }
  }

  /// 订阅WebSocket频道
  void _subscribeWebSocketChannel(String topic) {
    final parts = topic.split(':');
    if (parts.length < 2) return;
    
    final channel = parts[0]; // ticker, depth, kline等
    final symbol = parts.length > 2 
        ? '${parts[1]}:${parts[2]}'  // kline:BTC/USDT:1m
        : parts[1];  // ticker:BTC/USDT
    
    _marketWebSocket.subscribe(channel, symbol: symbol);
  }

  /// 取消WebSocket频道订阅
  void _unsubscribeWebSocketChannel(String topic) {
    final parts = topic.split(':');
    if (parts.length < 2) return;
    
    final channel = parts[0];
    final symbol = parts.length > 2 
        ? '${parts[1]}:${parts[2]}'
        : parts[1];
    
    _marketWebSocket.unsubscribe(channel, symbol: symbol);
  }

  /// 连接WebSocket
  Future<void> connect({String? url}) async {
    await _marketWebSocket.connect(url: url);
  }

  /// 断开WebSocket连接
  Future<void> disconnect() async {
    unsubscribeAll();
    await _marketWebSocket.disconnect();
  }

  /// 是否已连接
  bool get isConnected => _marketWebSocket.isConnected;

  /// 获取某个主题的订阅数量（用于调试）
  int getSubscriptionCount(String topic) {
    return _subscribers[topic]?.length ?? 0;
  }

  /// 获取所有订阅的主题（用于调试）
  List<String> getSubscribedTopics() {
    return _subscribers.keys.toList();
  }

  /// 释放资源
  void dispose() {
    _messageSubscription?.cancel();
    unsubscribeAll();
  }
}
