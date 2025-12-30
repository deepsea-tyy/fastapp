import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/assets/asset_metrics.dart';
import 'package:fastapp/presentation/views/wallet/currency/asset_detail_screen.dart';
import 'package:flutter/material.dart';

/// 其他非0资产组件
class OtherNonZeroAssets extends StatelessWidget {
  const OtherNonZeroAssets({super.key});

  @override
  Widget build(BuildContext context) {
    // 示例数据：可以替换为实际数据
    final assets = [
      _AssetData(
        symbol: 'TON',
        name: 'Toncoin',
        iconColor: Colors.blue.shade400,
        iconText: 'T',
        dailyPnL: '-¥0.00',
        pnlPercent: '-1.46%',
        balance: '0.00',
        balanceSubtitle: '¥0.00907611',
        costPrice: '¥25.81',
        latestPrice: '1.623',
      ),
      // 可以添加更多资产
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '其他非0资产',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // 资产列表
          ...assets.asMap().entries.map((entry) {
            final index = entry.key;
            final asset = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 32),
                _AssetListItem(asset: asset),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// 资产数据模型
class _AssetData {
  final String symbol;
  final String name;
  final Color iconColor;
  final String iconText;
  final String dailyPnL;
  final String pnlPercent;
  final String balance;
  final String balanceSubtitle;
  final String costPrice;
  final String latestPrice;

  _AssetData({
    required this.symbol,
    required this.name,
    required this.iconColor,
    required this.iconText,
    required this.dailyPnL,
    required this.pnlPercent,
    required this.balance,
    required this.balanceSubtitle,
    required this.costPrice,
    required this.latestPrice,
  });
}

/// 资产列表项组件
class _AssetListItem extends StatelessWidget {
  final _AssetData asset;

  const _AssetListItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(
              symbol: asset.symbol,
              name: asset.name,
              iconColor: asset.iconColor,
              iconText: asset.iconText,
              walletType: WalletType.SPOT,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 资产概览行
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: asset.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    asset.iconText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                asset.symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                asset.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.share, color: Colors.grey.shade600, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 详细数据区域
          AssetMetrics(
            dailyPnL: asset.dailyPnL,
            pnlPercent: asset.pnlPercent,
            balance: asset.balance,
            balanceSubtitle: asset.balanceSubtitle,
            costPrice: asset.costPrice,
            latestPrice: asset.latestPrice,
          ),
        ],
      ),
    );
  }
}
