import 'package:flutter/material.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'service_item_model.dart';
import '../../../finance/finance_home_screen.dart';
import '../../../finance/finance_dual_investment_screen.dart';

/// 服务仓库
/// 统一管理所有可用的服务项
class ServiceRepository {
  /// 装饰颜色
  static final decorationColor = Colors.orange.shade300;

  /// 获取所有可用的服务项
  static List<AppServiceItem> getAllServices() {
    return [
      // 常用功能
      ...getCommonServices(),
      // 活动和奖励
      ...getActivityServices(),
      // 交易服务
      ...getTradeServices(),
      // 理财服务
      ...getFinanceServices(),
    ];
  }

  /// 常用功能
  static List<AppServiceItem> getCommonServices() {
    return [
      AppServiceItem.simple(id: 'transfer', icon: Icons.compare_arrows, label: '划转'),
      AppServiceItem.simple(id: 'buy_crypto', icon: Icons.shopping_cart_outlined, label: '购买加密货币'),
      AppServiceItem.simple(id: 'deposit', icon: Icons.add_circle_outline, label: '买币/充币'),
      AppServiceItem.simple(id: 'disable_account', icon: Icons.block, label: '禁用账户'),
      AppServiceItem.simple(id: 'statement', icon: Icons.description_outlined, label: '账户结单'),
      AppServiceItem.simple(id: 'demo_trade', icon: Icons.science_outlined, label: '模拟交易'),
      AppServiceItem.simple(id: 'launchpool', icon: Icons.rocket_launch, label: 'Launchpool'),
      AppServiceItem.simple(id: 'crypto_deposit', icon: Icons.account_balance_outlined, label: '数字货币充值'),
      AppServiceItem.simple(id: 'invite_reward', icon: Icons.card_giftcard, label: '邀请奖励'),
      AppServiceItem.simple(id: 'order_management', icon: Icons.list_alt, label: '订单管理'),
      AppServiceItem.simple(id: 'sell_fiat', icon: Icons.sell_outlined, label: '卖出至法币'),
      AppServiceItem.simple(id: 'security', icon: Icons.security, label: '安全设置'),
    ];
  }

  /// 活动和奖励
  static List<AppServiceItem> getActivityServices() {
    return [
      AppServiceItem.simple(id: 'wotd', icon: Icons.star, label: 'WOTD'),
      AppServiceItem.simple(id: 'hot_activity', icon: Icons.local_fire_department, label: '热门活动'),
      AppServiceItem.simple(id: 'new_coin', icon: Icons.new_releases, label: '新币上线活动'),
      AppServiceItem.simple(id: 'trade_reward', icon: Icons.emoji_events, label: '交易合约奖励'),
    ];
  }

  /// 交易服务
  static List<AppServiceItem> getTradeServices() {
    return [
      AppServiceItem.simple(id: 'convert', icon: Icons.swap_horiz_outlined, label: '闪兑'),
      AppServiceItem.simple(id: 'spot', icon: Icons.donut_large, label: '现货'),
      AppServiceItem.simple(id: 'alpha', icon: Icons.star_border, label: 'Alpha'),
      AppServiceItem.simple(id: 'margin', icon: Icons.percent, label: '杠杆'),
      AppServiceItem.simple(id: 'futures', icon: Icons.receipt_long_outlined, label: '合约'),
      AppServiceItem.simple(id: 'copy_trade', icon: Icons.people_outline, label: '跟单交易'),
      AppServiceItem.simple(id: 'c2c', icon: Icons.people_alt_outlined, label: 'C2C买币'),
      AppServiceItem.simple(id: 'trade_bot', icon: Icons.smart_toy_outlined, label: '交易机器人'),
      AppServiceItem.simple(id: 'dca', icon: Icons.repeat, label: '闪兑定投'),
      AppServiceItem.simple(id: 'options', icon: Icons.menu_book_outlined, label: '期权'),
    ];
  }

  /// 理财服务
  static List<AppServiceItem> getFinanceServices() {
    return [
      AppServiceItem.navigable(
        id: 'finance',
        icon: Icons.account_balance_wallet_outlined,
        label: '理财',
        destination: const FinanceHomeScreen(),
      ),
      AppServiceItem.simple(id: 'sol_stake', icon: Icons.wb_sunny_outlined, label: '质押'),
      AppServiceItem.simple(id: 'onchain_earn', icon: Icons.link, label: '链上赚币'),
      AppServiceItem.simple(id: 'super_mining', icon: Icons.rocket_outlined, label: '超级挖矿'),
      AppServiceItem.simple(id: 'mining_pool', icon: Icons.construction_outlined, label: '矿池'),
      AppServiceItem.navigable(
        id: 'dual_investment',
        icon: Icons.sync_alt,
        label: '双币投资',
        destination: const FinanceDualInvestmentScreen(),
      ),
    ];
  }

  /// 根据分类获取服务
  static List<AppServiceItem> getServicesByCategory(String category) {
    switch (category) {
      case '常用功能':
        return getCommonServices();
      case '活动和奖励':
        return getActivityServices();
      case '交易':
        return getTradeServices();
      case '理财':
        return getFinanceServices();
      default:
        return [];
    }
  }

  /// 根据ID获取服务项
  static AppServiceItem? getServiceById(String id) {
    try {
      return getAllServices().firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取默认的快捷入口ID列表
  static List<String> getDefaultQuickEntranceIds() {
    return ['c2c', 'finance', 'hot_activity', 'invite_reward', 'transfer'];
  }
}

