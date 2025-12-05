import 'package:fastapp/presentation/views/wallet/currency/transfer_screen.dart';
import 'package:flutter/material.dart';

/// 空余额状态组件
class EmptyBalanceState extends StatelessWidget {
  final VoidCallback? onAddBalance;

  const EmptyBalanceState({
    super.key,
    this.onAddBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 可用余额显示
            const Text(
              '可用余额: 0.00 USDT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // 提示文字
            Text(
              '将资金转入您的合约账户进行交易',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            // 增加余额按钮（带橙色短横线装饰）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 橙色短横线装饰
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // 按钮
                OutlinedButton(
                  onPressed: onAddBalance ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TransferScreen(),
                          ),
                        );
                      },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '增加余额',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
