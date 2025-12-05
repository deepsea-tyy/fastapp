import 'dart:math';
import '../../domain/entity/market/kline_data.dart';
import '../../domain/entity/market/depth_data.dart';
import '../../domain/entity/market/ticker_data.dart';
import '../../domain/entity/market/market_pair.dart';
import '../../domain/entity/futures/position.dart';
import '../../domain/entity/futures/funding_rate.dart';
import '../../domain/entity/futures/leverage.dart';
import '../../domain/entity/futures/mark_price.dart';

/// 模拟行情数据生成器
class MockMarketData {
  static final Random _random = Random();

  /// 生成K线数据
  static List<KlineData> generateKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit = 100,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final end = endTime ?? now;
    
    // 根据时间周期计算每个K线的时间间隔（毫秒）
    final intervalMs = _getIntervalMs(interval);
    final limitValue = limit ?? 100;
    final start = startTime ?? (end - (limitValue * intervalMs));
    
    final List<KlineData> klines = [];
    double basePrice = _getBasePrice(symbol);
    
    for (int i = 0; i < limitValue; i++) {
      final timestamp = start + (i * intervalMs);
      final open = double.parse(basePrice.toStringAsFixed(2));
      final change = (basePrice * 0.02) * (_random.nextDouble() - 0.5); // ±2%波动
      final high = double.parse((open + (change.abs() * 1.5)).toStringAsFixed(2));
      final low = double.parse((open - (change.abs() * 1.5)).toStringAsFixed(2));
      final close = double.parse((open + change).toStringAsFixed(2));
      final volume = double.parse((_random.nextDouble() * 1000 + 100).toStringAsFixed(2));
      final amount = double.parse((volume * close).toStringAsFixed(2));
      
      klines.add(KlineData(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
        amount: amount,
      ));
      
      basePrice = close; // 下一个K线的开盘价等于当前收盘价
    }
    
