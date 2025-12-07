import 'package:flutter/material.dart';
import '../finance/finance_home_screen.dart';
import '../finance/finance_dual_investment_screen.dart';
import 'models/service_item.dart';
import 'constants/service_constants.dart';
import 'widgets/service_widgets.dart';

/// 服务页面
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {

  // 常用功能列表
  List<ServiceItem> get _commonServices => [
    ServiceItem.simple(icon: Icons.compare_arrows, label: '划转'),
    ServiceItem.simple(icon: Icons.account_balance_wallet, label: '币安钱包'),
    ServiceItem.simple(icon: Icons.shopping_cart_outlined, label: '购买加密货币'),
    ServiceItem.simple(icon: Icons.add_circle_outline, label: '买币/充币'),
    ServiceItem.simple(icon: Icons.block, label: '禁用账户'),
    ServiceItem.simple(icon: Icons.description_outlined, label: '账户结单'),
    ServiceItem.simple(icon: Icons.science_outlined, label: '模拟交易'),
    ServiceItem.simple(icon: Icons.rocket_launch, label: 'Launchpool'),
    ServiceItem.simple(icon: Icons.account_balance_outlined, label: '数字货币充值'),
    ServiceItem.simple(icon: Icons.card_giftcard, label: '邀请奖励'),
    ServiceItem.simple(icon: Icons.payment, label: '支付'),
    ServiceItem.simple(icon: Icons.list_alt, label: '订单管理'),
    ServiceItem.simple(icon: Icons.sell_outlined, label: '卖出至法币'),
    ServiceItem.simple(icon: Icons.security, label: '账户安全'),
  ];

  // 活动和奖励列表
  List<ServiceItem> get _activityServices => [
    ServiceItem.simple(icon: Icons.star, label: 'WOTD'),
    ServiceItem.simple(icon: Icons.local_fire_department, label: '热门活动'),
    ServiceItem.simple(icon: Icons.new_releases, label: '新币上线活动'),
    ServiceItem.simple(icon: Icons.emoji_events, label: '交易合约赢奖励'),
  ];

  // 交易服务列表
  List<ServiceItem> get _tradeServices => [
    ServiceItem.simple(icon: Icons.swap_horiz_outlined, label: '闪兑'),
    ServiceItem.simple(icon: Icons.donut_large, label: '现货'),
    ServiceItem.simple(icon: Icons.star_border, label: 'Alpha'),
    ServiceItem.simple(icon: Icons.percent, label: '杠杆'),
    ServiceItem.simple(icon: Icons.receipt_long_outlined, label: '合约'),
    ServiceItem.simple(icon: Icons.people_outline, label: '跟单交易'),
    ServiceItem.simple(icon: Icons.business_outlined, label: '场外大宗交易'),
    ServiceItem.simple(icon: Icons.people_alt_outlined, label: 'C2C买币'),
    ServiceItem.simple(icon: Icons.smart_toy_outlined, label: '交易机器人'),
    ServiceItem.simple(icon: Icons.repeat, label: '闪兑定投'),
    ServiceItem.simple(icon: Icons.trending_up, label: '指数关连'),
    ServiceItem.simple(icon: Icons.menu_book_outlined, label: '期权'),
  ];

  // 理财服务列表
  List<ServiceItem> get _financeServices => [
    ServiceItem.navigable(
      icon: Icons.account_balance_wallet_outlined,
      label: '理财',
      destination: const FinanceHomeScreen(),
    ),
    ServiceItem.simple(icon: Icons.wb_sunny_outlined, label: 'SOL 质押'),
    ServiceItem.simple(icon: Icons.link, label: '链上赚币'),
    ServiceItem.simple(icon: Icons.stadium_outlined, label: '收益竞技场'),
    ServiceItem.simple(icon: Icons.rocket_outlined, label: '超级挖矿'),
    ServiceItem.simple(icon: Icons.local_offer_outlined, label: '折价买币'),
    ServiceItem.simple(icon: Icons.verified_user_outlined, label: '保本赚币'),
    ServiceItem.simple(icon: Icons.construction_outlined, label: '币安矿池'),
    ServiceItem.simple(icon: Icons.diamond_outlined, label: 'ETH 质押'),
    ServiceItem.navigable(
      icon: Icons.sync_alt,
      label: '双币投资',
      destination: const FinanceDualInvestmentScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceConstants.backgroundColor,
      appBar: const ServiceAppBar(),
      body: ServiceTabView(
        sections: [
          ServiceSection(title: '常用功能', services: _commonServices),
          ServiceSection(title: '活动和奖励', services: _activityServices),
          ServiceSection(title: '交易', services: _tradeServices),
          ServiceSection(title: '理财', services: _financeServices),
        ],
      ),
    );
  }
}