import 'package:flutter/material.dart';
import 'finance_product_detail_screen.dart';
import 'models/finance_product.dart';
import 'constants/finance_constants.dart';
import 'widgets/common_widgets.dart';

/// 链上赚币页面
class FinanceOnChainScreen extends StatefulWidget {
  const FinanceOnChainScreen({super.key});

  @override
  State<FinanceOnChainScreen> createState() => _FinanceOnChainScreenState();
}

class _FinanceOnChainScreenState extends State<FinanceOnChainScreen> {
  // 链上赚币产品列表
  final List<OnChainProduct> _products = [
    OnChainProduct(
      name: 'USDT',
      protocol: 'Aave-Plasma',
      icon: Icons.account_balance_wallet,
      iconColor: FinanceConstants.colorUSDT,
      rate: '2.5%~4%',
      duration: '定期',
    ),
    OnChainProduct(
      name: 'BTC',
      protocol: 'Solv',
      icon: Icons.currency_bitcoin,
      iconColor: FinanceConstants.colorBTC,
      rate: '0.7%~1.6%',
      duration: '定期',
    ),
    OnChainProduct(
      name: 'WBETH',
      protocol: 'EigenLayer',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorETH,
      rate: '0.2%~0.35%',
      duration: '定期',
    ),
    OnChainProduct(
      name: 'BTC',
      protocol: 'Babylon',
      icon: Icons.currency_bitcoin,
      iconColor: FinanceConstants.colorBTC,
      rate: '1.5%~2.5%',
      duration: '定期',
    ),
    OnChainProduct(
      name: 'BNB',
      protocol: 'Lista',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorBNB,
      rate: '0.2%~0.5%',
      duration: '定期',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinanceConstants.backgroundColor,
      appBar: FinanceAppBar(
        title: '链上赚币',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 标题和描述区域
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '链上赚币便捷申购，轻松赚收益',
                        style: FinanceConstants.headingStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '什么是链上赚币',
                        style: TextStyle(
                          fontSize: FinanceConstants.fontSizeMedium,
                          color: FinanceConstants.primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // 装饰性图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FinanceConstants.primaryColorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: FinanceConstants.primaryColorDark,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 产品列表
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(product);
              },
            ),
          ),
          // 底部提示
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '没有更多数据',
              style: TextStyle(
                fontSize: FinanceConstants.fontSizeMedium,
                color: FinanceConstants.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(OnChainProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FinanceProductDetailScreen(
          productName: '${product.name} ${product.protocol}',
          productRate: product.rate,
          productColor: product.iconColor,
          productIcon: product.icon,
        ),
      ),
    );
  }

  Widget _buildProductCard(OnChainProduct product) {
    return GestureDetector(
      onTap: () => _navigateToDetail(product),
      child: Container(
        padding: const EdgeInsets.all(FinanceConstants.paddingMedium),
        decoration: BoxDecoration(
          color: FinanceConstants.backgroundColor,
          borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusMedium),
          border: Border.all(color: FinanceConstants.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 代币图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: product.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                product.icon,
                size: 24,
                color: product.iconColor,
              ),
            ),
            const SizedBox(width: 12),
            // 代币信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: FinanceConstants.headingStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.protocol,
                    style: FinanceConstants.secondaryStyle(null),
                  ),
                ],
              ),
            ),
            // 收益率和协议图标
            Row(
              children: [
                // 协议图标（简化显示）
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: product.iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.layers,
                    size: 14,
                    color: product.iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.rate,
                      style: FinanceConstants.rateStyle(null),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.duration,
                      style: TextStyle(
                        fontSize: FinanceConstants.fontSizeSmall,
                        color: FinanceConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 申购按钮
            SubscribeButton(onPressed: () => _navigateToDetail(product)),
          ],
        ),
      ),
    );
  }
}
