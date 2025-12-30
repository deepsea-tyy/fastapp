import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/store/app/exchange_rate_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';

/// 货币格式化工具类
class CurrencyFormatter {
  /// 统一货币显示规则
  static String formatCurrencyDisplay(String currency) {
    switch (currency) {
      case 'CNY':
        return '¥';
      case 'JPY':
        return 'JPY';
      default:
        return currency;
    }
  }

  /// 约等于显示的货币格式（带符号或代码+空格）
  static String formatFiatCurrencyForApprox(String currency) {
    switch (currency) {
      case 'CNY':
        return '¥';
      case 'JPY':
        return 'JPY '; // JPY使用代码+空格
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'KRW':
        return '₩';
      default:
        return '$currency ';
    }
  }

  /// 获取钱包货币汇率（相对于USDT）
  static double getWalletExchangeRate(
    String quoteCurrency,
    MarketStore marketStore,
  ) {
    switch (quoteCurrency) {
      case 'USDT':
        return 1.0;
      case 'BTC':
        final btcTicker = _getTicker(marketStore, 'BTCUSDT');
        return btcTicker.lastPrice > 0 ? 1.0 / btcTicker.lastPrice : 1.0;
      case 'ETH':
        final ethTicker = _getTicker(marketStore, 'ETHUSDT');
        return ethTicker.lastPrice > 0 ? 1.0 / ethTicker.lastPrice : 1.0;
      case 'BNB':
        final bnbTicker = _getTicker(marketStore, 'BNBUSDT');
        return bnbTicker.lastPrice > 0 ? 1.0 / bnbTicker.lastPrice : 1.0;
      default:
        return 1.0;
    }
  }

  /// 获取法币汇率（相对于USD）
  static double getFiatExchangeRate(
    String fiatCurrency,
    ExchangeRateStore exchangeRateStore,
  ) {
    switch (fiatCurrency) {
      case 'CNY':
        return exchangeRateStore.cny;
      case 'USD':
        return 1.0;
      case 'EUR':
        return exchangeRateStore.eur;
      case 'JPY':
        return exchangeRateStore.jpy;
      case 'KRW':
        return exchangeRateStore.krw;
      default:
        return 1.0;
    }
  }

  /// 获取ticker数据
  static TickerData _getTicker(MarketStore marketStore, String symbol) {
    return marketStore.tickerList.firstWhere(
      (t) => t.symbol == symbol,
      orElse: () => TickerData(
        symbol: symbol,
        lastPrice: 1.0,
        openPrice: 1.0,
        highPrice: 1.0,
        lowPrice: 1.0,
        volume: 0.0,
        amount: 0.0,
        timestamp: 0,
      ),
    );
  }
}
