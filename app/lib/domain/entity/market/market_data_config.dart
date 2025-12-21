import 'currency.dart';
import 'spot_pair.dart';
import 'futures_pair.dart';
import 'option_pair.dart';

/// 市场数据配置
class MarketDataConfig {
  /// 版本号
  final int version;

  /// 币种列表（按链分类：chain -> symbol -> currency）
  final Map<String, Map<String, Currency>> currencies;

  /// 现货交易对列表（按链分类：chain -> symbol -> spot_pair）
  final Map<String, Map<String, SpotPair>> spotPairs;

  /// 合约交易对列表（按链和结算币种分类：chain -> settlement_currency -> symbol -> futures_pair）
  final Map<String, Map<String, Map<String, FuturesPair>>> futuresPairs;

  /// 期权交易对列表（按链分类：chain -> symbol -> option_pair）
  final Map<String, Map<String, OptionPair>> optionPairs;

  MarketDataConfig({
    required this.version,
    required this.currencies,
    required this.spotPairs,
    required this.futuresPairs,
    required this.optionPairs,
  });

  /// 从JSON创建
  factory MarketDataConfig.fromJson(Map<String, dynamic> json) {
    // 解析版本号
    final version = (json['version'] ?? 0) as int;

    // 解析币种（chain -> symbol -> currency）
    final currenciesJson = json['currency'] as Map<String, dynamic>? ?? {};
    final currencies = <String, Map<String, Currency>>{};
    currenciesJson.forEach((chain, chainCurrencies) {
      final chainMap = <String, Currency>{};
      (chainCurrencies as Map<String, dynamic>).forEach((symbol, currencyData) {
        chainMap[symbol] = Currency.fromJson(currencyData as Map<String, dynamic>);
      });
      currencies[chain] = chainMap;
    });

    // 解析现货交易对（chain -> symbol -> spot_pair）
    final spotJson = json['spot'] as Map<String, dynamic>? ?? {};
    final spotPairs = <String, Map<String, SpotPair>>{};
    spotJson.forEach((chain, chainSpots) {
      final chainMap = <String, SpotPair>{};
      (chainSpots as Map<String, dynamic>).forEach((symbol, spotData) {
        chainMap[symbol] = SpotPair.fromJson(spotData as Map<String, dynamic>);
      });
      spotPairs[chain] = chainMap;
    });

    // 解析合约交易对（chain -> settlement_currency -> symbol -> futures_pair）
    final futuresJson = json['futures'] as Map<String, dynamic>? ?? {};
    final futuresPairs = <String, Map<String, Map<String, FuturesPair>>>{};
    futuresJson.forEach((chain, chainFutures) {
      final chainMap = <String, Map<String, FuturesPair>>{};
      (chainFutures as Map<String, dynamic>).forEach((settlementCurrency, settlementPairs) {
        final settlementMap = <String, FuturesPair>{};
        (settlementPairs as Map<String, dynamic>).forEach((symbol, futuresData) {
          settlementMap[symbol] = FuturesPair.fromJson(futuresData as Map<String, dynamic>);
        });
        chainMap[settlementCurrency] = settlementMap;
      });
      futuresPairs[chain] = chainMap;
    });

    // 解析期权交易对（chain -> symbol -> option_pair）
    final optionJson = json['option'] as Map<String, dynamic>? ?? {};
    final optionPairs = <String, Map<String, OptionPair>>{};
    optionJson.forEach((chain, chainOptions) {
      final chainMap = <String, OptionPair>{};
      (chainOptions as Map<String, dynamic>).forEach((symbol, optionData) {
        chainMap[symbol] = OptionPair.fromJson(optionData as Map<String, dynamic>);
      });
      optionPairs[chain] = chainMap;
    });

    return MarketDataConfig(
      version: version,
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
      'currency': currencies.map(
        (chain, chainCurrencies) => MapEntry(
          chain,
          chainCurrencies.map((symbol, currency) => MapEntry(symbol, currency.toJson())),
        ),
      ),
      'spot': spotPairs.map(
        (chain, chainSpots) => MapEntry(
          chain,
          chainSpots.map((symbol, spot) => MapEntry(symbol, spot.toJson())),
        ),
      ),
      'futures': futuresPairs.map(
        (chain, chainFutures) => MapEntry(
          chain,
          chainFutures.map(
            (settlementCurrency, settlementPairs) => MapEntry(
              settlementCurrency,
              settlementPairs.map((symbol, futures) => MapEntry(symbol, futures.toJson())),
            ),
          ),
        ),
      ),
      'option': optionPairs.map(
        (chain, chainOptions) => MapEntry(
          chain,
          chainOptions.map((symbol, option) => MapEntry(symbol, option.toJson())),
        ),
      ),
    };
  }

