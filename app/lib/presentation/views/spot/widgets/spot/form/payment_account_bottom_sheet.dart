import 'package:fastapp/presentation/views/spot/widgets/spot/form/utils.dart';
import 'package:flutter/material.dart';

/// 选择付款账户底部弹窗
class PaymentAccountBottomSheet extends StatefulWidget {
  const PaymentAccountBottomSheet({super.key});

  @override
  State<PaymentAccountBottomSheet> createState() => _PaymentAccountBottomSheetState();
}

class _PaymentAccountBottomSheetState extends State<PaymentAccountBottomSheet> {
  String _selectedAccount = '现货账户';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '选择付款账户',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  '可用总余额',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '0 USDT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          _buildAccountOption('现货账户', '0 USDT', '现货账户'),
          const SizedBox(height: 12),
          _buildAccountOption('资金账户', '0 USDT', '资金账户'),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '* 在一笔交易中使用多个账户的可用余额,按账户优先顺序依次扣款。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          buildBottomSheetButton(
            onPressed: () => Navigator.of(context).pop(),
            text: '确认',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption(String label, String balance, String value) {
    final isSelected = _selectedAccount == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAccount = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black87 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isSelected ? null : Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balance,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
