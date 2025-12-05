import 'package:fastapp/presentation/views/spot/widgets/spot/form/utils.dart';
import 'package:flutter/material.dart';

// 自动借款/还款弹框
class AutoBorrowRepayBottomSheet extends StatelessWidget {
  final bool autoBorrow;
  final bool autoRepay;
  final ValueChanged<bool> onAutoBorrowChanged;
  final ValueChanged<bool> onAutoRepayChanged;

  const AutoBorrowRepayBottomSheet({
    super.key,
    required this.autoBorrow,
    required this.autoRepay,
    required this.onAutoBorrowChanged,
    required this.onAutoRepayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('自动借款/还款', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          _buildAutoOption(
            '自动借款',
            '系统将自动以您的名义借贷来执行订单。订单发布成功将立即产生利息。如果订单已全部取消，本金将自动偿还。',
            value: autoBorrow,
            onChanged: onAutoBorrowChanged,
          ),
          const SizedBox(height: 16),
          _buildAutoOption(
            '自动还款',
            '您在交易后获得的资产将被自动用来偿还您的杠杆账户中同一币种的负债。',
            value: autoRepay,
            onChanged: onAutoRepayChanged,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAutoOption(String title, String description, {required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.amber),
      ],
    );
  }
}
