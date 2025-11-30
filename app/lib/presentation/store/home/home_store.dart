import 'package:fastapp/domain/entity/copy_trading/trader_card.dart';
import 'package:fastapp/domain/entity/crypto/crypto_coin.dart';
import 'package:fastapp/domain/entity/faq/faq_item.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  // 加密货币标签页索引 (0: 热门榜, 1: 涨幅榜, 2: 新币榜)
  @observable
  int cryptoTabIndex = 0;

  // 加密货币列表数据
  @observable
  ObservableList<CryptoCoin> cryptoCoins = ObservableList<CryptoCoin>();

  // FAQ 列表
  @observable
  ObservableList<FaqItem> faqItems = ObservableList<FaqItem>();

  // 跟单交易员列表
  @observable
  ObservableList<TraderCard> traderCards = ObservableList<TraderCard>();

  // 底部导航栏选中索引
  @observable
  int bottomNavIndex = 0;

  // Actions
  @action
  void setCryptoTabIndex(int index) {
    cryptoTabIndex = index;
  }

  @action
  void toggleFaqItem(int index) {
    if (index >= 0 && index < faqItems.length) {
      faqItems[index].isExpanded = !faqItems[index].isExpanded;
    }
  }

  @action
  void setBottomNavIndex(int index) {
    bottomNavIndex = index;
  }

  // 初始化数据
  @action
  void initData() {
    // 初始化加密货币数据
    cryptoCoins.addAll([
      CryptoCoin(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 90714.12,
        changePercent: -5.19,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/btc.png',
      ),
      CryptoCoin(
        symbol: 'ETH',
        name: 'Ethereum',
        price: 3034.23,
        changePercent: -5.11,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/eth.png',
      ),
      CryptoCoin(
        symbol: 'SOL',
        name: 'Solana',
        price: 137.45,
        changePercent: -2.64,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/sol.png',
      ),
      CryptoCoin(
        symbol: 'XRP',
        name: 'XRP',
        price: 2.1733,
        changePercent: -3.98,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/xrp.png',
      ),
      CryptoCoin(
        symbol: 'BGB',
        name: 'Bitget Token',
        price: 3.7,
        changePercent: -4.0,
        logoUrl: 'https://static.bgbstatic.com/portalx-static/img/coin/bgb.png',
      ),
    ]);

    // 初始化 FAQ 数据
    faqItems.addAll([
      FaqItem(
        question: '什么是加密货币交易所？',
        answer: '加密货币交易所是一个数字平台，允许用户买卖、交易和存储各种加密货币。',
      ),
      FaqItem(
        question: 'Bitget 提供哪些产品？',
        answer: 'Bitget 提供现货交易、合约交易、理财、跟单交易等多种产品和服务。',
      ),
      FaqItem(
        question: '如何追踪加密货币价格？',
        answer: '您可以在 Bitget 的行情页面实时查看各种加密货币的价格和涨跌幅。',
      ),
      FaqItem(
        question: '如何在 Bitget 上交易加密货币？',
        answer: '注册账户后，完成身份验证，充值资金即可开始交易。',
      ),
      FaqItem(
        question: '如何在 Bitget 上用加密货币赚钱？',
        answer: '您可以通过交易、理财、跟单等方式在 Bitget 上获得收益。',
      ),
      FaqItem(
        question: '为什么选择 Bitget 作为您的加密货币交易平台？',
        answer: 'Bitget 提供安全、便捷的交易服务，拥有完善的用户保护机制和丰富的产品线。',
      ),
    ]);

    // 初始化跟单交易员数据
    traderCards.addAll([
      TraderCard(
        username: 'GainGold',
        avatarUrl: 'https://static.bgbstatic.com/portalx-static/img/trader/gaingold.png',
        copyCount: 531,
        maxCopyCount: 1000,
        profit30Days: 1328.74,
        roi30Days: 8910.34,
        chartImageUrl: 'https://static.bgbstatic.com/portalx-static/img/chart/gaingold.png',
      ),
      TraderCard(
        username: 'Lemonwater',
        avatarUrl: 'https://static.bgbstatic.com/portalx-static/img/trader/lemonwater.png',
        copyCount: 316,
        maxCopyCount: 550,
        profit30Days: 46158.51,
        roi30Days: 7077.89,
        chartImageUrl: 'https://static.bgbstatic.com/portalx-static/img/chart/lemonwater.png',
      ),
    ]);
  }

  void dispose() {}
}

