import 'currency.dart';
import 'spot_pair.dart';
import 'futures_pair.dart';
import 'option_pair.dart';

/// 市场数据配置（扁平化结构）
class MarketDataConfig {
  /// 版本号
  final int version;

  /// 链列表
  final List<String> chains;

  /// 代币协议（symbol -> token_standard）
  final Map<String, String> tokenStandard;

  /// 币种列表（扁平化：symbol -> currency）
  final Map<String, Currency> currencies;

  /// 现货交易对列表（扁平化：symbol -> spot_pair）
  final Map<String, SpotPair> spotPairs;

  /// 合约交易对列表（扁平化：symbol -> futures_pair）
  final Map<String, FuturesPair> futuresPairs;

  /// 期权交易对列表（扁平化：symbol -> option_pair）
  final Map<String, OptionPair> optionPairs;

  MarketDataConfig({
    required this.version,
    required this.chains,
    required this.tokenStandard,
    required this.currencies,
    required this.spotPairs,
    required this.futuresPairs,
    required this.optionPairs,
  });

  /// 从JSON创建
  factory MarketDataConfig.fromJson(Map<String, dynamic> json) {
    // 解析版本号
    final version = (json['version'] ?? 0) as int;

    // 解析链列表
    final chainsJson = json['chain'] as List<dynamic>? ?? [];
    final chains = chainsJson.map((e) => e.toString()).toList();

    // 解析代币协议
    final tokenStandardJson = json['token_standard'] as Map<String, dynamic>? ?? {};
    final tokenStandard = <String, String>{};
    tokenStandardJson.forEach((symbol, standard) {
      tokenStandard[symbol] = standard.toString();
    });

    // 解析币种（扁平化：symbol -> currency）
    final currenciesJson = json['currency'] as Map<String, dynamic>? ?? {};
    final currencies = <String, Currency>{};
    currenciesJson.forEach((symbol, currencyData) {
      currencies[symbol] = Currency.fromJson(currencyData as Map<String, dynamic>);
    });

    // 解析现货交易对（扁平化：symbol -> spot_pair）
    final spotJson = json['spot'] as Map<String, dynamic>? ?? {};
    final spotPairs = <String, SpotPair>{};
    spotJson.forEach((symbol, spotData) {
      spotPairs[symbol] = SpotPair.fromJson(spotData as Map<String, dynamic>);
    });

    // 解析合约交易对（扁平化：symbol -> futures_pair）
    final futuresJson = json['futures'] as Map<String, dynamic>? ?? {};
    final futuresPairs = <String, FuturesPair>{};
    futuresJson.forEach((symbol, futuresData) {
      futuresPairs[symbol] = FuturesPair.fromJson(futuresData as Map<String, dynamic>);
    });

    // 解析期权交易对（扁平化：symbol -> option_pair）
    final optionJson = json['option'] as Map<String, dynamic>? ?? {};
    final optionPairs = <String, OptionPair>{};
    optionJson.forEach((symbol, optionData) {
      optionPairs[symbol] = OptionPair.fromJson(optionData as Map<String, dynamic>);
    });

    return MarketDataConfig(
      version: version,
      chains: chains,
      tokenStandard: tokenStandard,
      currencies: currencies,
      spotPairs: spotPairs,
      futuresPairs: futuresPairs,
      optionPairs: optionPairs,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'chain': chains,
      'token_standard': tokenStandard,
      'currency': currencies.map((symbol, currency) => MapEntry(symbol, currency.toJson())),
      'spot': spotPairs.map((symbol, spot) => MapEntry(symbol, spot.toJson())),
      'futures': futuresPairs.map((symbol, futures) => MapEntry(symbol, futures.toJson())),
      'option': optionPairs.map((symbol, option) => MapEntry(symbol, option.toJson())),
    };
  }

  // ==================== 币种查询 ====================

  /// 获取币种
  Currency? getCurrency(String symbol) => currencies[symbol];

  /// 获取所有币种列表
  List<Currency> get allCurrencies => currencies.values.toList();