    return klines;
  }

  /// 生成深度图数据
  static DepthChartData generateDepthData({
    required String symbol,
    int limit = 20,
  }) {
    final basePrice = _getBasePrice(symbol);
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 生成买盘（价格从高到低）
    final List<DepthData> bids = [];
    double cumulativeBid = 0;
    for (int i = 0; i < limit; i++) {
      final price = double.parse((basePrice * (1 - (i * 0.001))).toStringAsFixed(2)); // 价格递减，保留2位小数
      final quantity = double.parse((_random.nextDouble() * 10 + 1).toStringAsFixed(2));
      cumulativeBid += quantity;
      bids.add(DepthData(
        price: price,
        quantity: quantity,
        cumulativeQuantity: double.parse(cumulativeBid.toStringAsFixed(2)),
      ));
    }
    
    // 生成卖盘（价格从低到高）
    final List<DepthData> asks = [];
    double cumulativeAsk = 0;
    for (int i = 0; i < limit; i++) {
      final price = double.parse((basePrice * (1 + (i * 0.001))).toStringAsFixed(2)); // 价格递增，保留2位小数
      final quantity = double.parse((_random.nextDouble() * 10 + 1).toStringAsFixed(2));
      cumulativeAsk += quantity;
      asks.add(DepthData(
        price: price,
        quantity: quantity,
        cumulativeQuantity: double.parse(cumulativeAsk.toStringAsFixed(2)),
      ));
    }
    
    return DepthChartData(
      bids: bids.reversed.toList(), // 反转，使价格从高到低
      asks: asks,
      lastPrice: double.parse(basePrice.toStringAsFixed(2)),
      timestamp: now,
    );
  }

  /// 生成Ticker数据
  static TickerData generateTickerData(String symbol) {
    final basePrice = _getBasePrice(symbol);
    final now = DateTime.now().millisecondsSinceEpoch;
    final changePercent = (_random.nextDouble() - 0.5) * 10; // ±5%波动
    final openPrice = double.parse((basePrice / (1 + changePercent / 100)).toStringAsFixed(2));
    final highPrice = double.parse((basePrice * (1 + _random.nextDouble() * 0.05)).toStringAsFixed(2));
    final lowPrice = double.parse((basePrice * (1 - _random.nextDouble() * 0.05)).toStringAsFixed(2));
    final lastPrice = double.parse(basePrice.toStringAsFixed(2));
    final volume = double.parse((_random.nextDouble() * 10000 + 1000).toStringAsFixed(2));
    final amount = double.parse((volume * basePrice).toStringAsFixed(2));
    final changeAmount = double.parse((lastPrice - openPrice).toStringAsFixed(2));
    
    return TickerData(
      symbol: symbol,
      lastPrice: lastPrice,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      amount: amount,
      changePercent: changePercent,
      changeAmount: changeAmount,
      timestamp: now,
    );
  }

  /// 生成所有Ticker数据
  static List<TickerData> generateAllTickerData() {
    final symbols = ['BTC/USDT', 'ETH/USDT', 'SOL/USDT', 'XRP/USDT', 'BGB/USDT'];
    return symbols.map((symbol) => generateTickerData(symbol)).toList();
  }

  /// 生成交易对列表
  static List<MarketPair> generateMarketPairs() {
    return [
      MarketPair(
        symbol: 'BTC/USDT',
        baseCurrency: 'BTC',
        quoteCurrency: 'USDT',
        name: 'Bitcoin',
        pricePrecision: 2,
        quantityPrecision: 6,
        minQuantity: 0.0001,
        minAmount: 10,
        enabled: true,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/btc.png',
      ),
      MarketPair(
        symbol: 'ETH/USDT',
        baseCurrency: 'ETH',
        quoteCurrency: 'USDT',
        name: 'Ethereum',
        pricePrecision: 2,
        quantityPrecision: 4,
        minQuantity: 0.001,
        minAmount: 10,
        enabled: true,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/eth.png',
      ),
      MarketPair(
        symbol: 'SOL/USDT',
        baseCurrency: 'SOL',
        quoteCurrency: 'USDT',
        name: 'Solana',
        pricePrecision: 2,
        quantityPrecision: 2,
        minQuantity: 0.01,
        minAmount: 10,
        enabled: true,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/sol.png',
      ),
      MarketPair(
        symbol: 'XRP/USDT',
        baseCurrency: 'XRP',
        quoteCurrency: 'USDT',
        name: 'XRP',
        pricePrecision: 4,
        quantityPrecision: 2,
        minQuantity: 1,
        minAmount: 10,
        enabled: true,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/xrp.png',
      ),
      MarketPair(
        symbol: 'BGB/USDT',
        baseCurrency: 'BGB',
        quoteCurrency: 'USDT',
        name: 'Bitget Token',
        pricePrecision: 4,
        quantityPrecision: 2,
        minQuantity: 1,
        minAmount: 10,
        enabled: true,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/bgb.png',
      ),
    ];
  }

  /// 根据时间周期获取毫秒数
  static int _getIntervalMs(String interval) {
    switch (interval) {
      case '1m':
        return 60 * 1000;
      case '5m':
        return 5 * 60 * 1000;
      case '15m':
        return 15 * 60 * 1000;
      case '1h':
        return 60 * 60 * 1000;
      case '4h':
        return 4 * 60 * 60 * 1000;
      case '1d':
        return 24 * 60 * 60 * 1000;
      default:
        return 60 * 1000; // 默认1分钟
    }
  }

  /// 根据交易对获取基础价格
  static double _getBasePrice(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC/USDT':
        return 90714.12;
      case 'ETH/USDT':
        return 3034.23;
      case 'SOL/USDT':
        return 137.45;
      case 'XRP/USDT':
        return 2.1733;
      case 'BGB/USDT':
        return 3.7;
      default:
        return 100.0;
    }
  }

  /// 生成持仓列表
  static List<Position> generatePositions({String? symbol}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Position> positions = [];
    
    if (symbol == null || symbol == 'BTC/USDT') {
      final basePrice = _getBasePrice('BTC/USDT');
      positions.add(Position(
        id: 'pos_btc_1',
        symbol: 'BTC/USDT',
        side: PositionSide.long,
        quantity: 0.1,
        openPrice: basePrice * 0.98,
        markPrice: basePrice,
        unrealizedPnl: (basePrice - basePrice * 0.98) * 0.1,
        realizedPnl: 0,
        leverage: 10,
        margin: (basePrice * 0.98 * 0.1) / 10,
        maintenanceMarginRate: 0.01,
        liquidationPrice: basePrice * 0.9,
        createdAt: now - 86400000,
        updatedAt: now,
      ));
    }
    
    return positions;
  }

  /// 生成资金费率
  static FundingRate? generateFundingRate({String? symbol}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final nextFunding = now + 8 * 60 * 60 * 1000; // 8小时后
    
    return FundingRate(
      symbol: symbol ?? 'BTC/USDT',
      rate: (_random.nextDouble() - 0.5) * 0.01, // ±0.5%
      nextFundingTime: nextFunding,
      timestamp: now,
    );
  }

  /// 生成所有资金费率
  static List<FundingRate> generateAllFundingRates() {
    final symbols = ['BTC/USDT', 'ETH/USDT', 'SOL/USDT'];
    return symbols.map((symbol) => generateFundingRate(symbol: symbol)!).toList();
  }

  /// 生成杠杆设置
  static Leverage? generateLeverage(String symbol) {
    return Leverage(
      symbol: symbol,
      leverage: 10,
      maxLeverage: 100,
      minLeverage: 1,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 生成标记价格
  static MarkPrice? generateMarkPrice({String? symbol}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final basePrice = _getBasePrice(symbol ?? 'BTC/USDT');
    final indexPrice = basePrice * (1 + (_random.nextDouble() - 0.5) * 0.001);
    
    return MarkPrice(
      symbol: symbol ?? 'BTC/USDT',
      price: basePrice,
      indexPrice: indexPrice,
      timestamp: now,
    );
  }

  /// 生成所有标记价格
  static List<MarkPrice> generateAllMarkPrices() {
    final symbols = ['BTC/USDT', 'ETH/USDT', 'SOL/USDT'];
    return symbols.map((symbol) => generateMarkPrice(symbol: symbol)!).toList();
  }
}

