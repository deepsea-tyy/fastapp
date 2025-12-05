import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/market/market_pair.dart';
import 'package:fastapp/domain/usecase/market/get_ticker_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:fastapp/data/network/websocket/websocket_service.dart';
import 'package:fastapp/data/network/websocket/market_websocket.dart';
import 'package:mobx/mobx.dart';

part 'market_store.g.dart';

class MarketStore = _MarketStore with _$MarketStore;

abstract class _MarketStore with Store {
  final GetTickerUseCase _getTickerUseCase;
  final GetAllTickerUseCase _getAllTickerUseCase;
  final ErrorStore _errorStore;
  final WebSocketService _webSocketService;

  _MarketStore(
    this._getTickerUseCase,
    this._getAllTickerUseCase,
    this._errorStore,
    this._webSocketService,
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

    try {
      final tickers = await _getAllTickerUseCase.call(params: null);
      tickerList.clear();
      tickerList.addAll(tickers);
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoading = false;
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

