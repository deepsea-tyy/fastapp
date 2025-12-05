import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 预估总资产卡片
class OverviewAssets extends StatefulWidget {
  const OverviewAssets({super.key});

  @override
  State<OverviewAssets> createState() => _OverviewAssetsState();
}

class _OverviewAssetsState extends State<OverviewAssets> {
  final WalletStore _store = getIt<WalletStore>();
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final asset = _store.asset;
        final totalAsset = asset?.totalAsset ?? 0.0;
        final fiatEquivalent = totalAsset * 7.08; // 假设汇率
        final todayPnL = -0.00000869;
        final todayPnLPercent = -0.00;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '预估总资产',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isBalanceVisible
                        ? '${totalAsset.toStringAsFixed(8)}'
                        : '****',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'USDT',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '≈¥${fiatEquivalent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '今日盈亏',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$todayPnL USDT(${todayPnLPercent >= 0 ? '+' : ''}${todayPnLPercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: todayPnL >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
