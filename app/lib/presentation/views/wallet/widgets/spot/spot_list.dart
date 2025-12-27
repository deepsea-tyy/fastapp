import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SpotList extends StatelessWidget {
  final WalletType walletType;

  const SpotList({super.key, required this.walletType});

  @override
  Widget build(BuildContext context) {
    final store = getIt<WalletStore>();
    final marketDataStore = getIt<MarketDataStore>();

    return Observer(
      builder: (_) {
        final balances = store.accountBalance?.getBalancesByType(walletType);

        if (balances == null || balances.isEmpty) {
          return const EmptyState(text: '暂无资产');
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: balances.length,
          itemBuilder: (context, index) {
            final balance = balances[index];
            final currency = marketDataStore.getCurrency(balance.symbol);

            return _buildAssetItem(
              symbol: balance.symbol,
              name: balance.name ?? balance.symbol,
              available: balance.available,
              frozen: balance.frozen,
              total: balance.total,
              profit: balance.profit,
              profitRate: balance.profitRate,
              avgPrice: balance.avgPrice,
              logoUrl: currency?.logo,
              isLast: index == balances.length - 1,
            );
          },
        );
      },
    );
  }

  Widget _buildAssetItem({
    required String symbol,
    required String name,
    required double available,
    required double frozen,
    required double total,
    double? profit,
    double? profitRate,
    double? avgPrice,
    String? logoUrl,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: logoUrl == null ? _getIconColor(symbol) : null,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl != null
                ? Image.network(
                    logoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        symbol.isNotEmpty ? symbol[0] : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      symbol.isNotEmpty ? symbol[0] : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          total.toStringAsFixed(8),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (profit != null && profit != 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${profit > 0 ? '+' : ''}${profit.toStringAsFixed(8)} USDT(${profitRate != null ? '${profitRate > 0 ? '+' : ''}${profitRate.toStringAsFixed(2)}%' : '0.00%'})',
                            style: TextStyle(
                              fontSize: 12,
                              color: profit > 0 ? Colors.green : profit < 0 ? Colors.red : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 构建动态信息行
                ..._buildInfoRows(available, frozen, avgPrice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(double available, double frozen, double? avgPrice) {
    final List<Widget> rows = [];

    // 可用余额 - 始终显示
    if (available != 0) {
      rows.add(_buildInfoRow('可用', available.toStringAsFixed(8)));
    }

    // 冻结 - 仅当大于0时显示
    if (frozen > 0) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(_buildInfoRow('冻结', frozen.toStringAsFixed(8)));
    }

    // 平均买入价 - 仅当有值且大于0时显示
    if (avgPrice != null && avgPrice > 0) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(_buildInfoRow('平均买入价', '${avgPrice.toStringAsFixed(2)} USDT'));
    }

    return rows;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Color _getIconColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return Colors.orange;
      case 'ETH':
        return Colors.blue;
      case 'USDT':
        return Colors.green;
      case 'BNB':
        return Colors.amber;
      case 'SOL':
        return Colors.purple;
      case 'ADA':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
