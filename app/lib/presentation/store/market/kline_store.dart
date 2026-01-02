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
    // 取消旧的订阅（如果存在）
    _websocketSubscription?.cancel();
    
    // 监听 WebSocket 消息
    _websocketSubscription = _webSocket.messageStream.listen((message) {
      if (message.type == WebSocketMessageType.kline) {
        // 检查 symbol 是否匹配（支持带斜杠和不带斜杠的格式）
        final messageSymbol = message.symbol;
        final normalizedMessageSymbol = messageSymbol.replaceAll('/', '');
        final normalizedCurrentSymbol = currentSymbol.replaceAll('/', '');
        
        // 检查 symbol 是否匹配
        if (normalizedMessageSymbol == normalizedCurrentSymbol) {
          // 解析K线数据
          try {
            final klineData = KlineData.fromJson(message.data as Map<String, dynamic>);
            // 检查时间戳是否与当前 interval 匹配
            if (_isTimestampMatchInterval(klineData.timestamp, currentInterval)) {
              // 更新K线数据
              updateLatestKline(klineData);
            }
          } catch (e) {
            // 忽略解析错误
            print('KlineStore: 解析K线数据失败: $e');
          }
        }
      }
    });
  }

  /// 检查时间戳是否与指定的 interval 匹配
  bool _isTimestampMatchInterval(int timestamp, String interval) {
    final seconds = timestamp ~/ 1000;
    
    switch (interval) {
      case '1s':
        // 1s 数据：时间戳可以是任意秒数，但通常不是整分钟（除非刚好是整分钟的第一秒）
        // 更准确的方法是：如果当前订阅的是 1s，则接受所有数据（因为服务器已经过滤了）
        // 但为了安全，我们检查时间戳是否是秒级别的（能被 1000 整除）
        return timestamp % 1000 == 0;
      case '1m':
        // 1m 数据：时间戳是整分钟（能被 60 整除）
        return seconds % 60 == 0;
      case '3m':
        return seconds % 180 == 0;
      case '5m':
        return seconds % 300 == 0;
      case '15m':
        return seconds % 900 == 0;
      case '30m':
        return seconds % 1800 == 0;
      case '1h':
        return seconds % 3600 == 0;
      case '2h':
        return seconds % 7200 == 0;
      case '4h':
        return seconds % 14400 == 0;
      case '6h':
        return seconds % 21600 == 0;
      case '8h':
        return seconds % 28800 == 0;
      case '12h':
        return seconds % 43200 == 0;
      case '1d':
        return seconds % 86400 == 0;
      case '3d':
        return seconds % 259200 == 0;
      case '1w':
        return seconds % 604800 == 0;
      case '1M':
        // 月份周期较复杂，暂时返回 true
        return true;
      default:
        return true;
    }
  }

  // K线数据列表
  @observable
  ObservableList<KlineData> klineData = ObservableList<KlineData>();

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

  // 时间周期列表
  final List<String> intervals = ['1s', '1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d', '3d', '1w', '1M'];

  // 当前订阅的主题（用于取消订阅）
  String? _currentKlineTopic;

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    final oldSymbol = currentSymbol;
    currentSymbol = symbol;
    // 切换交易对时，更新WebSocket订阅
    if (oldSymbol != symbol) {
      _subscribeKline(symbol, currentInterval);
    }
  }

  @action
  void setCurrentInterval(String interval) {
    final oldInterval = currentInterval;
    currentInterval = interval;
    // 切换时间周期时，更新WebSocket订阅并重新加载数据
    if (oldInterval != interval) {
      _subscribeKline(currentSymbol, interval);
      // 重新加载新周期的历史数据
      loadKlineData();
    }
  }

  /// 订阅K线实时数据
  void _subscribeKline(String symbol, String interval) {
    // 取消之前的订阅
    if (_currentKlineTopic != null) {
      _webSocket.unsubscribe('kline', symbol: _currentKlineTopic!);
    }

    // 设置新的订阅主题
    _currentKlineTopic = '$symbol:$interval';

    // 检查 WebSocket 是否已连接
    if (!_webSocket.isConnected) {
      // 如果未连接，尝试连接
      _webSocket.connect().then((_) {
        // 连接成功后订阅
        _webSocket.subscribe('kline', symbol: _currentKlineTopic!);
      }).catchError((e) {
        print('KlineStore: WebSocket 连接失败: $e');
      });
      return;
    }

    // 订阅新的K线频道
    _webSocket.subscribe('kline', symbol: _currentKlineTopic!);
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
      // 分时图（1s）加载少量历史数据（最近2分钟，120条）作为初始显示
      // 然后通过 WebSocket 实时更新，避免首次进入时一直显示加载状态
      if (currentInterval == '1s') {
        final data = await _getKlineUseCase.call(
          params: kline_usecase.GetKlineParams(
            symbol: currentSymbol,
            interval: '1s',
            page: 1,
            pageSize: 120, // 2分钟的数据（120秒），既能快速显示，又不会数据过多
          ),
        );
        // 等新数据加载完成后再清空旧数据，实现平滑过渡
        klineData.clear();
        klineData.addAll(data);
        isLoading = false;
        return;
      }

      // 其他周期使用分页参数
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
      // 等新数据加载完成后再清空旧数据，实现平滑过渡
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
  /// 如果时间戳不同，则按时间戳顺序插入到正确位置（确保数据始终按时间升序排列）
  @action
  void updateLatestKline(KlineData newKline) {
    // 对于分时图（1s），如果当前有 1m 数据，收到第一个 1s 数据时清空 1m 数据
    if (currentInterval == '1s' && klineData.isNotEmpty) {
      // 检查第一条数据的时间戳，如果是 1m 粒度（时间戳是分钟级别的），则清空
      final firstKline = klineData.first;
      final firstTimestamp = firstKline.timestamp;
      final newTimestamp = newKline.timestamp;
      
      // 如果第一条数据是 1m 粒度（时间戳能被 60000 整除），且新数据是 1s 粒度，则清空
      // 1m = 60000 毫秒
      if (firstTimestamp % 60000 == 0 && newTimestamp % 60000 != 0) {
        klineData.clear();
        klineData.add(newKline);
        return;
      }
    }
    
    if (klineData.isEmpty) {
      klineData.add(newKline);
      return;
    }

    // 查找相同时间戳的数据（从后往前查找，因为通常新数据在最后）
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
      // 如果是新的K线，按时间戳顺序插入到正确位置
      // 从后往前查找插入位置（因为通常新数据在最后）
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
    // 取消WebSocket订阅
    _websocketSubscription?.cancel();
    _websocketSubscription = null;
    if (_currentKlineTopic != null) {
      _webSocket.unsubscribe('kline', symbol: _currentKlineTopic!);
      _currentKlineTopic = null;
    }
  }
}