  /// 按链筛选币种
  List<Currency> getCurrenciesByChain(String chain) {
    return currencies.values.where((c) => c.chain == chain).toList();
  }

  /// 获取启用的币种
  List<Currency> get enabledCurrencies {
    return currencies.values.where((c) => c.isEnabled).toList();
  }

  /// 获取热门币种
  List<Currency> get hotCurrencies {
    return currencies.values.where((c) => c.isHot).toList();
  }

  // ==================== 现货交易对查询 ====================

  /// 获取现货交易对
  SpotPair? getSpotPair(String symbol) => spotPairs[symbol];

  /// 获取所有现货列表
  List<SpotPair> get allSpots => spotPairs.values.toList();

  /// 按链筛选现货交易对
  List<SpotPair> getSpotPairsByChain(String chain) {
    return spotPairs.values.where((s) => s.chain == chain).toList();
  }

  /// 获取启用的现货交易对
  List<SpotPair> get enabledSpots {
    return spotPairs.values.where((s) => s.isEnabled).toList();
  }

  /// 按基础币种筛选现货交易对
  List<SpotPair> getSpotPairsByBaseCurrency(String baseCurrency) {
    return spotPairs.values.where((s) => s.baseCurrencySymbol == baseCurrency).toList();
  }

  /// 按计价币种筛选现货交易对
  List<SpotPair> getSpotPairsByQuoteCurrency(String quoteCurrency) {
    return spotPairs.values.where((s) => s.quoteCurrencySymbol == quoteCurrency).toList();
  }

  // ==================== 合约交易对查询 ====================

  /// 获取合约交易对
  FuturesPair? getFuturesPair(String symbol) => futuresPairs[symbol];

  /// 获取所有合约列表
  List<FuturesPair> get allFutures => futuresPairs.values.toList();

  /// 按链筛选合约交易对
  List<FuturesPair> getFuturesPairsByChain(String chain) {
    return futuresPairs.values.where((f) => f.chain == chain).toList();
  }

  /// 获取USDT本位合约列表
  List<FuturesPair> get usdtFutures {
    return futuresPairs.values.where((f) => f.settlementCurrencySymbol == 'USDT').toList();
  }

  /// 获取币本位合约列表
  List<FuturesPair> get coinFutures {
    return futuresPairs.values.where((f) => f.settlementCurrencySymbol == 'COIN').toList();
  }

  /// 按结算币种筛选合约交易对
  List<FuturesPair> getFuturesPairsBySettlementCurrency(String settlementCurrency) {
    return futuresPairs.values.where((f) => f.settlementCurrencySymbol == settlementCurrency).toList();
  }

  /// 获取启用的合约交易对
  List<FuturesPair> get enabledFutures {
    return futuresPairs.values.where((f) => f.isEnabled).toList();
  }

  // ==================== 期权交易对查询 ====================

  /// 获取期权交易对
  OptionPair? getOptionPair(String symbol) => optionPairs[symbol];

  /// 获取所有期权列表
  List<OptionPair> get allOptions => optionPairs.values.toList();

  /// 按链筛选期权交易对
  List<OptionPair> getOptionPairsByChain(String chain) {
    return optionPairs.values.where((o) => o.chain == chain).toList();
  }

  /// 获取启用的期权交易对
  List<OptionPair> get enabledOptions {
    return optionPairs.values.where((o) => o.isEnabled).toList();
  }

  // ==================== 工具方法 ====================

  /// 获取代币协议
  String? getTokenStandard(String symbol) => tokenStandard[symbol];

  /// 获取所有链名称列表（从所有数据中提取）
  List<String> get allChains {
    final Set<String> chains = {};
    chains.addAll(currencies.values.map((c) => c.chain));
    chains.addAll(spotPairs.values.map((s) => s.chain));
    chains.addAll(futuresPairs.values.map((f) => f.chain));
    chains.addAll(optionPairs.values.map((o) => o.chain));
    return chains.toList();
  }
}