  /// 获取币种（需要指定链和符号）
  Currency? getCurrency(String chain, String symbol) {
    return currencies[chain]?[symbol];
  }

  /// 获取所有链的币种（按符号查找，返回第一个匹配的）
  Currency? getCurrencyBySymbol(String symbol) {
    for (final chainCurrencies in currencies.values) {
      final currency = chainCurrencies[symbol];
      if (currency != null) return currency;
    }
    return null;
  }

  /// 获取指定链的所有币种
  List<Currency> getCurrenciesByChain(String chain) {
    return currencies[chain]?.values.toList() ?? [];
  }

  /// 获取所有币种列表
  List<Currency> get allCurrencies {
    final List<Currency> result = [];
    currencies.forEach((_, chainCurrencies) {
      result.addAll(chainCurrencies.values);
    });
    return result;
  }

  /// 获取现货交易对（需要指定链和符号）
  SpotPair? getSpotPair(String chain, String symbol) {
    return spotPairs[chain]?[symbol];
  }

  /// 获取所有链的现货交易对（按符号查找，返回第一个匹配的）
  SpotPair? getSpotPairBySymbol(String symbol) {
    for (final chainSpots in spotPairs.values) {
      final spot = chainSpots[symbol];
      if (spot != null) return spot;
    }
    return null;
  }

  /// 获取指定链的所有现货交易对
  List<SpotPair> getSpotPairsByChain(String chain) {
    return spotPairs[chain]?.values.toList() ?? [];
  }

  /// 获取所有现货列表
  List<SpotPair> get allSpots {
    final List<SpotPair> result = [];
    spotPairs.forEach((_, chainSpots) {
      result.addAll(chainSpots.values);
    });
    return result;
  }

  /// 获取合约交易对（需要指定链、结算币种和符号）
  FuturesPair? getFuturesPair(String chain, String settlementCurrency, String symbol) {
    return futuresPairs[chain]?[settlementCurrency]?[symbol];
  }

  /// 获取所有链的合约交易对（按结算币种和符号查找，返回第一个匹配的）
  FuturesPair? getFuturesPairBySymbol(String settlementCurrency, String symbol) {
    for (final chainFutures in futuresPairs.values) {
      final futures = chainFutures[settlementCurrency]?[symbol];
      if (futures != null) return futures;
    }
    return null;
  }

  /// 获取指定链的USDT本位合约列表
  List<FuturesPair> getUsdtFuturesByChain(String chain) {
    return futuresPairs[chain]?['USDT']?.values.toList() ?? [];
  }

  /// 获取指定链的币本位合约列表
  List<FuturesPair> getCoinFuturesByChain(String chain) {
    return futuresPairs[chain]?['COIN']?.values.toList() ?? [];
  }

  /// 获取USDT本位合约列表（所有链）
  List<FuturesPair> get usdtFutures {
    final List<FuturesPair> result = [];
    futuresPairs.forEach((_, chainFutures) {
      result.addAll(chainFutures['USDT']?.values ?? []);
    });
    return result;
  }

  /// 获取币本位合约列表（所有链）
  List<FuturesPair> get coinFutures {
    final List<FuturesPair> result = [];
    futuresPairs.forEach((_, chainFutures) {
      result.addAll(chainFutures['COIN']?.values ?? []);
    });
    return result;
  }

  /// 获取所有合约列表
  List<FuturesPair> get allFutures {
    final List<FuturesPair> result = [];
    futuresPairs.forEach((_, chainFutures) {
      chainFutures.forEach((_, settlementPairs) {
        result.addAll(settlementPairs.values);
      });
    });
    return result;
  }

  /// 获取期权交易对（需要指定链和符号）
  OptionPair? getOptionPair(String chain, String symbol) {
    return optionPairs[chain]?[symbol];
  }

  /// 获取所有链的期权交易对（按符号查找，返回第一个匹配的）
  OptionPair? getOptionPairBySymbol(String symbol) {
    for (final chainOptions in optionPairs.values) {
      final option = chainOptions[symbol];
      if (option != null) return option;
    }
    return null;
  }

  /// 获取指定链的所有期权交易对
  List<OptionPair> getOptionPairsByChain(String chain) {
    return optionPairs[chain]?.values.toList() ?? [];
  }

  /// 获取所有期权列表
  List<OptionPair> get allOptions {
    final List<OptionPair> result = [];
    optionPairs.forEach((_, chainOptions) {
      result.addAll(chainOptions.values);
    });
    return result;
  }

  /// 获取所有链名称列表
  List<String> get allChains {
    final Set<String> chains = {};
    chains.addAll(currencies.keys);
    chains.addAll(spotPairs.keys);
    chains.addAll(futuresPairs.keys);
    chains.addAll(optionPairs.keys);
    return chains.toList();
  }
}
