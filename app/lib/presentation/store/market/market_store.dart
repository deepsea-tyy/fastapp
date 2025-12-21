import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/market/market_pair.dart';
import 'package:fastapp/domain/usecase/market/get_ticker_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/data/network/websocket/websocket_service.dart';
import 'package:fastapp/data/network/websocket/market_websocket.dart';
import 'package:mobx/mobx.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';

part 'market_store.g.dart';

class MarketStore = _MarketStore with _$MarketStore;

abstract class _MarketStore with Store {
  final GetTickerUseCase _getTickerUseCase;
  final GetAllTickerUseCase _getAllTickerUseCase;
  final ErrorStore _errorStore;
  final WebSocketService _webSocketService;
  final MarketDataStore _marketDataStore;

  _MarketStore(
    this._getTickerUseCase,
    this._getAllTickerUseCase,
    this._errorStore,
    this._webSocketService,
    this._marketDataStore,
  );

  // 当前选中的交易对
  @observable
  MarketPair? selectedPair;

  // Ticker数据列表
  @observable
  ObservableList<TickerData> tickerList = ObservableList<TickerData>();

  // 是否正在加载
  @observable
  bool isLoading = false;

  // 错误消息
  @observable
  String? errorMessage;

  // 已加载的 ticker 数量
  @observable
  int loadedTickerCount = 0;

  // 总 ticker 数量
  @observable
  int totalTickerCount = 0;

  // 是否部分加载完成（首次加载完成，后续批次还在加载）
  @observable
  bool isPartiallyLoaded = false;

  // 分批大小
  static const int _batchSize = 100;

  // 当前订阅的主题（用于取消订阅）
  String? _currentTickerTopic;

  // Actions
  @action
  void setSelectedPair(MarketPair pair) {
    selectedPair = pair;
    // 切换交易对时，更新WebSocket订阅
    _subscribeTicker(pair.symbol);
  }

  /// 订阅Ticker实时数据
  void _subscribeTicker(String symbol) {
    // 取消之前的订阅
    if (_currentTickerTopic != null) {
      _webSocketService.unsubscribe(_currentTickerTopic!);
    }

    // 确保WebSocket已连接
    if (!_webSocketService.isConnected) {
      _webSocketService.connect();
    }

    // 订阅新的交易对
    final topic = 'ticker:$symbol';
    _currentTickerTopic = topic;
    
    _webSocketService.subscribe(topic, (message) {
      if (message.type == WebSocketMessageType.ticker &&
          message.symbol == symbol) {
        try {
          final tickerData = TickerData.fromJson(message.data as Map<String, dynamic>);
          _updateTickerInList(tickerData);
        } catch (e) {
          // 忽略解析错误
        }
      }
    });
  }

  /// 更新列表中的Ticker数据
  @action
  void _updateTickerInList(TickerData tickerData) {
    final index = tickerList.indexWhere((t) => t.symbol == tickerData.symbol);
    if (index >= 0) {
      tickerList[index] = tickerData;
    } else {
      // 如果不存在，添加到列表
      tickerList.add(tickerData);
    }
  }

  @action
  Future<void> loadAllTickers() async {
    isLoading = true;
    errorMessage = null;
    loadedTickerCount = 0;
    isPartiallyLoaded = false;

    try {
      final symbols = _marketDataStore.allSpotPairs
          .where((pair) => pair.isEnabled)
          .map((pair) => pair.symbol)
          .toList();

      if (symbols.isEmpty) {
        tickerList.clear();
        totalTickerCount = 0;
        isLoading = false;
        return;
      }

      totalTickerCount = symbols.length;

      // 分批处理
      final batches = <List<String>>[];
      for (int i = 0; i < symbols.length; i += _batchSize) {
        batches.add(symbols.sublist(
          i,
          i + _batchSize > symbols.length ? symbols.length : i + _batchSize,
        ));
      }

      if (batches.isEmpty) {
        isLoading = false;
        return;
      }

      // 第一次请求：同步等待，用于首次渲染
      final firstBatch = batches[0];
      final firstTickers = await _getAllTickerUseCase.call(
        params: GetAllTickerParams(symbols: firstBatch),
      );

      tickerList
        ..clear()
        ..addAll(firstTickers);
      loadedTickerCount = firstTickers.length;

      // 如果只有一个批次，直接完成
      if (batches.length == 1) {
        isPartiallyLoaded = false;
        isLoading = false;
      } else {
        // 有多个批次时，标记为部分加载，继续加载剩余批次
        isPartiallyLoaded = true;
        isLoading = false; // 首次加载完成，允许渲染
        // 后续批次：异步执行，不阻塞
        _loadRemainingBatches(batches.sublist(1));
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      isLoading = false;
      isPartiallyLoaded = false;
    }
  }

  /// 异步加载剩余批次
  Future<void> _loadRemainingBatches(List<List<String>> batches) async {
    for (final batch in batches) {
      try {
        final tickers = await _getAllTickerUseCase.call(
          params: GetAllTickerParams(symbols: batch),
        );

        // 增量更新：合并到现有列表
        _mergeTickers(tickers);
        loadedTickerCount += tickers.length;
      } catch (e) {
        // 单批失败不影响其他批次，记录错误但不中断
      }
    }

    // 所有批次加载完成
    isPartiallyLoaded = false;
    isLoading = false;
  }

  /// 合并 ticker 数据（避免重复）
  @action
  void _mergeTickers(List<TickerData> newTickers) {
    for (final ticker in newTickers) {
      final index = tickerList.indexWhere((t) => t.symbol == ticker.symbol);
      if (index >= 0) {
        // 更新已存在的
        tickerList[index] = ticker;
      } else {
        // 添加新的
        tickerList.add(ticker);
      }
    }
  }

  @action
  Future<void> refreshTickers() async {
    await loadAllTickers();
  }

  void dispose() {
    // 取消WebSocket订阅
    if (_currentTickerTopic != null) {
      _webSocketService.unsubscribe(_currentTickerTopic!);
      _currentTickerTopic = null;
    }
  }
}

