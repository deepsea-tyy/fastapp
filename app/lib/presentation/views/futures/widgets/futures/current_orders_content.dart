import 'package:flutter/material.dart';

/// 当前委托内容组件
class CurrentOrdersContent extends StatelessWidget {
  final VoidCallback? onBuySellPressed;
  final VoidCallback? onAddFundsPressed;

  const CurrentOrdersContent({
    super.key,
    this.onBuySellPressed,
    this.onAddFundsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '暂无委托',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // TODO: 跳转到跟单交易页面
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '跟单交易',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
