import 'package:flutter/material.dart';

/// 自动借还底部弹窗
class AutoBorrowRepayBottomSheet extends StatefulWidget {
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
  State<AutoBorrowRepayBottomSheet> createState() => _AutoBorrowRepayBottomSheetState();
}

class _AutoBorrowRepayBottomSheetState extends State<AutoBorrowRepayBottomSheet> {
  late bool _autoBorrow;
  late bool _autoRepay;

  @override
  void initState() {
    super.initState();
    _autoBorrow = widget.autoBorrow;
    _autoRepay = widget.autoRepay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖拽指示器
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题
          const Text(
            '自动借还',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // 自动借款开关
          _buildSwitchRow(
            '自动借款',
            _autoBorrow,
            (value) {
              setState(() => _autoBorrow = value);
              widget.onAutoBorrowChanged(value);
            },
          ),
          const SizedBox(height: 8),
          Text(
            '开启后，下单时若余额不足，将自动借款完成交易',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          // 自动还款开关
          _buildSwitchRow(
            '自动还款',
            _autoRepay,
            (value) {
              setState(() => _autoRepay = value);
              widget.onAutoRepayChanged(value);
            },
          ),
          const SizedBox(height: 8),
          Text(
            '开启后，卖出成交时将自动还款',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C842),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '确认',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFF5C842),
        ),
      ],
    );
  }
}
