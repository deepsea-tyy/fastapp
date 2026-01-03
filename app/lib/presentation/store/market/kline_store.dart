import 'dart:async';
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
  ) {
    _initWebSocket();
  }

  StreamSubscription? _websocketSubscription;

  /// 初始化 WebSocket 监听
  void _initWebSocket() {
    _websocketSubscription?.cancel();
    _websocketSubscription = _webSocket.messageStream.listen((message) {
      if (message.type == WebSocketMessageType.kline) {
        try {
          // 验证消息的 symbol 是否匹配
          final messageSymbol = message.symbol.replaceAll('/', '');
          final currentSymbolNormalized = currentSymbol.replaceAll('/', '');
          
          // 检查symbol是否匹配
          if (messageSymbol != currentSymbolNormalized) {
            return; // symbol不匹配，忽略此消息
          }
          
          // 解析K线数据
          final newKline = KlineData.fromJson(message.data as Map<String, dynamic>);
          
          // 判断消息来自哪个订阅（通过时间戳间隔判断）
          // 1s周期：时间戳间隔应该是1秒
          // 其他周期：时间戳间隔应该是周期的整数倍
          
          // 所有周期都只订阅1s数据，用于显示最新价格
          // 处理1s数据更新（用于显示最新价格）
          if (isSubscribed1s && _currentKlineTopic1s != null) {
            updateLatestKline1s(newKline);
          }
          
          // 如果是1s周期，同时更新K线图数据
          if (currentInterval == '1s') {
            if (klineData.isEmpty) {
              // 如果当前周期数据为空，直接添加
              updateLatestKline(newKline);
            } else {
              final lastTimestamp = klineData.last.timestamp;
              final timeDiff = newKline.timestamp - lastTimestamp;
              // 1s周期：时间差应该是1秒
              if (timeDiff >= 0 && timeDiff <= 2000) {
                updateLatestKline(newKline);
              }
            }
          } else {
            // 其他周期：根据1s数据判断是否新增柱子
            // 如果1s数据的时间戳跨越到新的周期，可以新增柱子
            // 但在同一个柱子周期内，只更新最新价格显示，不更新K线图
            _updateKlineForOtherInterval(newKline);
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    });
  }

  // K线数据列表（当前选择的周期）
  @observable
  ObservableList<KlineData> klineData = ObservableList<KlineData>();

  // 1s周期数据列表（用于显示最新价格，始终订阅）
  @observable
  ObservableList<KlineData> klineData1s = ObservableList<KlineData>();

  // 当前交易对
  @observable
  String currentSymbol = 'BTC/USDT';

  // 当前时间周期
  @observable
  String currentInterval = '15m';

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

  // 是否已订阅
  @observable
  bool isSubscribed = false;

  // 是否正在订阅/切换中
  @observable
  bool isSubscribing = false;

  // 时间周期列表
  final List<String> intervals = ['1s', '1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M'];

  // 当前订阅的主题（用于取消订阅）
  String? _currentKlineTopic;
  
  // 1s周期订阅主题（用于取消订阅）
  String? _currentKlineTopic1s;
  
  // 是否已订阅1s周期
  @observable
  bool isSubscribed1s = false;

  /// 获取1s周期的最新价格（计算属性，用于触发Observer）
  @computed
  double get latestPrice1s {
    return klineData1s.isNotEmpty ? klineData1s.last.close : 0.0;
  }

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    final symbolChanged = currentSymbol != symbol;
    currentSymbol = symbol;
    
    // 所有周期都只订阅1s数据（用于显示最新价格）
    // 其他周期不订阅自己的周期数据，只加载历史数据
    _subscribeKline1s(symbol);
    
    // 确保数据已加载（首次进入或订阅状态丢失时需要加载）
    if (klineData.isEmpty && !isLoading) {
      loadKlineData();
    }
  }

  @action
  void setCurrentInterval(String interval) {
    // 如果 interval 相同，只需要刷新数据
    if (currentInterval == interval) {
      loadKlineData();
      return;
    }
    
    currentInterval = interval;
    // 所有周期都只订阅1s数据（用于显示最新价格）
    // 其他周期不订阅自己的周期数据，只加载历史数据
    _subscribeKline1s(currentSymbol);
    loadKlineData();
  }

  /// 订阅K线实时数据（已废弃，现在所有周期都只订阅1s数据）
  /// 保留此方法以保持兼容性，但不再使用
  @action
  Future<void> _subscribeKline(String symbol, String interval) async {
    // 不再订阅其他周期的实时数据，所有周期都只订阅1s数据
    // 此方法保留以保持兼容性
    isSubscribed = false;
    _currentKlineTopic = null;
  }

  /// 订阅1s周期K线数据（用于显示最新价格）
  @action
  Future<void> _subscribeKline1s(String symbol) async {
    // 检查是否已经订阅了相同的1s周期
    final normalizedSymbol = symbol.replaceAll('/', '');
    final expectedTopic1s = '$normalizedSymbol:1s';
    if (_currentKlineTopic1s == expectedTopic1s && isSubscribed1s) {
      // 即使已订阅，也确保数据已加载
      if (klineData1s.isEmpty) {
        _loadKlineData1s(symbol);
      }
      return; // 已经订阅，不需要重复订阅
    }

    try {
      // 取消之前的1s订阅
      if (_currentKlineTopic1s != null) {
        _webSocket.unsubscribe('kline', symbol: _currentKlineTopic1s!);
      }

      // 设置新的1s订阅主题
      _currentKlineTopic1s = expectedTopic1s;

      // 确保 WebSocket 已连接
      if (!_webSocket.isConnected) {
        await _webSocket.connect();
      }

      // 订阅1s周期K线频道
      _webSocket.subscribe('kline', symbol: _currentKlineTopic1s!);
      isSubscribed1s = true;
      
      // 加载1s周期数据（只加载最近的数据）
      _loadKlineData1s(symbol);
    } catch (e) {
      isSubscribed1s = false;
      // 不设置errorMessage，因为1s订阅失败不影响主功能
    }
  }

  /// 加载1s周期数据（用于显示最新价格）
  @action
  Future<void> _loadKlineData1s(String symbol) async {
    try {
      final data = await _getKlineUseCase.call(
        params: kline_usecase.GetKlineParams(
          symbol: symbol,
          interval: '1s',
          page: 1,
          pageSize: 120, // 只加载最近120条数据
        ),
      );
      klineData1s.clear();
      klineData1s.addAll(data);
    } catch (e) {
      // 忽略错误，不影响主功能
    }
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
    int? page,
    int? pageSize,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      if (currentInterval == '1s') {
        final data = await _getKlineUseCase.call(
          params: kline_usecase.GetKlineParams(
            symbol: currentSymbol,
            interval: '1s',
            page: 1,
            pageSize: 120,
          ),
        );
        klineData.clear();
        klineData.addAll(data);
        isLoading = false;
        return;
      }

      final effectivePage = page ?? 1;
      final effectivePageSize = pageSize ?? 500;

      final data = await _getKlineUseCase.call(
        params: kline_usecase.GetKlineParams(
          symbol: currentSymbol,
          interval: currentInterval,
          page: effectivePage,
          pageSize: effectivePageSize,
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

  /// 获取时间周期对应的秒数
  int _getIntervalSeconds(String interval) {
    switch (interval) {
      case '1s':
        return 1;
      case '1m':
        return 60;
      case '3m':
        return 180;
      case '5m':
        return 300;
      case '15m':
        return 900;
      case '30m':
        return 1800;
      case '1h':
        return 3600;
      case '2h':
        return 7200;
      case '4h':
        return 14400;
      case '6h':
        return 21600;
      case '8h':
        return 28800;
      case '12h':
        return 43200;
      case '1d':
        return 86400;
      case '3d':
        return 259200;
      case '1w':
        return 604800;
      case '1M':
        return 2592000;
      default:
        return 60;
    }
  }

  /// 更新1s周期K线数据（用于显示最新价格）
  @action
  void updateLatestKline1s(KlineData newKline) {
    if (klineData1s.isEmpty) {
      klineData1s.add(newKline);
      return;
    }

    final lastKline = klineData1s.last;
    final timeDiff = newKline.timestamp - lastKline.timestamp;
    
    // 如果时间戳匹配或时间差在0-2秒之间，更新最后一条
    if (timeDiff >= 0 && timeDiff <= 2000) {
      // 先移除再添加，确保触发ObservableList的响应
      klineData1s.removeLast();
      klineData1s.add(newKline);
    } else if (newKline.timestamp > lastKline.timestamp) {
      // 时间戳大于，追加新数据
      klineData1s.add(newKline);
      // 保持最多120条数据
      if (klineData1s.length > 120) {
        klineData1s.removeAt(0);
      }
    }
  }

  /// 根据1s数据更新其他周期的K线图
  /// 策略：
  /// 1. 根据1s数据的时间戳判断是否跨越到新的周期
  /// 2. 如果跨越到新周期，新增柱子（开盘价使用上一个周期的收盘价）
  /// 3. 在同一个周期内，更新最后一条K线的收盘价（用于显示最新价格）
  @action
  void _updateKlineForOtherInterval(KlineData newKline1s) {
    if (klineData.isEmpty || currentInterval == '1s') {
      return; // 数据为空或是1s周期，不需要处理
    }

    final intervalSeconds = _getIntervalSeconds(currentInterval);
    final intervalMs = intervalSeconds * 1000;
    
    // 获取最后一条K线
    final lastKline = klineData.last;
    final lastTimestamp = lastKline.timestamp;
    
    // 计算最后一条K线所属的周期开始时间戳
    final lastPeriodStart = (lastTimestamp ~/ intervalMs) * intervalMs;
    
    // 计算新1s数据所属的周期开始时间戳
    final newPeriodStart = (newKline1s.timestamp ~/ intervalMs) * intervalMs;
    
    // 如果跨越到新的周期，新增柱子
    if (newPeriodStart > lastPeriodStart) {
      // 创建新的K线数据
      // 开盘价使用上一个周期的收盘价
      // 初始高低价和收盘价都使用当前1s价格
      final newKline = KlineData(
        timestamp: newPeriodStart,
        open: lastKline.close, // 新周期的开盘价等于上一个周期的收盘价
        high: newKline1s.close,
        low: newKline1s.close,
        close: newKline1s.close,
        volume: 0,
        amount: 0,
      );
      klineData.add(newKline);
    } else if (newPeriodStart == lastPeriodStart) {
      // 在同一个周期内，更新最后一条K线的价格（用于显示最新价格）
      // 更新high/low/close，保持open不变
      final updatedKline = KlineData(
        timestamp: lastKline.timestamp,
        open: lastKline.open, // 开盘价不变
        high: lastKline.high > newKline1s.close ? lastKline.high : newKline1s.close,
        low: lastKline.low < newKline1s.close ? lastKline.low : newKline1s.close,
        close: newKline1s.close, // 更新收盘价为1s的最新价格
        volume: lastKline.volume,
        amount: lastKline.amount,
      );
      klineData[klineData.length - 1] = updatedKline;
    }
    // 如果 newPeriodStart < lastPeriodStart，说明是延迟到达的数据，忽略
  }

  /// 更新最新的K线数据（用于实时数据推送）
  /// 对于非1s周期，服务器推送的是正在形成的K线（未完成的K线）
  /// 策略：
  /// 1. 如果时间戳匹配最后一条数据，直接更新（最常见）
  /// 2. 对于非1s周期，服务器推送的时间戳是周期对齐的，应该完全匹配最后一条的时间戳
  /// 3. 如果时间戳大于最后一条数据，追加到末尾（新的K线开始）
  /// 4. 如果时间戳小于最后一条数据，查找匹配的位置更新或插入
  @action
  void updateLatestKline(KlineData newKline) {
    if (klineData.isEmpty) {
      klineData.add(newKline);
      return;
    }

    final lastKline = klineData.last;
    
    // 情况1: 时间戳完全匹配最后一条数据（最常见的情况：更新正在形成的K线）
    // 服务器推送的时间戳是周期对齐的，对于非1s周期，时间戳应该完全匹配
    if (lastKline.timestamp == newKline.timestamp) {
      klineData[klineData.length - 1] = newKline;
      return;
    }
    
    // 情况2: 时间戳大于最后一条数据（新的K线开始）
    // 对于非1s周期，新K线的时间戳应该是最后一条K线时间戳 + 周期长度
    if (newKline.timestamp > lastKline.timestamp) {
      // 对于非1s周期，验证新时间戳是否是周期的整数倍
      if (currentInterval != '1s') {
        final intervalSeconds = _getIntervalSeconds(currentInterval);
        final intervalMs = intervalSeconds * 1000;
        final expectedNextTimestamp = lastKline.timestamp + intervalMs;
        
        // 如果新时间戳等于预期的下一个周期开始时间，追加新K线
        if (newKline.timestamp == expectedNextTimestamp) {
          klineData.add(newKline);
          return;
        }
        // 如果新时间戳不等于预期的下一个周期，可能是数据异常，忽略
        return;
      } else {
        // 1s周期，直接追加
        klineData.add(newKline);
        return;
      }
    }
    
    // 情况3: 时间戳小于最后一条数据（可能是延迟到达的数据，需要查找匹配位置）
    // 从后往前查找相同时间戳的数据
    int? sameTimestampIndex;
    for (int i = klineData.length - 1; i >= 0; i--) {
      if (klineData[i].timestamp == newKline.timestamp) {
        sameTimestampIndex = i;
        break;
      }
      // 如果找到更早的时间戳，说明已经过了，可以停止查找
      if (klineData[i].timestamp < newKline.timestamp) {
        break;
      }
    }
    
    if (sameTimestampIndex != null) {
      // 如果是同一根K线（相同时间戳），更新该条数据
      klineData[sameTimestampIndex] = newKline;
    } else {
      // 如果是历史数据，按时间戳顺序插入到正确位置
      int insertIndex = klineData.length;
      for (int i = klineData.length - 1; i >= 0; i--) {
        if (klineData[i].timestamp < newKline.timestamp) {
          insertIndex = i + 1;
          break;
        } else if (klineData[i].timestamp > newKline.timestamp) {
          insertIndex = i;
        }
      }
      klineData.insert(insertIndex, newKline);
    }
  }

  void dispose() {
    _websocketSubscription?.cancel();
    _websocketSubscription = null;
    if (_currentKlineTopic != null) {
      _webSocket.unsubscribe('kline', symbol: _currentKlineTopic!);
      _currentKlineTopic = null;
    }
    if (_currentKlineTopic1s != null) {
      _webSocket.unsubscribe('kline', symbol: _currentKlineTopic1s!);
      _currentKlineTopic1s = null;
    }
    isSubscribed = false;
    isSubscribed1s = false;
    isSubscribing = false;
  }
}

