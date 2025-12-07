import 'package:flutter/material.dart';

/// 杠杆交易顶部按钮组组件
class LeverageTopButtons extends StatelessWidget {
  final String marginMode;
  final String leverage;
  final VoidCallback onMarginModeTap;
  final VoidCallback onLeverageTap;
  final VoidCallback onAutoBorrowRepayTap;
  final VoidCallback onManualBorrowRepayTap;

  const LeverageTopButtons({
    super.key,
    required this.marginMode,
    required this.leverage,
    required this.onMarginModeTap,
    required this.onLeverageTap,
    required this.onAutoBorrowRepayTap,
    required this.onManualBorrowRepayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTopButton(marginMode, onTap: onMarginModeTap),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton(leverage, onTap: onLeverageTap),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton('自动', onTap: onAutoBorrowRepayTap),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton('借/还', onTap: onManualBorrowRepayTap),
        ),
      ],
    );
  }

  Widget _buildTopButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }
}
