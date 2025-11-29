import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/market/market_pair.dart';
import 'package:fastapp/domain/usecase/market/get_ticker_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_kline_usecase.dart';
import 'package:mobx/mobx.dart';

part 'market_store.g.dart';

class MarketStore = _MarketStore with _$MarketStore;

abstract class _MarketStore with Store {
  final GetTickerUseCase _getTickerUseCase;
  final GetAllTickerUseCase _getAllTickerUseCase;
  final ErrorStore _errorStore;

  _MarketStore(
    this._getTickerUseCase,
    this._getAllTickerUseCase,
    this._errorStore,
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

  // Actions
  @action
  void setSelectedPair(MarketPair pair) {
    selectedPair = pair;
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

  void dispose() {}
}

