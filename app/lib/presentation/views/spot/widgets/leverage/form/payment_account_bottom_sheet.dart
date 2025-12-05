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
          _buildAccountOption('全仓', '0 USDT', '全仓'),
          const SizedBox(height: 12),
          _buildAccountOption('现货账户', '0 USDT', '现货账户'),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? Colors.black87 : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balance,
                    style: TextStyle(
                      fontSize: 12,
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
