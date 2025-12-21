import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/usecase/market/download_market_data_usecase.dart';
import 'package:fastapp/domain/entity/market/market_data_config.dart';
import 'package:fastapp/domain/entity/market/spot_pair.dart';
import 'package:fastapp/domain/entity/market/futures_pair.dart';
import 'package:fastapp/domain/entity/market/option_pair.dart';
import 'package:fastapp/domain/entity/market/currency.dart';
import 'package:mobx/mobx.dart';

part 'market_data_store.g.dart';

class MarketDataStore = _MarketDataStore with _$MarketDataStore;

abstract class _MarketDataStore with Store {
  final DownloadMarketDataUseCase _downloadMarketDataUseCase;
  final ErrorStore _errorStore;

  _MarketDataStore(
    this._downloadMarketDataUseCase,
    this._errorStore,
  );

  @observable
  MarketDataConfig? marketDataConfig;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isInitialized = false;

  /// 下载并缓存市场数据
  /// 启动时总是先请求服务器，失败则降级使用本地数据
  @action
  Future<void> loadMarketData() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    try {
      // 总是先尝试从服务器下载，失败则自动降级到本地数据
      marketDataConfig = await _downloadMarketDataUseCase.call(params: null);
      isInitialized = true;
      // 如果成功加载（无论是服务器还是本地），清除错误信息
      if (marketDataConfig != null) {
        errorMessage = null;
      }
    } catch (e) {
      // 只有在服务器和本地都没有数据时才设置错误
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      // 即使出错，如果已经初始化过，保持初始化状态
      // 这样可以使用之前的缓存数据
    } finally {
      isLoading = false;
    }
  }

  /// 刷新市场数据
  @action
  Future<void> refreshMarketData() async {
    await loadMarketData();
  }

  /// 获取所有现货交易对
  @computed
  List<SpotPair> get allSpotPairs {
    return marketDataConfig?.allSpots ?? [];
  }

  /// 获取 USDT 本位合约
  @computed
  List<FuturesPair> get usdtFutures {
    return marketDataConfig?.usdtFutures ?? [];
  }

  /// 获取币本位合约
  @computed
  List<FuturesPair> get coinFutures {
    return marketDataConfig?.coinFutures ?? [];
  }

  /// 获取所有合约
  @computed
  List<FuturesPair> get allFutures {
    return marketDataConfig?.allFutures ?? [];
  }

  /// 获取所有期权
  @computed
  List<OptionPair> get allOptions {
    return marketDataConfig?.allOptions ?? [];
  }

  /// 根据符号获取现货交易对
  SpotPair? getSpotPair(String symbol) {
    return marketDataConfig?.getSpotPair(symbol);
  }

  /// 根据符号获取合约交易对
  FuturesPair? getFuturesPair(String symbol) {
    return marketDataConfig?.getFuturesPair(symbol);
  }

  /// 根据符号获取期权交易对
  OptionPair? getOptionPair(String symbol) {
    return marketDataConfig?.getOptionPair(symbol);
  }

  /// 获取所有币种列表
  @computed
  List<Currency> get allCurrencies {
    return marketDataConfig?.allCurrencies ?? [];
  }

  /// 根据符号获取币种
  Currency? getCurrency(String symbol) {
    return marketDataConfig?.getCurrency(symbol);
  }

  /// 根据链获取币种列表
  List<Currency> getCurrenciesByChain(String chain) {
    return marketDataConfig?.getCurrenciesByChain(chain) ?? [];
  }

  /// 根据链获取现货交易对列表
  List<SpotPair> getSpotPairsByChain(String chain) {
    return marketDataConfig?.getSpotPairsByChain(chain) ?? [];
  }

  /// 根据链获取合约交易对列表
  List<FuturesPair> getFuturesPairsByChain(String chain) {
    return marketDataConfig?.getFuturesPairsByChain(chain) ?? [];
  }

  /// 根据链获取期权交易对列表
  List<OptionPair> getOptionPairsByChain(String chain) {
    return marketDataConfig?.getOptionPairsByChain(chain) ?? [];
  }

  /// 获取所有链名称列表
  @computed
  List<String> get allChains {
    return marketDataConfig?.allChains ?? [];
  }

  /// 获取热门币种列表
  @computed
  List<Currency> get hotCurrencies {
    return marketDataConfig?.hotCurrencies ?? [];
  }
}
